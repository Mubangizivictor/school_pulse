import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/shared/boarding/dorm_student_roster_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: AppTheme.light(), home: child);
}

void main() {
  const students = [
    RosterStudent(id: 's1', name: 'Aiden Mwangi', attendanceStatus: 'present'),
    RosterStudent(id: 's2', name: 'Brian Ochieng', attendanceStatus: 'absent'),
    RosterStudent(id: 's3', name: 'Caleb Nsubuga', attendanceStatus: null),
  ];

  testWidgets('All tab shows every boarder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DormStudentRosterScreen(
          dormitoryName: 'Sunrise House',
          students: students,
          isLoading: false,
          onStudentTap: (_) {},
        ),
      ),
    );

    expect(find.text('Aiden Mwangi'), findsOneWidget);
    expect(find.text('Brian Ochieng'), findsOneWidget);
    expect(find.text('Caleb Nsubuga'), findsOneWidget);
  });

  testWidgets('Absent tab filters to only absent boarders', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DormStudentRosterScreen(
          dormitoryName: 'Sunrise House',
          students: students,
          isLoading: false,
          onStudentTap: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Absent'));
    await tester.pumpAndSettle();

    expect(find.text('Brian Ochieng'), findsOneWidget);
    expect(find.text('Aiden Mwangi'), findsNothing);
  });

  testWidgets(
    'a boarder with no attendance record yet counts as Present',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          DormStudentRosterScreen(
            dormitoryName: 'Sunrise House',
            students: students,
            isLoading: false,
            onStudentTap: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Present'));
      await tester.pumpAndSettle();

      expect(find.text('Aiden Mwangi'), findsOneWidget);
      expect(find.text('Caleb Nsubuga'), findsOneWidget);
      expect(find.text('Brian Ochieng'), findsNothing);
    },
  );

  testWidgets('tapping a row fires onStudentTap with the student id', (
    tester,
  ) async {
    String? tappedId;
    await tester.pumpWidget(
      _wrap(
        DormStudentRosterScreen(
          dormitoryName: 'Sunrise House',
          students: students,
          isLoading: false,
          onStudentTap: (id) => tappedId = id,
        ),
      ),
    );

    await tester.tap(find.text('Aiden Mwangi'));
    await tester.pump();

    expect(tappedId, 's1');
  });
}
