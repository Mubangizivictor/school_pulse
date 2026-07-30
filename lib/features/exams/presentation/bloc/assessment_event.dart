import 'package:equatable/equatable.dart';
import '../../domain/entities/assessment_type.dart';
import '../../domain/entities/grading_system.dart';

abstract class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssessmentConfig extends AssessmentEvent {
  final String schoolId;
  const LoadAssessmentConfig(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class LoadMarksForEntry extends AssessmentEvent {
  final String schoolId;
  final String assessmentTypeId;
  final String subjectId;
  final String classId;

  const LoadMarksForEntry({
    required this.schoolId,
    required this.assessmentTypeId,
    required this.subjectId,
    required this.classId,
  });

  @override
  List<Object?> get props => [schoolId, assessmentTypeId, subjectId, classId];
}

class UpdateMarkLocal extends AssessmentEvent {
  final String studentId;
  final double? score;
  final String? comment;

  const UpdateMarkLocal({
    required this.studentId,
    this.score,
    this.comment,
  });

  @override
  List<Object?> get props => [studentId, score, comment];
}

class AddAssessmentType extends AssessmentEvent {
  final String schoolId;
  final AssessmentType assessmentType;
  const AddAssessmentType(this.schoolId, this.assessmentType);

  @override
  List<Object?> get props => [schoolId, assessmentType];
}

class AddGradingSystem extends AssessmentEvent {
  final String schoolId;
  final GradingSystem gradingSystem;
  const AddGradingSystem(this.schoolId, this.gradingSystem);

  @override
  List<Object?> get props => [schoolId, gradingSystem];
}

class ModerateMarks extends AssessmentEvent {
  final List<String> markIds;
  final String moderatorId;
  const ModerateMarks(this.markIds, this.moderatorId);

  @override
  List<Object?> get props => [markIds, moderatorId];
}

class ApproveMarks extends AssessmentEvent {
  final List<String> markIds;
  final String approverId;
  const ApproveMarks(this.markIds, this.approverId);

  @override
  List<Object?> get props => [markIds, approverId];
}

class SaveMarksEvent extends AssessmentEvent {
  final String schoolId;
  const SaveMarksEvent(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class SubmitMarksEvent extends AssessmentEvent {
  final String schoolId;
  final List<String> markIds;
  const SubmitMarksEvent(this.schoolId, this.markIds);

  @override
  List<Object?> get props => [schoolId, markIds];
}
