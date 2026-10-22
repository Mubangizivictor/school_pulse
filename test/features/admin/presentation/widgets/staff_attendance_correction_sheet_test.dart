import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';
import 'package:school_pulse/features/admin/presentation/widgets/staff_attendance_correction_sheet.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class _MockCubit extends MockCubit<StaffAttendanceState>
    implements StaffAttendanceCubit {}

void main() {
  late _MockCubit cubit;
  final day = DateTime(2026, 9, 16);
  final staff = UserEntity(
    id: 'staff-1',
    name: 'Alex Kato',
    email: 'a@s.com',
    schoolId: 'school-a',
    roles: const [UserRole.classTeacher],
  );
  final row = StaffAttendanceRow(
    staff: staff,
    record: StaffAttendanceRecord(
      schoolId: 'school-a',
      staffId: 'staff-1',
      clockIn: DateTime(2026, 9, 16, 8, 10),
      status: StaffAttendanceStatus.late,
      location: 'Main Gate',
    ),
  );

  setUp(() {
    cubit = _MockCubit();
    when(
      () => cubit.state,
    ).thenReturn(StaffAttendanceState(day: DateTime(2026)));
  });

  Widget pump() {
    return MaterialApp(
      home: Scaffold(
        body: StaffAttendanceCorrectionSheet(
          cubit: cubit,
          schoolId: 'school-a',
          day: day,
          row: row,
        ),
      ),
    );
  }

  testWidgets('a reason is required before submitting', (tester) async {
    await tester.pumpWidget(pump());
    await tester.tap(find.widgetWithText(FilledButton, 'Save correction'));
    await tester.pump();

    expect(find.text('A reason is required.'), findsOneWidget);
    verifyNever(
      () => cubit.submitCorrection(
        staffId: any(named: 'staffId'),
        day: any(named: 'day'),
        reason: any(named: 'reason'),
        patch: any(named: 'patch'),
      ),
    );
  });

  testWidgets(
    'submitting with a reason calls cubit.submitCorrection and pops with true when applied immediately',
    (tester) async {
      when(
        () => cubit.submitCorrection(
          staffId: any(named: 'staffId'),
          day: any(named: 'day'),
          reason: any(named: 'reason'),
          patch: any(named: 'patch'),
        ),
      ).thenAnswer((_) async => false);

      await tester.pumpWidget(pump());
      await tester.enterText(
        find.widgetWithText(TextField, 'Reason (required)'),
        'Forgot to clock out',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save correction'));
      await tester.pumpAndSettle();

      verify(
        () => cubit.submitCorrection(
          staffId: 'staff-1',
          day: day,
          reason: 'Forgot to clock out',
          patch: any(named: 'patch'),
        ),
      ).called(1);
    },
  );

  testWidgets('a submission failure surfaces an inline error, not a crash', (
    tester,
  ) async {
    when(
      () => cubit.submitCorrection(
        staffId: any(named: 'staffId'),
        day: any(named: 'day'),
        reason: any(named: 'reason'),
        patch: any(named: 'patch'),
      ),
    ).thenThrow(Exception('boom'));

    await tester.pumpWidget(pump());
    await tester.enterText(
      find.widgetWithText(TextField, 'Reason (required)'),
      'Forgot to clock out',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save correction'));
    await tester.pump();

    expect(
      find.text('Correction failed. Check your connection and try again.'),
      findsOneWidget,
    );
  });
}
