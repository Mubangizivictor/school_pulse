import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

import 'staff_attendance_state.dart';

/// Drives the admin Staff Attendance dashboard. Holds the selected day,
/// campus, search, status filter and page; subscribes to the day's records
/// and re-subscribes when day/campus change. All derivation (join, filter,
/// pagination, summary) lives on [StaffAttendanceState].
class StaffAttendanceCubit extends Cubit<StaffAttendanceState> {
  StaffAttendanceCubit({
    required StaffAttendanceRepository repository,
    required GetStaffMembers getStaffMembers,
    required StructureRepository structureRepository,
    required String schoolId,
    DateTime? today,
  }) : _repo = repository,
       _getStaffMembers = getStaffMembers,
       _structure = structureRepository,
       _schoolId = schoolId,
       _today = _dateOnly(today ?? DateTime.now()),
       super(StaffAttendanceState(day: _dateOnly(today ?? DateTime.now())));

  // Named constructor args use the public vocabulary (`repository`,
  // `getStaffMembers`, ...); these private fields hold them.
  // ignore_for_file: prefer_initializing_formals
  final StaffAttendanceRepository _repo;
  final GetStaffMembers _getStaffMembers;
  final StructureRepository _structure;
  final String _schoolId;

  /// "Today" as this cubit was constructed - the upper bound for day
  /// navigation. Injectable so tests are deterministic.
  final DateTime _today;

  StreamSubscription<List<StaffAttendanceRecord>>? _recordsSub;
  StreamSubscription? _campusesSub;
  StreamSubscription? _shiftsSub;
  StreamSubscription? _leaveSub;

  String? _rosterError;
  String? _recordsError;

  String? get _combinedError => _rosterError ?? _recordsError;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _closed => isClosed;

  Future<void> init() async {
    _subscribeCampuses();
    _subscribeShifts();
    await _loadRoster();
    _subscribeRecords();
    _subscribeLeave();
  }

  void _subscribeShifts() {
    _shiftsSub?.cancel();
    _shiftsSub = _repo
        .watchShifts(schoolId: _schoolId)
        .listen(
          (shifts) {
            if (!_closed) emit(state.copyWith(shifts: shifts));
          },
          onError: (_) {
            // Shifts are an enhancement (scheduled-shift display + late
            // derivation) - a failure here shouldn't block the dashboard.
          },
        );
  }

  void _subscribeLeave() {
    _leaveSub?.cancel();
    _leaveSub = _repo
        .watchLeaveForDay(schoolId: _schoolId, day: state.day)
        .listen((leave) {
          if (!_closed) emit(state.copyWith(leave: leave));
        }, onError: (_) {});
  }

  void _subscribeCampuses() {
    _campusesSub?.cancel();
    _campusesSub = _structure
        .watchCampuses(_schoolId)
        .listen(
          (campuses) {
            if (_closed) return;
            emit(state.copyWith(campuses: campuses));
          },
          onError: (_) {
            // Campuses are optional - a failure here just means "All campuses".
            if (!_closed) emit(state.copyWith(campuses: const []));
          },
        );
  }

  Future<void> _loadRoster() async {
    emit(state.copyWith(isLoadingRoster: true));
    final result = await _getStaffMembers(NoParams());
    if (_closed) return;
    result.fold(
      (failure) {
        _rosterError = failure.message;
        emit(
          state.copyWith(
            isLoadingRoster: false,
            roster: const [],
            error: _combinedError,
          ),
        );
      },
      (staff) {
        _rosterError = null;
        emit(
          state.copyWith(
            isLoadingRoster: false,
            roster: staff,
            error: _combinedError,
          ),
        );
      },
    );
  }

  void _subscribeRecords() {
    _recordsSub?.cancel();
    _recordsError = null;
    emit(state.copyWith(isLoadingRecords: true, error: _combinedError));
    _recordsSub = _repo
        .watchDay(schoolId: _schoolId, day: state.day, campusId: state.campusId)
        .listen(
          (records) {
            if (_closed) return;
            _recordsError = null;
            emit(
              state.copyWith(
                records: records,
                isLoadingRecords: false,
                isOffline: false,
                error: _combinedError,
              ),
            );
          },
          onError: (Object e) {
            if (_closed) return;
            final offline = e is FirebaseException && e.code == 'unavailable';
            _recordsError = offline
                ? null
                : 'Could not load attendance. Pull to retry.';
            emit(
              state.copyWith(
                isLoadingRecords: false,
                isOffline: offline,
                error: _combinedError,
              ),
            );
          },
        );
  }

  Future<void> retry() async {
    _rosterError = null;
    _recordsError = null;
    await _loadRoster();
    _subscribeRecords();
  }

  void setDay(DateTime day) {
    final d = _dateOnly(day);
    if (d == state.day) return;
    // Never allow the future.
    final clamped = d.isAfter(_today) ? _today : d;
    if (clamped == state.day) return;
    emit(state.copyWith(day: clamped, page: 0));
    _subscribeRecords();
    _subscribeLeave();
  }

  void previousDay() => setDay(state.day.subtract(const Duration(days: 1)));

  void nextDay() {
    if (!state.day.isBefore(_today)) return;
    setDay(state.day.add(const Duration(days: 1)));
  }

  void goToToday() => setDay(_today);

  bool get canGoNext => state.day.isBefore(_today);

  void setCampus(String? campusId) {
    if (campusId == state.campusId) return;
    emit(state.copyWith(campusId: campusId, page: 0));
    _subscribeRecords();
  }

  void setQuery(String query) => emit(state.copyWith(query: query, page: 0));

  void setFilter(StaffAttendanceFilter filter) =>
      emit(state.copyWith(filter: filter, page: 0));

  void setPage(int page) {
    final clamped = page.clamp(0, state.pageCount - 1);
    if (clamped == state.page) return;
    emit(state.copyWith(page: clamped));
  }

  void previousPage() => setPage(state.safePage - 1);
  void nextPage() => setPage(state.safePage + 1);

  /// One-shot fetch for the CSV export.
  Future<List<StaffAttendanceRecord>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) {
    return _repo.fetchRange(
      schoolId: _schoolId,
      from: from,
      to: to,
      campusId: state.campusId,
    );
  }

  /// Selects/deselects a staff member for the desktop right-detail-panel.
  /// Tapping an already-selected row deselects it.
  void selectStaff(String? staffId) {
    emit(
      state.copyWith(
        selectedStaffId: staffId == state.selectedStaffId ? null : staffId,
      ),
    );
  }

  /// Authorised "Mark staff attendance" for today. Guards against a
  /// double-tap firing two submissions via [isSubmittingAction]; the
  /// callable itself is also idempotent (deterministic doc id), so a retry
  /// after a network blip never creates a duplicate record.
  Future<bool> markAttendance(String staffId, {String? location}) async {
    if (state.isSubmittingAction) return false;
    emit(state.copyWith(isSubmittingAction: true, actionError: null));
    try {
      await _repo.clockIn(
        schoolId: _schoolId,
        staffId: staffId,
        day: _today,
        location: location,
      );
      if (!_closed) emit(state.copyWith(isSubmittingAction: false));
      return true;
    } catch (e) {
      if (!_closed) {
        emit(
          state.copyWith(
            isSubmittingAction: false,
            actionError: 'Could not mark attendance. Try again.',
          ),
        );
      }
      return false;
    }
  }

  @override
  Future<void> close() {
    _recordsSub?.cancel();
    _campusesSub?.cancel();
    _shiftsSub?.cancel();
    _leaveSub?.cancel();
    return super.close();
  }
}
