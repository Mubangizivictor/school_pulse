import 'package:equatable/equatable.dart';
import '../../domain/entities/academic_dashboard_stats.dart';
import '../../domain/entities/academic_intervention.dart';
import '../../domain/entities/class_observation.dart';
import '../../domain/entities/curriculum.dart';
import '../../domain/entities/lesson_tracking.dart';
import '../../domain/entities/teacher_workload.dart';
import '../../domain/entities/homework_record.dart';
import '../../domain/entities/assessment_moderation.dart';
import '../../domain/entities/today_operations.dart';

abstract class DeanState extends Equatable {
  const DeanState();

  @override
  List<Object?> get props => [];
}

class DeanInitial extends DeanState {}

class DeanLoading extends DeanState {}

class AcademicDashboardLoaded extends DeanState {
  final AcademicDashboardStats stats;
  const AcademicDashboardLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class CurriculaLoaded extends DeanState {
  final List<Curriculum> curricula;
  const CurriculaLoaded(this.curricula);
  @override
  List<Object?> get props => [curricula];
}

class SubjectsLoaded extends DeanState {
  final List<Subject> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  List<Object?> get props => [subjects];
}

class TeacherWorkloadsLoaded extends DeanState {
  final List<TeacherWorkload> workloads;
  const TeacherWorkloadsLoaded(this.workloads);
  @override
  List<Object?> get props => [workloads];
}

class TeacherWorkloadDetailLoaded extends DeanState {
  final TeacherWorkload workload;
  const TeacherWorkloadDetailLoaded(this.workload);
  @override
  List<Object?> get props => [workload];
}

class LessonRecordsLoaded extends DeanState {
  final List<LessonRecord> records;
  const LessonRecordsLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class HomeworkRecordsLoaded extends DeanState {
  final List<HomeworkRecord> records;
  const HomeworkRecordsLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class PendingModerationAssessmentsLoaded extends DeanState {
  final List<AssessmentModeration> assessments;
  const PendingModerationAssessmentsLoaded(this.assessments);
  @override
  List<Object?> get props => [assessments];
}

class PerformanceAnalyticsLoaded extends DeanState {
  final Map<String, dynamic> analytics;
  const PerformanceAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class InterventionsLoaded extends DeanState {
  final List<AcademicIntervention> interventions;
  const InterventionsLoaded(this.interventions);
  @override
  List<Object?> get props => [interventions];
}

class ClassObservationsLoaded extends DeanState {
  final List<ClassObservation> observations;
  const ClassObservationsLoaded(this.observations);
  @override
  List<Object?> get props => [observations];
}

class MasterTimetableLoaded extends DeanState {
  final Map<String, dynamic> timetable;
  const MasterTimetableLoaded(this.timetable);
  @override
  List<Object?> get props => [timetable];
}

class ExaminationSchedulesLoaded extends DeanState {
  final List<dynamic> schedules;
  const ExaminationSchedulesLoaded(this.schedules);
  @override
  List<Object?> get props => [schedules];
}

class TodaysOperationsLoaded extends DeanState {
  final TodaysOperations operations;
  const TodaysOperationsLoaded(this.operations);
  @override
  List<Object?> get props => [operations];
}

class MissedLessonsLoaded extends DeanState {
  final List<LessonRecord> lessons;
  final Map<String, bool> resolvedById;
  const MissedLessonsLoaded(this.lessons, this.resolvedById);
  @override
  List<Object?> get props => [lessons, resolvedById];
}

class AssessmentsOverviewLoaded extends DeanState {
  final List<AssessmentModeration> assessments;
  const AssessmentsOverviewLoaded(this.assessments);
  @override
  List<Object?> get props => [assessments];
}

class StudentAcademicProfileLoaded extends DeanState {
  final Map<String, dynamic> profile;
  const StudentAcademicProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class DeanOperationSuccess extends DeanState {
  final String message;
  const DeanOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DeanError extends DeanState {
  final String message;
  const DeanError(this.message);
  @override
  List<Object?> get props => [message];
}
