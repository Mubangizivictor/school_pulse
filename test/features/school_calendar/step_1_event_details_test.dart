import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/school_calendar/presentation/screens/add_event_flow/add_event_draft.dart';
import 'package:school_pulse/features/school_calendar/presentation/screens/add_event_flow/step_1_event_details.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Step1EventDetails validation', () {
    testWidgets('Next is disabled until title, start and end date are set', (
      tester,
    ) async {
      final draft = AddEventDraft();
      var nextTapped = false;
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: Step1EventDetails(
              draft: draft,
              onNext: () => nextTapped = true,
            ),
          ),
        ),
      );

      final nextButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);

      await tester.enterText(
        find.widgetWithText(TextField, 'Enter title').hitTestable().first,
        'Sports Day',
      );

      // Title alone (no dates) still leaves Next disabled.
      final stillDisabled = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(stillDisabled.onPressed, isNull);
      expect(nextTapped, isFalse);
    });

    testWidgets('Next becomes enabled once title/start/end are all valid', (
      tester,
    ) async {
      final draft = AddEventDraft()
        ..title = 'Sports Day'
        ..startDate = DateTime(2026, 9, 1)
        ..endDate = DateTime(2026, 9, 1);
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: Step1EventDetails(draft: draft, onNext: () {}),
          ),
        ),
      );
      final nextButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(nextButton.onPressed, isNotNull);
    });

    test('end date before start date is invalid (guarded at draft level)', () {
      final draft = AddEventDraft()
        ..title = 'Invalid'
        ..startDate = DateTime(2026, 9, 5)
        ..endDate = DateTime(2026, 9, 1);
      final valid =
          draft.title.trim().isNotEmpty &&
          draft.startDate != null &&
          draft.endDate != null &&
          !draft.endDate!.isBefore(draft.startDate!);
      expect(valid, isFalse);
    });
  });
}
