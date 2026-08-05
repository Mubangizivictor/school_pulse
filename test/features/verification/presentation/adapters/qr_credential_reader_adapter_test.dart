import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/presentation/adapters/qr_credential_reader_adapter.dart';

void main() {
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

  test('submitRawPayload is a no-op before start() has been called', () async {
    final adapter = QrCredentialReaderAdapter();
    final emitted = <String>[];
    adapter.credentials.listen(
      (c) => emitted.add((c as QrScanCredential).rawPayload),
    );

    adapter.submitRawPayload('SP-0001');
    await Future.delayed(Duration.zero);

    expect(emitted, isEmpty);
    adapter.dispose();
  });

  test(
    'emits a QrScanCredential for each payload submitted while active',
    () async {
      final adapter = QrCredentialReaderAdapter();
      final emitted = <String>[];
      adapter.credentials.listen(
        (c) => emitted.add((c as QrScanCredential).rawPayload),
      );

      await adapter.start(context);
      adapter.submitRawPayload('SP-0001');
      adapter.submitRawPayload('SP-0002');
      await Future.delayed(Duration.zero);

      expect(emitted, ['SP-0001', 'SP-0002']);
      adapter.dispose();
    },
  );

  test('stops emitting once stop() has been called', () async {
    final adapter = QrCredentialReaderAdapter();
    final emitted = <String>[];
    adapter.credentials.listen(
      (c) => emitted.add((c as QrScanCredential).rawPayload),
    );

    await adapter.start(context);
    await adapter.stop();
    adapter.submitRawPayload('SP-0001');
    await Future.delayed(Duration.zero);

    expect(emitted, isEmpty);
    adapter.dispose();
  });

  test(
    'isAvailable is always true (camera capture handled by the shell UI, not this adapter)',
    () async {
      final adapter = QrCredentialReaderAdapter();
      expect(await adapter.isAvailable(), isTrue);
      adapter.dispose();
    },
  );
}
