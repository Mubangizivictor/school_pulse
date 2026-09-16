import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/pulse_table.dart';
import 'package:school_pulse/features/admin/admin_staff_attendance_screen.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

class _MockCubit extends MockCubit<StaffAttendanceState>
    implements StaffAttendanceCubit {}

UserEntity _user(List<UserRole> roles) => UserEntity(
  id: 'u1',
  name: 'Viewer',
  email: 'v@s.com',
  schoolId: 'school-a',
  roles: roles,
);

UserEntity _staff(String id) => UserEntity(
  id: id,
  name: 'Staff $id',
  email: '$id@s.com',
  schoolId: 'school-a',
  roles: const [UserRole.classTeacher],
);

StaffAttendanceRecord _rec(String id, StaffAttendanceStatus status) =>
    StaffAttendanceRecord(
      schoolId: 'school-a',
      staffId: id,
      clockIn: DateTime(2026, 9, 1, 8, 10),
      status: status,
      location: 'Main campus',
    );

void main() {
  late _MockCubit cubit;
  final day = DateTime(2026, 9, 1);

  setUpAll(() {
    registerFallbackValue(StaffAttendanceFilter.all);
  });

  setUp(() {
    cubit = _MockCubit();
    when(() => cubit.canGoNext).thenReturn(true);
    when(() => cubit.retry()).thenAnswer((_) async {});
    when(cubit.previousDay).thenReturn(null);
    when(cubit.nextDay).thenReturn(null);
    when(cubit.goToToday).thenReturn(null);
    when(() => cubit.setQuery(any())).thenReturn(null);
    when(() => cubit.setCampus(any())).thenReturn(null);
    when(() => cubit.setFilter(any())).thenReturn(null);
    when(() => cubit.setPage(any())).thenReturn(null);
    when(cubit.previousPage).thenReturn(null);
    when(cubit.nextPage).thenReturn(null);
    when(() => cubit.selectStaff(any())).thenReturn(null);
  });

  StaffAttendanceState stateWith({
    List<UserEntity> roster = const [],
    List<StaffAttendanceRecord> records = const [],
    bool isLoadingRoster = false,
    bool isLoadingRecords = false,
    String? error,
    bool isOffline = false,
    String? selectedStaffId,
  }) {
    return StaffAttendanceState(
      day: day,
      roster: roster,
      records: records,
      isLoadingRoster: isLoadingRoster,
      isLoadingRecords: isLoadingRecords,
      error: error,
      isOffline: isOffline,
      selectedStaffId: selectedStaffId,
    );
  }

  // MediaQuery alone does not affect actual layout constraints (LayoutBuilder
  // reads the real test viewport, not an injected MediaQueryData) - callers
  // that need a specific width must additionally set tester.view.physicalSize
  // (see setViewSize below).
  Widget pump(UserEntity user, StaffAttendanceState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      Stream<StaffAttendanceState>.empty(),
      initialState: state,
    );
    return MaterialApp(
      theme: AppTheme.light(),
      home: BlocProvider<StaffAttendanceCubit>.value(
        value: cubit,
        child: StaffAttendanceView(user: user),
      ),
    );
  }

  void setViewSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders summary cards and the attendance table', (tester) async {
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(
          roster: [_staff('1'), _staff('2')],
          records: [_rec('1', StaffAttendanceStatus.onTime)],
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Present now'), findsOneWidget);
    expect(find.text('Late arrivals'), findsOneWidget);
    expect(find.text('Not clocked in'), findsOneWidget);
    expect(find.text('Average clock-in'), findsOneWidget);
    expect(find.byType(PulseTable<StaffAttendanceRow>), findsOneWidget);
    expect(find.text('Staff 1'), findsOneWidget);
  });

  testWidgets('shows a skeleton while loading with no records', (tester) async {
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(isLoadingRoster: true, isLoadingRecords: true),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Present now'), findsNothing);
  });

  testWidgets('shows an error state with Retry that calls the cubit', (
    tester,
  ) async {
    when(() => cubit.retry()).thenAnswer((_) async {});
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(error: 'Could not load attendance. Pull to retry.'),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Could not load attendance'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    verify(() => cubit.retry()).called(1);
  });

  testWidgets('Export button is hidden for a non-manager role', (tester) async {
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.deputyHead]),
        stateWith(roster: [_staff('1')]),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.file_download_outlined), findsNothing);
  });

  testWidgets('Export button is shown for an HR officer', (tester) async {
    await tester.pumpWidget(
      pump(_user(const [UserRole.hrOfficer]), stateWith(roster: [_staff('1')])),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
  });

  testWidgets('correction action is hidden for a deputy head (view only)', (
    tester,
  ) async {
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.deputyHead]),
        stateWith(
          roster: [_staff('1')],
          records: [_rec('1', StaffAttendanceStatus.onTime)],
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('correction action is shown for a school admin', (tester) async {
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(
          roster: [_staff('1')],
          records: [_rec('1', StaffAttendanceStatus.onTime)],
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('offline banner shows when the cubit reports offline', (
    tester,
  ) async {
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(roster: [_staff('1')], isOffline: true),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Offline'), findsOneWidget);
  });

  testWidgets(
    'not-clocked-in status uses the error/red semantic, not a muted outline',
    (tester) async {
      await tester.pumpWidget(
        pump(
          _user(const [UserRole.schoolAdmin]),
          stateWith(roster: [_staff('1')]),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      final context = tester.element(find.byType(StaffAttendanceView));
      final theme = Theme.of(context);
      final semantic = theme.extension<SemanticColors>()!;

      final badgeFinder = find.text('NOT CLOCKED IN');
      expect(badgeFinder, findsWidgets);
      final badge = tester.widget<Text>(badgeFinder.first);
      expect(badge.style?.color, theme.colorScheme.error);
      expect(badge.style?.color, isNot(semantic.success));
      expect(badge.style?.color, isNot(theme.colorScheme.outline));
    },
  );

  testWidgets('empty roster shows the "No staff yet" state', (tester) async {
    await tester.pumpWidget(
      pump(_user(const [UserRole.schoolAdmin]), stateWith()),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('No staff yet'), findsOneWidget);
  });

  testWidgets(
    'wide layout shows the "No staff selected" prompt when nothing is selected',
    (tester) async {
      setViewSize(tester, const Size(1440, 960));
      await tester.pumpWidget(
        pump(
          _user(const [UserRole.schoolAdmin]),
          stateWith(
            roster: [_staff('1')],
            records: [_rec('1', StaffAttendanceStatus.onTime)],
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('No staff selected'), findsOneWidget);
    },
  );

  testWidgets('wide layout shows staff details after selecting a row', (
    tester,
  ) async {
    setViewSize(tester, const Size(1440, 960));
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(
          roster: [_staff('1')],
          records: [_rec('1', StaffAttendanceStatus.onTime)],
          selectedStaffId: '1',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Staff details'), findsOneWidget);
    expect(find.text('No staff selected'), findsNothing);
  });

  testWidgets('below 1080w the log renders without a detail panel', (
    tester,
  ) async {
    setViewSize(tester, const Size(1024, 800));
    await tester.pumpWidget(
      pump(
        _user(const [UserRole.schoolAdmin]),
        stateWith(
          roster: [_staff('1')],
          records: [_rec('1', StaffAttendanceStatus.onTime)],
          selectedStaffId: '1',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Staff details'), findsNothing);
    expect(find.text('No staff selected'), findsNothing);
  });

  for (final size in const [
    Size(360, 780),
    Size(414, 896),
    Size(768, 1024),
    Size(1024, 800),
    Size(1440, 960),
  ]) {
    testWidgets('no overflow at ${size.width.toInt()}w', (tester) async {
      setViewSize(tester, size);
      await tester.pumpWidget(
        pump(
          _user(const [UserRole.schoolAdmin]),
          stateWith(
            roster: List.generate(6, (i) => _staff('$i')),
            records: [
              _rec('0', StaffAttendanceStatus.late),
              _rec('1', StaffAttendanceStatus.onTime),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }
}
