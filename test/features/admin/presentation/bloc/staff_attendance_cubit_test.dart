import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

class _MockRepo extends Mock implements StaffAttendanceRepository {}

class _MockGetStaffMembers extends Mock implements GetStaffMembers {}

class _MockStructureRepository extends Mock implements StructureRepository {}

UserEntity _staff(String id, {String? campusId}) => UserEntity(
  id: id,
  name: 'Staff $id',
  email: '$id@s.com',
  schoolId: 'school-a',
  roles: const [UserRole.classTeacher],
  campusId: campusId,
);

StaffAttendanceRecord _rec(
  String staffId, {
  StaffAttendanceStatus status = StaffAttendanceStatus.onTime,
  int hour = 8,
  String? campusId,
}) => StaffAttendanceRecord(
  schoolId: 'school-a',
  staffId: staffId,
  campusId: campusId,
  clockIn: DateTime(2026, 9, 1, hour, 0),
  status: status,
  location: 'Gate',
);

void main() {
  late _MockRepo repo;
  late _MockGetStaffMembers getStaff;
  late _MockStructureRepository structure;

  final today = DateTime(2026, 9, 1);

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    repo = _MockRepo();
    getStaff = _MockGetStaffMembers();
    structure = _MockStructureRepository();
    when(
      () => structure.watchCampuses(any()),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      () => repo.watchShifts(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      () => repo.watchLeaveForDay(
        schoolId: any(named: 'schoolId'),
        day: any(named: 'day'),
      ),
    ).thenAnswer((_) => Stream.value(const []));
  });

  StaffAttendanceCubit build({
    List<UserEntity>? roster,
    Failure? rosterFailure,
    List<StaffAttendanceRecord>? records,
    Object? recordsError,
  }) {
    when(() => getStaff(any())).thenAnswer(
      (_) async => rosterFailure != null
          ? Left(rosterFailure)
          : Right(roster ?? const []),
    );
    when(
      () => repo.watchDay(
        schoolId: any(named: 'schoolId'),
        day: any(named: 'day'),
        campusId: any(named: 'campusId'),
      ),
    ).thenAnswer(
      // A fresh stream per subscription - the cubit re-subscribes on
      // day/campus change.
      (_) => recordsError != null
          ? Stream<List<StaffAttendanceRecord>>.error(recordsError)
          : Stream.value(records ?? const []),
    );
    return StaffAttendanceCubit(
      repository: repo,
      getStaffMembers: getStaff,
      structureRepository: structure,
      schoolId: 'school-a',
      today: today,
    );
  }

  test('starts on today with default filters', () {
    final cubit = build();
    expect(cubit.state.day, today);
    expect(cubit.state.filter, StaffAttendanceFilter.all);
    expect(cubit.state.page, 0);
    cubit.close();
  });

  blocTest<StaffAttendanceCubit, StaffAttendanceState>(
    'init loads roster and records and clears loading flags',
    build: () =>
        build(roster: [_staff('1'), _staff('2')], records: [_rec('1')]),
    act: (c) => c.init(),
    verify: (c) {
      expect(c.state.isLoading, isFalse);
      expect(c.state.roster, hasLength(2));
      expect(c.state.records, hasLength(1));
    },
  );

  blocTest<StaffAttendanceCubit, StaffAttendanceState>(
    'roster failure surfaces as an error and an empty roster',
    build: () => build(rosterFailure: const ServerFailure('boom')),
    act: (c) => c.init(),
    verify: (c) {
      expect(c.state.error, 'boom');
      expect(c.state.roster, isEmpty);
    },
  );

  blocTest<StaffAttendanceCubit, StaffAttendanceState>(
    'a stream error marks offline for unavailable, error otherwise',
    // A non-Firebase error → generic error message, not offline.
    build: () => build(roster: [_staff('1')], recordsError: StateError('nope')),
    act: (c) => c.init(),
    verify: (c) {
      expect(c.state.isOffline, isFalse);
      expect(c.state.error, contains('Could not load'));
    },
  );

  group('derivation', () {
    test('join + status filter + pagination', () async {
      final cubit = build(
        roster: List.generate(30, (i) => _staff('$i')),
        records: [
          _rec('0', status: StaffAttendanceStatus.late),
          _rec('1'),
        ],
      );
      await cubit.init();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.filteredCount, 30);
      expect(cubit.state.pagedRows, hasLength(25));
      expect(cubit.state.pageCount, 2);

      cubit.setFilter(StaffAttendanceFilter.late);
      expect(cubit.state.filteredCount, 1);
      expect(cubit.state.pagedRows.single.staff.id, '0');

      cubit.setFilter(StaffAttendanceFilter.notClockedIn);
      expect(cubit.state.filteredCount, 28);
      await cubit.close();
    });

    test('search matches name or staff code, resets page', () async {
      final cubit = build(
        roster: [_staff('alpha'), _staff('beta'), _staff('gamma')],
        records: const [],
      );
      await cubit.init();
      await Future<void>.delayed(Duration.zero);

      cubit.setPage(0);
      cubit.setQuery('beta');
      expect(cubit.state.filteredRows.map((r) => r.staff.id), ['beta']);
      expect(cubit.state.page, 0);
      await cubit.close();
    });

    test('summary counts present/late/notClockedIn and avg clock-in', () async {
      final cubit = build(
        roster: [_staff('1'), _staff('2'), _staff('3'), _staff('4')],
        records: [
          _rec('1', hour: 8),
          _rec('2', status: StaffAttendanceStatus.late, hour: 9),
          _rec('3', status: StaffAttendanceStatus.onLeave, hour: 0),
        ],
      );
      await cubit.init();
      await Future<void>.delayed(Duration.zero);

      final s = cubit.state.summary;
      expect(s.total, 4);
      expect(s.present, 2); // onTime + late both count as present
      expect(s.late, 1);
      expect(s.onLeave, 1);
      expect(s.notClockedIn, 1); // staff 4
      expect(s.avgClockInMinutes, (8 * 60 + 9 * 60) ~/ 2); // 510
      await cubit.close();
    });

    test('campus scoping filters roster and summary', () async {
      final cubit = build(
        roster: [
          _staff('1', campusId: 'main'),
          _staff('2', campusId: 'annex'),
        ],
        records: const [],
      );
      await cubit.init();
      await Future<void>.delayed(Duration.zero);

      cubit.setCampus('main');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.filteredRows.map((r) => r.staff.id), ['1']);
      expect(cubit.state.summary.total, 1);
      await cubit.close();
    });
  });

  group('navigation', () {
    test('nextDay is a no-op on today; previousDay moves back', () async {
      final cubit = build(roster: const [], records: const []);
      await cubit.init();
      cubit.nextDay();
      expect(cubit.state.day, today);
      cubit.previousDay();
      expect(cubit.state.day, DateTime(2026, 8, 31));
      expect(cubit.canGoNext, isTrue);
      await cubit.close();
    });

    test('setDay clamps a future date to today', () async {
      final cubit = build(roster: const [], records: const []);
      await cubit.init();
      cubit.setDay(DateTime(2099, 1, 1));
      expect(cubit.state.day, today);
      await cubit.close();
    });

    test('changing day re-subscribes to records', () async {
      var subs = 0;
      final cubit = build(roster: const []);
      when(
        () => repo.watchDay(
          schoolId: any(named: 'schoolId'),
          day: any(named: 'day'),
          campusId: any(named: 'campusId'),
        ),
      ).thenAnswer((_) {
        subs++;
        return Stream.value(const []);
      });
      await cubit.init();
      final before = subs;
      cubit.previousDay();
      expect(subs, greaterThan(before));
      await cubit.close();
    });
  });

  test('fetchRange delegates to the repo with the selected campus', () async {
    final cubit = build(roster: const [], records: const []);
    await cubit.init();
    cubit.setCampus('main');
    when(
      () => repo.fetchRange(
        schoolId: any(named: 'schoolId'),
        from: any(named: 'from'),
        to: any(named: 'to'),
        campusId: any(named: 'campusId'),
      ),
    ).thenAnswer((_) async => [_rec('1')]);

    final out = await cubit.fetchRange(from: today, to: today);
    expect(out, hasLength(1));
    verify(
      () => repo.fetchRange(
        schoolId: 'school-a',
        from: today,
        to: today,
        campusId: 'main',
      ),
    ).called(1);
    await cubit.close();
  });

  group('selectStaff', () {
    test('selects then deselects on a second call with the same id', () async {
      final cubit = build(roster: const [], records: const []);
      await cubit.init();
      cubit.selectStaff('staff-1');
      expect(cubit.state.selectedStaffId, 'staff-1');
      cubit.selectStaff('staff-1');
      expect(cubit.state.selectedStaffId, isNull);
      await cubit.close();
    });
  });

  group('markAttendance', () {
    test('calls repo.clockIn and clears isSubmittingAction on success', () async {
      final cubit = build(roster: const [], records: const []);
      await cubit.init();
      when(
        () => repo.clockIn(
          schoolId: any(named: 'schoolId'),
          staffId: any(named: 'staffId'),
          day: any(named: 'day'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async {});

      final ok = await cubit.markAttendance('staff-1');
      expect(ok, isTrue);
      expect(cubit.state.isSubmittingAction, isFalse);
      expect(cubit.state.actionError, isNull);
      verify(
        () => repo.clockIn(
          schoolId: 'school-a',
          staffId: 'staff-1',
          day: today,
          location: null,
        ),
      ).called(1);
      await cubit.close();
    });

    test('surfaces actionError and clears isSubmittingAction on failure', () async {
      final cubit = build(roster: const [], records: const []);
      await cubit.init();
      when(
        () => repo.clockIn(
          schoolId: any(named: 'schoolId'),
          staffId: any(named: 'staffId'),
          day: any(named: 'day'),
          location: any(named: 'location'),
        ),
      ).thenThrow(Exception('network'));

      final ok = await cubit.markAttendance('staff-1');
      expect(ok, isFalse);
      expect(cubit.state.isSubmittingAction, isFalse);
      expect(cubit.state.actionError, isNotNull);
      await cubit.close();
    });

    test('a second call while submitting is a no-op', () async {
      final cubit = build(roster: const [], records: const []);
      await cubit.init();
      final completer = Completer<void>();
      when(
        () => repo.clockIn(
          schoolId: any(named: 'schoolId'),
          staffId: any(named: 'staffId'),
          day: any(named: 'day'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) => completer.future);

      final first = cubit.markAttendance('staff-1');
      final second = await cubit.markAttendance('staff-1');
      expect(second, isFalse);
      completer.complete();
      await first;
      verify(
        () => repo.clockIn(
          schoolId: any(named: 'schoolId'),
          staffId: any(named: 'staffId'),
          day: any(named: 'day'),
          location: any(named: 'location'),
        ),
      ).called(1);
      await cubit.close();
    });
  });
}
