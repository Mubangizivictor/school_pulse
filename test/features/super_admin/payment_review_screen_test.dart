// Proves PaymentReviewScreen (full-page/wide-panel payment verification,
// replacing the old bottom sheet) preserves the real approve/reject/proof
// business logic, disables Approve when the submitted amount doesn't match
// the expected plan price, requires a reject reason before allowing submit,
// and never leaks a raw exception into the user-facing SnackBar. The real
// screen depends on ManualPaymentService (Cloud Functions) and url_launcher,
// which this fast widget-test layer doesn't set up, so this verifies
// composition at the source level - the same approach used for the other
// Firebase-backed screens in this suite (see billing_home_screen_test.dart).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/payment_review_screen.dart',
    ).readAsStringSync();
  });

  test('renders payment detail rows sourced from the real ManualSubscriptionPayment', () {
    expect(source.contains("label: 'School', value: payment.schoolName"), isTrue);
    expect(source.contains("label: 'Expected amount'"), isTrue);
    expect(source.contains("label: 'Submitted amount'"), isTrue);
    expect(source.contains("label: 'Reference', value: payment.reference"), isTrue);
  });

  test('Approve is disabled when the amount does not match the expected plan price', () {
    expect(
      source.contains('onPressed: (_isWorking || !payment.amountMatches)'),
      isTrue,
    );
  });

  test('Approve/Reject buttons are only shown while pending verification', () {
    expect(
      source.contains(
        'payment.status == ManualPaymentStatus.pendingVerification',
      ),
      isTrue,
    );
  });

  test('reject requires a reason of at least 3 characters before confirming', () {
    expect(source.contains('if (value.length >= 3) Navigator.pop(dialogContext, value);'), isTrue);
  });

  test('approve and reject go through ManualPaymentService, not a direct write', () {
    expect(source.contains('_payments.approve(payment.id)'), isTrue);
    expect(source.contains('_payments.reject(payment.id, reason)'), isTrue);
  });

  test('proof is opened via a fresh, time-limited secure link, not a cached URL', () {
    expect(source.contains('_payments.getProofUrl(_payment.id)'), isTrue);
    expect(source.contains('LaunchMode.externalApplication'), isTrue);
  });

  test('no proof attached shows an explicit empty state, not a blank card', () {
    expect(source.contains('No proof attached'), isTrue);
  });

  test('closing the screen reports whether a mutation happened via Navigator.pop result', () {
    expect(source.contains('Navigator.pop(context, _didMutate)'), isTrue);
    expect(source.contains('_didMutate = true;'), isTrue);
  });

  test('errors never leak a raw exception string to the SnackBar', () {
    expect(source.contains('_showSnack(_friendlyError(error), isError: true)'), isTrue);
    // Regression: _friendlyError must fall back to the shared
    // friendlyErrorMessage() helper, not a raw error.toString() with only a
    // prefix stripped - that leaked Dart/Firebase internals into the UI.
    expect(source.contains('return friendlyErrorMessage(error);'), isTrue);
    expect(
      source.contains("import 'package:school_pulse/core/error/friendly_error_message.dart';"),
      isTrue,
    );
    expect(source.contains("text.replaceFirst(RegExp(r'^Exception:"), isFalse);
  });
}
