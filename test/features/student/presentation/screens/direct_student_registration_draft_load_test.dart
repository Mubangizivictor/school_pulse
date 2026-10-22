import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level regression coverage for `_load()` in
/// `DirectStudentRegistrationScreen` (the "resume draft" path of the
/// direct-learner-enrolment wizard). Same source-assertion approach as
/// `direct_student_registration_fees_step_test.dart` in this directory,
/// since this screen has no mounted-widget harness.
void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/student/presentation/screens/direct_student_registration_screen.dart',
    ).readAsStringSync();
  });

  test('_load() restores guardianOverride so resuming a draft does not '
      'silently drop an active override and its justification', () {
    final loadStart = source.indexOf('void _load(');
    final loadEnd = source.indexOf('\n  }\n', loadStart);
    expect(loadStart, greaterThan(-1));
    expect(loadEnd, greaterThan(loadStart));
    final loadBody = source.substring(loadStart, loadEnd);

    expect(
      loadBody.contains("d['guardianOverride']"),
      isTrue,
      reason:
          '_load must read guardianOverride back out of the saved draft '
          "doc, mirroring the _data getter's "
          "\"'guardianOverride': _override ? {'reason': _overrideReason} "
          ": null\" write",
    );
    expect(
      loadBody.contains('_override ='),
      isTrue,
      reason: '_load must restore the _override flag from the saved draft',
    );
    expect(
      loadBody.contains('_overrideReason ='),
      isTrue,
      reason:
          '_load must restore _overrideReason from the saved draft so the '
          'justification text survives a resume',
    );
  });
}
