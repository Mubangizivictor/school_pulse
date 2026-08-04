import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

abstract class EnrollmentWizardEvent extends Equatable {
  const EnrollmentWizardEvent();

  @override
  List<Object?> get props => [];
}

class NextStepRequested extends EnrollmentWizardEvent {}

class PreviousStepRequested extends EnrollmentWizardEvent {}

class StepUpdated extends EnrollmentWizardEvent {
  final int step;
  const StepUpdated(this.step);
  @override
  List<Object?> get props => [step];
}

class StudentInfoUpdated extends EnrollmentWizardEvent {
  final String? name;
  final DateTime? dateOfBirth;
  final Gender? gender;
  const StudentInfoUpdated({this.name, this.dateOfBirth, this.gender});
  @override
  List<Object?> get props => [name, dateOfBirth, gender];
}

class AcademicPlacementUpdated extends EnrollmentWizardEvent {
  final String? targetClassId;
  final String? targetStreamId;
  final String? academicYearId;
  final String? previousSchool;
  const AcademicPlacementUpdated({
    this.targetClassId,
    this.targetStreamId,
    this.academicYearId,
    this.previousSchool,
  });
  @override
  List<Object?> get props => [targetClassId, targetStreamId, academicYearId, previousSchool];
}

class ParentInfoUpdated extends EnrollmentWizardEvent {
  final String? name;
  final String? phone;
  const ParentInfoUpdated({this.name, this.phone});
  @override
  List<Object?> get props => [name, phone];
}

class DocumentUploaded extends EnrollmentWizardEvent {
  final String type;
  final String url;
  const DocumentUploaded(this.type, this.url);
  @override
  List<Object?> get props => [type, url];
}

class DocumentUploadStarted extends EnrollmentWizardEvent {
  final String type;
  const DocumentUploadStarted(this.type);
  @override
  List<Object?> get props => [type];
}

class DocumentUploadFailed extends EnrollmentWizardEvent {
  final String type;
  final String message;
  const DocumentUploadFailed(this.type, this.message);
  @override
  List<Object?> get props => [type, message];
}

class DocumentUploadRequested extends EnrollmentWizardEvent {
  final String type;
  final dynamic file;
  const DocumentUploadRequested(this.type, this.file);
  @override
  List<Object?> get props => [type, file];
}

class AdmissionTypeSelected extends EnrollmentWizardEvent {
  final String type;
  const AdmissionTypeSelected(this.type);
  @override
  List<Object?> get props => [type];
}

class SubmitEnrollmentRequested extends EnrollmentWizardEvent {
  final String schoolId;
  const SubmitEnrollmentRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}
