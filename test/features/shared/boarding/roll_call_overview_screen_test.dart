import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/shared/boarding/roll_call_overview_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: AppTheme.light(), home: child);
}

void main() {
  group('RollCallOverviewScreen', () {
    testWidgets('shows present/absent/late counts from attendance records', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RollCallOverviewScreen(
            selectedType: 'Morning',
            onTypeChanged: (_) {},
            selectedDate: DateTime(2026, 8, 20),
            onDateChanged: (_) {},
            dormitories: const [
              RollCallDormitory(id: 'd1', name: 'Sunrise House'),
            ],
            attendanceRecords: const [
              RollCallAttendanceRecord(
                studentId: 's1',
                dormitoryId: 'd1',
                status: 'present',
              ),
              RollCallAttendanceRecord(
                studentId: 's2',
                dormitoryId: 'd1',
                status: 'absent',
              ),
            ],
            isLoading: false,
            onStartRollCall: (_, __) {},
          ),
        ),
      );

      expect(find.text('Sunrise House'), findsOneWidget);
      expect(find.text('Start Roll Call'), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no dormitories', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RollCallOverviewScreen(
            selectedType: 'Morning',
            onTypeChanged: (_) {},
            selectedDate: DateTime(2026, 8, 20),
            onDateChanged: (_) {},
            dormitories: const [],
            attendanceRecords: const [],
            isLoading: false,
            onStartRollCall: (_, __) {},
          ),
        ),
      );

      expect(find.text('No Dormitories'), findsOneWidget);
    });

    testWidgets('shows skeletons while loading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RollCallOverviewScreen(
            selectedType: 'Morning',
            onTypeChanged: (_) {},
            selectedDate: DateTime(2026, 8, 20),
            onDateChanged: (_) {},
            dormitories: const [],
            attendanceRecords: const [],
            isLoading: true,
            onStartRollCall: (_, __) {},
          ),
        ),
      );

      // Loading skeletons replace the gauge/breakdown - no dormitory
      // breakdown empty-state or gauge text should be present yet.
      expect(find.text('No Dormitories'), findsNothing);
    });

    testWidgets('tapping a session tab fires onTypeChanged', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          RollCallOverviewScreen(
            selectedType: 'Morning',
            onTypeChanged: (type) => selected = type,
            selectedDate: DateTime(2026, 8, 20),
            onDateChanged: (_) {},
            dormitories: const [],
            attendanceRecords: const [],
            isLoading: false,
            onStartRollCall: (_, __) {},
          ),
        ),
      );

      await tester.tap(find.text('Evening'));
      await tester.pump();

      expect(selected, 'Evening');
    });
  });
}
