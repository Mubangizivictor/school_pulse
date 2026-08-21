import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/subject_enrollment.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/repositories/lesson_repository.dart';
import '../../../domain/repositories/subject_student_repository.dart';

abstract class SubjectTeacherDashboardEvent extends Equatable {
  const SubjectTeacherDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the dashboard for a responsibility. Raised on open, on
/// pull-to-refresh, and every time the active responsibility changes - which
/// is what clears the previous subject's figures.
class DashboardRequested extends SubjectTeacherDashboardEvent {
  final ActiveResponsibilityContext context;

  const DashboardRequested(this.context);

  @override
  List<Object?> get props => [context];
}

/// Metrics for the currently selected subject and class.
///
/// The counts are nullable on purpose. A tile with no data yet renders as a
/// dash, because "attendance has not been taken today" and "nobody was
/// present" are different facts and a dashboard that shows 0 for both is
/// lying to the teacher.
class SubjectTeacherDashboardState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// The assignment these figures belong to. Held so a late response from a
  /// previous subject can be discarded instead of painting over the new one.
  final String? roleAssignmentId;

  final int? studentsEnrolled;
  final int? presentToday;
  final int? absentToday;
  final int? lessonsToday;

  /// Today's periods for this assignment, in time order.
  final List<Lesson> todaysLessons;

  const SubjectTeacherDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.roleAssignmentId,
    this.studentsEnrolled,
    this.presentToday,
    this.absentToday,
    this.lessonsToday,
    this.todaysLessons = const [],
  });

  /// The lesson to surface on the dashboard: one in progress if there is one,
  /// otherwise the next one still to come, otherwise the last one of the day
  /// so the card does not go blank the moment teaching finishes.
  Lesson? get featuredLesson {
    if (todaysLessons.isEmpty) return null;
    final ongoing = todaysLessons
        .where((l) => l.status == LessonStatus.ongoing)
        .firstOrNull;
    if (ongoing != null) return ongoing;

    final now = DateTime.now();
    final upcoming = todaysLessons
        .where((l) => l.scheduledEnd.isAfter(now))
        .firstOrNull;
    return upcoming ?? todaysLessons.last;
  }

  const SubjectTeacherDashboardState.initial() : this(isLoading: true);

  /// Attendance percentage of the enrolled cohort, or null when either half
  /// of the fraction is still unknown.
  double? get presentPercentage {
    final present = presentToday;
    final enrolled = studentsEnrolled;
    if (present == null || enrolled == null || enrolled == 0) return null;
    return (present / enrolled) * 100;
  }

  double? get absentPercentage {
    final absent = absentToday;
    final enrolled = studentsEnrolled;
    if (absent == null || enrolled == null || enrolled == 0) return null;
    return (absent / enrolled) * 100;
  }

  SubjectTeacherDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? roleAssignmentId,
    int? studentsEnrolled,
    int? presentToday,
    int? absentToday,
    int? lessonsToday,
    List<Lesson>? todaysLessons,
    bool clearError = false,
  }) {
    return SubjectTeacherDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      studentsEnrolled: studentsEnrolled ?? this.studentsEnrolled,
      presentToday: presentToday ?? this.presentToday,
      absentToday: absentToday ?? this.absentToday,
      lessonsToday: lessonsToday ?? this.lessonsToday,
      todaysLessons: todaysLessons ?? this.todaysLessons,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    roleAssignmentId,
    studentsEnrolled,
    presentToday,
    absentToday,
    lessonsToday,
    todaysLessons,
  ];
}

/// Deliberately not unified with [ClassTeacherDashboardBloc] - see that
/// class's doc comment. The independent per-branch failure folding below
/// (a lessons failure must not blank out a student count that already
/// loaded) is the reason a shared fetch-strategy base was rejected in favor
/// of the small duplication left between the two blocs.
class SubjectTeacherDashboardBloc
    extends Bloc<SubjectTeacherDashboardEvent, SubjectTeacherDashboardState> {
  final SubjectStudentRepository studentRepository;
  final LessonRepository lessonRepository;

  SubjectTeacherDashboardBloc({
    required this.studentRepository,
    required this.lessonRepository,
  }) : super(const SubjectTeacherDashboardState.initial()) {
    on<DashboardRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<SubjectTeacherDashboardState> emit,
  ) async {
    // Start from a clean state rather than copyWith: carrying the previous
    // assignment's numbers across a switch would briefly show Grade 10A's
    // enrollment under Grade 10B.
    emit(
      SubjectTeacherDashboardState(
        isLoading: true,
        roleAssignmentId: event.context.roleAssignmentId,
      ),
    );

    // Both reads go out together; neither depends on the other.
    final results = await Future.wait([
      studentRepository.getSubjectStudents(context: event.context),
      lessonRepository.getTodaysLessons(context: event.context),
    ]);

    // The teacher may have switched again while these were in flight.
    if (state.roleAssignmentId != event.context.roleAssignmentId) return;

    final students = results[0] as Either<Failure, List<SubjectStudentSummary>>;
    final lessons = results[1] as Either<Failure, List<Lesson>>;

    var next = state.copyWith(isLoading: false);
    String? error;

    students.fold(
      (failure) => error ??= _messageFor(failure),
      (list) => next = next.copyWith(studentsEnrolled: list.length),
    );

    lessons.fold(
      // A timetable that will not load must not blank out the student count
      // that did.
      (failure) => error ??= _messageFor(failure),
      (list) =>
          next = next.copyWith(lessonsToday: list.length, todaysLessons: list),
    );

    emit(
      error == null
          ? next.copyWith(clearError: true)
          : next.copyWith(errorMessage: error),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    NetworkFailure() => 'You are offline. Showing saved data.',
    ValidationFailure() => failure.message,
    _ => 'Could not load this subject. Pull down to retry.',
  };
}
