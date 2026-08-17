import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student_identity/domain/entities/student_identity.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/domain/services/nfc_credential_service.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_event.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_state.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

class MockNfcCredentialRepository extends Mock
    implements NfcCredentialRepository {}

void main() {
  late StudentIdentityBloc bloc;
  late MockStudentIdentityRepository repository;
  late MockNfcCredentialRepository nfcCredentialRepository;
  late NfcCredentialService nfcCredentialService;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const uniqueSystemId = 'SP-STUDENT-abc';
  const cardUid = 'CARD-001';

  const identity = StudentIdentity(
    studentId: studentId,
    schoolId: schoolId,
    uniqueSystemId: uniqueSystemId,
    schoolStudentId: 'MH-2026-000001',
    qrCodeData: uniqueSystemId,
  );

  setUpAll(() {
    registerFallbackValue(Student.empty());
  });

  setUp(() {
    repository = MockStudentIdentityRepository();
    nfcCredentialRepository = MockNfcCredentialRepository();
    nfcCredentialService = NfcCredentialService(
      nfcCredentialRepository: nfcCredentialRepository,
      studentIdentityRepository: repository,
    );
    bloc = StudentIdentityBloc(
      repository: repository,
      nfcCredentialService: nfcCredentialService,
    );

    when(
      () => repository.getStudentIdentity(studentId),
    ).thenAnswer((_) async => const Right(identity));
    when(
      () => nfcCredentialRepository.findAssignedCredential(
        identityId: any(named: 'identityId'),
        schoolId: any(named: 'schoolId'),
      ),
    ).thenAnswer((_) async => const Right(cardUid));
    when(
      () => repository.updateNfcStatus(any(), any()),
    ).thenAnswer((_) async => const Right(null));
  });

  tearDown(() => bloc.close());

  group('LoadStudentIdentityEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'emits [Loading, Loaded] with the currently assigned card looked up',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const LoadStudentIdentityEvent(studentId, schoolId: schoolId),
      ),
      expect: () => [
        StudentIdentityLoading(),
        const StudentIdentityLoaded(identity, assignedCardUid: cardUid),
      ],
    );
  });

  group('AssignNfcCardEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'assigns the card, marks nfcStatus active, and re-emits the refreshed identity',
      build: () {
        when(
          () => nfcCredentialRepository.assign(
            credentialValue: any(named: 'credentialValue'),
            identityId: any(named: 'identityId'),
            identityType: any(named: 'identityType'),
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AssignNfcCardEvent(
          cardUid: cardUid,
          studentId: studentId,
          uniqueSystemId: uniqueSystemId,
          schoolId: schoolId,
        ),
      ),
      expect: () => [
        const StudentIdentityActionSuccess(
          'Card assigned',
          identity,
          assignedCardUid: cardUid,
        ),
      ],
      verify: (_) {
        verify(() => repository.updateNfcStatus(studentId, 'active')).called(1);
      },
    );

    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'emits an error and never touches nfcStatus when the underlying assign fails',
      build: () {
        when(
          () => nfcCredentialRepository.assign(
            credentialValue: any(named: 'credentialValue'),
            identityId: any(named: 'identityId'),
            identityType: any(named: 'identityType'),
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer((_) async => Left(ServerFailure('already assigned')));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AssignNfcCardEvent(
          cardUid: cardUid,
          studentId: studentId,
          uniqueSystemId: uniqueSystemId,
          schoolId: schoolId,
        ),
      ),
      expect: () => [const StudentIdentityError('already assigned')],
      verify: (_) {
        verifyNever(() => repository.updateNfcStatus(any(), any()));
      },
    );
  });

  group('RevokeNfcCardEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'revokes the card and marks nfcStatus revoked',
      build: () {
        when(
          () => nfcCredentialRepository.revoke(
            credentialValue: any(named: 'credentialValue'),
            schoolId: any(named: 'schoolId'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RevokeNfcCardEvent(
          cardUid: cardUid,
          studentId: studentId,
          schoolId: schoolId,
          reason: 'lost',
        ),
      ),
      expect: () => [
        const StudentIdentityActionSuccess(
          'Card revoked',
          identity,
          assignedCardUid: cardUid,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.updateNfcStatus(studentId, 'revoked'),
        ).called(1);
      },
    );
  });

  group('ReactivateNfcCardEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'reactivates the card and marks nfcStatus active',
      build: () {
        when(
          () => nfcCredentialRepository.reactivate(
            credentialValue: any(named: 'credentialValue'),
            schoolId: any(named: 'schoolId'),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ReactivateNfcCardEvent(
          cardUid: cardUid,
          studentId: studentId,
          schoolId: schoolId,
        ),
      ),
      expect: () => [
        const StudentIdentityActionSuccess(
          'Card reactivated',
          identity,
          assignedCardUid: cardUid,
        ),
      ],
      verify: (_) {
        verify(() => repository.updateNfcStatus(studentId, 'active')).called(1);
      },
    );
  });
}
