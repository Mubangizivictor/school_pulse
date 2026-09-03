// Proves OwnerNotificationHistoryScreen streams the same realtime
// super_admin_notifications feed as the main notifications screen
// (unbounded, date-grouped), applies the same six owner filter chips, and
// routes into the real OwnerNotificationDetailScreen carrying the same
// service instance. The real screen depends on OwnerNotificationService
// (Firestore-backed, injectable for tests), which this fast widget-test
// layer doesn't set up beyond source inspection, so this verifies
// composition at the source level - the same approach used by
// billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/owner_notification_history_screen.dart',
    ).readAsStringSync();
  });

  test('the service is injectable for tests but defaults to the production OwnerNotificationService', () {
    expect(source.contains('final OwnerNotificationService? service;'), isTrue);
    expect(source.contains('widget.service ?? OwnerNotificationService()'), isTrue);
  });

  test('notifications are streamed live from the real service, not fetched once', () {
    expect(source.contains('_service.watchNotifications()'), isTrue);
    expect(source.contains('StreamBuilder<List<OwnerNotification>>'), isTrue);
  });

  test('supports all six owner filter chips (all/critical/billing/platform/schools/security)', () {
    expect(source.contains('OwnerNotificationFilter.all'), isTrue);
    expect(source.contains('OwnerNotificationFilter.critical'), isTrue);
    expect(source.contains('OwnerNotificationFilter.billing'), isTrue);
    expect(source.contains('OwnerNotificationFilter.platform'), isTrue);
    expect(source.contains('OwnerNotificationFilter.schools'), isTrue);
    expect(source.contains('OwnerNotificationFilter.security'), isTrue);
  });

  test('critical filter includes both critical and requiresReview severities', () {
    expect(
      source.contains(
        'n.severity == OwnerNotificationSeverity.critical ||\n            n.severity == OwnerNotificationSeverity.requiresReview',
      ),
      isTrue,
    );
  });

  test('results are grouped by day with Today/Yesterday/weekday/full-date labels', () {
    expect(source.contains("if (diff == 0) return 'Today';"), isTrue);
    expect(source.contains("if (diff == 1) return 'Yesterday';"), isTrue);
    expect(source.contains("DateFormat('EEEE').format(date)"), isTrue);
  });

  test('an empty filtered result shows an explicit empty state naming the active filter', () {
    expect(source.contains("'Nothing in \${_filter.label} yet.'"), isTrue);
  });

  test('tapping a notification opens the real detail screen, carrying the same service instance', () {
    expect(source.contains('OwnerNotificationDetailScreen(\n                                  notification: n,\n                                  service: _service,'), isTrue);
  });

  test('mark-read/archive/delete all go through the real service, not local-only state', () {
    expect(source.contains('onMarkRead: n.isUnread\n                                ? () => _service.markRead(n.id)'), isTrue);
    expect(source.contains('onArchive: () =>\n                                _service.archiveNotification(n.id)'), isTrue);
    expect(source.contains('onDelete: () =>\n                                _service.deleteNotification(n.id)'), isTrue);
  });
}
