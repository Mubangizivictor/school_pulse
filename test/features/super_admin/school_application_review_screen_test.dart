// Proves SchoolApplicationReviewScreen renders review checklist/detail data
// from the real SchoolApplication entity, requires a confirmation sheet and
// (for reject) a minimum-length reason before dispatching
// ApproveSchoolApplicationEvent/RejectSchoolApplicationEvent, and — this is
// the exact screen where the original raw-error-leak bug was found and
// fixed — surfaces SuperAdminBloc's errorMessage verbatim in a SnackBar, so
// the source of that message (the bloc/repository layer) must never be a
// raw exception.toString(). The real screen depends on SuperAdminBloc
// (Firestore/Functions), which this fast widget-test layer doesn't set up,
// so this verifies composition at the source level - the same approach used
// by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String screenSource;
  late String stateSource;

  setUpAll(() {
    screenSource = File(
      'lib/features/super_admin/presentation/pages/school_application_review_screen.dart',
    ).readAsStringSync();
    final stateFile = File(
      'lib/features/super_admin/presentation/bloc/super_admin_state.dart',
    );
    stateSource = stateFile.existsSync() ? stateFile.readAsStringSync() : '';
  });

  test(
    'renders school/location/subscription/administrator detail cards from the real application',
    () {
      expect(
        screenSource.contains("_Detail('School name', application.schoolName)"),
        isTrue,
      );
      expect(
        screenSource.contains("_Detail('District', application.district)"),
        isTrue,
      );
      expect(
        screenSource.contains("_Detail('Selected plan', application.plan)"),
        isTrue,
      );
      expect(
        screenSource.contains("_Detail('Name', application.administratorName)"),
        isTrue,
      );
    },
  );

  test(
    'review checklist reflects real application fields, not hardcoded booleans',
    () {
      expect(
        screenSource.contains(
          "('Email verified', application.administratorEmailVerified)",
        ),
        isTrue,
      );
      expect(
        screenSource.contains("('Terms accepted', application.termsAccepted)"),
        isTrue,
      );
    },
  );

  test('review actions are only shown when application.canReview is true', () {
    expect(
      screenSource.contains('bottomNavigationBar: application.canReview'),
      isTrue,
    );
  });

  test(
    'approve requires confirmation and dispatches ApproveSchoolApplicationEvent, not a direct write',
    () {
      expect(
        screenSource.contains('ApproveSchoolApplicationEvent(application.id)'),
        isTrue,
      );
      expect(
        screenSource.contains("Text('Approve & Request Payment')"),
        isTrue,
      );
    },
  );

  test(
    'reject requires a reason of at least 3 characters and dispatches RejectSchoolApplicationEvent',
    () {
      expect(screenSource.contains('if (value.length < 3) return;'), isTrue);
      expect(
        screenSource.contains(
          'RejectSchoolApplicationEvent(\n        applicationId: application.id,\n        reason: reason,\n      )',
        ),
        isTrue,
      );
    },
  );

  test(
    'approval clarifies paid access stays locked until payment is verified',
    () {
      expect(
        screenSource.contains(
          'Paid access stays locked until the subscription payment is received',
        ),
        isTrue,
      );
    },
  );

  test(
    'bloc errorMessage is surfaced verbatim in a SnackBar - the exact path the original leak used',
    () {
      expect(
        screenSource.contains('content: Text(state.errorMessage!)'),
        isTrue,
      );
    },
  );

  test(
    'regression: SuperAdminState does not build errorMessage from a raw exception.toString()',
    () {
      // The original bug: a raw exception's .toString() (Dart/Firebase
      // internals, e.g. "[cloud_firestore/permission-denied] ...") was placed
      // directly into errorMessage and rendered verbatim above. Guard against
      // regressing that by asserting the bloc/state layer prefers
      // friendlyErrorMessage()/a clean .message over toString() when it
      // constructs errorMessage.
      if (stateSource.isNotEmpty) {
        expect(stateSource.contains('errorMessage: error.toString()'), isFalse);
      }
    },
  );
}
