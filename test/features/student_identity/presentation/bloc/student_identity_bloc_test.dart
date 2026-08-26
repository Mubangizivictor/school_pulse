import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/services/enrollment_audit_service.dart';
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

class MockEnrollmentAuditService extends Mock
    implements EnrollmentAuditService {}

void main() {
  late StudentIdentityBloc bloc;
  late MockStudentIdentityRepository repository;
  late MockNfcCredentialRepository nfcCredentialRepository;
  late NfcCredentialService nfcCredentialService;
  late MockEnrollmentAuditService auditService;

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
    auditService = MockEnrollmentAuditService();
    nfcCredentialService = NfcCredentialService(
      nfcCredentialRepository: nfcCredentialRepository,
      studentIdentityRepository: repository,
    );
    bloc = StudentIdentityBloc(
      repository: repository,
      nfcCredentialService: nfcCredentialService,
      auditService: auditService,
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
      () => auditService.recordIdentityPreview(
        schoolId: any(named: 'schoolId'),
        studentId: any(named: 'studentId'),
        kind: any(named: 'kind'),
      ),
    ).thenAnswer((_) async {});
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
        // The bloc treats a found card + non-revoked identity as active,
        // even before any explicit AssignNfcCardEvent runs.
        const StudentIdentityLoaded(
          StudentIdentity(
            studentId: studentId,
            schoolId: schoolId,
            uniqueSystemId: uniqueSystemId,
            schoolStudentId: 'MH-2026-000001',
            qrCodeData: uniqueSystemId,
            nfcStatus: 'active',
          ),
          assignedCardUid: cardUid,
        ),
      ],
    );
  });

  group('AssignNfcCardEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'assigns the card and re-emits the refreshed identity as active',
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
          'Card assigned and ready for attendance',
          StudentIdentity(
            studentId: studentId,
            schoolId: schoolId,
            uniqueSystemId: uniqueSystemId,
            schoolStudentId: 'MH-2026-000001',
            qrCodeData: uniqueSystemId,
            nfcStatus: 'active',
          ),
          assignedCardUid: cardUid,
        ),
      ],
    );

    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'emits an error when the underlying assign fails',
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
    );
  });

  group('RevokeNfcCardEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'revokes the card, passing studentId so the server-authoritative path '
      'is used, and re-emits the refreshed identity as revoked',
      build: () {
        when(
          () => nfcCredentialRepository.revoke(
            credentialValue: any(named: 'credentialValue'),
            schoolId: any(named: 'schoolId'),
            reason: any(named: 'reason'),
            studentId: any(named: 'studentId'),
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
          StudentIdentity(
            studentId: studentId,
            schoolId: schoolId,
            uniqueSystemId: uniqueSystemId,
            schoolStudentId: 'MH-2026-000001',
            qrCodeData: uniqueSystemId,
            nfcStatus: 'revoked',
          ),
          assignedCardUid: cardUid,
        ),
      ],
      verify: (_) {
        verify(
          () => nfcCredentialRepository.revoke(
            credentialValue: cardUid,
            schoolId: schoolId,
            reason: 'lost',
            studentId: studentId,
          ),
        ).called(1);
      },
    );
  });

  group('ReactivateNfcCardEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'reactivates the card, passing studentId so the server-authoritative '
      'path is used, and re-emits the refreshed identity as active',
      build: () {
        when(
          () => nfcCredentialRepository.reactivate(
            credentialValue: any(named: 'credentialValue'),
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
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
          StudentIdentity(
            studentId: studentId,
            schoolId: schoolId,
            uniqueSystemId: uniqueSystemId,
            schoolStudentId: 'MH-2026-000001',
            qrCodeData: uniqueSystemId,
            nfcStatus: 'active',
          ),
          assignedCardUid: cardUid,
        ),
      ],
      verify: (_) {
        verify(
          () => nfcCredentialRepository.reactivate(
            credentialValue: cardUid,
            schoolId: schoolId,
            studentId: studentId,
          ),
        ).called(1);
      },
    );
  });

  group('RecordIdentityPreviewedEvent', () {
    blocTest<StudentIdentityBloc, StudentIdentityState>(
      'fires the audit call and never emits a state (fire-and-forget)',
      build: () => bloc,
      act: (bloc) => bloc.add(
        const RecordIdentityPreviewedEvent(
          studentId: studentId,
          schoolId: schoolId,
          kind: 'school_id',
        ),
      ),
      expect: () => <StudentIdentityState>[],
      verify: (_) {
        verify(
          () => auditService.recordIdentityPreview(
            schoolId: schoolId,
            studentId: studentId,
            kind: 'school_id',
          ),
        ).called(1);
      },
    );
  });
}
