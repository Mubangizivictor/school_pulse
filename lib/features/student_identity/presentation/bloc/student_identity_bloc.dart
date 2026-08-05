import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';
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
      final result = await repository.getStudentIdentity(event.studentId);
      await result.fold(
        (failure) async => emit(StudentIdentityError(failure.message)),
        (identity) async {
          final cardUid = await _lookupAssignedCard(
            identity.uniqueSystemId,
            event.schoolId,
          );
          emit(StudentIdentityLoaded(identity, assignedCardUid: cardUid));
        },
      );
    });

    on<GenerateStudentIdentityEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      final result = await repository.generateStudentIdentity(event.student);
      result.fold(
        (failure) => emit(StudentIdentityError(failure.message)),
        (identity) => emit(StudentIdentityLoaded(identity)),
      );
    });

    on<CacheStudentsOfflineEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      final result = await repository.cacheStudentsForOffline(event.students);
      result.fold(
        (failure) => emit(StudentIdentityError(failure.message)),
        (_) => emit(StudentIdentityCacheSuccess()),
      );
    });

    on<AssignNfcCardEvent>((event, emit) async {
      final result = await nfcCredentialService.assignToStudent(
        cardUid: event.cardUid,
        studentId: event.studentId,
        uniqueSystemId: event.uniqueSystemId,
        schoolId: event.schoolId,
      );
      await _emitNfcActionResult(
        result,
        emit,
        successMessage: 'Card assigned',
        studentId: event.studentId,
        uniqueSystemId: event.uniqueSystemId,
        schoolId: event.schoolId,
      );
    });

    on<ReplaceNfcCardEvent>((event, emit) async {
      final result = await nfcCredentialService.replaceForStudent(
        oldCardUid: event.oldCardUid,
        newCardUid: event.newCardUid,
        studentId: event.studentId,
        uniqueSystemId: event.uniqueSystemId,
        schoolId: event.schoolId,
        reason: event.reason,
      );
      await _emitNfcActionResult(
        result,
        emit,
        successMessage: 'Card replaced',
        studentId: event.studentId,
        uniqueSystemId: event.uniqueSystemId,
        schoolId: event.schoolId,
      );
    });

    on<RevokeNfcCardEvent>((event, emit) async {
      final result = await nfcCredentialService.revokeForStudent(
        cardUid: event.cardUid,
        studentId: event.studentId,
        schoolId: event.schoolId,
        reason: event.reason,
      );
      await _emitNfcActionResult(
        result,
        emit,
        successMessage: 'Card revoked',
        studentId: event.studentId,
        schoolId: event.schoolId,
      );
    });

    on<ReactivateNfcCardEvent>((event, emit) async {
      final result = await nfcCredentialService.reactivateForStudent(
        cardUid: event.cardUid,
        studentId: event.studentId,
        schoolId: event.schoolId,
      );
      await _emitNfcActionResult(
        result,
        emit,
        successMessage: 'Card reactivated',
        studentId: event.studentId,
        schoolId: event.schoolId,
      );
    });
  }

  Future<String?> _lookupAssignedCard(
    String uniqueSystemId,
    String schoolId,
  ) async {
    final result = await nfcCredentialService.findAssignedCardForStudent(
      uniqueSystemId: uniqueSystemId,
      schoolId: schoolId,
    );
    return result.fold((_) => null, (cardUid) => cardUid);
  }

  // Shared tail for every NFC lifecycle event: on success, re-fetch the
  // identity + card mapping so the UI reflects the new state immediately.
  Future<void> _emitNfcActionResult(
    Either<Failure, void> result,
    Emitter<StudentIdentityState> emit, {
    required String successMessage,
    required String studentId,
    required String schoolId,
    String? uniqueSystemId,
  }) async {
    await result.fold(
      (failure) async => emit(StudentIdentityError(failure.message)),
      (_) async {
        final identityResult = await repository.getStudentIdentity(studentId);
        await identityResult.fold(
          (failure) async => emit(StudentIdentityError(failure.message)),
          (identity) async {
            final cardUid = await _lookupAssignedCard(
              identity.uniqueSystemId,
              schoolId,
            );
            emit(
              StudentIdentityActionSuccess(
                successMessage,
                identity,
                assignedCardUid: cardUid,
              ),
            );
          },
        );
      },
    );
  }
}
