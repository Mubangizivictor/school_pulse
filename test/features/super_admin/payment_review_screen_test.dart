// Proves the payment-verification surface preserves the real
// approve/reject/proof business logic after the redesign. The shared review
// panel now lives in payment_inspector.dart (embedded as a persistent
// desktop inspector by BillingPage and as a bottom sheet / pushed page by
// PaymentReviewScreen); this test asserts the guarantees against whichever
// file now owns each piece. The real screen depends on ManualPaymentService
// (Cloud Functions) and url_launcher, which this fast widget-test layer
// doesn't set up, so this verifies composition at the source level - the same
// approach used for the other Firebase-backed screens in this suite.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String inspector;
  late String reviewScreen;

  setUpAll(() {
    inspector = File(
      'lib/features/super_admin/presentation/pages/payment_inspector.dart',
    ).readAsStringSync();
    reviewScreen = File(
      'lib/features/super_admin/presentation/pages/payment_review_screen.dart',
    ).readAsStringSync();
  });

  test('renders payment detail rows sourced from the real ManualSubscriptionPayment', () {
    expect(inspector.contains("_detail(context, 'Plan', payment.planName)"), isTrue);
    expect(inspector.contains("_detail(context, 'Expected', _money.format(payment.expectedAmount))"), isTrue);
    expect(inspector.contains("_money.format(payment.submittedAmount)"), isTrue);
    expect(inspector.contains("'Reference'"), isTrue);
    expect(inspector.contains('payment.reference'), isTrue);
  });

  test('Approve is disabled when the amount does not match the expected plan price', () {
    expect(
      inspector.contains('final canApprove = !_isWorking && payment.amountMatches;'),
      isTrue,
    );
    expect(inspector.contains('onPressed: canApprove ? _approve : null'), isTrue);
  });

  test('Approve/Reject buttons are only shown while pending verification', () {
    expect(
      inspector.contains(
        'payment.status == ManualPaymentStatus.pendingVerification',
      ),
      isTrue,
    );
  });

  test('reject requires a reason of at least 3 characters before confirming', () {
    expect(inspector.contains('if (value.length >= 3) Navigator.pop(dialogContext, value);'), isTrue);
  });

  test('approve and reject go through ManualPaymentService, not a direct write', () {
    expect(inspector.contains('_payments.approve(payment.id)'), isTrue);
    expect(inspector.contains('_payments.reject(payment.id, reason)'), isTrue);
  });

  test('every decision is confirmed and guarded against duplicate submits', () {
    // Confirmation dialog before each mutation.
    expect(inspector.contains("title: const Text('Approve payment?')"), isTrue);
    expect(inspector.contains("title: const Text('Reject payment proof')"), isTrue);
    // Duplicate-action guard: bail if a request is already in flight.
    expect(inspector.contains('if (_isWorking) return;'), isTrue);
  });

  test('proof is opened via a fresh, time-limited secure link, not a cached URL', () {
    expect(inspector.contains('_payments.getProofUrl(widget.payment.id)'), isTrue);
    expect(inspector.contains('LaunchMode.externalApplication'), isTrue);
  });

  test('no proof attached shows an explicit empty state, not a blank card', () {
    expect(inspector.contains('No proof was attached to this payment.'), isTrue);
  });

  test('closing the surface reports whether a mutation happened', () {
    // Bottom-sheet path: onMutated flips the flag returned to the caller.
    expect(reviewScreen.contains('mutated = true;'), isTrue);
    expect(reviewScreen.contains('return mutated;'), isTrue);
    // Pushed-page path: pops true on a successful decision.
    expect(reviewScreen.contains('onMutated: () => Navigator.pop(context, true)'), isTrue);
  });

  test('URL is synced to the detail path while open and back on close', () {
    expect(reviewScreen.contains("context.go(detailUrl)"), isTrue);
    expect(reviewScreen.contains("context.go(sectionUrl)"), isTrue);
  });

  test('errors never leak a raw exception string to the SnackBar', () {
    expect(inspector.contains('_showSnack(_friendlyError(error), isError: true)'), isTrue);
    // Regression: _friendlyError must fall back to the shared
    // friendlyErrorMessage() helper, not a raw error.toString() with only a
    // prefix stripped - that leaked Dart/Firebase internals into the UI.
    expect(inspector.contains('return friendlyErrorMessage(error);'), isTrue);
    expect(
      inspector.contains("import 'package:school_pulse/core/error/friendly_error_message.dart';"),
      isTrue,
    );
    expect(inspector.contains("text.replaceFirst(RegExp(r'^Exception:"), isFalse);
  });
}
