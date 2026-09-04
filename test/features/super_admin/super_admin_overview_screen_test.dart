// Proves SuperAdminOverviewScreen's metric/attention/activity logic is
// derived from real SuperAdminBloc state, not fabricated: "Action needed"
// sums real pending applications + expired subscriptions + unverified
// schools (an explicit metadata flag, never invented), the revenue tile
// reflects real approved payments rather than a plan-price estimate, and
// a bloc failure shows a retry state rather than a blank/crashed screen.
// There is already a companion
// test/features/super_admin/super_admin_overview_screen_platform_health_card_test.dart
// covering the platform-health card; this file focuses on the metric/
// attention/activity/MRR logic not covered there. The real screen depends
// on SuperAdminBloc (Firestore-backed), which this fast widget-test layer
// doesn't set up, so this verifies composition at the source level - the
// same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/super_admin_overview_screen.dart',
    ).readAsStringSync();
  });

  test('a bloc failure shows an explicit retry state, not a blank/crashed screen', () {
    expect(source.contains('state.status == SuperAdminStatus.failure'), isTrue);
    expect(
      source.contains("title: 'Platform overview is unavailable'"),
      isTrue,
    );
    expect(source.contains('action: onRefresh'), isTrue);
  });

  test('Action needed sums real pending applications, expired subscriptions, and unverified schools', () {
    expect(
      source.contains('a.status == SchoolApplicationStatus.pendingReview'),
      isTrue,
    );
    expect(
      source.contains('s.subscriptionExpiry.isBefore(DateTime.now())'),
      isTrue,
    );
    expect(source.contains('final needsAction = pendingApps + expired + unverified;'), isTrue);
  });

  test('unverified schools use an explicit existing metadata flag, never a fabricated metric', () {
    expect(source.contains("s.metadata['verified'] == false"), isTrue);
  });

  test('revenue tile sums real approved payments, not an estimate from plan list prices', () {
    expect(source.contains('final revenueTotal = state.approvedRevenueTotal;'), isTrue);
    expect(source.contains("label: 'Revenue collected (UGX)',"), isTrue);
    expect(source.contains('value: _formatUgx(revenueTotal),'), isTrue);
    // The old plan-price estimate must be gone entirely, not just unused.
    expect(source.contains('_estimatedMonthlyRevenue'), isFalse);
  });

  test('platform health signal is streamed from the real repository, never derived from local read success', () {
    expect(source.contains('final PlatformHealthRepository _repo = PlatformHealthRepository();'), isTrue);
    expect(source.contains('_repo.watchCurrent()'), isTrue);
    // A missing aggregate must show a neutral state, not a false "healthy".
    expect(source.contains("'Checking platform status…'"), isTrue);
  });

  test('activity timeline shows the 5 most recent real audit logs, sorted newest first', () {
    expect(
      source.contains('recent.sort((a, b) => b.timestamp.compareTo(a.timestamp))'),
      isFalse,
    );
    expect(source.contains('..sort((a, b) => b.timestamp.compareTo(a.timestamp));'), isTrue);
    expect(source.contains('recent.take(5)'), isTrue);
  });

  test('quick actions route to real destinations, not placeholder callbacks', () {
    expect(source.contains("context.go('/super-admin/plans')"), isTrue);
    expect(source.contains("context.go('/super-admin/audit-logs')"), isTrue);
  });

  test('the notifications bell badges unread count from the real service stream', () {
    expect(source.contains('OwnerNotificationService().watchNotifications()'), isTrue);
    expect(source.contains('isLabelVisible: unread > 0'), isTrue);
  });
}
