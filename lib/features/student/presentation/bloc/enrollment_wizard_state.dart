import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

enum EnrollmentWizardStatus { initial, loading, submitting, success, failure }

class EnrollmentWizardState extends Equatable {
  final int currentStep;
  final EnrollmentWizardStatus status;
  final String? errorMessage;

  // Data collected during the wizard
  final String studentName;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String? targetClassId;
  final String? targetStreamId;
  final String? academicYearId;
  final String? previousSchool;
  final String applicantParentName;
  final String applicantParentPhone;
  final Map<String, String> attachedDocuments;
  final Set<String> uploadingDocuments;

  // For selecting from lists
  final String admissionType; // e.g., 'New Student', 'Transfer'

  const EnrollmentWizardState({
    this.currentStep = 1,
    this.status = EnrollmentWizardStatus.initial,
    this.errorMessage,
    this.studentName = '',
    this.dateOfBirth,
    this.gender = Gender.male,
    this.targetClassId,
    this.targetStreamId,
    this.academicYearId,
    this.previousSchool,
    this.applicantParentName = '',
    this.applicantParentPhone = '',
    this.attachedDocuments = const {},
    this.uploadingDocuments = const {},
    this.admissionType = 'New Student',
  });

  EnrollmentWizardState copyWith({
    int? currentStep,
    EnrollmentWizardStatus? status,
    String? errorMessage,
    String? studentName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? targetClassId,
    String? targetStreamId,
    String? academicYearId,
    String? previousSchool,
    String? applicantParentName,
    String? applicantParentPhone,
    Map<String, String>? attachedDocuments,
    Set<String>? uploadingDocuments,
    String? admissionType,
  }) {
    return EnrollmentWizardState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage,
      studentName: studentName ?? this.studentName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      targetClassId: targetClassId ?? this.targetClassId,
      targetStreamId: targetStreamId ?? this.targetStreamId,
      academicYearId: academicYearId ?? this.academicYearId,
      previousSchool: previousSchool ?? this.previousSchool,
      applicantParentName: applicantParentName ?? this.applicantParentName,
      applicantParentPhone: applicantParentPhone ?? this.applicantParentPhone,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      uploadingDocuments: uploadingDocuments ?? this.uploadingDocuments,
      admissionType: admissionType ?? this.admissionType,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    status,
    errorMessage,
    studentName,
    dateOfBirth,
    gender,
    targetClassId,
    targetStreamId,
    academicYearId,
    previousSchool,
    applicantParentName,
    applicantParentPhone,
    attachedDocuments,
    uploadingDocuments,
    admissionType,
  ];

  bool get isFirstStep => currentStep == 1;
  bool get isLastStep => currentStep == 12;
  double get progress => currentStep / 12;

  // Whether the current step's required fields are filled in, used to
  // gate the Continue button so users can't skip ahead with blank data.
  bool get canContinue {
    switch (currentStep) {
      case 4:
        return studentName.trim().isNotEmpty && dateOfBirth != null;
      case 6:
        return applicantParentName.trim().isNotEmpty &&
            applicantParentPhone.trim().isNotEmpty;
      case 7:
        return targetClassId != null && academicYearId != null;
      default:
        return true;
    }
  }
}
