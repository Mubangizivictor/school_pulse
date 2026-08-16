import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/academic_dashboard_stats.dart';
import '../entities/curriculum.dart';
import '../entities/teacher_workload.dart';
import '../entities/lesson_tracking.dart';
import '../entities/academic_intervention.dart';
import '../entities/class_observation.dart';
import '../entities/homework_record.dart';
import '../entities/assessment_moderation.dart';

abstract class DeanRepository {
  Future<Either<Failure, AcademicDashboardStats>> getAcademicDashboardStats();

  // Curriculum & Subjects
  Future<Either<Failure, List<Curriculum>>> getCurricula();
  Future<Either<Failure, void>> updateCurriculum(Curriculum curriculum);
  Future<Either<Failure, List<Subject>>> getSubjects();
  Future<Either<Failure, void>> updateSubjectAllocation(
    String subjectId,
    List<String> teacherIds,
  );

  // Teacher Workload
  Future<Either<Failure, List<TeacherWorkload>>> getTeacherWorkloads();
  Future<Either<Failure, TeacherWorkload>> getTeacherWorkloadDetail(
    String teacherId,
  );

  // Lesson Monitoring
  Future<Either<Failure, List<LessonRecord>>> getLessonRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? teacherId,
    String? classId,
    LessonStatus? status,
  });

  // Homework Monitoring
  Future<Either<Failure, List<HomeworkRecord>>> getHomeworkRecords({
    String? classId,
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Assessment & Marks QA
  Future<Either<Failure, void>> approveAssessmentMarks(String assessmentId);
  Future<Either<Failure, void>> rejectAssessmentMarks(
    String assessmentId,
    String reason,
  );
  Future<Either<Failure, List<AssessmentModeration>>>
  getPendingModerationAssessments();

  // Performance Analytics
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceAnalytics({
    required String type, // 'school', 'class', 'subject', 'teacher', 'student'
    String? id,
    String? academicYear,
    String? term,
  });

  // Student Academic Support & Interventions
  Future<Either<Failure, List<AcademicIntervention>>> getInterventions();
  Future<Either<Failure, void>> createIntervention(
    AcademicIntervention intervention,
  );
  Future<Either<Failure, void>> updateInterventionStatus(
    String id,
    InterventionStatus status,
    String outcomes,
  );

  // Class Observations
  Future<Either<Failure, List<ClassObservation>>> getClassObservations();
  Future<Either<Failure, void>> recordObservation(ClassObservation observation);

  // Timetable & Exams
  Future<Either<Failure, Map<String, dynamic>>> getMasterTimetable();
  Future<Either<Failure, List<dynamic>>> getExaminationSchedules();

  // Communication
  Future<Either<Failure, void>> sendAcademicAnnouncement({
    required String title,
    required String message,
    required List<String> targetRoles,
    List<String>? targetIds,
  });
}
