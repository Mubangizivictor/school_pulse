import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_device_service.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/presentation/adapters/fingerprint_credential_reader_adapter.dart';

class MockBiometricDeviceService extends Mock
    implements BiometricDeviceService {}

void main() {
  late MockBiometricDeviceService deviceService;
  late FingerprintCredentialReaderAdapter adapter;

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

  setUp(() {
    deviceService = MockBiometricDeviceService();
    adapter = FingerprintCredentialReaderAdapter(deviceService);
  });

  test('isAvailable reflects the underlying device connection state', () async {
    when(() => deviceService.isConnected).thenReturn(true);
    expect(await adapter.isAvailable(), isTrue);

    when(() => deviceService.isConnected).thenReturn(false);
    expect(await adapter.isAvailable(), isFalse);
  });

  test('start() initializes the underlying device service', () async {
    when(() => deviceService.initialize()).thenAnswer((_) async {});

    await adapter.start(context);

    verify(() => deviceService.initialize()).called(1);
  });

  test('stop() disconnects the underlying device service', () async {
    when(() => deviceService.disconnect()).thenAnswer((_) async {});

    await adapter.stop();

    verify(() => deviceService.disconnect()).called(1);
  });

  test(
    'captureForClaimedIdentity emits a FingerprintScanCredential carrying the claimed identity',
    () async {
      final emitted = <FingerprintScanCredential>[];
      adapter.credentials.listen(
        (c) => emitted.add(c as FingerprintScanCredential),
      );

      await adapter.captureForClaimedIdentity(
        claimedIdentityId: 'student-1',
        claimedIdentityType: 'student',
        deviceId: 'device-1',
      );
      await Future.delayed(Duration.zero);

      expect(emitted, hasLength(1));
      expect(emitted.single.claimedIdentityId, 'student-1');
      expect(emitted.single.claimedIdentityType, 'student');
    },
  );
}
