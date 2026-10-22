import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'enrollment_setup_wizard_event.dart'
    show GuardianDraft, FeePlanLineData;

const int kWizardStepCount = 12;

class EnrollmentSetupWizardState extends Equatable {
  final int currentStep; // 0-based, 0..7
  final bool isLoading;
  final bool isActivating;
  final bool activated;
  final String? error;
  final String? infoMessage;

  // Identity carried through from admission (read-only display data).
  final String? studentId;
  final String schoolId;
  final String schoolCode;
  final String uniqueSystemId;
  final String studentCode;
  final String admissionNumber;

  // Step 0: Basic Info
  final String studentName;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String? religion;
  final String? nationality;

  // Step 1: Class & Stream (front-loaded placement)
  final String selectedClassId;
  final String? selectedStreamId;

  // Step 2: Guardians
  final List<GuardianDraft> guardians;
  final bool guardiansLinked;
  final List<String> parentAccessCodes;
  final String? siblingStudentId;

  // Step 3: Health & Emergency
  final MedicalInfo? medicalInfo;
  final List<EmergencyContact> emergencyContacts;

  // Step 4: Transport
  final String? transportInfo;

  // Step 5 (was 1)
  final StudentBoardingType? boardingType;
  final String? joiningStatus;

  // Step 6 (was 2)
  final String classId;
  final String? streamId;
  final String academicYearId;

  // Step 7 (was 3) - legacy free-text fee-structure fields. Kept for read
  // compatibility with older code paths (see AdmissionService.enrollStudent)
  // but no longer written by this wizard for new enrolments - the matched
  // fee-plan fields below are the source of truth going forward.
  final String? feeStructureId;
  final String? term;
  final double? totalBilled;
  final bool hasScholarshipAward;

  // Fee-plan match (from the `findMatchingFeePlan` callable). Immutable
  // published-plan snapshot data only - never a client-typed amount. A null
  // matchedFeePlanId with billingPending true means no published plan
  // matched this learner's year/term/class/category yet; the wizard must
  // still let activation proceed (see EnrollmentSetupWizardState.canActivate)
  // and surface this plainly in the Review step.
  final String? matchedFeePlanId;
  final String? matchedFeePlanVersionId;
  final String? matchedFeePlanName;
  final int? matchedFeePlanTotalUgx;
  final List<FeePlanLineData> matchedFeePlanLines;
  final bool billingPending;

  // chargeIds of the matched plan's optional (non-required) lines the
  // learner opted into, e.g. meals or transport. Required lines are always
  // billed and never appear here.
  final Set<String> selectedFeeAddOnIds;

  // Step 4
  final String? houseId;
  final String? hostelId;
  final String? roomId;
  final String? bed;
  final bool dormitoryAssigned;

  // Step 5
  final Set<String> selectedClubIds;
  final bool clubsSaved;

  // Step 6
  final bool parentLinked;
  final String? parentAccessCode;

  // Step 7
  final bool identityExists;
  final String? qrCodeData;
  final bool nfcRegistered;
  final bool nfcSkipped;

  // Draft resume (Isar-backed, local-only; see EnrollmentSetupDraftIsar).
  final bool resumedFromDraft;
  final int completedStepCount;

  const EnrollmentSetupWizardState({
    this.currentStep = 0,
    this.isLoading = false,
    this.isActivating = false,
    this.activated = false,
    this.error,
    this.infoMessage,
    this.studentId,
    this.schoolId = '',
    this.schoolCode = '',
    this.uniqueSystemId = '',
    this.studentCode = '',
    this.admissionNumber = '',
    this.studentName = '',
    this.dateOfBirth,
    this.gender = Gender.male,
    this.religion,
    this.nationality,
    this.selectedClassId = '',
    this.selectedStreamId,
    this.guardians = const [],
    this.guardiansLinked = false,
    this.parentAccessCodes = const [],
    this.siblingStudentId,
    this.medicalInfo,
    this.emergencyContacts = const [],
    this.transportInfo,
    this.boardingType,
    this.joiningStatus,
    this.classId = '',
    this.streamId,
    this.academicYearId = '',
    this.feeStructureId,
    this.term,
    this.totalBilled,
    this.hasScholarshipAward = false,
    this.matchedFeePlanId,
    this.matchedFeePlanVersionId,
    this.matchedFeePlanName,
    this.matchedFeePlanTotalUgx,
    this.matchedFeePlanLines = const [],
    this.billingPending = true,
    this.selectedFeeAddOnIds = const {},
    this.houseId,
    this.hostelId,
    this.roomId,
    this.bed,
    this.dormitoryAssigned = false,
    this.selectedClubIds = const {},
    this.clubsSaved = false,
    this.parentLinked = false,
    this.parentAccessCode,
    this.identityExists = false,
    this.qrCodeData,
    this.nfcRegistered = false,
    this.nfcSkipped = false,
    this.resumedFromDraft = false,
    this.completedStepCount = 0,
  });

  bool get isLastStep => currentStep == kWizardStepCount - 1;
  bool get isFirstStep => currentStep == 0;

  /// Required lines plus whichever optional lines (meals, transport, etc.)
  /// the learner opted into - the amount that will actually be billed.
  int get billedFeeTotalUgx => matchedFeePlanLines
      .where((line) => line.required || selectedFeeAddOnIds.contains(line.chargeId))
      .fold(0, (sum, line) => sum + line.amountUgx);

  /// Required-for-activation checklist. Boarding/House and clubs/NFC are
  /// intentionally excluded - see the wizard spec's Review step.
  bool get canActivate =>
      academicYearId.isNotEmpty &&
      classId.isNotEmpty &&
      studentCode.isNotEmpty &&
      guardians.isNotEmpty &&
      guardiansLinked;

  EnrollmentSetupWizardState copyWith({
    int? currentStep,
    bool? isLoading,
    bool? isActivating,
    bool? activated,
    String? error,
    bool clearError = false,
    String? infoMessage,
    bool clearInfoMessage = false,
    String? studentId,
    String? schoolId,
    String? schoolCode,
    String? uniqueSystemId,
    String? studentCode,
    String? admissionNumber,
    String? studentName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? religion,
    String? nationality,
    String? selectedClassId,
    String? selectedStreamId,
    bool clearSelectedStreamId = false,
    List<GuardianDraft>? guardians,
    bool? guardiansLinked,
    List<String>? parentAccessCodes,
    String? siblingStudentId,
    MedicalInfo? medicalInfo,
    List<EmergencyContact>? emergencyContacts,
    String? transportInfo,
    StudentBoardingType? boardingType,
    String? joiningStatus,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? feeStructureId,
    String? term,
    double? totalBilled,
    bool? hasScholarshipAward,
    String? matchedFeePlanId,
    bool clearMatchedFeePlanId = false,
    String? matchedFeePlanVersionId,
    String? matchedFeePlanName,
    int? matchedFeePlanTotalUgx,
    bool clearMatchedFeePlanTotalUgx = false,
    List<FeePlanLineData>? matchedFeePlanLines,
    bool? billingPending,
    Set<String>? selectedFeeAddOnIds,
    String? houseId,
    String? hostelId,
    String? roomId,
    String? bed,
    bool? dormitoryAssigned,
    Set<String>? selectedClubIds,
    bool? clubsSaved,
    bool? parentLinked,
    String? parentAccessCode,
    bool? identityExists,
    String? qrCodeData,
    bool? nfcRegistered,
    bool? nfcSkipped,
    bool? resumedFromDraft,
    int? completedStepCount,
  }) {
    return EnrollmentSetupWizardState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      isActivating: isActivating ?? this.isActivating,
      activated: activated ?? this.activated,
      error: clearError ? null : (error ?? this.error),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
      schoolCode: schoolCode ?? this.schoolCode,
      uniqueSystemId: uniqueSystemId ?? this.uniqueSystemId,
      studentCode: studentCode ?? this.studentCode,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      studentName: studentName ?? this.studentName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      nationality: nationality ?? this.nationality,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedStreamId: clearSelectedStreamId
          ? null
          : (selectedStreamId ?? this.selectedStreamId),
      guardians: guardians ?? this.guardians,
      guardiansLinked: guardiansLinked ?? this.guardiansLinked,
      parentAccessCodes: parentAccessCodes ?? this.parentAccessCodes,
      siblingStudentId: siblingStudentId ?? this.siblingStudentId,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      transportInfo: transportInfo ?? this.transportInfo,
      boardingType: boardingType ?? this.boardingType,
      joiningStatus: joiningStatus ?? this.joiningStatus,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      academicYearId: academicYearId ?? this.academicYearId,
      feeStructureId: feeStructureId ?? this.feeStructureId,
      term: term ?? this.term,
      totalBilled: totalBilled ?? this.totalBilled,
      hasScholarshipAward: hasScholarshipAward ?? this.hasScholarshipAward,
      matchedFeePlanId: clearMatchedFeePlanId
          ? null
          : (matchedFeePlanId ?? this.matchedFeePlanId),
      matchedFeePlanVersionId: clearMatchedFeePlanId
          ? null
          : (matchedFeePlanVersionId ?? this.matchedFeePlanVersionId),
      matchedFeePlanName: clearMatchedFeePlanId
          ? null
          : (matchedFeePlanName ?? this.matchedFeePlanName),
      matchedFeePlanTotalUgx: clearMatchedFeePlanTotalUgx
          ? null
          : (matchedFeePlanTotalUgx ?? this.matchedFeePlanTotalUgx),
      matchedFeePlanLines: matchedFeePlanLines ?? this.matchedFeePlanLines,
      billingPending: billingPending ?? this.billingPending,
      selectedFeeAddOnIds: selectedFeeAddOnIds ?? this.selectedFeeAddOnIds,
      houseId: houseId ?? this.houseId,
      hostelId: hostelId ?? this.hostelId,
      roomId: roomId ?? this.roomId,
      bed: bed ?? this.bed,
      dormitoryAssigned: dormitoryAssigned ?? this.dormitoryAssigned,
      selectedClubIds: selectedClubIds ?? this.selectedClubIds,
      clubsSaved: clubsSaved ?? this.clubsSaved,
      parentLinked: parentLinked ?? this.parentLinked,
      parentAccessCode: parentAccessCode ?? this.parentAccessCode,
      identityExists: identityExists ?? this.identityExists,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      nfcRegistered: nfcRegistered ?? this.nfcRegistered,
      nfcSkipped: nfcSkipped ?? this.nfcSkipped,
      resumedFromDraft: resumedFromDraft ?? this.resumedFromDraft,
      completedStepCount: completedStepCount ?? this.completedStepCount,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isLoading,
    isActivating,
    activated,
    error,
    infoMessage,
    studentId,
    schoolId,
    schoolCode,
    uniqueSystemId,
    studentCode,
    admissionNumber,
    studentName,
    dateOfBirth,
    gender,
    religion,
    nationality,
    selectedClassId,
    selectedStreamId,
    guardians,
    guardiansLinked,
    parentAccessCodes,
    siblingStudentId,
    medicalInfo,
    emergencyContacts,
    transportInfo,
    boardingType,
    joiningStatus,
    classId,
    streamId,
    academicYearId,
    feeStructureId,
    term,
    totalBilled,
    hasScholarshipAward,
    matchedFeePlanId,
    matchedFeePlanVersionId,
    matchedFeePlanName,
    matchedFeePlanTotalUgx,
    matchedFeePlanLines,
    billingPending,
    selectedFeeAddOnIds,
    houseId,
    hostelId,
    roomId,
    bed,
    dormitoryAssigned,
    selectedClubIds,
    clubsSaved,
    parentLinked,
    parentAccessCode,
    identityExists,
    qrCodeData,
    nfcRegistered,
    nfcSkipped,
    resumedFromDraft,
    completedStepCount,
  ];
}
