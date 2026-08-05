import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/staff_role_assignment.dart';
import '../../../domain/repositories/staff_assignment_repository.dart';
import '../../../domain/services/academic_calendar_service.dart';
import '../../../domain/services/active_responsibility_service.dart';
import 'subject_teacher_context_event.dart';
import 'subject_teacher_context_state.dart';

/// Owns "which responsibility is the teacher acting under". Every other
/// Subject Teacher BLoC reads the context from here rather than resolving one
/// of its own, so a switch changes the whole panel at once and no screen can
/// be left querying the previous subject.
class SubjectTeacherContextBloc
    extends Bloc<SubjectTeacherContextEvent, SubjectTeacherContextState> {
  final ActiveResponsibilityService responsibilityService;
  final StaffAssignmentRepository assignmentRepository;
  final AcademicCalendarService calendarService;

  StreamSubscription<List<StaffRoleAssignment>>? _assignmentWatch;
  String? _schoolId;
  String? _userId;

  SubjectTeacherContextBloc({
    required this.responsibilityService,
    required this.assignmentRepository,
    required this.calendarService,
  }) : super(const SubjectTeacherContextState.initial()) {
    on<ContextRequested>(_onRequested);
    on<ContextSwitched>(_onSwitched);
    on<ContextRevalidated>(_onRevalidated);
    on<ContextAssignmentsChanged>(_onAssignmentsChanged);
    on<ContextNoticeCleared>(_onNoticeCleared);
    on<ContextCleared>(_onCleared);
  }

  Future<void> _onRequested(
    ContextRequested event,
    Emitter<SubjectTeacherContextState> emit,
  ) async {
    _schoolId = event.schoolId;
    _userId = event.userId;
    emit(
      state.copyWith(isLoading: true, clearError: true, clearUnavailable: true),
    );

    final period = await calendarService.getCurrentPeriod(_schoolId!);
    if (!period.hasYear) {
      // Nothing in the panel can be scoped without a year, so this is its own
      // state rather than an empty student list with no explanation.
      emit(
        state.copyWith(
          isLoading: false,
          unavailableReason: ContextUnavailableReason.noAcademicYear,
          clearActive: true,
        ),
      );
      return;
    }

    final result = await responsibilityService.resolve(
      schoolId: event.schoolId,
      userId: event.userId,
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _messageFor(failure),
          unavailableReason: ContextUnavailableReason.loadFailed,
        ),
      ),
      (resolution) {
        if (!resolution.hasActive) {
          emit(
            state.copyWith(
              isLoading: false,
              available: resolution.available,
              unavailableReason: ContextUnavailableReason.noAssignments,
              clearActive: true,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            isLoading: false,
            active: resolution.active,
            available: resolution.available,
            notice: resolution.switchReason,
            clearUnavailable: true,
            clearError: true,
          ),
        );
      },
    );

    _listenForAssignmentChanges();
  }

  Future<void> _onSwitched(
    ContextSwitched event,
    Emitter<SubjectTeacherContextState> emit,
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
        // The switch was refused - the assignment is gone or suspended. Keep
        // the current responsibility in effect and reload the list so the
        // stale entry disappears from the switcher.
        emit(
          state.copyWith(
            isSwitching: false,
            errorMessage: _messageFor(failure),
          ),
        );
        add(const ContextAssignmentsChanged());
      },
      (context) async {
        final refreshed = await assignmentRepository.getValidAssignments(
          schoolId: schoolId,
          userId: userId,
          academicYearId: context.academicYearId,
        );
        emit(
          state.copyWith(
            isSwitching: false,
            active: context,
            available: refreshed.getOrElse(() => state.available),
            clearUnavailable: true,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onRevalidated(
    ContextRevalidated event,
    Emitter<SubjectTeacherContextState> emit,
  ) async {
    if (!state.hasActive) return;

    final result = await responsibilityService.revalidate();
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _messageFor(failure),
          unavailableReason: failure is AssignmentInvalidFailure
              ? ContextUnavailableReason.assignmentSuspended
              : null,
        ),
      ),
      // Permissions are re-read on revalidate, so a narrowed scope reaches
      // the screens that are already open.
      (context) => emit(state.copyWith(active: context, clearError: true)),
    );
  }

  Future<void> _onAssignmentsChanged(
    ContextAssignmentsChanged event,
    Emitter<SubjectTeacherContextState> emit,
  ) async {
    final schoolId = _schoolId;
    final userId = _userId;
    if (schoolId == null || userId == null) return;

    final result = await responsibilityService.resolve(
      schoolId: schoolId,
      userId: userId,
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: _messageFor(failure))),
      (resolution) {
        if (!resolution.hasActive) {
          emit(
            state.copyWith(
              available: resolution.available,
              unavailableReason: ContextUnavailableReason.noAssignments,
              clearActive: true,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            active: resolution.active,
            available: resolution.available,
            notice: resolution.switchReason,
            clearUnavailable: true,
          ),
        );
      },
    );
  }

  void _onNoticeCleared(
    ContextNoticeCleared event,
    Emitter<SubjectTeacherContextState> emit,
  ) {
    emit(state.copyWith(clearNotice: true));
  }

  Future<void> _onCleared(
    ContextCleared event,
    Emitter<SubjectTeacherContextState> emit,
  ) async {
    await _assignmentWatch?.cancel();
    _assignmentWatch = null;
    await responsibilityService.clear(schoolId: _schoolId);
    _schoolId = null;
    _userId = null;
    emit(const SubjectTeacherContextState());
  }

  /// Subscribes to the teacher's assignment rows so an admin suspending or
  /// re-scoping a responsibility reaches an open panel immediately, rather
  /// than at the next cold start.
  void _listenForAssignmentChanges() {
    final schoolId = _schoolId;
    final userId = _userId;
    if (schoolId == null || userId == null || _assignmentWatch != null) return;

    _assignmentWatch = assignmentRepository
        .watchAssignments(schoolId: schoolId, userId: userId)
        .listen(
          (_) => add(const ContextAssignmentsChanged()),
          // A dropped listener must not break the panel; the periodic revalidate
          // before writes still catches revocations.
          onError: (_) {},
        );
  }

  String _messageFor(Failure failure) => switch (failure) {
    AssignmentInvalidFailure() => failure.message,
    PermissionDeniedFailure() => failure.message,
    NetworkFailure() => 'You are offline. Showing your saved responsibilities.',
    CacheFailure() => 'Could not read your saved responsibilities.',
    // Raw Firestore text never reaches the user - it leaks document
    // paths and internal ids.
    _ => 'Could not load your responsibilities. Pull down to retry.',
  };

  @override
  Future<void> close() {
    _assignmentWatch?.cancel();
    return super.close();
  }
}
