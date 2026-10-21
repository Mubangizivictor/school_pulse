// Proves Screen D (school_admin_actions_screen.dart) sources real school
// admins (SuperAdminRepository.getSchoolAdmins), routes the support session
// through the sanctioned requestSupportAccess callable rather than the
// retired owner-impersonation enterSupportMode flow, has no Delete school
// action, and requires a confirmation + reason on every lifecycle action.
// The real screen depends on SuperAdminBloc/SupportAccessService
// (Firestore/Functions), which this fast widget-test layer doesn't set up,
// so this verifies composition at the source level - the same approach
// used by the other Firebase-backed screen tests in this suite.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/school_admin_actions_screen.dart',
    ).readAsStringSync();
  });

  test(
    'admins are sourced from the real getSchoolAdmins query, not a mock list',
    () {
      expect(
        source.contains('repository.getSchoolAdmins(widget.school.id)'),
        isTrue,
      );
    },
  );

  test(
    'support session uses the sanctioned requestSupportAccess flow, not enterSupportMode',
    () {
      expect(source.contains('SupportAccessService'), isTrue);
      expect(source.contains('service.request('), isTrue);
      expect(source.contains('EnterSupportModeRequested'), isFalse);
      expect(source.contains('enterSupportMode'), isFalse);
    },
  );

  test(
    'support session requires a reason and states the 30-minute audited expiry',
    () {
      expect(source.contains('30-minute'), isTrue);
      expect(source.contains('audited'), isTrue);
      expect(
        source.contains("'Please enter a reason (min 3 characters)'"),
        isTrue,
      );
    },
  );

  test('there is no Delete school action anywhere on this screen', () {
    expect(source.contains('Delete school'), isFalse);
    expect(source.contains('Delete School'), isFalse);
    expect(source.contains('deleteSchoolDialog('), isFalse);
  });

  test(
    'suspend/reactivate/archive all require confirmation and are logged',
    () {
      expect(source.contains('confirmSchoolStatusChange'), isTrue);
      expect(source.contains('_confirmArchive'), isTrue);
      expect(source.contains('Every administrative action is logged.'), isTrue);
    },
  );

  test('archive requires a meaningful reason before dispatching', () {
    expect(source.contains('if (reason.length < 3) return;'), isTrue);
  });
}
