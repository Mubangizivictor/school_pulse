import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../../domain/entities/attendance_access_context.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_category_permission.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/services/attendance_participant_resolver.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;
  final PermissionEvaluator permissionEvaluator;
  final AttendanceParticipantResolver participantResolver;

  static const _institutionWideRoles = {
    UserRole.schoolAdmin,
    UserRole.director,
    UserRole.headTeacher,
    UserRole.deputyHead,
  };

  AttendanceBloc({
    required this.repository,
    required this.permissionEvaluator,
    required this.participantResolver,
  }) : super(AttendanceInitial()) {
    on<LoadScopesRequested>(_onLoadScopes);
    on<LoadRosterRequested>(_onLoadRoster);
    on<MarkAttendanceRequested>(_onMarkAttendance);
    on<MarkBatchAttendanceRequested>(_onMarkBatch);
    on<LoadRecordsRequested>(_onLoadRecords);
    on<SyncPendingAttendanceRequested>(_onSyncPending);
  }

  Future<void> _onSyncPending(
    SyncPendingAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    await repository.syncPendingAttendance(event.schoolId);
  }

  Future<Either<Failure, AttendanceAccessContext>> _resolveAccess(
    UserEntity operatorUser,
  ) {
    return participantResolver.resolve(operatorUser);
  }

  Future<void> _onLoadScopes(
    LoadScopesRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final accessResult = await _resolveAccess(event.operatorUser);
    await accessResult.fold(
      (failure) async => emit(AttendanceError(failure.message)),
      (access) async {
        if (!access.hasAnyAccess) {
          emit(
            const AttendanceActionDenied(
              'No attendance group has been assigned to your account. '
              'Contact your Institution Administrator.',
            ),
          );
          return;
        }
        final result = await repository.getScopes(
          event.schoolId,
          event.category,
          access,
        );
        result.fold(
          (failure) => emit(AttendanceError(failure.message)),
          (scopes) => emit(ScopesLoaded(scopes)),
        );
      },
    );
  }

  Future<void> _onLoadRoster(
    LoadRosterRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    final accessResult = await _resolveAccess(event.operatorUser);
    await accessResult.fold(
      (failure) async => emit(AttendanceError(failure.message)),
      (access) async {
        if (!access.canActOnScope(event.category, event.scopeId)) {
          emit(
            const AttendanceActionDenied(
              'This is not part of your assigned attendance group.',
            ),
          );
          return;
        }
        final result = await repository.getRoster(
          event.schoolId,
          event.category,
          event.scopeId,
          access,
        );
        result.fold(
          (failure) => emit(AttendanceError(failure.message)),
          (roster) => emit(RosterLoaded(roster)),
        );
      },
    );
  }

  /// School leadership is already authorised institution-wide by the same
  /// role bypass used by the attendance Firestore rules. Do not require a
  /// School Admin to also hold a teacher assignment or granular scan
  /// permission just to test/operate student attendance.
  Future<bool> _canMark(
    AttendanceCategory category,
    UserEntity operatorUser,
  ) async {
    if (operatorUser.roles.any(_institutionWideRoles.contains)) {
      return true;
    }

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

  Future<Either<AttendanceState, AttendanceAccessContext>> _authorize(
    AttendanceRecord record,
    UserEntity operatorUser,
  ) async {
    final allowed = await _canMark(record.category, operatorUser);
    if (!allowed) {
      return const Left(
        AttendanceActionDenied(
          'You do not have permission to take attendance for this category.',
        ),
      );
    }

    final accessResult = await _resolveAccess(operatorUser);
    return accessResult.fold(
      (failure) => Left(AttendanceError(failure.message)),
      (access) => access.canActOnScope(record.category, record.scopeId)
          ? Right(access)
          : const Left(
              AttendanceActionDenied(
                'This person is not part of your assigned attendance group.',
              ),
            ),
    );
  }

  AttendanceRecord _withAssignment(
    AttendanceRecord record,
    AttendanceAccessContext access,
  ) {
    final assignmentId = access.assignmentIdForScope(
      record.category,
      record.scopeId,
    );
    if (assignmentId == null) return record;
    return record.copyWith(roleAssignmentId: assignmentId);
  }

  Future<void> _onMarkAttendance(
    MarkAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final authResult = await _authorize(event.record, event.operatorUser);
    final denial = authResult.fold((denied) => denied, (_) => null);
    if (denial != null) {
      emit(denial);
      return;
    }
    final access = authResult.getOrElse(
      () => throw StateError('unreachable - denial handled above'),
    );

    final result = await repository.markAttendance(
      _withAssignment(event.record, access),
    );
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

    final accessResult = await _resolveAccess(event.operatorUser);
    final outcome = await accessResult
        .fold<
          Future<Either<AttendanceState, AttendanceAccessContext>>
        >((failure) async => Left(AttendanceError(failure.message)), (
          access,
        ) async {
          final allowed = await _canMark(
            event.records.first.category,
            event.operatorUser,
          );
          if (!allowed) {
            return const Left(
              AttendanceActionDenied(
                'You do not have permission to take attendance for this category.',
              ),
            );
          }
          final outOfScope = event.records.any(
            (r) => !access.canActOnScope(r.category, r.scopeId),
          );
          if (outOfScope) {
            return const Left(
              AttendanceActionDenied(
                'One or more people are not part of your assigned attendance group.',
              ),
            );
          }
          return Right(access);
        });
    final denial = outcome.fold((denied) => denied, (_) => null);
    if (denial != null) {
      emit(denial);
      return;
    }
    final access = outcome.getOrElse(
      () => throw StateError('unreachable - denial handled above'),
    );

    emit(AttendanceLoading());
    final stamped = event.records
        .map((r) => _withAssignment(r, access))
        .toList();
    final result = await repository.markBatch(stamped);
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
    final accessResult = await _resolveAccess(event.operatorUser);
    await accessResult.fold(
      (failure) async => emit(AttendanceError(failure.message)),
      (access) async {
        final result = await repository.getRecords(
          schoolId: event.schoolId,
          access: access,
          category: event.category,
          from: event.from,
          to: event.to,
          scopeId: event.scopeId,
        );
        result.fold(
          (failure) => emit(AttendanceError(failure.message)),
          (records) => emit(RecordsLoaded(records)),
        );
      },
    );
  }
}
