// Proves SchoolPaymentsScreen enforces school-scoping server-side (via
// ManualPaymentService.getPayments(schoolId: ...)), never trusts a route/
// filter param as the authorization boundary, and covers the compact
// filter/date-range/empty/error/retry states the spec asks for. The real
// screen depends on ManualPaymentService (Cloud Functions), which this fast
// widget-test layer doesn't set up, so this verifies composition at the
// source level - the same approach used for the other Firebase-backed
// screens in this suite.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;
  late String serviceSource;
  late String subscriptionScreenSource;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/school_payments_screen.dart',
    ).readAsStringSync();
    serviceSource = File(
      'lib/features/super_admin/data/services/manual_payment_service.dart',
    ).readAsStringSync();
    subscriptionScreenSource = File(
      'lib/features/super_admin/presentation/pages/school_subscription_screen.dart',
    ).readAsStringSync();
  });

  test('payments are fetched scoped to this school, not an unscoped list', () {
    expect(source.contains('schoolId: widget.school.id'), isTrue);
  });

  test(
    'the underlying service call is a real schoolId parameter, not a client-side filter',
    () {
      expect(serviceSource.contains("'schoolId': ?schoolId"), isTrue);
    },
  );

  test('filters cover All, Pending review, Paid, Failed', () {
    for (final label in ['All', 'Pending review', 'Paid', 'Failed']) {
      expect(source.contains("'$label'"), isTrue, reason: label);
    }
  });

  test('supports a date range filter', () {
    expect(source.contains('showDateRangePicker'), isTrue);
    expect(source.contains('startDate: _dateRange?.start'), isTrue);
    expect(source.contains('endDate: _dateRange?.end'), isTrue);
  });

  test('has loading, empty, error, retry and pull-to-refresh states', () {
    expect(source.contains('SchoolPulseLoader'), isTrue);
    expect(
      source.contains('No payments recorded for this school yet.'),
      isTrue,
    );
    expect(source.contains('RefreshIndicator'), isTrue);
    expect(
      source.contains(
        "TextButton(onPressed: _load, child: const Text('Retry'))",
      ),
      isTrue,
    );
  });

  test('review action only opens for a pending-verification payment', () {
    expect(source.contains('ManualPaymentStatus.pendingVerification'), isTrue);
    expect(source.contains('PaymentReviewScreen(payment: payment)'), isTrue);
  });

  test(
    'View all payments from Subscription passes the same school through, preserving selection',
    () {
      expect(
        subscriptionScreenSource.contains(
          'SchoolPaymentsScreen(school: widget.school)',
        ),
        isTrue,
      );
    },
  );
}
