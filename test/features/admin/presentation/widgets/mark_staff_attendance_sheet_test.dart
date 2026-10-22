import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';
import 'package:school_pulse/features/admin/presentation/widgets/mark_staff_attendance_sheet.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class _MockCubit extends MockCubit<StaffAttendanceState>
    implements StaffAttendanceCubit {}

void main() {
  late _MockCubit cubit;
  final staff = UserEntity(
    id: 'staff-1',
    name: 'Alex Kato',
    email: 'a@s.com',
    schoolId: 'school-a',
    roles: const [UserRole.classTeacher],
  );

  StaffAttendanceState stateWith({
    bool isSubmittingAction = false,
    String? actionError,
  }) => StaffAttendanceState(
    day: DateTime(2026, 9, 16),
    isSubmittingAction: isSubmittingAction,
    actionError: actionError,
  );

  setUp(() {
    cubit = _MockCubit();
  });

  Widget pump(StaffAttendanceState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      Stream<StaffAttendanceState>.empty(),
      initialState: state,
    );
    return MaterialApp(
      home: Scaffold(
        body: MarkStaffAttendanceSheet(cubit: cubit, staff: staff),
      ),
    );
  }

  testWidgets('submits via cubit.markAttendance with the trimmed location', (
    tester,
  ) async {
    when(
      () => cubit.markAttendance(any(), location: any(named: 'location')),
    ).thenAnswer((_) async => true);
    await tester.pumpWidget(pump(stateWith()));

    await tester.enterText(find.byType(TextField), '  Main campus  ');
    await tester.tap(find.widgetWithText(FilledButton, 'Mark attendance'));
    await tester.pump();

    verify(
      () => cubit.markAttendance('staff-1', location: 'Main campus'),
    ).called(1);
  });

  testWidgets('passes null location when the field is empty', (tester) async {
    when(
      () => cubit.markAttendance(any(), location: any(named: 'location')),
    ).thenAnswer((_) async => true);
    await tester.pumpWidget(pump(stateWith()));

    await tester.tap(find.widgetWithText(FilledButton, 'Mark attendance'));
    await tester.pump();

    verify(() => cubit.markAttendance('staff-1', location: null)).called(1);
  });

  testWidgets('shows a spinner and disables the field while submitting', (
    tester,
  ) async {
    await tester.pumpWidget(pump(stateWith(isSubmittingAction: true)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('shows actionError text when the cubit reports one', (
    tester,
  ) async {
    await tester.pumpWidget(
      pump(stateWith(actionError: 'Could not mark attendance. Try again.')),
    );

    expect(find.text('Could not mark attendance. Try again.'), findsOneWidget);
  });
}
