import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';

abstract class EnrollmentSetupWizardEvent extends Equatable {
  const EnrollmentSetupWizardEvent();
  @override
  List<Object?> get props => [];
}

/// Launches the wizard for an already-admitted student. Sets the student's
/// status to [StudentStatus.enrollmentInProgress] (via repository) so an
/// admin who exits mid-wizard can see and resume it later.
class WizardStarted extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  final String studentId;
  final String schoolId;
  final String schoolCode;
  final String uniqueSystemId;
  final String studentCode;
  final String admissionNumber;
  final String academicYearId;
  final String classId;
  final String? streamId;

  const WizardStarted({
    required this.operatorUser,
    required this.studentId,
    required this.schoolId,
    required this.schoolCode,
    required this.uniqueSystemId,
    required this.studentCode,
    required this.admissionNumber,
    required this.academicYearId,
    required this.classId,
    this.streamId,
  });

  @override
  List<Object?> get props => [
    operatorUser,
    studentId,
    schoolId,
    schoolCode,
    uniqueSystemId,
    studentCode,
    admissionNumber,
    academicYearId,
    classId,
    streamId,
  ];
}

class WizardNextStep extends EnrollmentSetupWizardEvent {
  const WizardNextStep();
}

class WizardPreviousStep extends EnrollmentSetupWizardEvent {
  const WizardPreviousStep();
}

// Step 1: Admission
class AdmissionDetailsUpdated extends EnrollmentSetupWizardEvent {
  final StudentBoardingType boardingType;
  final String joiningStatus;
  const AdmissionDetailsUpdated({
    required this.boardingType,
    required this.joiningStatus,
  });
  @override
  List<Object?> get props => [boardingType, joiningStatus];
}

// Step 2: Academic Placement
class AcademicPlacementUpdated extends EnrollmentSetupWizardEvent {
  final String classId;
  final String? streamId;
  final String academicYearId;
  const AcademicPlacementUpdated({
    required this.classId,
    this.streamId,
    required this.academicYearId,
  });
  @override
  List<Object?> get props => [classId, streamId, academicYearId];
}

// Step 3: Finance
class FinanceDetailsUpdated extends EnrollmentSetupWizardEvent {
  final String? feeStructureId;
  final String? term;
  final double? totalBilled;
  const FinanceDetailsUpdated({
    this.feeStructureId,
    this.term,
    this.totalBilled,
  });
  @override
  List<Object?> get props => [feeStructureId, term, totalBilled];
}

class ScholarshipAwardRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  final ScholarshipAwardType type;
  final double amountOrPercentage;
  final bool isPercentage;
  final DateTime effectiveStart;
  final DateTime? effectiveEnd;
  final String reason;
  final String? supportingDocumentUrl;
  const ScholarshipAwardRequested({
    required this.operatorUser,
    required this.type,
    required this.amountOrPercentage,
    required this.isPercentage,
    required this.effectiveStart,
    this.effectiveEnd,
    required this.reason,
    this.supportingDocumentUrl,
  });
  @override
  List<Object?> get props => [
    operatorUser,
    type,
    amountOrPercentage,
    isPercentage,
    effectiveStart,
    effectiveEnd,
    reason,
    supportingDocumentUrl,
  ];
}

// Step 4: Boarding/House
class HouseSelected extends EnrollmentSetupWizardEvent {
  final String? houseId;
  const HouseSelected(this.houseId);
  @override
  List<Object?> get props => [houseId];
}

class DormitoryAssignmentRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  final String hostelId;
  final String roomId;
  final String bed;
  const DormitoryAssignmentRequested({
    required this.operatorUser,
    required this.hostelId,
    required this.roomId,
    required this.bed,
  });
  @override
  List<Object?> get props => [operatorUser, hostelId, roomId, bed];
}

// Step 5: Clubs
class ClubMembershipToggled extends EnrollmentSetupWizardEvent {
  final String clubId;
  final bool join;
  const ClubMembershipToggled(this.clubId, this.join);
  @override
  List<Object?> get props => [clubId, join];
}

class ClubMembershipsSaveRequested extends EnrollmentSetupWizardEvent {
  const ClubMembershipsSaveRequested();
}

// Step 6: Parent/Guardian
class ParentLinkRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  final String phoneNumber;
  final String? parentName;
  final bool isLegalGuardian;
  final bool isPrimaryGuardian;
  final bool financialAccess;
  final bool pickupAuthorized;
  const ParentLinkRequested({
    required this.operatorUser,
    required this.phoneNumber,
    this.parentName,
    this.isLegalGuardian = false,
    this.isPrimaryGuardian = false,
    this.financialAccess = false,
    this.pickupAuthorized = false,
  });
  @override
  List<Object?> get props => [
    operatorUser,
    phoneNumber,
    parentName,
    isLegalGuardian,
    isPrimaryGuardian,
    financialAccess,
    pickupAuthorized,
  ];
}

class ParentLinkSkipped extends EnrollmentSetupWizardEvent {
  const ParentLinkSkipped();
}

// Step 7: Student Identity
class IdentityPreviewRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  const IdentityPreviewRequested(this.operatorUser);
  @override
  List<Object?> get props => [operatorUser];
}

class NfcRegistrationRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  final String credentialValue;
  const NfcRegistrationRequested({
    required this.operatorUser,
    required this.credentialValue,
  });
  @override
  List<Object?> get props => [operatorUser, credentialValue];
}

class NfcRegistrationSkipped extends EnrollmentSetupWizardEvent {
  const NfcRegistrationSkipped();
}

// Step 8: Review & Activate
class ActivationRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  const ActivationRequested(this.operatorUser);
  @override
  List<Object?> get props => [operatorUser];
}
