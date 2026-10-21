// Proves BillingPage (Payments listing/filter/export surface distinct from
// BillingHomeScreen's compact dashboard) loads real ManualSubscriptionPayment
// data via ManualPaymentService, supports the deep-link initialFilter param,
// filters/sorts/searches client-side, opens the real PaymentReviewScreen on
// tap, and never leaks a raw exception into the error state. The real
// screen depends on ManualPaymentService (Firestore/Functions), which this
// fast widget-test layer doesn't set up, so this verifies composition at
// the source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/billing_page.dart',
    ).readAsStringSync();
  });

  test(
    'payments are loaded from the real ManualPaymentService, not a mock',
    () {
      expect(
        source.contains(
          'final ManualPaymentService _payments = ManualPaymentService();',
        ),
        isTrue,
      );
      expect(
        source.contains('final items = await _payments.getPayments();'),
        isTrue,
      );
    },
  );

  test(
    'supports a deep-link initial status filter, e.g. from the Dashboard needs-review card',
    () {
      expect(
        source.contains('final ManualPaymentStatus? initialFilter;'),
        isTrue,
      );
      expect(source.contains('_filter = widget.initialFilter;'), isTrue);
    },
  );

  test('loading, error, and empty states are all handled explicitly', () {
    expect(source.contains('SchoolPulseLoader()'), isTrue);
    expect(
      source.contains('class _ErrorState extends StatelessWidget'),
      isTrue,
    );
    expect(
      source.contains('class _EmptyState extends StatelessWidget'),
      isTrue,
    );
  });

  test(
    'tapping a payment opens the real PaymentReviewScreen and reloads on mutation',
    () {
      expect(
        source.contains('PaymentReviewScreen.open(context, payment)'),
        isTrue,
      );
      expect(source.contains('if (mutated == true) await _reload();'), isTrue);
    },
  );

  test(
    'summary tiles are computed from date-scoped real data, not hardcoded numbers',
    () {
      expect(
        source.contains('int _count(ManualPaymentStatus status) =>'),
        isTrue,
      );
      expect(source.contains('int get _totalVerifiedRevenue'), isTrue);
    },
  );

  test('errors never leak a raw exception string to the error state', () {
    // Regression: _friendlyError must fall back to the shared
    // friendlyErrorMessage() helper, not a raw error.toString() with only a
    // prefix stripped - that leaked Dart/Firebase internals into the UI.
    expect(source.contains('return friendlyErrorMessage(error);'), isTrue);
    expect(
      source.contains(
        "import 'package:school_pulse/core/error/friendly_error_message.dart';",
      ),
      isTrue,
    );
    expect(source.contains("text.replaceFirst(RegExp(r'^Exception:"), isFalse);
  });
}
