import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression coverage: the student-profile route (`/staff/admin/
/// students/:id`) and its `documents`/`identity`/`portal` sub-routes used
/// to build `AdminStudentProfileScreen`/`AdminStudentDocumentsScreen`/
/// `IdentityAndCardsScreen`/`StudentPortalCodesScreen` directly as bare
/// top-level pages, each self-scaffolding with no persistent sidebar -
/// unlike every other `/staff/admin/*` route, which renders through
/// `AdminShell`.
///
/// The fix routes these builders through `AdminShell(section:
/// AdminSection.students)`; `AdminStudentsSectionBody` (rendered inside
/// that shell) resolves the live URL/`extra` back to the right screen.
void main() {
  late String source;

  setUpAll(() {
    source = File('lib/app/router.dart').readAsStringSync();
  });

  test("the student ':id' route and its documents/identity/portal sub-routes "
      'are built directly from AdminShell(section: AdminSection.students)', () {
    final studentsBlockStart = source.indexOf("path: 'students',");
    expect(studentsBlockStart, greaterThan(-1));

    final idBlockStart = source.indexOf("path: ':id',", studentsBlockStart);
    expect(idBlockStart, greaterThan(studentsBlockStart));

    // The :id subtree ends where its sibling 'appointments' route begins.
    final idBlockEnd = source.indexOf("path: 'appointments'", idBlockStart);
    expect(idBlockEnd, greaterThan(idBlockStart));

    final block = source.substring(idBlockStart, idBlockEnd);

    for (final legacyScreen in [
      'AdminStudentProfileScreen(',
      'AdminStudentDocumentsScreen(',
      'IdentityAndCardsScreen(',
      'StudentPortalCodesScreen(',
    ]) {
      expect(
        block.contains(legacyScreen),
        isFalse,
        reason:
            '$legacyScreen must not be built directly by a router GoRoute '
            'any more - it should render inside AdminShell via '
            'AdminStudentsSectionBody, or the profile screen loses the '
            'persistent sidebar.',
      );
    }

    final shellBuilderCount = 'AdminShell(section: AdminSection.students)'
        .allMatches(block)
        .length;
    // :id itself / documents / identity / portal = 4 GoRoutes.
    expect(
      shellBuilderCount,
      4,
      reason:
          'expected 4 AdminShell(section: AdminSection.students) builders '
          'in the :id subtree (:id, documents, identity, portal) - found '
          '$shellBuilderCount.',
    );
  });

  test('AdminStudentsSectionBody dispatches every student-profile path to its '
      'matching screen', () {
    final dispatcher = File(
      'lib/features/admin/presentation/shell/admin_students_section_body.dart',
    ).readAsStringSync();

    expect(
      dispatcher.contains('AdminStudentProfileScreen'),
      isTrue,
      reason:
          'AdminStudentsSectionBody must render AdminStudentProfileScreen '
          'for /staff/admin/students/:id',
    );
    for (final entry in {
      'documents': 'AdminStudentDocumentsScreen',
      'identity': 'IdentityAndCardsScreen',
      'portal': 'StudentPortalCodesScreen',
    }.entries) {
      expect(
        dispatcher.contains("endsWith('/${entry.key}')"),
        isTrue,
        reason: 'AdminStudentsSectionBody must branch on /${entry.key}',
      );
      expect(
        dispatcher.contains(entry.value),
        isTrue,
        reason:
            'AdminStudentsSectionBody must render ${entry.value} for '
            '/${entry.key}',
      );
    }
  });
}
