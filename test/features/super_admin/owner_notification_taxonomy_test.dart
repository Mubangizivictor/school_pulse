import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';

OwnerNotification _n(Map<String, dynamic> json) =>
    OwnerNotification.fromJson({'id': 'n', ...json});

void main() {
  group('category derivation', () {
    test('explicit category wins', () {
      expect(_n({'category': 'security'}).category,
          OwnerNotificationCategory.security);
      expect(_n({'category': 'platform_health'}).category,
          OwnerNotificationCategory.platform);
    });

    test('derives billing from a payment id', () {
      expect(_n({'paymentId': 'p1'}).category, OwnerNotificationCategory.billing);
    });

    test('derives schools from an application id', () {
      expect(_n({'applicationId': 'a1'}).category,
          OwnerNotificationCategory.schools);
    });

    test('derives platform from a health type', () {
      expect(_n({'type': 'platform_health_incident'}).category,
          OwnerNotificationCategory.platform);
    });

    test('unknown shape falls back to digest', () {
      expect(_n({'type': 'something_else'}).category,
          OwnerNotificationCategory.digest);
    });
  });

  group('severity derivation', () {
    test('a pending manual payment requires review', () {
      final n = _n({
        'category': 'billing',
        'type': 'manual_payment_pending',
        'paymentId': 'p1',
      });
      expect(n.severity, OwnerNotificationSeverity.requiresReview);
      expect(n.severity.showsOnTile, isTrue);
    });

    test(
      'an already-approved school request is information, not requires-review '
      '(even if it still carries the original applicationId)',
      () {
        final n = _n({
          'category': 'schools',
          'type': 'school_payment_method_approved',
          'applicationId': 'app_1',
        });
        expect(n.severity, OwnerNotificationSeverity.information);
        expect(n.severity.showsOnTile, isFalse);
      },
    );

    test('a new/pending school application requires review', () {
      final n = _n({
        'category': 'schools',
        'type': 'new_application_submitted',
        'applicationId': 'app_2',
      });
      expect(n.severity, OwnerNotificationSeverity.requiresReview);
    });

    test('a degraded platform event is critical', () {
      final n = _n({'category': 'platform', 'healthState': 'degraded'});
      expect(n.severity, OwnerNotificationSeverity.critical);
      expect(n.platformHealthDegraded, isTrue);
    });

    test('an operational platform event is information, green (not degraded)',
        () {
      final n = _n({'category': 'platform', 'healthState': 'operational'});
      expect(n.platformHealthDegraded, isFalse);
      expect(n.severity, OwnerNotificationSeverity.information);
      expect(n.severity.showsOnTile, isFalse);
    });

    test('a resolved notification reads RESOLVED', () {
      final n = _n({
        'category': 'billing',
        'status': 'resolved',
        'resolvedAt': DateTime.utc(2026, 9, 1).toIso8601String(),
      });
      expect(n.severity, OwnerNotificationSeverity.resolved);
    });

    test('a digest is information', () {
      expect(_n({'type': 'weekly_owner_digest'}).severity,
          OwnerNotificationSeverity.information);
    });
  });

  group('reference masking on the entity', () {
    test('an already-masked reference passes through', () {
      expect(_n({'reference': 'MOMO •••• 4821'}).reference, 'MOMO •••• 4821');
    });
  });

  test('filter labels are exactly the six chips in order', () {
    expect(
      OwnerNotificationFilter.values.map((f) => f.label).toList(),
      ['All', 'Critical', 'Billing', 'Platform', 'Schools', 'Security'],
    );
  });
}
