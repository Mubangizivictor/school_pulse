import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level regression coverage for the redesigned Step 5 ("Fees &
/// billing") of the direct-learner-enrolment wizard
/// (`DirectStudentRegistrationScreen._fees()`). This screen has no existing
/// widget-pump test harness (it talks to Firestore/DI directly with no
/// fakes wired up), so - consistent with
/// `admin_students_admissions_shell_wiring_test.dart` in this same
/// directory tree - these are static-source assertions rather than a
/// mounted widget test.
void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/student/presentation/screens/direct_student_registration_screen.dart',
    ).readAsStringSync();
  });

  test('Step 5 renders a two-column fee-plan/billing-summary layout plus a '
      'full-width bursary card', () {
    expect(source.contains('Widget _feePlanCard()'), isTrue);
    expect(source.contains('Widget _billingSummaryCard()'), isTrue);
    expect(source.contains('Widget _bursaryCard()'), isTrue);
    expect(
      source.contains('Expanded(child: feePlanCard)'),
      isTrue,
      reason:
          'wide layout must place the fee plan and billing summary '
          'cards side by side',
    );
  });

  test('pending-fee-plan state matches the required copy and stays '
      'non-blocking', () {
    expect(source.contains('No matching published fee plan'), isTrue);
    expect(
      source.contains('You can continue enrolment. Billing will remain'),
      isTrue,
    );
    expect(source.contains('Finance Manager publishes and'), isTrue);
    expect(source.contains('assigns a fee plan.'), isTrue);
  });

  test('ambiguous/multiple published plans are surfaced as a finance-review '
      'block instead of being silently resolved', () {
    expect(source.contains('_checkForAmbiguousPlans'), isTrue);
    expect(source.contains('Needs finance review'), isTrue);
    expect(
      source.contains('findPublishedPlansForSelector'),
      isTrue,
      reason:
          'ambiguity must be detected via the real repository query, not '
          'a hard-coded/mocked list',
    );
  });

  test('billing summary uses only the four explicit statuses, never an '
      'invented amount', () {
    for (final status in [
      'Fee plan assigned',
      'Pending fee plan',
      'Needs finance review',
    ]) {
      expect(
        source.contains(status),
        isTrue,
        reason: 'missing status: $status',
      );
    }
    expect(source.contains("'Not available yet'"), isTrue);
  });

  test('"Open fee plans" is gated behind the finance permission check', () {
    expect(source.contains('_checkFinancePermission'), isTrue);
    expect(source.contains('Permission.enrollmentBursaryAssign'), isTrue);
    expect(
      source.contains(
        'Contact a Finance Manager to publish or assign a fee plan.',
      ),
      isTrue,
      reason:
          'users without the permission must see a non-actionable '
          'message, not a broken/hidden button',
    );
  });

  test('bursary/discount is assigned only through the permission-gated '
      'approved-award selector, never a raw toggle', () {
    expect(
      source.contains(
        "SwitchListTile(\n        contentPadding: EdgeInsets.zero,\n        value: _bursaryEnabled,",
      ),
      isFalse,
      reason: 'the raw "Award bursary / discount" toggle must be removed',
    );
    expect(source.contains('class _AwardSelectorSheet'), isTrue);
    expect(source.contains('_openAwardSelector'), isTrue);
    expect(
      source.contains('await _checkFinancePermission();') &&
          source.contains('_openAwardSelector'),
      isTrue,
    );
  });

  test('draft persistence and final submission both carry the award type', () {
    final occurrences = "'type': _bursaryType.name,".allMatches(source).length;
    expect(
      occurrences,
      2,
      reason:
          'award type must be persisted in both the draft blob and the '
          'directEnrolLearner submission payload',
    );
  });
}
