import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for the "double sidebar" / "legacy sidebar" bug:
/// the admissions/enrolment routes (`/staff/admin/admissions*`) used to
/// build their screens (`AdmissionsListScreen`, `NewApplicationScreen`,
/// `DirectStudentRegistrationScreen`, `AdmissionReviewScreen`,
/// `EnrollmentSetupWizardScreen`) directly as bare top-level pages, each
/// with its own `Scaffold`/`AppBar` and no persistent sidebar - unlike every
/// other `/staff/admin/*` route, which renders through `AdminShell`.
///
/// The fix routes these builders through `AdminShell(section:
/// AdminSection.students)`; `AdminStudentsSectionBody` (rendered inside
/// that shell) resolves the live URL back to the right admission screen.
/// `AdminSection.fromLocation` already mapped every `/staff/admin/
/// admissions*` path to `AdminSection.students` (see
/// admin_section_routing_test.dart), so the sidebar's Students item stays
/// selected throughout - this test guards the other half: that the route
/// builders actually hand off to that shell instead of a bare screen.
void main() {
  late String source;

  setUpAll(() {
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test('the admissions route and every enrolment sub-route it owns are '
      'built directly from AdminShell(section: AdminSection.students)', () {
    final admissionsBlockStart = source.indexOf("path: 'admissions',");
    expect(admissionsBlockStart, greaterThan(-1));

    // The admissions route tree ends where the next sibling GoRoute under
    // the admin shell begins - 'students' immediately follows admissions.
    final admissionsBlockEnd = source.indexOf(
      "path: 'students'",
      admissionsBlockStart,
    );
    expect(admissionsBlockEnd, greaterThan(admissionsBlockStart));

    final block = source.substring(admissionsBlockStart, admissionsBlockEnd);

    // None of the legacy bare-screen builders should be constructed
    // directly from a router GoRoute builder any more.
    for (final legacyScreen in [
      'AdmissionsListScreen(',
      'NewApplicationScreen(',
      'DirectStudentRegistrationScreen(',
      'AdmissionReviewScreen(',
      'EnrollmentSetupWizardScreen(',
    ]) {
      expect(
        block.contains(legacyScreen),
        isFalse,
        reason:
            '$legacyScreen must not be built directly by a router GoRoute '
            'any more - it should render inside AdminShell via '
            'AdminStudentsSectionBody, or every admissions/enrolment '
            'screen loses the persistent sidebar.',
      );
    }

    // Every route in the admissions subtree must build the canonical shell.
    final shellBuilderCount = 'AdminShell(section: AdminSection.students)'
        .allMatches(block)
        .length;
    // new / register / review / review/enroll / the bare admissions route
    // itself = 5 GoRoutes in this subtree.
    expect(
      shellBuilderCount,
      5,
      reason:
          'expected 5 AdminShell(section: AdminSection.students) builders '
          'in the admissions subtree (admissions, new, register, review, '
          'review/enroll) - found $shellBuilderCount. If new admission/'
          'enrolment routes were added, wire them through AdminShell too.',
    );
  });

  test('AdminStudentsSectionBody dispatches every admissions path to its '
      'matching screen', () {
    final dispatcher = File(
      'lib/features/admin/presentation/shell/admin_students_section_body.dart',
    ).readAsStringSync();

    for (final entry in {
      "'/staff/admin/admissions'": 'AdmissionsListScreen',
      "'/staff/admin/admissions/new'": 'NewApplicationScreen',
      "'/staff/admin/admissions/register'": 'DirectStudentRegistrationScreen',
      "'/staff/admin/admissions/review'": 'AdmissionReviewScreen',
      "'/staff/admin/admissions/review/enroll'": 'EnrollmentSetupWizardScreen',
    }.entries) {
      expect(
        dispatcher.contains(entry.key),
        isTrue,
        reason: 'AdminStudentsSectionBody must branch on ${entry.key}',
      );
      expect(
        dispatcher.contains(entry.value),
        isTrue,
        reason:
            'AdminStudentsSectionBody must render ${entry.value} for '
            '${entry.key}',
      );
    }
  });

  test('AdminWebShell renders the students section through '
      'AdminStudentsSectionBody, not a fixed directory screen', () {
    final webShell = File(
      'lib/features/admin/presentation/shell/admin_web_shell.dart',
    ).readAsStringSync();
    expect(webShell.contains('AdminStudentsSectionBody'), isTrue);
  });
}
