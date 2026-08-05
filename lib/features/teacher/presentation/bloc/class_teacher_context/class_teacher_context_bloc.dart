import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/staff_role_assignment.dart';
import '../../../domain/repositories/staff_assignment_repository.dart';
import '../../../domain/services/academic_calendar_service.dart';
import '../../../domain/services/active_responsibility_service.dart';
import '../../../domain/services/class_teacher_assignment_service.dart';
import 'class_teacher_context_event.dart';
import 'class_teacher_context_state.dart';

/// Owns "which class is this teacher acting as Class Teacher for".
///
/// Every other Class Teacher BLoC reads its context from here rather than
/// resolving one of its own, so switching responsibility changes the whole
/// panel at once and no screen is left querying the previous class. It shares
/// the [ActiveResponsibilityService] with the Subject Teacher panel - one
/// account, one selection - and narrows it to the Class Teacher row.
class ClassTeacherContextBloc
    extends Bloc<ClassTeacherContextEvent, ClassTeacherContextState> {
  final ActiveResponsibilityService responsibilityService;
  final ClassTeacherAssignmentService assignmentService;
  final StaffAssignmentRepository assignmentRepository;
  final AcademicCalendarService calendarService;

  StreamSubscription<List<StaffRoleAssignment>>? _assignmentWatch;
  String? _schoolId;
  String? _userId;

  ClassTeacherContextBloc({
    required this.responsibilityService,
    required this.assignmentService,
    required this.assignmentRepository,
    required this.calendarService,
  }) : super(const ClassTeacherContextState.initial()) {
    on<ClassContextRequested>(_onRequested);
    on<ClassContextSwitched>(_onSwitched);
    on<ClassContextRevalidated>(_onRevalidated);
    on<ClassContextAssignmentsChanged>(_onAssignmentsChanged);
    on<ClassContextNoticeCleared>(_onNoticeCleared);
    on<ClassContextHandOffConsumed>(_onHandOffConsumed);
    on<ClassContextCleared>(_onCleared);
  }

  Future<void> _onRequested(
    ClassContextRequested event,
    Emitter<ClassTeacherContextState> emit,
  ) async {
    _schoolId = event.schoolId;
    _userId = event.userId;
    emit(
      state.copyWith(isLoading: true, clearError: true, clearUnavailable: true),
    );

    await _load(emit, forceRefresh: event.forceRefresh);
    _listenForAssignmentChanges();
  }

  Future<void> _onAssignmentsChanged(
    ClassContextAssignmentsChanged event,
    Emitter<ClassTeacherContextState> emit,
  ) async {
    if (_schoolId == null || _userId == null) return;
    await _load(emit);
  }

  /// The single path that turns "this account's assignments" into "this
  /// panel's class". Used by the initial load and by every admin-triggered
  /// refresh, so a suspension reaches an open panel the same way a cold start
  /// would.
  Future<void> _load(
    Emitter<ClassTeacherContextState> emit, {
    bool forceRefresh = false,
  }) async {
    final schoolId = _schoolId!;
    final userId = _userId!;

    final period = await calendarService.getCurrentPeriod(schoolId);
    if (!period.hasYear) {
      emit(
        state.copyWith(
          isLoading: false,
          unavailableReason: ClassContextUnavailableReason.noAcademicYear,
          clearActive: true,
        ),
      );
      return;
    }

    final assignmentsResult = await assignmentRepository.getAssignments(
      schoolId: schoolId,
      userId: userId,
      forceRefresh: forceRefresh,
    );

    final allAssignments = assignmentsResult.getOrElse(() => state.available);

    // When the shared selection is already a class row - the usual case, the
    // teacher having arrived here through the switcher - adopt it as-is.
    // Re-selecting would overwrite the persisted choice of a teacher who
    // holds two classes under a school's override.
    final shared = responsibilityService.current;
    if (shared != null &&
        shared.isClassTeacher &&
        shared.assignmentStatus == AssignmentStatus.active) {
      emit(
        state.copyWith(
          isLoading: false,
          active: shared,
          available: allAssignments,
          hasCurrentTerm: period.hasTerm,
          clearUnavailable: true,
          clearError: true,
        ),
      );
      return;
    }

    final activeResult = await assignmentService.resolveActiveAssignment(
      schoolId: schoolId,
      userId: userId,
      forceRefresh: forceRefresh,
    );

    await activeResult.fold(
      (failure) async => emit(
        state.copyWith(
          isLoading: false,
          available: allAssignments,
          errorMessage: _messageFor(failure),
          unavailableReason: ClassContextUnavailableReason.loadFailed,
        ),
      ),
      (assignment) async {
        if (assignment == null) {
          // No *valid* class row. Distinguish "never had one" from "had one
          // that an admin suspended or that ran out", because the teacher's
          // next step differs and the approved UI says so.
          emit(
            state.copyWith(
              isLoading: false,
              available: allAssignments,
              unavailableReason: _explainMissingClass(allAssignments),
              hasCurrentTerm: period.hasTerm,
              clearActive: true,
            ),
          );
          return;
        }

        // Route the selection through the shared service so the Subject
        // Teacher panel and this one never disagree about what is active.
        final switched = await responsibilityService.switchTo(
          assignmentId: assignment.id,
          schoolId: schoolId,
          userId: userId,
        );

        switched.fold(
          (failure) => emit(
            state.copyWith(
              isLoading: false,
              available: allAssignments,
              errorMessage: _messageFor(failure),
              unavailableReason: ClassContextUnavailableReason.loadFailed,
              clearActive: true,
            ),
          ),
          (context) => emit(
            state.copyWith(
              isLoading: false,
              active: context,
              available: allAssignments,
              hasCurrentTerm: period.hasTerm,
              clearUnavailable: true,
              clearError: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSwitched(
    ClassContextSwitched event,
    Emitter<ClassTeacherContextState> emit,
  ) async {
    final schoolId = _schoolId;
    final userId = _userId;
    if (schoolId == null || userId == null) return;

    emit(state.copyWith(isSwitching: true, clearError: true));

    final result = await responsibilityService.switchTo(
      assignmentId: event.assignmentId,
      schoolId: schoolId,
      userId: userId,
    );

    await result.fold(
      (failure) async {
        // Refused - the assignment is gone or suspended since the switcher was
        // drawn. Keep the current class in effect and reload so the stale row
        // disappears from the list.
        emit(
          state.copyWith(
            isSwitching: false,
            errorMessage: _messageFor(failure),
          ),
        );
        add(const ClassContextAssignmentsChanged());
      },
      (context) async {
        final refreshed = await assignmentRepository.getAssignments(
          schoolId: schoolId,
          userId: userId,
        );
        final available = refreshed.getOrElse(() => state.available);

        if (!context.isClassTeacher) {
          // The teacher chose a responsibility this panel does not serve.
          // Drop the class context so nothing class-scoped survives the
          // switch, and let the router open the right panel.
          emit(
            state.copyWith(
              isSwitching: false,
              available: available,
              handOffTo: context.roleType,
              clearActive: true,
              clearError: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            isSwitching: false,
            active: context,
            available: available,
            clearUnavailable: true,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onRevalidated(
    ClassContextRevalidated event,
    Emitter<ClassTeacherContextState> emit,
  ) async {
    if (!state.hasActive) return;

    final result = await responsibilityService.revalidate();
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _messageFor(failure),
          unavailableReason: failure is AssignmentInvalidFailure
              ? ClassContextUnavailableReason.assignmentSuspended
              : null,
        ),
      ),
      // Permissions are re-read here too: an admin may have narrowed the
      // scope without ending the assignment, and open screens must see that.
      (context) => emit(state.copyWith(active: context, clearError: true)),
    );
  }

  void _onNoticeCleared(
    ClassContextNoticeCleared event,
    Emitter<ClassTeacherContextState> emit,
  ) {
    emit(state.copyWith(clearNotice: true));
  }

  void _onHandOffConsumed(
    ClassContextHandOffConsumed event,
    Emitter<ClassTeacherContextState> emit,
  ) {
    emit(state.copyWith(clearHandOff: true));
  }

  Future<void> _onCleared(
    ClassContextCleared event,
    Emitter<ClassTeacherContextState> emit,
  ) async {
    await _assignmentWatch?.cancel();
    _assignmentWatch = null;
    await responsibilityService.clear(schoolId: _schoolId);
    _schoolId = null;
    _userId = null;
    emit(const ClassTeacherContextState());
  }

  /// Turns "there is no valid class row" into the specific reason, using the
  /// rows the admin still has on file.
  ClassContextUnavailableReason _explainMissingClass(
    List<StaffRoleAssignment> assignments,
  ) {
    final classRows = assignments
        .where((a) => a.roleType == StaffResponsibilityType.classTeacher)
        .toList();
    if (classRows.isEmpty) {
      return ClassContextUnavailableReason.noClassAssignment;
    }
    if (classRows.any((a) => a.status == AssignmentStatus.suspended)) {
      return ClassContextUnavailableReason.assignmentSuspended;
    }
    if (classRows.any(
      (a) =>
          a.status == AssignmentStatus.expired ||
          (a.status == AssignmentStatus.active && !a.isCurrentlyValid()),
    )) {
      return ClassContextUnavailableReason.assignmentExpired;
    }
    return ClassContextUnavailableReason.noClassAssignment;
  }

  /// Subscribes to the teacher's assignment rows so an admin suspending or
  /// re-scoping the class responsibility reaches an open panel immediately,
  /// rather than at the next cold start.
  void _listenForAssignmentChanges() {
    final schoolId = _schoolId;
    final userId = _userId;
    if (schoolId == null || userId == null || _assignmentWatch != null) return;

    _assignmentWatch = assignmentRepository
        .watchAssignments(schoolId: schoolId, userId: userId)
        .listen(
          (_) => add(const ClassContextAssignmentsChanged()),
          // A dropped listener must not break the panel; the revalidate before
          // every sensitive write still catches revocations.
          onError: (_) {},
        );
  }

  String _messageFor(Failure failure) => switch (failure) {
    AssignmentInvalidFailure() => failure.message,
    PermissionDeniedFailure() => failure.message,
    NetworkFailure() => 'You are offline. Showing your saved class.',
    CacheFailure() => 'Could not read your saved class.',
    // Raw Firestore text never reaches the user - it leaks document paths
    // and internal ids.
    _ => 'Could not load your class. Pull down to retry.',
  };

  @override
  Future<void> close() {
    _assignmentWatch?.cancel();
    return super.close();
  }
}
