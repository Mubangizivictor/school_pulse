import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/staff_identity.dart';
import '../../domain/repositories/staff_identity_repository.dart';
import '../../domain/services/staff_nfc_credential_service.dart';
import 'staff_identity_event.dart';
import 'staff_identity_state.dart';

class StaffIdentityBloc extends Bloc<StaffIdentityEvent, StaffIdentityState> {
  final StaffIdentityRepository repository;
  final StaffNfcCredentialService nfcCredentialService;

  StaffIdentityBloc({
    required this.repository,
    required this.nfcCredentialService,
  }) : super(StaffIdentityInitial()) {
    on<LoadStaffIdentityEvent>((event, emit) async {
      emit(StaffIdentityLoading());
      try {
        final result = await repository
            .getOrIssueStaffIdentity(event.staffId)
            .timeout(const Duration(seconds: 15));
        await result.fold(
          (failure) async => emit(StaffIdentityError(failure.message)),
          (identity) async {
            final cardUid = await _lookupAssignedCard(
              identity.staffId,
              identity.schoolId,
            );
            final effective = cardUid != null && identity.nfcStatus != 'revoked'
                ? _withNfcStatus(identity, 'active')
                : identity;
            emit(StaffIdentityLoaded(effective, assignedCardUid: cardUid));
          },
        );
      } on TimeoutException {
        emit(
          const StaffIdentityError(
            'Staff identity is taking too long to load. Check your connection and try again.',
          ),
        );
      } catch (error) {
        emit(StaffIdentityError(error.toString()));
      }
    });

    on<RegenerateStaffQrCredentialEvent>((event, emit) async {
      emit(StaffIdentityLoading());
      try {
        final result = await repository
            .regenerateQrCredential(event.identity)
            .timeout(const Duration(seconds: 15));
        result.fold(
          (failure) => emit(StaffIdentityError(failure.message)),
          (identity) => emit(
            StaffIdentityActionSuccess(
              'New QR credential generated. Previous QR is inactive.',
              identity,
            ),
          ),
        );
      } on TimeoutException {
        emit(const StaffIdentityError('QR credential update timed out.'));
      } catch (error) {
        emit(StaffIdentityError(error.toString()));
      }
    });

    on<AssignStaffNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .assignToStaff(
              cardUid: event.cardUid,
              staffId: event.staffId,
              schoolId: event.schoolId,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card assigned',
          successStatus: 'active',
          staffId: event.staffId,
        );
      } on TimeoutException {
        emit(const StaffIdentityError('NFC card assignment timed out.'));
      } catch (error) {
        emit(StaffIdentityError(error.toString()));
      }
    });

    on<ReplaceStaffNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .replaceForStaff(
              oldCardUid: event.oldCardUid,
              newCardUid: event.newCardUid,
              staffId: event.staffId,
              schoolId: event.schoolId,
              reason: event.reason,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card replaced',
          successStatus: 'active',
          staffId: event.staffId,
        );
      } on TimeoutException {
        emit(const StaffIdentityError('NFC card replacement timed out.'));
      } catch (error) {
        emit(StaffIdentityError(error.toString()));
      }
    });

    on<RevokeStaffNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .revokeForStaff(
              cardUid: event.cardUid,
              staffId: event.staffId,
              schoolId: event.schoolId,
              reason: event.reason,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card revoked',
          successStatus: 'revoked',
          staffId: event.staffId,
        );
      } on TimeoutException {
        emit(const StaffIdentityError('NFC card revocation timed out.'));
      } catch (error) {
        emit(StaffIdentityError(error.toString()));
      }
    });

    on<ReactivateStaffNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .reactivateForStaff(
              cardUid: event.cardUid,
              staffId: event.staffId,
              schoolId: event.schoolId,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card reactivated',
          successStatus: 'active',
          staffId: event.staffId,
        );
      } on TimeoutException {
        emit(const StaffIdentityError('NFC card reactivation timed out.'));
      } catch (error) {
        emit(StaffIdentityError(error.toString()));
      }
    });
  }

  Future<String?> _lookupAssignedCard(String staffId, String schoolId) async {
    try {
      final result = await nfcCredentialService
          .findAssignedCardForStaff(staffId: staffId, schoolId: schoolId)
          .timeout(const Duration(seconds: 8));
      return await result.fold((_) => null, (cardUid) => cardUid);
    } catch (_) {
      return null;
    }
  }

  StaffIdentity _withNfcStatus(StaffIdentity identity, String status) {
    if (identity.nfcStatus == status) return identity;
    return StaffIdentity(
      staffId: identity.staffId,
      schoolId: identity.schoolId,
      uniqueSystemId: identity.uniqueSystemId,
      qrCodeData: identity.qrCodeData,
      nfcStatus: status,
    );
  }

  Future<void> _emitNfcActionResult(
    Either<Failure, void> result,
    Emitter<StaffIdentityState> emit, {
    required String successMessage,
    required String successStatus,
    required String staffId,
  }) async {
    await result.fold(
      (failure) async => emit(StaffIdentityError(failure.message)),
      (_) async {
        try {
          final identityResult = await repository
              .getOrIssueStaffIdentity(staffId)
              .timeout(const Duration(seconds: 15));
          await identityResult.fold(
            (failure) async => emit(StaffIdentityError(failure.message)),
            (identity) async {
              final cardUid = await _lookupAssignedCard(
                identity.staffId,
                identity.schoolId,
              );
              emit(
                StaffIdentityActionSuccess(
                  successMessage,
                  _withNfcStatus(identity, successStatus),
                  assignedCardUid: cardUid,
                ),
              );
            },
          );
        } on TimeoutException {
          emit(
            StaffIdentityError(
              '$successMessage, but refreshing the staff identity timed out.',
            ),
          );
        }
      },
    );
  }
}
