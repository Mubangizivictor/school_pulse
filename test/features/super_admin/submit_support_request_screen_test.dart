// Proves SubmitSupportRequestScreen serves both "Report a Problem" and
// "Submit a Request" from the exact same underlying form (only the origin
// tag and on-screen copy differ), requires subject/description before
// submitting, guards unsaved edits, and (this is a second raw-error-leak
// bug found and fixed while writing this test, alongside the fix already
// applied earlier in this session) never interpolates a raw caught
// exception into the visible error text. The real screen constructs a
// SupportTicketService (Firestore-backed) eagerly in State's field
// initializer, which throws without Firebase.initializeApp() even before
// any network call happens - so pumpWidget cannot render this screen at
// all in this fast widget-test layer without full Firebase setup. This
// verifies composition at the source level instead - the same approach
// used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/submit_support_request_screen.dart',
    ).readAsStringSync();
  });

  test('both entry points share the same form/flow; only origin tag and copy differ', () {
    expect(source.contains("_isReportProblem => widget.args.origin == 'report_problem'"), isTrue);
    expect(
      source.contains(
        "_isReportProblem ? 'Report a Problem' : 'Submit a Request'",
      ),
      isTrue,
    );
  });

  test('unsaved edits are guarded before navigating away', () {
    expect(source.contains('SuperAdminUnsavedChangesGuard('), isTrue);
    expect(source.contains('hasUnsavedChanges: _dirty && !_submitting'), isTrue);
  });

  test('submission creates a real ticket via SupportTicketService, then navigates to the conversation', () {
    expect(source.contains('_service.createTicket('), isTrue);
    expect(
      source.contains("context.pushReplacement('/super-admin/settings/support/ticket/\$ticketId')"),
      isTrue,
    );
  });

  test('errors never interpolate a raw caught exception into the visible error text', () {
    // Regression: this screen originally did
    // `_error = 'Could not submit this ticket. Please try again.\n\$e';`
    // which rendered a raw Dart/Firebase exception string directly to the
    // owner. Fixed to use the shared friendlyErrorMessage() helper.
    expect(source.contains(r"'\n$e'"), isFalse);
    expect(source.contains('friendlyErrorMessage(\n          e,'), isTrue);
    expect(
      source.contains("import 'package:school_pulse/core/error/friendly_error_message.dart';"),
      isTrue,
    );
  });

  test('form requires both subject and description before submitting', () {
    expect(source.contains("? 'Subject is required'"), isTrue);
    expect(source.contains("? 'Description is required'"), isTrue);
    expect(source.contains('if (!_formKey.currentState!.validate()) return;'), isTrue);
  });

  test('priority selector offers Low/Medium/High, defaulting to Medium', () {
    expect(source.contains('SupportTicketPriority _priority = SupportTicketPriority.medium;'), isTrue);
    expect(source.contains("value: SupportTicketPriority.low,\n                      label: Text('Low')"), isTrue);
    expect(source.contains("value: SupportTicketPriority.high,\n                      label: Text('High')"), isTrue);
  });
}
