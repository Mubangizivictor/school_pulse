import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
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

    when(
      () => studentIdentityRepository.updateNfcStatus(any(), any()),
    ).thenAnswer((_) async => const Right(null));
  });

  group('assignToStudent', () {
    test('assigns the card then marks the identity nfcStatus active', () async {
      when(
        () => nfcCredentialRepository.assign(
          credentialValue: cardUid,
          identityId: uniqueSystemId,
          identityType: 'student',
          schoolId: schoolId,
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
        () => studentIdentityRepository.updateNfcStatus(studentId, 'active'),
      ).called(1);
    });

    test(
      'propagates the failure and never touches nfcStatus when assign fails',
      () async {
        when(
          () => nfcCredentialRepository.assign(
            credentialValue: any(named: 'credentialValue'),
            identityId: any(named: 'identityId'),
            identityType: any(named: 'identityType'),
            schoolId: any(named: 'schoolId'),
          ),
        ).thenAnswer((_) async => Left(ServerFailure('already assigned')));

        final result = await service.assignToStudent(
          cardUid: cardUid,
          studentId: studentId,
          uniqueSystemId: uniqueSystemId,
          schoolId: schoolId,
        );

        expect(result, Left(ServerFailure('already assigned')));
        verifyNever(
          () => studentIdentityRepository.updateNfcStatus(any(), any()),
        );
      },
    );
  });

  group('revokeForStudent', () {
    test(
      'revokes the card then marks the identity nfcStatus revoked',
      () async {
        when(
          () => nfcCredentialRepository.revoke(
            credentialValue: any(named: 'credentialValue'),
            schoolId: any(named: 'schoolId'),
            reason: any(named: 'reason'),
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
          () => studentIdentityRepository.updateNfcStatus(studentId, 'revoked'),
        ).called(1);
      },
    );
  });

  group('reactivateForStudent', () {
    test(
      'reactivates the card then marks the identity nfcStatus active',
      () async {
        when(
          () => nfcCredentialRepository.reactivate(
            credentialValue: any(named: 'credentialValue'),
            schoolId: any(named: 'schoolId'),
          ),
        ).thenAnswer((_) async => const Right(null));

        final result = await service.reactivateForStudent(
          cardUid: cardUid,
          studentId: studentId,
          schoolId: schoolId,
        );

        expect(result.isRight(), true);
        verify(
          () => studentIdentityRepository.updateNfcStatus(studentId, 'active'),
        ).called(1);
      },
    );
  });

  group('replaceForStudent', () {
    test(
      'replaces the card then marks the identity nfcStatus active',
      () async {
        when(
          () => nfcCredentialRepository.replace(
            oldCredentialValue: any(named: 'oldCredentialValue'),
            newCredentialValue: any(named: 'newCredentialValue'),
            identityId: any(named: 'identityId'),
            identityType: any(named: 'identityType'),
            schoolId: any(named: 'schoolId'),
            reason: any(named: 'reason'),
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
          () => studentIdentityRepository.updateNfcStatus(studentId, 'active'),
        ).called(1);
      },
    );
  });
}
