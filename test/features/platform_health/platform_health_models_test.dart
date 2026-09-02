import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/platform_health/domain/platform_health_models.dart';

void main() {
  group('platformHealthStatusFromValue', () {
    test('maps all 5 real status strings correctly', () {
      expect(platformHealthStatusFromValue('operational'), PlatformHealthStatus.operational);
      expect(platformHealthStatusFromValue('degraded'), PlatformHealthStatus.degraded);
      expect(platformHealthStatusFromValue('outage'), PlatformHealthStatus.outage);
      expect(platformHealthStatusFromValue('not_configured'), PlatformHealthStatus.notConfigured);
      expect(platformHealthStatusFromValue('unknown'), PlatformHealthStatus.unknown);
    });

    test('an unrecognized or missing value defaults safely to unknown, never operational', () {
      expect(platformHealthStatusFromValue(null), PlatformHealthStatus.unknown);
      expect(platformHealthStatusFromValue(''), PlatformHealthStatus.unknown);
      expect(platformHealthStatusFromValue('garbage'), PlatformHealthStatus.unknown);
    });
  });

  group('PlatformHealthSummary.fromMap', () {
    test('parses a full aggregate doc with all 10 components', () {
      final summary = PlatformHealthSummary.fromMap({
        'status': 'operational',
        'summary': 'All monitored services are operational.',
        'components': {
          'auth': {'status': 'operational', 'message': 'ok'},
          'firestore': {'status': 'operational', 'message': 'ok'},
          'functions': {'status': 'operational', 'message': 'ok'},
          'storage': {'status': 'not_configured', 'message': 'No bucket.'},
          'notifications': {'status': 'operational', 'message': 'ok'},
          'scheduledJobs': {'status': 'operational', 'message': 'ok'},
          'schoolOnboarding': {'status': 'operational', 'message': 'ok'},
          'subscriptionProcessing': {'status': 'operational', 'message': 'ok'},
          'securityMonitoring': {'status': 'operational', 'message': 'ok'},
          'platformRelease': {'status': 'not_configured', 'message': 'No version metadata.'},
        },
      });
      expect(summary.status, PlatformHealthStatus.operational);
      // platformRelease is intentionally excluded from the display list.
      expect(summary.components.length, 9);
      expect(summary.components.map((c) => c.id), isNot(contains('platformRelease')));
    });

    test('attentionComponents excludes operational and notConfigured, includes degraded/outage/unknown', () {
      final summary = PlatformHealthSummary.fromMap({
        'status': 'degraded',
        'summary': '2 checks need attention.',
        'components': {
          'auth': {'status': 'operational', 'message': ''},
          'firestore': {'status': 'degraded', 'message': 'slow'},
          'functions': {'status': 'outage', 'message': 'down'},
          'storage': {'status': 'not_configured', 'message': ''},
          'notifications': {'status': 'unknown', 'message': ''},
        },
      });
      final attentionIds = summary.attentionComponents.map((c) => c.id).toSet();
      expect(attentionIds, {'firestore', 'functions', 'notifications'});
    });

    test('a missing components map produces an empty component list, not a crash', () {
      final summary = PlatformHealthSummary.fromMap({'status': 'unknown', 'summary': ''});
      expect(summary.components, isEmpty);
    });
  });

  group('platformHealthComponentLabel', () {
    test('returns the human label for every known component id', () {
      expect(platformHealthComponentLabel('auth'), 'Authentication');
      expect(platformHealthComponentLabel('scheduledJobs'), 'Scheduled jobs');
      expect(platformHealthComponentLabel('securityMonitoring'), 'Security monitoring');
    });

    test('falls back to the raw id for an unrecognized component', () {
      expect(platformHealthComponentLabel('somethingNew'), 'somethingNew');
    });
  });

  group('platformHealthRecommendedAction', () {
    test('returns a non-empty recommendation for every displayed component', () {
      for (final (id, _) in kPlatformHealthComponentOrder) {
        expect(platformHealthRecommendedAction(id), isNotNull, reason: '$id has no recommended action');
      }
    });

    test('returns null for an unrecognized component id', () {
      expect(platformHealthRecommendedAction('unknownComponent'), isNull);
    });
  });
}
