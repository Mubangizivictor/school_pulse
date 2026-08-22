import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

const int kWizardStepCount = 8;

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

  // Step 1
  final StudentBoardingType? boardingType;
  final String? joiningStatus;

  // Step 2
  final String classId;
  final String? streamId;
  final String academicYearId;

  // Step 3
  final String? feeStructureId;
  final String? term;
  final double? totalBilled;
  final bool hasScholarshipAward;

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
  final bool parentLinkSkippedFlag;

  // Step 7
  final bool identityExists;
  final bool nfcRegistered;
  final bool nfcSkipped;

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
    this.boardingType,
    this.joiningStatus,
    this.classId = '',
    this.streamId,
    this.academicYearId = '',
    this.feeStructureId,
    this.term,
    this.totalBilled,
    this.hasScholarshipAward = false,
    this.houseId,
    this.hostelId,
    this.roomId,
    this.bed,
    this.dormitoryAssigned = false,
    this.selectedClubIds = const {},
    this.clubsSaved = false,
    this.parentLinked = false,
    this.parentAccessCode,
    this.parentLinkSkippedFlag = false,
    this.identityExists = false,
    this.nfcRegistered = false,
    this.nfcSkipped = false,
  });

  bool get isLastStep => currentStep == kWizardStepCount - 1;
  bool get isFirstStep => currentStep == 0;

  /// Required-for-activation checklist. Boarding/House and clubs/NFC are
  /// intentionally excluded - see the wizard spec's Review step.
  bool get canActivate =>
      academicYearId.isNotEmpty &&
      classId.isNotEmpty &&
      studentCode.isNotEmpty &&
      (parentLinked || parentLinkSkippedFlag);

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
    StudentBoardingType? boardingType,
    String? joiningStatus,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? feeStructureId,
    String? term,
    double? totalBilled,
    bool? hasScholarshipAward,
    String? houseId,
    String? hostelId,
    String? roomId,
    String? bed,
    bool? dormitoryAssigned,
    Set<String>? selectedClubIds,
    bool? clubsSaved,
    bool? parentLinked,
    String? parentAccessCode,
    bool? parentLinkSkippedFlag,
    bool? identityExists,
    bool? nfcRegistered,
    bool? nfcSkipped,
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
      boardingType: boardingType ?? this.boardingType,
      joiningStatus: joiningStatus ?? this.joiningStatus,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      academicYearId: academicYearId ?? this.academicYearId,
      feeStructureId: feeStructureId ?? this.feeStructureId,
      term: term ?? this.term,
      totalBilled: totalBilled ?? this.totalBilled,
      hasScholarshipAward: hasScholarshipAward ?? this.hasScholarshipAward,
      houseId: houseId ?? this.houseId,
      hostelId: hostelId ?? this.hostelId,
      roomId: roomId ?? this.roomId,
      bed: bed ?? this.bed,
      dormitoryAssigned: dormitoryAssigned ?? this.dormitoryAssigned,
      selectedClubIds: selectedClubIds ?? this.selectedClubIds,
      clubsSaved: clubsSaved ?? this.clubsSaved,
      parentLinked: parentLinked ?? this.parentLinked,
      parentAccessCode: parentAccessCode ?? this.parentAccessCode,
      parentLinkSkippedFlag:
          parentLinkSkippedFlag ?? this.parentLinkSkippedFlag,
      identityExists: identityExists ?? this.identityExists,
      nfcRegistered: nfcRegistered ?? this.nfcRegistered,
      nfcSkipped: nfcSkipped ?? this.nfcSkipped,
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
    boardingType,
    joiningStatus,
    classId,
    streamId,
    academicYearId,
    feeStructureId,
    term,
    totalBilled,
    hasScholarshipAward,
    houseId,
    hostelId,
    roomId,
    bed,
    dormitoryAssigned,
    selectedClubIds,
    clubsSaved,
    parentLinked,
    parentAccessCode,
    parentLinkSkippedFlag,
    identityExists,
    nfcRegistered,
    nfcSkipped,
  ];
}
