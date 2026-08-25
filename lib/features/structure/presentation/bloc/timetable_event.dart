import 'package:equatable/equatable.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/entities/teaching_plan.dart';
import '../../domain/entities/timetable.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

/// Starts watching every timetable for the school (optionally narrowed to
/// one academic year/class), for the list screen.
class TimetableListRequested extends TimetableEvent {
  final String schoolId;
  final String? academicYearId;
  final String? classId;

  const TimetableListRequested({
    required this.schoolId,
    this.academicYearId,
    this.classId,
  });

  @override
  List<Object?> get props => [schoolId, academicYearId, classId];
}

class TimetableListUpdated extends TimetableEvent {
  final List<Timetable> timetables;

  const TimetableListUpdated(this.timetables);

  @override
  List<Object?> get props => [timetables];
}

/// Opens one timetable for editing/viewing: loads its lessons and every
/// other lesson at the school for the same academic year/term, so the
/// conflict resolver has the full pool to check against.
class TimetableOpened extends TimetableEvent {
  final String schoolId;
  final String timetableId;

  const TimetableOpened({required this.schoolId, required this.timetableId});

  @override
  List<Object?> get props => [schoolId, timetableId];
}

class TimetableDetailLoaded extends TimetableEvent {
  final Timetable timetable;

  const TimetableDetailLoaded(this.timetable);

  @override
  List<Object?> get props => [timetable];
}

class TimetableLessonsUpdated extends TimetableEvent {
  final List<TimetableLesson> lessons;

  const TimetableLessonsUpdated(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

class TimetableOtherLessonsLoaded extends TimetableEvent {
  final List<TimetableLesson> lessons;

  const TimetableOtherLessonsLoaded(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

class TimetableClosed extends TimetableEvent {
  const TimetableClosed();
}

/// Creates a new draft timetable for a class (or class/stream) and opens it.
class TimetableCreateRequested extends TimetableEvent {
  final Timetable draft;

  const TimetableCreateRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Validates and saves one lesson (add or edit) against the conflict
/// resolver before writing it - both the occurrence-collision checks
/// ([TimetableConflictResolver.findConflicts]) and, when the caller
/// supplies them, the curriculum-allocation checks
/// ([TimetableConflictResolver.checkAllocation]): is the subject actually
/// allocated to this class, and is the teacher actually assigned to teach
/// it. Those two lists come from outside this bloc (Structure's own
/// TeachingPlan/TeachingAssignment data) since TimetableBloc is
/// deliberately not wired to every other Structure repository; the screen
/// dispatching this event is expected to have already loaded them for the
/// timetable's class/level/year/term.
class TimetableLessonSaveRequested extends TimetableEvent {
  final TimetableLesson lesson;
  final List<TeachingPlanSubject> levelPlanSubjects;
  final List<ClassPlanOverride> classOverrides;
  final List<TeachingAssignment> teachingAssignments;

  const TimetableLessonSaveRequested(
    this.lesson, {
    this.levelPlanSubjects = const [],
    this.classOverrides = const [],
    this.teachingAssignments = const [],
  });

  @override
  List<Object?> get props => [
    lesson,
    levelPlanSubjects,
    classOverrides,
    teachingAssignments,
  ];
}

class TimetableLessonRemoveRequested extends TimetableEvent {
  final String lessonId;

  const TimetableLessonRemoveRequested(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

/// Full conflict re-scan of everything in the currently open timetable;
/// marks it `validated` if clean, matching the Draft -> Validated ->
/// Published lifecycle - validating does not publish.
class TimetableValidateRequested extends TimetableEvent {
  final String validatedBy;

  const TimetableValidateRequested({required this.validatedBy});

  @override
  List<Object?> get props => [validatedBy];
}

/// Full conflict re-scan of everything in the currently open timetable,
/// used before publishing.
class TimetablePublishRequested extends TimetableEvent {
  final String publishedBy;

  const TimetablePublishRequested({required this.publishedBy});

  @override
  List<Object?> get props => [publishedBy];
}

class TimetableArchiveRequested extends TimetableEvent {
  final String archivedBy;

  const TimetableArchiveRequested({required this.archivedBy});

  @override
  List<Object?> get props => [archivedBy];
}
