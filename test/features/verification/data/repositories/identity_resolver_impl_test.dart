import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_cache_records.dart';
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
    registerFallbackValue(
      CachedCredential(
        credentialValue: '',
        credentialType: 'nfc',
        identityId: '',
        identityType: 'student',
        schoolId: '',
        status: 'active',
        updatedAt: DateTime(2026),
      ),
    );
    registerFallbackValue(
      RevokedCredential(
        credentialValue: '',
        schoolId: '',
        revokedAt: DateTime(2026),
        reason: '',
      ),
    );
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
    const qrToken = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNO_0123456789';
    const qrPayload = 'SPQR1.$qrToken';

    test(
      'resolves an active opaque QR credential to a StudentResolvedIdentity',
      () async {
        when(
          () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
        ).thenAnswer((_) async => Right(student));
        when(
          () => localDataSource.findRevocation(qrToken, 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential(qrToken, 'school-1'),
        ).thenAnswer(
          (_) async => CachedCredential(
            credentialValue: qrToken,
            credentialType: 'qr',
            identityId: 'SP-0001',
            identityType: 'student',
            schoolId: 'school-1',
            status: 'active',
            updatedAt: DateTime.now(),
          ),
        );

        final result = await resolver.resolve(
          QrScanCredential(rawPayload: qrPayload, scannedAt: DateTime.now()),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<StudentResolvedIdentity>());
        expect((identity as StudentResolvedIdentity).studentCode, 'SP-0001');
      },
    );

    test(
      'rejects arbitrary QR content before attempting an identity lookup',
      () async {
        final result = await resolver.resolve(
          QrScanCredential(
            rawPayload: 'https://example.com',
            scannedAt: DateTime.now(),
          ),
          context,
        );

        final identity = result.getOrElse(() => throw Exception());
        expect(identity, isA<UnresolvedResolvedIdentity>());
        expect((identity as UnresolvedResolvedIdentity).reason, 'invalid_qr');
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
      'resolves via CachedCredential when the card UID is cached and active',
      () async {
        when(
          () => localDataSource.findRevocation('UID123', 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential('UID123', 'school-1'),
        ).thenAnswer(
          (_) async => CachedCredential(
            credentialValue: 'UID123',
            credentialType: 'nfc',
            identityId: 'SP-0001',
            identityType: 'student',
            schoolId: 'school-1',
            status: 'active',
            updatedAt: DateTime.now(),
          ),
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
          (_) async => RevokedCredential(
            credentialValue: 'UID999',
            schoolId: 'school-1',
            revokedAt: DateTime.now(),
            reason: 'lost card',
          ),
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
      'a malformed/garbage card payload (not a real hex UID) resolves as '
      'unknown_credential rather than throwing or matching anything - '
      'School Pulse never trusts raw NFC content as an implicit credential',
      () async {
        const garbage = 'not-a-real-ntag-uid;DROP TABLE students;--';
        when(
          () => localDataSource.findRevocation(garbage, 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential(garbage, 'school-1'),
        ).thenAnswer((_) async => null);

        final result = await resolver.resolve(
          NfcScanCredential(cardUid: garbage, scannedAt: DateTime.now()),
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

    test('resolves correctly when updatedAt is a Firestore Timestamp (what '
        'Cloud Functions actually write via serverTimestamp()), not an ISO '
        'string - a bare DateTime.tryParse(x as String) would throw here '
        'and silently turn a valid card into unknown_credential', () async {
      when(
        () => localDataSource.findRevocation('UID-TS', 'school-1'),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.findCredential('UID-TS', 'school-1'),
      ).thenAnswer((_) async => null);
      await firestore
          .collection('schools')
          .doc('school-1')
          .collection('credentials')
          .doc('UID-TS')
          .set({
            'credentialValue': 'UID-TS',
            'credentialType': 'nfc',
            'identityId': 'SP-0001',
            'identityType': 'student',
            'schoolId': 'school-1',
            'status': 'active',
            'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
          });
      when(
        () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
      ).thenAnswer((_) async => Right(student));

      final result = await resolver.resolve(
        NfcScanCredential(cardUid: 'UID-TS', scannedAt: DateTime.now()),
        context,
      );

      final identity = result.getOrElse(() => throw Exception());
      expect(identity, isA<StudentResolvedIdentity>());
    });

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
