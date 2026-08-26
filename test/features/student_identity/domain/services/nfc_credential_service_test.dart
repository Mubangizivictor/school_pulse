import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/domain/services/nfc_credential_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';

class MockNfcCredentialRepository extends Mock
    implements NfcCredentialRepository {}

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

void main() {
  late NfcCredentialService service;
  late MockNfcCredentialRepository nfcCredentialRepository;
  late MockStudentIdentityRepository studentIdentityRepository;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const uniqueSystemId = 'SP-STUDENT-abc';
  const cardUid = 'CARD-001';

  setUp(() {
    nfcCredentialRepository = MockNfcCredentialRepository();
    studentIdentityRepository = MockStudentIdentityRepository();
    service = NfcCredentialService(
      nfcCredentialRepository: nfcCredentialRepository,
      studentIdentityRepository: studentIdentityRepository,
    );
  });

  group('assignToStudent', () {
    test(
      'assigns the card via the repository, keyed by canonical Student.id',
      () async {
        when(
          () => nfcCredentialRepository.assign(
            credentialValue: cardUid,
            identityId: studentId,
            identityType: 'student',
            schoolId: schoolId,
            studentId: studentId,
          ),
        ).thenAnswer((_) async => const Right(null));

        final result = await service.assignToStudent(
          cardUid: cardUid,
          studentId: studentId,
          uniqueSystemId: uniqueSystemId,
          schoolId: schoolId,
        );

        expect(result.isRight(), true);
        verify(
          () => nfcCredentialRepository.assign(
            credentialValue: cardUid,
            identityId: studentId,
            identityType: 'student',
            schoolId: schoolId,
            studentId: studentId,
          ),
        ).called(1);
      },
    );

    test('propagates the failure when assign fails', () async {
      when(
        () => nfcCredentialRepository.assign(
          credentialValue: any(named: 'credentialValue'),
          identityId: any(named: 'identityId'),
          identityType: any(named: 'identityType'),
          schoolId: any(named: 'schoolId'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('already assigned')));

      final result = await service.assignToStudent(
        cardUid: cardUid,
        studentId: studentId,
        uniqueSystemId: uniqueSystemId,
        schoolId: schoolId,
      );

      expect(result, Left(ServerFailure('already assigned')));
    });

    test(
      'resolves and names the conflicting student when the card is already '
      'registered to someone else, instead of a dead-end generic message',
      () async {
        when(
          () => nfcCredentialRepository.assign(
            credentialValue: any(named: 'credentialValue'),
            identityId: any(named: 'identityId'),
            identityType: any(named: 'identityType'),
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
          ),
        ).thenAnswer(
          (_) async => const Left(
            DuplicateCredentialFailure(
              conflictingIdentityId: 'SP-STUDENT-OTHER',
              conflictingIdentityType: 'student',
            ),
          ),
        );
        when(
          () => studentIdentityRepository.getStudentByUniqueId(
            'SP-STUDENT-OTHER',
          ),
        ).thenAnswer(
          (_) async => Right(
            Student(
              id: 'student-other',
              schoolId: schoolId,
              name: 'Jane Achieng',
              studentCode: 'SP002',
              admissionNumber: 'SP002',
              dateOfBirth: DateTime(2012),
              gender: Gender.female,
              classId: 'class-b',
              academicYearId: 'year-a',
              status: StudentStatus.active,
              level: EducationLevel.primary,
            ),
          ),
        );

        final result = await service.assignToStudent(
          cardUid: cardUid,
          studentId: studentId,
          uniqueSystemId: uniqueSystemId,
          schoolId: schoolId,
        );

        expect(result.isLeft(), true);
        final failure = result.fold((f) => f, (_) => null)!;
        expect(
          failure.message,
          'This card is already registered to Jane Achieng.',
        );
      },
    );

    test('falls back to the generic message when the conflicting student '
        'cannot be resolved (e.g. offline)', () async {
      when(
        () => nfcCredentialRepository.assign(
          credentialValue: any(named: 'credentialValue'),
          identityId: any(named: 'identityId'),
          identityType: any(named: 'identityType'),
          schoolId: any(named: 'schoolId'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          DuplicateCredentialFailure(
            conflictingIdentityId: 'SP-STUDENT-OTHER',
            conflictingIdentityType: 'student',
          ),
        ),
      );
      when(
        () =>
            studentIdentityRepository.getStudentByUniqueId('SP-STUDENT-OTHER'),
      ).thenAnswer((_) async => Left(ServerFailure('offline')));

      final result = await service.assignToStudent(
        cardUid: cardUid,
        studentId: studentId,
        uniqueSystemId: uniqueSystemId,
        schoolId: schoolId,
      );

      expect(result.isLeft(), true);
      final failure = result.fold((f) => f, (_) => null)!;
      expect(
        failure.message,
        'This card is already assigned to another identity. Revoke or replace it first.',
      );
    });
  });

  group('revokeForStudent', () {
    test('revokes the card via the repository, passing studentId through so '
        'the server-authoritative revokeNfcCredential path can be used', () async {
      when(
        () => nfcCredentialRepository.revoke(
          credentialValue: cardUid,
          schoolId: schoolId,
          reason: 'lost',
          studentId: studentId,
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await service.revokeForStudent(
        cardUid: cardUid,
        studentId: studentId,
        schoolId: schoolId,
        reason: 'lost',
      );

      expect(result.isRight(), true);
      verify(
        () => nfcCredentialRepository.revoke(
          credentialValue: cardUid,
          schoolId: schoolId,
          reason: 'lost',
          studentId: studentId,
        ),
      ).called(1);
    });
  });

  group('reactivateForStudent', () {
    test('reactivates the card via the repository, passing studentId through '
        'so the server-authoritative reactivateNfcCredential path can be used',
        () async {
      when(
        () => nfcCredentialRepository.reactivate(
          credentialValue: cardUid,
          schoolId: schoolId,
          studentId: studentId,
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await service.reactivateForStudent(
        cardUid: cardUid,
        studentId: studentId,
        schoolId: schoolId,
      );

      expect(result.isRight(), true);
      verify(
        () => nfcCredentialRepository.reactivate(
          credentialValue: cardUid,
          schoolId: schoolId,
          studentId: studentId,
        ),
      ).called(1);
    });
  });

  group('replaceForStudent', () {
    test('replaces the card via the repository', () async {
      when(
        () => nfcCredentialRepository.replace(
          oldCredentialValue: any(named: 'oldCredentialValue'),
          newCredentialValue: any(named: 'newCredentialValue'),
          identityId: any(named: 'identityId'),
          identityType: any(named: 'identityType'),
          schoolId: any(named: 'schoolId'),
          reason: any(named: 'reason'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await service.replaceForStudent(
        oldCardUid: 'OLD',
        newCardUid: 'NEW',
        studentId: studentId,
        uniqueSystemId: uniqueSystemId,
        schoolId: schoolId,
        reason: 'damaged',
      );

      expect(result.isRight(), true);
      verify(
        () => nfcCredentialRepository.replace(
          oldCredentialValue: 'OLD',
          newCredentialValue: 'NEW',
          identityId: studentId,
          identityType: 'student',
          schoolId: schoolId,
          reason: 'damaged',
          studentId: studentId,
        ),
      ).called(1);
    });
  });
}
