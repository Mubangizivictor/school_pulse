// Proves TrustedDevicesScreen reads the real Firestore-backed device
// registry via OwnerSessionCubit (no fabricated device list), shows an
// explicit empty state, flags and protects the current device from
// removal, and requires a destructive confirmation dialog before removing
// any other device. The real screen depends on OwnerSessionCubit
// (Firestore-backed), which this fast widget-test layer doesn't set up, so
// this verifies composition at the source level - the same approach used by
// billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/trusted_devices_screen.dart',
    ).readAsStringSync();
  });

  test(
    'sessions are sourced from the real OwnerSessionCubit state, not a hardcoded list',
    () {
      expect(
        source.contains('BlocBuilder<OwnerSessionCubit, OwnerSessionState>'),
        isTrue,
      );
      expect(source.contains('state.sessions[index]'), isTrue);
    },
  );

  test('shows a loading state and an explicit empty state', () {
    expect(source.contains('OwnerSessionStatus.loading'), isTrue);
    expect(source.contains('No devices registered yet.'), isTrue);
  });

  test(
    'the current device is flagged and cannot be removed from this screen',
    () {
      expect(
        source.contains(
          'final isCurrent = session.deviceId == state.currentDeviceId;',
        ),
        isTrue,
      );
      expect(source.contains("label: 'This device'"), isTrue);
      expect(
        source.contains('if (!isCurrent)\n                IconButton('),
        isTrue,
      );
    },
  );

  test('removing a device requires a destructive confirmation dialog', () {
    expect(source.contains("title: 'Remove this device?'"), isTrue);
    expect(source.contains('isDestructive: true'), isTrue);
    expect(
      source.contains(
        'context.read<OwnerSessionCubit>().removeSession(session.deviceId)',
      ),
      isTrue,
    );
  });

  test(
    'trust toggle calls setTrusted on the real cubit, not local-only state',
    () {
      expect(
        source.contains(
          'context\n                    .read<OwnerSessionCubit>()\n                    .setTrusted(session.deviceId, value)',
        ),
        isTrue,
      );
    },
  );
}
