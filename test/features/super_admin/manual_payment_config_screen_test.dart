// Proves ManualPaymentConfigScreen (owner-editable MTN/Airtel/bank/cash
// payment method configuration) reads/writes exclusively through the
// owner-scoped getManualPaymentConfig / updateManualPaymentConfig Cloud
// Functions, guards unsaved edits with SuperAdminUnsavedChangesGuard, and
// never leaks a raw exception into the visible error text. The real screen
// depends on FirebaseFunctions, which this fast widget-test layer doesn't
// set up (no Firebase.initializeApp), so this verifies composition at the
// source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/manual_payment_config_screen.dart',
    ).readAsStringSync();
  });

  test(
    'loads and saves only through the owner-scoped callables, never a direct Firestore write',
    () {
      expect(
        source.contains("httpsCallable('getManualPaymentConfig')"),
        isTrue,
      );
      expect(
        source.contains("httpsCallable('updateManualPaymentConfig')"),
        isTrue,
      );
      expect(source.contains('FirebaseFirestore'), isFalse);
    },
  );

  test('exposes all four provider cards: MTN, Airtel, Bank, Cash', () {
    expect(source.contains("title: 'MTN Mobile Money'"), isTrue);
    expect(source.contains("title: 'Airtel Money'"), isTrue);
    expect(source.contains("title: 'Bank Transfer'"), isTrue);
    expect(source.contains("title: 'Cash'"), isTrue);
  });

  test('unsaved edits are guarded before navigating away', () {
    expect(source.contains('SuperAdminUnsavedChangesGuard('), isTrue);
    expect(
      source.contains('hasUnsavedChanges: _hasUnsavedChanges && !_saving'),
      isTrue,
    );
  });

  test('loading state renders a loader, not a blank screen', () {
    expect(source.contains('SchoolPulseLoader()'), isTrue);
  });

  test('Save Changes button is present and disabled while saving', () {
    expect(
      source.contains("Text(_saving ? 'Saving…' : 'Save Changes')"),
      isTrue,
    );
    expect(source.contains('onPressed: _saving ? null : _save'), isTrue);
  });

  test('errors never leak a raw exception string to the UI', () {
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
