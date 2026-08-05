import 'package:equatable/equatable.dart';
import '../../domain/entities/academic_intervention.dart';
import '../../domain/entities/class_observation.dart';
import '../../domain/entities/curriculum.dart';
import '../../domain/entities/lesson_tracking.dart';

abstract class DeanEvent extends Equatable {
  const DeanEvent();

  @override
  List<Object?> get props => [];
}

class AcademicDashboardRequested extends DeanEvent {}

// Curriculum & Subjects
class CurriculaRequested extends DeanEvent {}

class UpdateCurriculumRequested extends DeanEvent {
  final Curriculum curriculum;
  const UpdateCurriculumRequested(this.curriculum);
  @override
  List<Object?> get props => [curriculum];
}

class SubjectsRequested extends DeanEvent {}

class UpdateSubjectAllocationRequested extends DeanEvent {
  final String subjectId;
  final List<String> teacherIds;
  const UpdateSubjectAllocationRequested(this.subjectId, this.teacherIds);
  @override
  List<Object?> get props => [subjectId, teacherIds];
}

// Teacher Workload
class TeacherWorkloadsRequested extends DeanEvent {}

class TeacherWorkloadDetailRequested extends DeanEvent {
  final String teacherId;
  const TeacherWorkloadDetailRequested(this.teacherId);
  @override
  List<Object?> get props => [teacherId];
}

// Lesson Monitoring
class LessonRecordsRequested extends DeanEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? teacherId;
  final String? classId;
  final LessonStatus? status;

  const LessonRecordsRequested({
    this.startDate,
    this.endDate,
    this.teacherId,
    this.classId,
    this.status,
  });
  @override
  List<Object?> get props => [startDate, endDate, teacherId, classId, status];
}

// Homework Monitoring
class HomeworkRecordsRequested extends DeanEvent {
  final String? classId;
  final String? teacherId;
  final DateTime? startDate;
  final DateTime? endDate;

  const HomeworkRecordsRequested({
    this.classId,
    this.teacherId,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [classId, teacherId, startDate, endDate];
}

// Assessment & Marks QA
class PendingModerationAssessmentsRequested extends DeanEvent {}

class ApproveAssessmentMarksRequested extends DeanEvent {
  final String assessmentId;
  const ApproveAssessmentMarksRequested(this.assessmentId);
  @override
  List<Object?> get props => [assessmentId];
}

class RejectAssessmentMarksRequested extends DeanEvent {
  final String assessmentId;
  final String reason;
  const RejectAssessmentMarksRequested(this.assessmentId, this.reason);
  @override
  List<Object?> get props => [assessmentId, reason];
}

// Report Card Approval
class PendingReportApprovalsRequested extends DeanEvent {}

class ApproveReportCardsRequested extends DeanEvent {
  final List<String> reportCardIds;
  const ApproveReportCardsRequested(this.reportCardIds);
  @override
  List<Object?> get props => [reportCardIds];
}

class RejectReportCardsRequested extends DeanEvent {
  final List<String> reportCardIds;
  final String reason;
  const RejectReportCardsRequested(this.reportCardIds, this.reason);
  @override
  List<Object?> get props => [reportCardIds, reason];
}

// Performance Analytics
class PerformanceAnalyticsRequested extends DeanEvent {
  final String type;
  final String? id;
  final String? academicYear;
  final String? term;

  const PerformanceAnalyticsRequested({
    required this.type,
    this.id,
    this.academicYear,
    this.term,
  });
  @override
  List<Object?> get props => [type, id, academicYear, term];
}

// Student Academic Support & Interventions
class InterventionsRequested extends DeanEvent {}

class CreateInterventionRequested extends DeanEvent {
  final AcademicIntervention intervention;
  const CreateInterventionRequested(this.intervention);
  @override
  List<Object?> get props => [intervention];
}

class UpdateInterventionStatusRequested extends DeanEvent {
  final String id;
  final InterventionStatus status;
  final String outcomes;
  const UpdateInterventionStatusRequested(this.id, this.status, this.outcomes);
  @override
  List<Object?> get props => [id, status, outcomes];
}

// Class Observations
class ClassObservationsRequested extends DeanEvent {}

class RecordObservationRequested extends DeanEvent {
  final ClassObservation observation;
  const RecordObservationRequested(this.observation);
  @override
  List<Object?> get props => [observation];
}

// Timetable & Exams
class MasterTimetableRequested extends DeanEvent {}

class ExaminationSchedulesRequested extends DeanEvent {}

// Communication
class SendAcademicAnnouncementRequested extends DeanEvent {
  final String title;
  final String message;
  final List<String> targetRoles;
  final List<String>? targetIds;

  const SendAcademicAnnouncementRequested({
    required this.title,
    required this.message,
    required this.targetRoles,
    this.targetIds,
  });
  @override
  List<Object?> get props => [title, message, targetRoles, targetIds];
}
