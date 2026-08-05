import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_category_permission.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;
  final PermissionEvaluator permissionEvaluator;

  AttendanceBloc({required this.repository, required this.permissionEvaluator})
    : super(AttendanceInitial()) {
    on<LoadScopesRequested>(_onLoadScopes);
    on<LoadRosterRequested>(_onLoadRoster);
    on<MarkAttendanceRequested>(_onMarkAttendance);
    on<MarkBatchAttendanceRequested>(_onMarkBatch);
    on<LoadRecordsRequested>(_onLoadRecords);
  }

  Future<void> _onLoadScopes(
    LoadScopesRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final result = await repository.getScopes(event.schoolId, event.category);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (scopes) => emit(ScopesLoaded(scopes)),
    );
  }

  Future<void> _onLoadRoster(
    LoadRosterRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final result = await repository.getRoster(
      event.schoolId,
      event.category,
      event.scopeId,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (roster) => emit(RosterLoaded(roster)),
    );
  }

  /// Matches the Firestore rules' hasAttendancePermission(): allowed if the
  /// operator holds either the category-specific scan permission or the
  /// blanket attendance.override - checking only the former would let a
  /// user who was granted just the override pass the server rule but get
  /// turned away client-side.
  Future<bool> _canMark(
    AttendanceCategory category,
    UserEntity operatorUser,
  ) async {
    final categoryResult = await permissionEvaluator.can(
      permissionForCategory(category),
      operatorUser,
    );
    if (categoryResult.fold((failure) => false, (v) => v)) return true;

    final overrideResult = await permissionEvaluator.can(
      Permission.attendanceOverride,
      operatorUser,
    );
    return overrideResult.fold((failure) => false, (v) => v);
  }

  Future<void> _onMarkAttendance(
    MarkAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final allowed = await _canMark(event.record.category, event.operatorUser);
    if (!allowed) {
      emit(
        const AttendanceActionDenied(
          'You do not have permission to take attendance for this category.',
        ),
      );
      return;
    }

    final result = await repository.markAttendance(event.record);
    result.fold((failure) {
      if (failure is ValidationFailure && failure.field == 'duplicate') {
        emit(AttendanceDuplicate(failure.message));
      } else {
        emit(AttendanceError(failure.message));
      }
    }, (record) => emit(AttendanceMarkSuccess(record)));
  }

  Future<void> _onMarkBatch(
    MarkBatchAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (event.records.isEmpty) return;
    final allowed = await _canMark(
      event.records.first.category,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        const AttendanceActionDenied(
          'You do not have permission to take attendance for this category.',
        ),
      );
      return;
    }

    emit(AttendanceLoading());
    final result = await repository.markBatch(event.records);
    result.fold((failure) {
      if (failure is ValidationFailure && failure.field == 'duplicate') {
        emit(AttendanceDuplicate(failure.message));
      } else {
        emit(AttendanceError(failure.message));
      }
    }, (records) => emit(AttendanceBatchMarkSuccess(records)));
  }

  Future<void> _onLoadRecords(
    LoadRecordsRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final result = await repository.getRecords(
      schoolId: event.schoolId,
      category: event.category,
      from: event.from,
      to: event.to,
      scopeId: event.scopeId,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (records) => emit(RecordsLoaded(records)),
    );
  }
}
