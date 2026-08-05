import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/verification/data/repositories/identity_resolver_impl.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

class MockGetStaffMembers extends Mock implements GetStaffMembers {}

class MockResolveParentAccessCode extends Mock
    implements ResolveParentAccessCode {}

class MockVerifyFingerprint extends Mock implements VerifyFingerprint {}

class MockVerificationLocalDataSource extends Mock
    implements VerificationLocalDataSource {}

void main() {
  late IdentityResolverImpl resolver;
  late MockStudentIdentityRepository studentIdentityRepository;
  late MockGetStaffMembers getStaffMembers;
  late MockResolveParentAccessCode resolveParentAccessCode;
  late MockVerifyFingerprint verifyFingerprint;
  late MockVerificationLocalDataSource localDataSource;
  late FakeFirebaseFirestore firestore;

  const gate = Gate(
    id: 'gate-1',
    name: 'Main Gate',
    type: 'Main Entrance',
    location: 'Front',
    assignedOfficerIds: [],
    operatingHours: {},
    allowedUserRoles: [],
    requiredVerificationMethods: [],
    schoolId: 'school-1',
  );

  const operatorUser = UserEntity(
    id: 'op-1',
    name: 'Gate Officer',
    email: 'officer@example.com',
    schoolId: 'school-1',
    roles: [UserRole.gatekeeper],
  );

  final context = VerificationContext(
    gate: gate,
    operatorUser: operatorUser,
    purpose: 'security.identity.verify',
    deviceId: 'device-1',
    requestedAt: DateTime(2026, 1, 1),
  );

  final student = Student(
    id: 'student-1',
    schoolId: 'school-1',
    name: 'Jane Student',
    studentCode: 'SP-0001',
    admissionNumber: 'A0001',
    dateOfBirth: DateTime(2012, 1, 1),
    gender: Gender.female,
    classId: 'class-1',
    academicYearId: 'year-1',
    status: StudentStatus.active,
    level: EducationLevel.primary,
  );

  const staff = UserEntity(
    id: 'staff-1',
    name: 'A Teacher',
    email: 'teacher@example.com',
    schoolId: 'school-1',
    staffCode: 'ST-0001',
    roles: [UserRole.subjectTeacher],
  );

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(CachedCredentialIsar());
    registerFallbackValue(RevokedCredentialIsar());
  });

  setUp(() {
    studentIdentityRepository = MockStudentIdentityRepository();
    getStaffMembers = MockGetStaffMembers();
    resolveParentAccessCode = MockResolveParentAccessCode();
    verifyFingerprint = MockVerifyFingerprint();
    localDataSource = MockVerificationLocalDataSource();
    firestore = FakeFirebaseFirestore();
    resolver = IdentityResolverImpl(
      studentIdentityRepository: studentIdentityRepository,
      getStaffMembers: getStaffMembers,
      resolveParentAccessCode: resolveParentAccessCode,
      verifyFingerprint: verifyFingerprint,
      localDataSource: localDataSource,
      firestore: firestore,
    );

    when(() => localDataSource.saveRevocation(any())).thenAnswer((_) async {});
    when(() => localDataSource.cacheCredential(any())).thenAnswer((_) async {});
  });

  group('QR credential', () {
    test(
      'resolves to a StudentResolvedIdentity when the code matches a student',
      () async {
        when(
          () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
        ).thenAnswer((_) async => Right(student));

        final result = await resolver.resolve(
          QrScanCredential(rawPayload: 'SP-0001', scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<StudentResolvedIdentity>());
        expect((identity as StudentResolvedIdentity).studentCode, 'SP-0001');
      },
    );

    test(
      'resolves to unresolved(unknown_credential) when nothing matches',
      () async {
        when(
          () => studentIdentityRepository.getStudentByUniqueId('BAD-CODE'),
        ).thenAnswer((_) async => const Right(null));

        final result = await resolver.resolve(
          QrScanCredential(rawPayload: 'BAD-CODE', scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<UnresolvedResolvedIdentity>());
        expect(
          (identity as UnresolvedResolvedIdentity).reason,
          'unknown_credential',
        );
      },
    );
  });

  group('manual code credential', () {
    test(
      'falls back to staff lookup when no student matches the code',
      () async {
        when(
          () => studentIdentityRepository.getStudentByUniqueId('ST-0001'),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => getStaffMembers(any()),
        ).thenAnswer((_) async => Right([staff]));

        final result = await resolver.resolve(
          const ManualCodeScanCredential(code: 'ST-0001'),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<StaffResolvedIdentity>());
        expect((identity as StaffResolvedIdentity).staffCode, 'ST-0001');
      },
    );

    test(
      'propagates a real repository failure instead of silently falling back to staff lookup',
      () async {
        when(
          () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
        ).thenAnswer(
          (_) async => const Left(CacheFailure('offline, no cached data')),
        );

        final result = await resolver.resolve(
          const ManualCodeScanCredential(code: 'SP-0001'),
          context,
        );

        expect(result.isLeft(), isTrue);
        verifyNever(() => getStaffMembers(any()));
      },
    );
  });

  group('NFC credential', () {
    test(
      'resolves via CachedCredentialIsar when the card UID is cached and active',
      () async {
        when(
          () => localDataSource.findRevocation('UID123', 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential('UID123', 'school-1'),
        ).thenAnswer(
          (_) async => CachedCredentialIsar()
            ..credentialValue = 'UID123'
            ..credentialType = 'nfc'
            ..identityId = 'SP-0001'
            ..identityType = 'student'
            ..schoolId = 'school-1'
            ..status = 'active'
            ..updatedAt = DateTime.now(),
        );
        when(
          () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
        ).thenAnswer((_) async => Right(student));

        final result = await resolver.resolve(
          NfcScanCredential(cardUid: 'UID123', scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<StudentResolvedIdentity>());
      },
    );

    test(
      'resolves to unresolved(revoked_credential) when the UID is on the revocation list',
      () async {
        when(
          () => localDataSource.findRevocation('UID999', 'school-1'),
        ).thenAnswer(
          (_) async => RevokedCredentialIsar()
            ..credentialValue = 'UID999'
            ..schoolId = 'school-1'
            ..revokedAt = DateTime.now()
            ..reason = 'lost card',
        );

        final result = await resolver.resolve(
          NfcScanCredential(cardUid: 'UID999', scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<UnresolvedResolvedIdentity>());
        expect(
          (identity as UnresolvedResolvedIdentity).reason,
          'revoked_credential',
        );
      },
    );

    test(
      'resolves to unresolved(unknown_credential) when the UID is not cached at all and Firestore has no record either',
      () async {
        when(
          () => localDataSource.findRevocation('UID000', 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential('UID000', 'school-1'),
        ).thenAnswer((_) async => null);

        final result = await resolver.resolve(
          NfcScanCredential(cardUid: 'UID000', scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<UnresolvedResolvedIdentity>());
        expect(
          (identity as UnresolvedResolvedIdentity).reason,
          'unknown_credential',
        );
      },
    );

    test(
      'falls back to Firestore and resolves when the card was assigned on a different device',
      () async {
        when(
          () => localDataSource.findRevocation('UID-REMOTE', 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential('UID-REMOTE', 'school-1'),
        ).thenAnswer((_) async => null);
        await firestore
            .collection('schools')
            .doc('school-1')
            .collection('credentials')
            .doc('UID-REMOTE')
            .set({
              'credentialValue': 'UID-REMOTE',
              'credentialType': 'nfc',
              'identityId': 'SP-0001',
              'identityType': 'student',
              'schoolId': 'school-1',
              'status': 'active',
              'updatedAt': DateTime.now().toIso8601String(),
            });
        when(
          () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
        ).thenAnswer((_) async => Right(student));

        final result = await resolver.resolve(
          NfcScanCredential(cardUid: 'UID-REMOTE', scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<StudentResolvedIdentity>());
        // Write-through: the next scan on this device should resolve
        // offline without hitting Firestore again.
        verify(() => localDataSource.cacheCredential(any())).called(1);
      },
    );

    test(
      'falls back to Firestore and denies when the card was revoked on a different device',
      () async {
        when(
          () =>
              localDataSource.findRevocation('UID-REVOKED-REMOTE', 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () =>
              localDataSource.findCredential('UID-REVOKED-REMOTE', 'school-1'),
        ).thenAnswer((_) async => null);
        await firestore
            .collection('schools')
            .doc('school-1')
            .collection('revoked_credentials')
            .doc('UID-REVOKED-REMOTE')
            .set({
              'credentialValue': 'UID-REVOKED-REMOTE',
              'schoolId': 'school-1',
              'reason': 'stolen',
            });

        final result = await resolver.resolve(
          NfcScanCredential(
            cardUid: 'UID-REVOKED-REMOTE',
            scannedAt: DateTime.now(),
          ),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<UnresolvedResolvedIdentity>());
        expect(
          (identity as UnresolvedResolvedIdentity).reason,
          'revoked_credential',
        );
        verify(() => localDataSource.saveRevocation(any())).called(1);
      },
    );
  });

  group('parent code credential', () {
    test(
      'uses the pre-selected child when the shell already disambiguated',
      () async {
        when(() => resolveParentAccessCode('PARENT-1')).thenAnswer(
          (_) async => const Right(
            ParentAccessCode(
              id: 'pc-1',
              parentCode: 'PARENT-1',
              schoolId: 'school-1',
              studentIds: ['student-1', 'student-2'],
              studentNames: ['Jane Student', 'Sibling Student'],
            ),
          ),
        );

        final result = await resolver.resolve(
          const ParentCodeScanCredential(
            code: 'PARENT-1',
            preSelectedChildId: 'student-2',
            preSelectedChildName: 'Sibling Student',
          ),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<ParentPickupResolvedIdentity>());
        expect((identity as ParentPickupResolvedIdentity).childId, 'student-2');
      },
    );

    test(
      'returns unresolved(multiple_children) with several children and no pre-selection',
      () async {
        when(() => resolveParentAccessCode('PARENT-2')).thenAnswer(
          (_) async => const Right(
            ParentAccessCode(
              id: 'pc-2',
              parentCode: 'PARENT-2',
              schoolId: 'school-1',
              studentIds: ['student-1', 'student-2'],
              studentNames: ['Jane Student', 'Sibling Student'],
            ),
          ),
        );

        final result = await resolver.resolve(
          const ParentCodeScanCredential(code: 'PARENT-2'),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<UnresolvedResolvedIdentity>());
        expect(
          (identity as UnresolvedResolvedIdentity).reason,
          'multiple_children',
        );
      },
    );
  });
}
