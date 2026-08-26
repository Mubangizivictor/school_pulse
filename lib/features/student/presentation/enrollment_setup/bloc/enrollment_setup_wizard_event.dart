import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
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

// Step 0: Basic Info
class BasicInfoUpdated extends EnrollmentSetupWizardEvent {
  final String name;
  final DateTime dateOfBirth;
  final Gender gender;
  final String? religion;
  final String? nationality;
  const BasicInfoUpdated({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.religion,
    this.nationality,
  });
  @override
  List<Object?> get props => [name, dateOfBirth, gender, religion, nationality];
}

// Step 1: Class & Stream (front-loaded placement, distinct from the later
// Academic Placement step which also covers subjects/teachers).
class ClassStreamSelected extends EnrollmentSetupWizardEvent {
  final String classId;
  final String? streamId;
  const ClassStreamSelected({required this.classId, this.streamId});
  @override
  List<Object?> get props => [classId, streamId];
}

// Step 2: Guardians (multi-guardian list)
class GuardianDraft extends Equatable {
  final String name;
  final String phoneNumber;
  final RelationshipType type;
  final String relationshipLabel; // e.g. "Father", "Mother", "Guardian"
  final String? email;
  final bool isLegalGuardian;
  final bool isPrimaryGuardian;
  final bool pickupAuthorized;

  const GuardianDraft({
    required this.name,
    required this.phoneNumber,
    required this.type,
    required this.relationshipLabel,
    this.email,
    this.isLegalGuardian = false,
    this.isPrimaryGuardian = false,
    this.pickupAuthorized = false,
  });

  GuardianDraft copyWith({
    String? name,
    String? phoneNumber,
    RelationshipType? type,
    String? relationshipLabel,
    String? email,
    bool? isLegalGuardian,
    bool? isPrimaryGuardian,
    bool? pickupAuthorized,
  }) {
    return GuardianDraft(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      type: type ?? this.type,
      relationshipLabel: relationshipLabel ?? this.relationshipLabel,
      email: email ?? this.email,
      isLegalGuardian: isLegalGuardian ?? this.isLegalGuardian,
      isPrimaryGuardian: isPrimaryGuardian ?? this.isPrimaryGuardian,
      pickupAuthorized: pickupAuthorized ?? this.pickupAuthorized,
    );
  }

  @override
  List<Object?> get props => [
    name,
    phoneNumber,
    type,
    relationshipLabel,
    email,
    isLegalGuardian,
    isPrimaryGuardian,
    pickupAuthorized,
  ];
}

class GuardiansListUpdated extends EnrollmentSetupWizardEvent {
  final List<GuardianDraft> guardians;
  const GuardiansListUpdated(this.guardians);
  @override
  List<Object?> get props => [guardians];
}

class GuardiansLinkRequested extends EnrollmentSetupWizardEvent {
  final UserEntity operatorUser;
  const GuardiansLinkRequested(this.operatorUser);
  @override
  List<Object?> get props => [operatorUser];
}

class SiblingLinkRequested extends EnrollmentSetupWizardEvent {
  final String siblingStudentId;
  const SiblingLinkRequested(this.siblingStudentId);
  @override
  List<Object?> get props => [siblingStudentId];
}

// Step 3: Health & Emergency
class HealthInfoUpdated extends EnrollmentSetupWizardEvent {
  final MedicalInfo medicalInfo;
  final List<EmergencyContact> emergencyContacts;
  const HealthInfoUpdated({
    required this.medicalInfo,
    required this.emergencyContacts,
  });
  @override
  List<Object?> get props => [medicalInfo, emergencyContacts];
}

// Step 4: Transport
class TransportInfoUpdated extends EnrollmentSetupWizardEvent {
  final String? transportInfo;
  const TransportInfoUpdated(this.transportInfo);
  @override
  List<Object?> get props => [transportInfo];
}

// Step 5 (was 1): Admission
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

  /// Itemized breakdown (tuition + line items) as read from the matched
  /// `finance.FeeStructure`, kept only for display in Review - the source
  /// of truth for the amount actually billed is [totalBilled].
  final Map<String, double>? itemizedBreakdown;
  final double? discountAmount;
  final double? discountPercentage;

  const FinanceDetailsUpdated({
    this.feeStructureId,
    this.term,
    this.totalBilled,
    this.itemizedBreakdown,
    this.discountAmount,
    this.discountPercentage,
  });
  @override
  List<Object?> get props => [
    feeStructureId,
    term,
    totalBilled,
    itemizedBreakdown,
    discountAmount,
    discountPercentage,
  ];
}

/// One line item from a matched, published fee-plan version (see
/// `functions/student_fee_billing.js` `findMatchingFeePlan`). Amounts are
/// always integer UGX - this is a read-only display/audit snapshot, never
/// something the wizard can edit.
class FeePlanLineData extends Equatable {
  final String chargeId;
  final String name;
  final int amountUgx;
  final bool required;
  final String? serviceKey;

  const FeePlanLineData({
    required this.chargeId,
    required this.name,
    required this.amountUgx,
    this.required = true,
    this.serviceKey,
  });

  @override
  List<Object?> get props => [chargeId, name, amountUgx, required, serviceKey];
}

/// Replaces the legacy [FinanceDetailsUpdated] free-text path for new
/// enrolments: carries the result of calling `findMatchingFeePlan` (a
/// published plan match, or none - billing pending) rather than a
/// client-typed amount. See enrollment_setup_wizard_screen.dart's
/// `_FinanceStep`.
class FeePlanMatchUpdated extends EnrollmentSetupWizardEvent {
  final String? planId;
  final String? versionId;
  final String? planName;
  final int? totalUgx;
  final List<FeePlanLineData> lines;
  final bool billingPending;

  const FeePlanMatchUpdated({
    this.planId,
    this.versionId,
    this.planName,
    this.totalUgx,
    this.lines = const [],
    required this.billingPending,
  });

  @override
  List<Object?> get props => [
    planId,
    versionId,
    planName,
    totalUgx,
    lines,
    billingPending,
  ];
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
