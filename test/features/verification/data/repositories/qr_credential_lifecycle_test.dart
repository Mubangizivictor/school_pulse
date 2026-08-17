import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
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
import 'package:school_pulse/features/verification/domain/services/qr_credential_codec.dart';

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

class MockGetStaffMembers extends Mock implements GetStaffMembers {}

class MockResolveParentAccessCode extends Mock
    implements ResolveParentAccessCode {}

class MockVerifyFingerprint extends Mock implements VerifyFingerprint {}

class MockVerificationLocalDataSource extends Mock
    implements VerificationLocalDataSource {}

/// QR-specific credential-lifecycle and tenant-isolation coverage, sitting
/// alongside identity_resolver_impl_test.dart's broader NFC/manual/parent
/// coverage. The NFC suite already proves revoked_credentials/status
/// handling generically - this file exercises the same machinery with real
/// QrCredentialCodec-issued tokens and the states unique to a printed QR ID
/// card's lifecycle (disabled/replaced/lost), plus cross-school isolation.
void main() {
  const codec = QrCredentialCodec();
  late IdentityResolverImpl resolver;
  late MockStudentIdentityRepository studentIdentityRepository;
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
    name: 'Class Teacher',
    email: 'teacher@example.com',
    schoolId: 'school-1',
    roles: [UserRole.classTeacher],
  );

  final context = VerificationContext(
    gate: gate,
    operatorUser: operatorUser,
    purpose: 'attendance.qr.scan',
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

  setUpAll(() {
    registerFallbackValue(
      CachedCredential(
        credentialValue: '',
        credentialType: 'qr',
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
    localDataSource = MockVerificationLocalDataSource();
    firestore = FakeFirebaseFirestore();
    resolver = IdentityResolverImpl(
      studentIdentityRepository: studentIdentityRepository,
      getStaffMembers: MockGetStaffMembers(),
      resolveParentAccessCode: MockResolveParentAccessCode(),
      verifyFingerprint: MockVerifyFingerprint(),
      localDataSource: localDataSource,
      firestore: firestore,
    );
    when(() => localDataSource.saveRevocation(any())).thenAnswer((_) async {});
    when(() => localDataSource.cacheCredential(any())).thenAnswer((_) async {});
  });

  Future<void> seedFirestoreCredential({
    required String schoolId,
    required String token,
    required String status,
    String identityId = 'SP-0001',
  }) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('credentials')
        .doc(token)
        .set({
          'credentialValue': token,
          'credentialType': 'qr',
          'identityId': identityId,
          'identityType': 'student',
          'schoolId': schoolId,
          'status': status,
          'updatedAt': DateTime.now().toIso8601String(),
          'credentialVersion': 1,
        });
  }

  group('QR credential lifecycle states', () {
    for (final status in ['disabled', 'replaced', 'lost']) {
      test(
        'a QR credential with status "$status" is denied, not treated as unknown',
        () async {
          final payload = codec.issuePayload();
          final token = codec.parse(payload)!;
          when(
            () => localDataSource.findRevocation(token, 'school-1'),
          ).thenAnswer((_) async => null);
          when(
            () => localDataSource.findCredential(token, 'school-1'),
          ).thenAnswer(
            (_) async => CachedCredential(
              credentialValue: token,
              credentialType: 'qr',
              identityId: 'SP-0001',
              identityType: 'student',
              schoolId: 'school-1',
              status: status,
              updatedAt: DateTime.now(),
            ),
          );

          final result = await resolver.resolve(
            QrScanCredential(rawPayload: payload, scannedAt: DateTime.now()),
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
    }

    test(
      'a replaced QR credential fetched fresh from Firestore (never seen on '
      'this device) is still denied, not resolved as the old identity',
      () async {
        final payload = codec.issuePayload();
        final token = codec.parse(payload)!;
        when(
          () => localDataSource.findRevocation(token, 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential(token, 'school-1'),
        ).thenAnswer((_) async => null);
        await seedFirestoreCredential(
          schoolId: 'school-1',
          token: token,
          status: 'replaced',
        );

        final result = await resolver.resolve(
          QrScanCredential(rawPayload: payload, scannedAt: DateTime.now()),
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
      'replacing a QR credential invalidates the old token: old resolves '
      'denied, new resolves active, both scoped to the same student',
      () async {
        final oldPayload = codec.issuePayload();
        final oldToken = codec.parse(oldPayload)!;
        final newPayload = codec.issuePayload();
        final newToken = codec.parse(newPayload)!;
        expect(oldToken, isNot(equals(newToken)));

        await seedFirestoreCredential(
          schoolId: 'school-1',
          token: oldToken,
          status: 'replaced',
        );
        await seedFirestoreCredential(
          schoolId: 'school-1',
          token: newToken,
          status: 'active',
        );
        when(
          () => localDataSource.findRevocation(any(), 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => localDataSource.findCredential(any(), 'school-1'),
        ).thenAnswer((_) async => null);
        when(
          () => studentIdentityRepository.getStudentByUniqueId('SP-0001'),
        ).thenAnswer((_) async => Right(student));

        final oldResult = await resolver.resolve(
          QrScanCredential(rawPayload: oldPayload, scannedAt: DateTime.now()),
          context,
        );
        final newResult = await resolver.resolve(
          QrScanCredential(rawPayload: newPayload, scannedAt: DateTime.now()),
          context,
        );

        expect(
          oldResult.getOrElse(() => throw Exception()),
          isA<UnresolvedResolvedIdentity>(),
        );
        final newIdentity = newResult.getOrElse(() => throw Exception());
        expect(newIdentity, isA<StudentResolvedIdentity>());
        expect((newIdentity as StudentResolvedIdentity).studentCode, 'SP-0001');
      },
    );
  });

  group('QR tenant isolation', () {
    test('a QR credential issued for School A never resolves under School B '
        'even with an identical token value', () async {
      final payload = codec.issuePayload();
      final token = codec.parse(payload)!;
      // Credential only exists under school-1's subcollection.
      await seedFirestoreCredential(
        schoolId: 'school-1',
        token: token,
        status: 'active',
      );

      const otherSchoolGate = Gate(
        id: 'gate-2',
        name: 'Other Gate',
        type: 'Main Entrance',
        location: 'Front',
        assignedOfficerIds: [],
        operatingHours: {},
        allowedUserRoles: [],
        requiredVerificationMethods: [],
        schoolId: 'school-2',
      );
      final otherSchoolContext = VerificationContext(
        gate: otherSchoolGate,
        operatorUser: operatorUser,
        purpose: 'attendance.qr.scan',
        deviceId: 'device-2',
        requestedAt: DateTime(2026, 1, 1),
      );
      when(
        () => localDataSource.findRevocation(token, 'school-2'),
      ).thenAnswer((_) async => null);
      when(
        () => localDataSource.findCredential(token, 'school-2'),
      ).thenAnswer((_) async => null);

      final result = await resolver.resolve(
        QrScanCredential(rawPayload: payload, scannedAt: DateTime.now()),
        otherSchoolContext,
      );

      final identity = result.getOrElse(() => throw Exception());
      expect(identity, isA<UnresolvedResolvedIdentity>());
      expect(
        (identity as UnresolvedResolvedIdentity).reason,
        'unknown_credential',
      );
    });
  });

  group('QR credential does not encode student data', () {
    test('a freshly issued QR payload contains no student identifiers - only '
        'the resolver, never the payload, ever carries identity', () {
      final payload = codec.issuePayload();
      expect(payload, isNot(contains(student.id)));
      expect(payload, isNot(contains(student.studentCode)));
      expect(payload, isNot(contains(student.admissionNumber)));
      expect(payload, isNot(contains('school-1')));
    });
  });
}
