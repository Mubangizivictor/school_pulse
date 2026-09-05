import 'package:equatable/equatable.dart';

/// A school's teaching plan for one education level in one academic year:
/// which subjects are taught, whether each is core or elective, and the
/// weekly lesson load. Classes in the level inherit this plan by default;
/// [ClassPlanOverride] rows record per-class adjustments on top of it.
///
/// Not a generic one-subject-at-a-time allocation - a plan groups every
/// subject for a level into one versioned, reviewable set. Saving a plan's
/// subjects bumps [templateVersion] so downstream consumers (timetables,
/// teacher assignments) can tell when the plan they built against is stale.
class TeachingPlan extends Equatable {
  final String id;
  final String schoolId;
  final String educationLevelId;
  final String academicYearId;

  /// The id of the plan this one was started from via "Use curriculum
  /// template" (another of this school's own plans - see
  /// [TeachingPlanSubjectsRepository]). Empty when built from scratch.
  final String templateSourceId;
  final int templateVersion;
  final bool isActive;
  final String createdBy;
  final DateTime? createdAt;
  final String updatedBy;
  final DateTime? updatedAt;

  /// Optional level-wide summary fields set from the simplified "Set up
  /// plan" sheet: a single total weekly lesson load for the whole plan and
  /// an optional default lesson duration, both purely informational school
  /// defaults - not a fixed timetable. Independent of the per-subject
  /// [TeachingPlanSubject.weeklyLessons] figures, which remain the
  /// authoritative per-subject breakdown when set.
  final int? totalWeeklyHours;
  final int? defaultLessonDurationMinutes;

  const TeachingPlan({
    required this.id,
    required this.schoolId,
    required this.educationLevelId,
    required this.academicYearId,
    this.templateSourceId = '',
    this.templateVersion = 1,
    this.isActive = true,
    this.createdBy = '',
    this.createdAt,
    this.updatedBy = '',
    this.updatedAt,
    this.totalWeeklyHours,
    this.defaultLessonDurationMinutes,
  });

  TeachingPlan copyWith({
    String? id,
    String? schoolId,
    String? educationLevelId,
    String? academicYearId,
    String? templateSourceId,
    int? templateVersion,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    int? totalWeeklyHours,
    bool clearTotalWeeklyHours = false,
    int? defaultLessonDurationMinutes,
    bool clearDefaultLessonDurationMinutes = false,
  }) {
    return TeachingPlan(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      educationLevelId: educationLevelId ?? this.educationLevelId,
      academicYearId: academicYearId ?? this.academicYearId,
      templateSourceId: templateSourceId ?? this.templateSourceId,
      templateVersion: templateVersion ?? this.templateVersion,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      totalWeeklyHours: clearTotalWeeklyHours
          ? null
          : (totalWeeklyHours ?? this.totalWeeklyHours),
      defaultLessonDurationMinutes: clearDefaultLessonDurationMinutes
          ? null
          : (defaultLessonDurationMinutes ?? this.defaultLessonDurationMinutes),
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    educationLevelId,
    academicYearId,
    templateSourceId,
    templateVersion,
    isActive,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    totalWeeklyHours,
    defaultLessonDurationMinutes,
  ];
}

/// One subject's place in a [TeachingPlan]: whether it's core or elective
/// and its weekly lesson load. [weeklyLessons] is nullable - null means "not
/// yet set", never a fabricated 0, so the UI can tell "blank" from "zero
/// lessons a week" (which is never a valid saved value; see
/// [TeachingPlanSubjectsRepository.saveSubject]).
class TeachingPlanSubject extends Equatable {
  final String id;
  final String schoolId;
  final String planId;
  final String subjectId;
  final bool isCore;
  final int? weeklyLessons;
  final int order;
  final bool isActive;

  const TeachingPlanSubject({
    required this.id,
    required this.schoolId,
    required this.planId,
    required this.subjectId,
    this.isCore = true,
    this.weeklyLessons,
    this.order = 0,
    this.isActive = true,
  });

  TeachingPlanSubject copyWith({
    String? id,
    String? schoolId,
    String? planId,
    String? subjectId,
    bool? isCore,
    int? weeklyLessons,
    bool clearWeeklyLessons = false,
    int? order,
    bool? isActive,
  }) {
    return TeachingPlanSubject(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      planId: planId ?? this.planId,
      subjectId: subjectId ?? this.subjectId,
      isCore: isCore ?? this.isCore,
      weeklyLessons: clearWeeklyLessons
          ? null
          : (weeklyLessons ?? this.weeklyLessons),
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    planId,
    subjectId,
    isCore,
    weeklyLessons,
    order,
    isActive,
  ];
}

/// The kind of per-class adjustment a [ClassPlanOverride] makes to its
/// parent [TeachingPlan]. A class with no override rows simply inherits the
/// level plan unchanged; streams inherit their parent class's effective
/// plan (level plan + class overrides) - there is no separate stream-level
/// override yet.
enum ClassPlanOverrideAction { add, remove, modify }

/// A single per-class adjustment on top of its education level's
/// [TeachingPlan]: add a subject the level plan doesn't have, remove one it
/// does, or modify (e.g. change weekly lessons for) one it does.
class ClassPlanOverride extends Equatable {
  final String id;
  final String schoolId;
  final String planId;
  final String classId;
  final String subjectId;
  final ClassPlanOverrideAction action;
  final bool? isCore;
  final int? weeklyLessons;
  final bool isActive;

  const ClassPlanOverride({
    required this.id,
    required this.schoolId,
    required this.planId,
    required this.classId,
    required this.subjectId,
    required this.action,
    this.isCore,
    this.weeklyLessons,
    this.isActive = true,
  });

  ClassPlanOverride copyWith({
    String? id,
    String? schoolId,
    String? planId,
    String? classId,
    String? subjectId,
    ClassPlanOverrideAction? action,
    bool? isCore,
    int? weeklyLessons,
    bool? isActive,
  }) {
    return ClassPlanOverride(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      planId: planId ?? this.planId,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      action: action ?? this.action,
      isCore: isCore ?? this.isCore,
      weeklyLessons: weeklyLessons ?? this.weeklyLessons,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    planId,
    classId,
    subjectId,
    action,
    isCore,
    weeklyLessons,
    isActive,
  ];
}
