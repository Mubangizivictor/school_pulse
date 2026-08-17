import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/student_identity.dart';
import '../../domain/repositories/student_identity_repository.dart';
import '../../domain/services/nfc_credential_service.dart';
import 'student_identity_event.dart';
import 'student_identity_state.dart';

class StudentIdentityBloc
    extends Bloc<StudentIdentityEvent, StudentIdentityState> {
  final StudentIdentityRepository repository;
  final NfcCredentialService nfcCredentialService;

  StudentIdentityBloc({
    required this.repository,
    required this.nfcCredentialService,
  }) : super(StudentIdentityInitial()) {
    on<LoadStudentIdentityEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      try {
        final result = await repository
            .getStudentIdentity(event.studentId)
            .timeout(const Duration(seconds: 15));
        await result.fold(
          (failure) async => emit(StudentIdentityError(failure.message)),
          (identity) async {
            final cardUid = await _lookupAssignedCard(
              identity.studentId,
              identity.schoolId,
            );
            final effective = cardUid != null && identity.nfcStatus != 'revoked'
                ? _withNfcStatus(identity, 'active')
                : identity;
            emit(StudentIdentityLoaded(effective, assignedCardUid: cardUid));
          },
        );
      } on TimeoutException {
        emit(
          const StudentIdentityError(
            'Student identity is taking too long to load. Check your connection and try again.',
          ),
        );
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<GenerateStudentIdentityEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      try {
        final result = await repository
            .generateStudentIdentity(event.student)
            .timeout(const Duration(seconds: 15));
        result.fold(
          (failure) => emit(StudentIdentityError(failure.message)),
          (identity) => emit(StudentIdentityLoaded(identity)),
        );
      } on TimeoutException {
        emit(
          const StudentIdentityError(
            'Student identity generation timed out. Check Firebase Functions deployment and your connection.',
          ),
        );
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<CacheStudentsOfflineEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      try {
        final result = await repository
            .cacheStudentsForOffline(event.students)
            .timeout(const Duration(seconds: 30));
        result.fold(
          (failure) => emit(StudentIdentityError(failure.message)),
          (_) => emit(StudentIdentityCacheSuccess()),
        );
      } on TimeoutException {
        emit(const StudentIdentityError('Offline student cache timed out.'));
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<RegenerateQrCredentialEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      try {
        final result = await repository
            .regenerateQrCredential(event.identity)
            .timeout(const Duration(seconds: 15));
        result.fold(
          (failure) => emit(StudentIdentityError(failure.message)),
          (identity) => emit(
            StudentIdentityActionSuccess(
              'New QR credential generated. Previous QR is inactive.',
              identity,
            ),
          ),
        );
      } on TimeoutException {
        emit(const StudentIdentityError('QR credential update timed out.'));
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<AssignNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .assignToStudent(
              cardUid: event.cardUid,
              studentId: event.studentId,
              uniqueSystemId: event.uniqueSystemId,
              schoolId: event.schoolId,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card assigned and ready for attendance',
          successStatus: 'active',
          studentId: event.studentId,
          schoolId: event.schoolId,
        );
      } on TimeoutException {
        emit(const StudentIdentityError('NFC card assignment timed out.'));
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<ReplaceNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .replaceForStudent(
              oldCardUid: event.oldCardUid,
              newCardUid: event.newCardUid,
              studentId: event.studentId,
              uniqueSystemId: event.uniqueSystemId,
              schoolId: event.schoolId,
              reason: event.reason,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card replaced',
          successStatus: 'active',
          studentId: event.studentId,
          schoolId: event.schoolId,
        );
      } on TimeoutException {
        emit(const StudentIdentityError('NFC card replacement timed out.'));
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<RevokeNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .revokeForStudent(
              cardUid: event.cardUid,
              studentId: event.studentId,
              schoolId: event.schoolId,
              reason: event.reason,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card revoked',
          successStatus: 'revoked',
          studentId: event.studentId,
          schoolId: event.schoolId,
        );
      } on TimeoutException {
        emit(const StudentIdentityError('NFC card revocation timed out.'));
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });

    on<ReactivateNfcCardEvent>((event, emit) async {
      try {
        final result = await nfcCredentialService
            .reactivateForStudent(
              cardUid: event.cardUid,
              studentId: event.studentId,
              schoolId: event.schoolId,
            )
            .timeout(const Duration(seconds: 15));
        await _emitNfcActionResult(
          result,
          emit,
          successMessage: 'Card reactivated',
          successStatus: 'active',
          studentId: event.studentId,
          schoolId: event.schoolId,
        );
      } on TimeoutException {
        emit(const StudentIdentityError('NFC card reactivation timed out.'));
      } catch (error) {
        emit(StudentIdentityError(error.toString()));
      }
    });
  }

  Future<String?> _lookupAssignedCard(
    String studentId,
    String schoolId,
  ) async {
    try {
      final result = await nfcCredentialService
          .findAssignedCardForStudent(
            uniqueSystemId: studentId,
            schoolId: schoolId,
          )
          .timeout(const Duration(seconds: 8));
      return result.fold((_) => null, (cardUid) => cardUid);
    } catch (_) {
      return null;
    }
  }

  StudentIdentity _withNfcStatus(StudentIdentity identity, String status) {
    if (identity.nfcStatus == status) return identity;
    return StudentIdentity(
      studentId: identity.studentId,
      schoolId: identity.schoolId,
      uniqueSystemId: identity.uniqueSystemId,
      schoolStudentId: identity.schoolStudentId,
      qrCodeData: identity.qrCodeData,
      nfcStatus: status,
    );
  }

  Future<void> _emitNfcActionResult(
    Either<Failure, void> result,
    Emitter<StudentIdentityState> emit, {
    required String successMessage,
    required String successStatus,
    required String studentId,
    required String schoolId,
  }) async {
    await result.fold(
      (failure) async => emit(StudentIdentityError(failure.message)),
      (_) async {
        try {
          final identityResult = await repository
              .getStudentIdentity(studentId)
              .timeout(const Duration(seconds: 15));
          await identityResult.fold(
            (failure) async => emit(StudentIdentityError(failure.message)),
            (identity) async {
              final cardUid = await _lookupAssignedCard(
                identity.studentId,
                identity.schoolId,
              );
              emit(
                StudentIdentityActionSuccess(
                  successMessage,
                  _withNfcStatus(identity, successStatus),
                  assignedCardUid: cardUid,
                ),
              );
            },
          );
        } on TimeoutException {
          emit(
            StudentIdentityError(
              '$successMessage, but refreshing the student identity timed out.',
            ),
          );
        }
      },
    );
  }
}
