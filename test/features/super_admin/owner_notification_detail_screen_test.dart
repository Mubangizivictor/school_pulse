// Proves OwnerNotificationDetailScreen shows only safe, authorized data
// (masked reference, amount gated to billing category), marks a notification
// read via the injectable OwnerNotificationService on open, deep-links out
// for category-specific actions without reproducing full management here,
// and never leaks a raw exception into the SnackBar. The real screen
// depends on OwnerNotificationService (Firestore-backed, injectable for
// tests), which this fast widget-test layer doesn't set up beyond source
// inspection, so this verifies composition at the source level - the same
// approach used by billing_home_screen_test.dart. (There is already a
// companion test/features/super_admin/owner_notification_screens_test.dart
// covering other aspects of this and sibling screens - this file focuses on
// the reference-masking and category-action logic.)
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/owner_notification_detail_screen.dart',
    ).readAsStringSync();
  });

  test('the service is injectable for tests but defaults to the production OwnerNotificationService', () {
    expect(source.contains('final OwnerNotificationService? service;'), isTrue);
    expect(source.contains('widget.service ?? OwnerNotificationService()'), isTrue);
  });

  test('opening an unread notification marks it read via the real service', () {
    expect(source.contains('if (_n.isUnread) {'), isTrue);
    expect(source.contains('unawaited(_service.markRead(_n.id));'), isTrue);
  });

  test('amount is only shown for billing-category notifications - never leaked for other categories', () {
    expect(
      source.contains(
        "_n.category == OwnerNotificationCategory.billing &&\n        _n.amountUgx > 0",
      ),
      isTrue,
    );
  });

  test('reference is always masked before display, defense in depth even if already masked upstream', () {
    expect(source.contains('String _maskReference(String raw)'), isTrue);
    expect(source.contains("rows.add((label: 'Reference', value: _maskReference(_n.reference)));"), isTrue);
  });

  test('deep-link actions only navigate; they never reproduce payment/school/security management here', () {
    expect(source.contains("_openDestination('/super-admin/payments')"), isTrue);
    expect(source.contains("_openDestination('/super-admin/platform-health')"), isTrue);
    expect(source.contains("_openDestination('/super-admin/settings/security')"), isTrue);
    expect(
      source.contains('you will re-confirm owner access there'),
      isTrue,
    );
  });

  test('delete requires confirmation and clarifies it only removes from the owner feed', () {
    expect(source.contains("title: const Text('Delete this notification?')"), isTrue);
    expect(
      source.contains('It is removed from your owner feed only. The underlying record is'),
      isTrue,
    );
    expect(source.contains('_service.deleteNotification(_n.id)'), isTrue);
  });

  test('errors never leak a raw exception string to the SnackBar - the original leak site', () {
    // Regression: _friendlyError must fall back to the shared
    // friendlyErrorMessage() helper, not a raw error.toString().
    expect(source.contains('return friendlyErrorMessage(error);'), isTrue);
    expect(
      source.contains("import 'package:school_pulse/core/error/friendly_error_message.dart';"),
      isTrue,
    );
    expect(source.contains("v.replaceFirst(RegExp(r'^Exception:"), isFalse);
  });
}
