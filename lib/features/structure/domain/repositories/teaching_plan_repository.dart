import '../entities/teaching_plan.dart';

/// Teaching plans (subjects + weekly lesson load per education level) and
/// their per-class overrides. Kept as its own repository, not part of
/// [StructureRepository], the same way [CurriculumAssignmentRepository] is -
/// see that class for the established precedent.
abstract class TeachingPlanRepository {
  Stream<List<TeachingPlan>> watchPlans();
  Stream<List<TeachingPlanSubject>> watchPlanSubjects(String planId);

  /// All active plan-subject rows across every plan for the current school -
  /// used by the plans overview to show a subject count per level without
  /// opening each plan individually.
  Stream<List<TeachingPlanSubject>> watchAllPlanSubjects();
  Stream<List<ClassPlanOverride>> watchClassOverrides(String planId);

  /// Creates or updates a plan's own row (scope/template/version metadata).
  /// Does not touch its subjects - see [saveSubject]/[saveSubjects].
  Future<void> savePlan(TeachingPlan plan);

  /// Updates only [TeachingPlan.totalWeeklyHours] and
  /// [TeachingPlan.defaultLessonDurationMinutes] on an existing plan, from
  /// the simplified "Set up plan" sheet. Does not touch subjects or bump
  /// [TeachingPlan.templateVersion] - these are informational summary
  /// fields, not the per-subject breakdown.
  Future<void> savePlanSummary(
    String planId, {
    required int? totalWeeklyHours,
    required int? defaultLessonDurationMinutes,
  });

  /// Adds/updates one subject in a plan. Bumps the parent plan's
  /// [TeachingPlan.templateVersion] so version-sensitive consumers can tell
  /// the plan changed.
  Future<void> saveSubject(TeachingPlanSubject subject);

  /// Adds/updates several subjects in one plan as a single atomic batch -
  /// used by "Use curriculum template" (copying another plan's subjects)
  /// and "Build from school subjects" (adding several at once). Bumps the
  /// parent plan's [TeachingPlan.templateVersion] once for the whole batch.
  Future<void> saveSubjects(List<TeachingPlanSubject> subjects);

  Future<void> removeSubject(String planId, String subjectId);

  Future<void> saveClassOverride(ClassPlanOverride override);

  /// Deletes a single class override, restoring inheritance from the level
  /// plan for that one subject.
  Future<void> deleteClassOverride(String overrideId);

  /// Deletes every override for [classId] under [planId], restoring full
  /// inheritance from the level plan.
  Future<void> resetClassToInherited(String planId, String classId);
}
