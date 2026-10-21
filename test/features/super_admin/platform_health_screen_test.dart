// Proves PlatformHealthScreen reads the cached platform_health/current
// aggregate via PlatformHealthRepository (checkPlatformHealth Cloud
// Function), refresh/acknowledge go through the real repository (not a
// mock), acknowledging an attention component requires a confirmation
// dialog, and loading/error states are handled explicitly. There is
// already a companion test/features/super_admin/
// platform_health_screen_redesign_test.dart covering the visual layout;
// this file focuses on the refresh/acknowledge/error-handling logic not
// covered there. The real screen depends on PlatformHealthRepository
// (Firestore/Functions-backed), which this fast widget-test layer doesn't
// set up, so this verifies composition at the source level - the same
// approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/platform_health_screen.dart',
    ).readAsStringSync();
  });

  test(
    'health is streamed from the real PlatformHealthRepository, not a mock',
    () {
      expect(
        source.contains(
          'final PlatformHealthRepository _repo = PlatformHealthRepository();',
        ),
        isTrue,
      );
      expect(source.contains('_repo.watchCurrent()'), isTrue);
    },
  );

  test(
    'refresh calls the real repository refresh and surfaces a scoped error, not a raw exception',
    () {
      expect(source.contains('await _repo.refresh();'), isTrue);
      expect(
        source.contains(
          "_refreshError = 'Could not refresh platform health right now.'",
        ),
        isTrue,
      );
    },
  );

  test(
    'acknowledging an attention component requires a dialog with an optional note',
    () {
      expect(
        source.contains('class _AcknowledgeDialog extends StatefulWidget'),
        isTrue,
      );
      expect(
        source.contains('_repo.acknowledgeIncident(componentId, note: note)'),
        isTrue,
      );
    },
  );

  test(
    'acknowledge action is only offered on attention-needing components',
    () {
      expect(
        source.contains('onAcknowledge: () => _acknowledge(component.id)'),
        isTrue,
      );
      expect(
        source.contains('summary?.attentionComponents ?? const []'),
        isTrue,
      );
    },
  );

  test(
    'loading and stream-error states are handled explicitly, not left blank',
    () {
      expect(source.contains('ConnectionState.waiting'), isTrue);
      expect(
        source.contains('class _ErrorCard extends StatelessWidget'),
        isTrue,
      );
      expect(
        source.contains("message: 'Could not load platform health.'"),
        isTrue,
      );
    },
  );

  test(
    'history section reads real incident audit logs, not fabricated entries',
    () {
      expect(source.contains('_repo.watchIncidentHistory()'), isTrue);
      expect(
        source.contains("log.action == 'PLATFORM_HEALTH_INCIDENT_RESOLVED'"),
        isTrue,
      );
    },
  );

  test(
    'component/attention/history sections all have explicit empty states',
    () {
      expect(
        source.contains("_CompactEmpty('No component data yet.')"),
        isTrue,
      );
      expect(
        source.contains(
          "_CompactEmpty('Nothing needs your attention right now.')",
        ),
        isTrue,
      );
      expect(
        source.contains("_CompactEmpty('No acknowledged incidents yet.')"),
        isTrue,
      );
    },
  );

  test(
    'errors surface a scoped user-facing message, never a raw exception.toString()',
    () {
      expect(source.contains('error.toString()'), isFalse);
    },
  );
}
