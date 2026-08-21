import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/staff_role_assignment.dart';
import '../../../domain/repositories/staff_assignment_repository.dart';
import '../../../domain/services/academic_calendar_service.dart';
import '../../../domain/services/active_responsibility_service.dart';
import '../shared/teacher_responsibility_context_mixin.dart';
import 'subject_teacher_context_event.dart';
import 'subject_teacher_context_state.dart';

/// Owns "which responsibility is the teacher acting under". Every other
/// Subject Teacher BLoC reads the context from here rather than resolving one
/// of its own, so a switch changes the whole panel at once and no screen can
/// be left querying the previous subject.
class SubjectTeacherContextBloc
    extends Bloc<SubjectTeacherContextEvent, SubjectTeacherContextState>
    with
        TeacherResponsibilityContextMixin<
          SubjectTeacherContextEvent,
          SubjectTeacherContextState
        > {
  @override
  final ActiveResponsibilityService responsibilityService;
  @override
  final StaffAssignmentRepository assignmentRepository;
  final AcademicCalendarService calendarService;

  @override
  SubjectTeacherContextEvent get assignmentsChangedEvent =>
      const ContextAssignmentsChanged();

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
    setActiveAccount(schoolId: event.schoolId, userId: event.userId);
    emit(
      state.copyWith(isLoading: true, clearError: true, clearUnavailable: true),
    );

    final period = await calendarService.getCurrentPeriod(schoolId!);
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
          errorMessage: messageFor(failure, offlineNoun: 'responsibilities'),
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

    listenForAssignmentChanges(add);
  }

  Future<void> _onSwitched(
    ContextSwitched event,
    Emitter<SubjectTeacherContextState> emit,
  ) async {
    final schoolId = this.schoolId;
    final userId = this.userId;
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
            errorMessage: messageFor(failure, offlineNoun: 'responsibilities'),
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
        final available = refreshed.getOrElse(() => state.available);

        if (context.roleType != StaffResponsibilityType.subjectTeacher) {
          // The teacher chose a responsibility this panel does not serve
          // (e.g. Class Teacher). Drop the subject context so no screen here
          // keeps querying the previous subject/class after the switch -
          // mirrors ClassTeacherContextBloc's hand-off on the way back.
          emit(
            state.copyWith(
              isSwitching: false,
              available: available,
              clearActive: true,
              clearUnavailable: true,
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
    ContextRevalidated event,
    Emitter<SubjectTeacherContextState> emit,
  ) async {
    if (!state.hasActive) return;

    final result = await responsibilityService.revalidate();
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: messageFor(failure, offlineNoun: 'responsibilities'),
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
    final schoolId = this.schoolId;
    final userId = this.userId;
    if (schoolId == null || userId == null) return;

    final result = await responsibilityService.resolve(
      schoolId: schoolId,
      userId: userId,
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: messageFor(failure, offlineNoun: 'responsibilities'))),
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
    await clearAccount();
    emit(const SubjectTeacherContextState());
  }

  @override
  Future<void> close() {
    cancelAssignmentWatch();
    return super.close();
  }
}
