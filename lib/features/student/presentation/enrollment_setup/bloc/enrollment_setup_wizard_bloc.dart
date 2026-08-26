import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/data/enrollment_setup/datasources/enrollment_setup_draft.dart';
import 'package:school_pulse/features/student/data/enrollment_setup/datasources/enrollment_setup_draft_local_data_source.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/dormitory_assignment.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/student_club_membership.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/student/domain/services/enrollment_audit_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/finance/domain/entities/student_financial_account.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_billing_repository.dart';
import 'enrollment_setup_wizard_event.dart';
import 'enrollment_setup_wizard_state.dart';

/// Drives the 8-step post-approval Enrollment Setup Wizard. Every
/// side-effecting step checks its own `Permission.enrollment*` id via
/// [permissionEvaluator] before writing, mirroring AdmissionBloc's
/// EnrollStudentRequested handler pattern exactly.
class EnrollmentSetupWizardBloc
    extends Bloc<EnrollmentSetupWizardEvent, EnrollmentSetupWizardState> {
  final StudentRepository studentRepository;
  final AdmissionService admissionService;
  final EnrollmentSetupRepository enrollmentSetupRepository;
  final ParentLinkingService parentLinkingService;
  final CreateRelationship createRelationship;
  final StudentIdentityRepository identityRepository;
  final NfcCredentialRepository nfcCredentialRepository;
  final PermissionEvaluator permissionEvaluator;
  final EnrollmentSetupDraftLocalDataSource? draftLocalDataSource;
  final EnrollmentAuditService? auditService;
  final NotificationSendService? notificationSender;
  final FinanceRepository? financeRepository;
  final FeeBillingRepository? feeBillingRepository;

  /// Bitmask of steps (0..7) whose data has been successfully persisted at
  /// least once. Not part of [EnrollmentSetupWizardState.props] directly -
  /// exposed via [EnrollmentSetupWizardState.completedStepCount] instead -
  /// so it's tracked here rather than duplicated as raw bloc state.
  int _completedStepsMask = 0;

  EnrollmentSetupWizardBloc({
    required this.studentRepository,
    required this.admissionService,
    required this.enrollmentSetupRepository,
    required this.parentLinkingService,
    required this.createRelationship,
    required this.identityRepository,
    required this.nfcCredentialRepository,
    required this.permissionEvaluator,
    this.draftLocalDataSource,
    this.auditService,
    this.notificationSender,
    this.financeRepository,
    this.feeBillingRepository,
  }) : super(const EnrollmentSetupWizardState()) {
    on<WizardStarted>(_onWizardStarted);
    on<WizardNextStep>(_onNextStep);
    on<WizardPreviousStep>(_onPreviousStep);
    on<BasicInfoUpdated>(_onBasicInfoUpdated);
    on<ClassStreamSelected>(_onClassStreamSelected);
    on<GuardiansListUpdated>(_onGuardiansListUpdated);
    on<GuardiansLinkRequested>(_onGuardiansLinkRequested);
    on<SiblingLinkRequested>(_onSiblingLinkRequested);
    on<HealthInfoUpdated>(_onHealthInfoUpdated);
    on<TransportInfoUpdated>(_onTransportInfoUpdated);
    on<AdmissionDetailsUpdated>(_onAdmissionDetailsUpdated);
    on<AcademicPlacementUpdated>(_onAcademicPlacementUpdated);
    on<FinanceDetailsUpdated>(_onFinanceDetailsUpdated);
    on<FeePlanMatchUpdated>(_onFeePlanMatchUpdated);
    on<ScholarshipAwardRequested>(_onScholarshipAwardRequested);
    on<HouseSelected>(_onHouseSelected);
    on<DormitoryAssignmentRequested>(_onDormitoryAssignmentRequested);
    on<ClubMembershipToggled>(_onClubMembershipToggled);
    on<ClubMembershipsSaveRequested>(_onClubMembershipsSaveRequested);
    on<IdentityPreviewRequested>(_onIdentityPreviewRequested);
    on<NfcRegistrationRequested>(_onNfcRegistrationRequested);
    on<NfcRegistrationSkipped>(_onNfcRegistrationSkipped);
    on<ActivationRequested>(_onActivationRequested);
  }

  Future<bool> _allowed(String permissionId, dynamic operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((failure) => false, (value) => value);
  }

  /// Serializes every collected-but-not-yet-final wizard selection into a
  /// JSON-safe map for the local draft blob. Deliberately mirrors only the
  /// fields a resumed session needs to look/feel identical to where the
  /// operator left off - not a full state dump (loading/error/transient
  /// flags are excluded on purpose).
  Map<String, dynamic> _stateToDraftJson(EnrollmentSetupWizardState s) => {
    'studentName': s.studentName,
    'dateOfBirth': s.dateOfBirth?.toIso8601String(),
    'gender': s.gender.name,
    'religion': s.religion,
    'nationality': s.nationality,
    'selectedClassId': s.selectedClassId,
    'selectedStreamId': s.selectedStreamId,
    'guardians': s.guardians
        .map(
          (g) => {
            'name': g.name,
            'phoneNumber': g.phoneNumber,
            'type': g.type.name,
            'relationshipLabel': g.relationshipLabel,
            'email': g.email,
            'isLegalGuardian': g.isLegalGuardian,
            'isPrimaryGuardian': g.isPrimaryGuardian,
            'pickupAuthorized': g.pickupAuthorized,
          },
        )
        .toList(),
    'guardiansLinked': s.guardiansLinked,
    'parentAccessCodes': s.parentAccessCodes,
    'siblingStudentId': s.siblingStudentId,
    'medicalInfo': s.medicalInfo == null
        ? null
        : {
            'bloodGroup': s.medicalInfo!.bloodGroup,
            'allergies': s.medicalInfo!.allergies,
            'chronicConditions': s.medicalInfo!.chronicConditions,
            'medications': s.medicalInfo!.medications,
            'disabilities': s.medicalInfo!.disabilities,
          },
    'emergencyContacts': s.emergencyContacts
        .map(
          (c) => {
            'name': c.name,
            'relationship': c.relationship,
            'phoneNumber': c.phoneNumber,
            'email': c.email,
          },
        )
        .toList(),
    'transportInfo': s.transportInfo,
    'boardingType': s.boardingType?.name,
    'joiningStatus': s.joiningStatus,
    'classId': s.classId,
    'streamId': s.streamId,
    'academicYearId': s.academicYearId,
    'feeStructureId': s.feeStructureId,
    'term': s.term,
    'totalBilled': s.totalBilled,
    'hasScholarshipAward': s.hasScholarshipAward,
    'houseId': s.houseId,
    'hostelId': s.hostelId,
    'roomId': s.roomId,
    'bed': s.bed,
    'dormitoryAssigned': s.dormitoryAssigned,
    'selectedClubIds': s.selectedClubIds.toList(),
    'clubsSaved': s.clubsSaved,
    'parentLinked': s.parentLinked,
    'parentAccessCode': s.parentAccessCode,
    'identityExists': s.identityExists,
    'nfcRegistered': s.nfcRegistered,
    'nfcSkipped': s.nfcSkipped,
  };

  EnrollmentSetupWizardState _applyDraftJson(
    EnrollmentSetupWizardState s,
    Map<String, dynamic> json,
  ) {
    StudentBoardingType? boardingType;
    final boardingName = json['boardingType'] as String?;
    if (boardingName != null) {
      for (final v in StudentBoardingType.values) {
        if (v.name == boardingName) boardingType = v;
      }
    }
    final guardians = (json['guardians'] as List? ?? []).map((raw) {
      final g = (raw as Map).cast<String, dynamic>();
      final typeName = g['type'] as String?;
      final type = RelationshipType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => RelationshipType.parent,
      );
      return GuardianDraft(
        name: g['name'] as String? ?? '',
        phoneNumber: g['phoneNumber'] as String? ?? '',
        type: type,
        relationshipLabel: g['relationshipLabel'] as String? ?? '',
        email: g['email'] as String?,
        isLegalGuardian: g['isLegalGuardian'] as bool? ?? false,
        isPrimaryGuardian: g['isPrimaryGuardian'] as bool? ?? false,
        pickupAuthorized: g['pickupAuthorized'] as bool? ?? false,
      );
    }).toList();

    final medicalJson = json['medicalInfo'];
    final medicalInfo = medicalJson is Map
        ? MedicalInfo(
            bloodGroup: medicalJson['bloodGroup'] as String?,
            allergies:
                (medicalJson['allergies'] as List?)?.cast<String>() ?? const [],
            chronicConditions:
                (medicalJson['chronicConditions'] as List?)?.cast<String>() ??
                const [],
            medications: medicalJson['medications'] as String?,
            disabilities: medicalJson['disabilities'] as String?,
          )
        : null;

    final emergencyContacts = (json['emergencyContacts'] as List? ?? []).map((
      raw,
    ) {
      final c = (raw as Map).cast<String, dynamic>();
      return EmergencyContact(
        name: c['name'] as String? ?? '',
        relationship: c['relationship'] as String? ?? '',
        phoneNumber: c['phoneNumber'] as String? ?? '',
        email: c['email'] as String?,
      );
    }).toList();

    Gender gender = s.gender;
    final genderName = json['gender'] as String?;
    if (genderName != null) {
      for (final v in Gender.values) {
        if (v.name == genderName) gender = v;
      }
    }

    return s.copyWith(
      studentName: json['studentName'] as String? ?? s.studentName,
      dateOfBirth: (json['dateOfBirth'] as String?) != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : s.dateOfBirth,
      gender: gender,
      religion: json['religion'] as String?,
      nationality: json['nationality'] as String?,
      selectedClassId: json['selectedClassId'] as String? ?? s.selectedClassId,
      selectedStreamId: json['selectedStreamId'] as String?,
      clearSelectedStreamId: json['selectedStreamId'] == null,
      guardians: guardians,
      guardiansLinked: json['guardiansLinked'] as bool? ?? false,
      parentAccessCodes:
          (json['parentAccessCodes'] as List?)?.cast<String>() ?? const [],
      siblingStudentId: json['siblingStudentId'] as String?,
      medicalInfo: medicalInfo,
      emergencyContacts: emergencyContacts,
      transportInfo: json['transportInfo'] as String?,
      boardingType: boardingType,
      joiningStatus: json['joiningStatus'] as String?,
      classId: json['classId'] as String? ?? s.classId,
      streamId: json['streamId'] as String?,
      academicYearId: json['academicYearId'] as String? ?? s.academicYearId,
      feeStructureId: json['feeStructureId'] as String?,
      term: json['term'] as String?,
      totalBilled: (json['totalBilled'] as num?)?.toDouble(),
      hasScholarshipAward: json['hasScholarshipAward'] as bool? ?? false,
      houseId: json['houseId'] as String?,
      hostelId: json['hostelId'] as String?,
      roomId: json['roomId'] as String?,
      bed: json['bed'] as String?,
      dormitoryAssigned: json['dormitoryAssigned'] as bool? ?? false,
      selectedClubIds:
          (json['selectedClubIds'] as List?)?.cast<String>().toSet() ??
          const {},
      clubsSaved: json['clubsSaved'] as bool? ?? false,
      parentLinked: json['parentLinked'] as bool? ?? false,
      parentAccessCode: json['parentAccessCode'] as String?,
      identityExists: json['identityExists'] as bool? ?? false,
      nfcRegistered: json['nfcRegistered'] as bool? ?? false,
      nfcSkipped: json['nfcSkipped'] as bool? ?? false,
    );
  }

  Future<void> _persistDraft(EnrollmentSetupWizardState s) async {
    final ds = draftLocalDataSource;
    if (ds == null || s.studentId == null || s.schoolId.isEmpty) return;
    await ds.saveDraft(
      schoolId: s.schoolId,
      studentId: s.studentId!,
      currentStep: s.currentStep,
      completedStepsMask: _completedStepsMask,
      stateJson: _stateToDraftJson(s),
    );
  }

  /// Persists the draft after every emitted state once the wizard has a
  /// studentId/schoolId to key on and isn't already fully activated. This
  /// is the "every step transition and every successful step write" hook
  /// required by the wizard-draft spec - simpler and less error-prone than
  /// threading an explicit `await _persistDraft(...)` into each of the
  /// eight per-step success branches individually, and it can never miss a
  /// future step handler that forgets to call it.
  @override
  void onChange(Change<EnrollmentSetupWizardState> change) {
    super.onChange(change);
    if (change.nextState.activated) return;
    if (change.nextState.isLoading || change.nextState.isActivating) return;
    unawaited(_persistDraft(change.nextState));
  }

  void _markStepComplete(int stepIndex) {
    _completedStepsMask |= (1 << stepIndex);
  }

  Future<void> _onWizardStarted(
    WizardStarted event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        studentId: event.studentId,
        schoolId: event.schoolId,
        schoolCode: event.schoolCode,
        uniqueSystemId: event.uniqueSystemId,
        studentCode: event.studentCode,
        admissionNumber: event.admissionNumber,
        academicYearId: event.academicYearId,
        classId: event.classId,
        streamId: event.streamId,
      ),
    );

    // Mark in-progress so the student is visible/resumable if the admin
    // exits mid-wizard. Best-effort: a failure here shouldn't block the
    // wizard from opening.
    await studentRepository.updateStudentStatus(
      event.studentId,
      StudentStatus.enrollmentInProgress,
    );

    // Resume from a local draft if one exists for this student+school
    // (see EnrollmentSetupDraft - device-local only, not a security
    // boundary; Firestore rules remain the real tenant isolation). Keyed by
    // studentId+schoolId rather than auth uid so the same draft survives a
    // logout/login by any operator with wizard access to this student.
    EnrollmentSetupDraft? draft;
    final ds = draftLocalDataSource;
    if (ds != null) {
      draft = await ds.getDraft(
        schoolId: event.schoolId,
        studentId: event.studentId,
      );
    }

    if (draft != null) {
      _completedStepsMask = draft.completedStepsMask;
      Map<String, dynamic> decoded = const {};
      try {
        final raw = jsonDecode(draft.stateJson);
        if (raw is Map) decoded = raw.cast<String, dynamic>();
      } catch (_) {
        // Corrupt/legacy draft blob - fall back to a fresh wizard rather
        // than surfacing a decode error to the operator.
      }
      final restored = _applyDraftJson(state, decoded).copyWith(
        currentStep: draft.currentStep,
        isLoading: false,
        resumedFromDraft: true,
        completedStepCount: draft.completedStepCount,
      );
      emit(restored);
      return;
    }

    // No draft - prefill the front-loaded steps from whatever the student
    // doc already carries (set at admission time, e.g. from
    // AdmissionApplication via admitStudent()) so a fresh wizard doesn't
    // ask for name/DOB/gender/class again when they're already known.
    final existing = await _loadCurrentStudent();
    emit(
      (existing == null
              ? state
              : state.copyWith(
                  studentName: existing.name,
                  dateOfBirth: existing.dateOfBirth,
                  gender: existing.gender,
                  religion: existing.religion,
                  nationality: existing.nationality,
                  selectedClassId: existing.classId,
                  selectedStreamId: existing.streamId,
                  clearSelectedStreamId: existing.streamId == null,
                  medicalInfo: existing.medicalInfo,
                  emergencyContacts: existing.emergencyContacts,
                  transportInfo: existing.transportInfo,
                ))
          .copyWith(isLoading: false, completedStepCount: 0),
    );
  }

  void _onNextStep(
    WizardNextStep event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    if (state.isLastStep) return;
    _markStepComplete(state.currentStep);
    emit(
      state.copyWith(
        currentStep: state.currentStep + 1,
        clearError: true,
        clearInfoMessage: true,
        completedStepCount: _popcount(_completedStepsMask),
      ),
    );
  }

  void _onPreviousStep(
    WizardPreviousStep event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    if (state.isFirstStep) return;
    emit(
      state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
        clearInfoMessage: true,
      ),
    );
  }

  static int _popcount(int mask) {
    var count = 0;
    var m = mask;
    while (m != 0) {
      count += m & 1;
      m >>= 1;
    }
    return count;
  }

  /// Loads and mutates the student doc for the front-loaded steps
  /// (Basic Info, Class & Stream, Health, Transport). `recordedBy` uses
  /// [state.schoolId] as a placeholder acting id is not available here -
  /// these are draft-local edits until Review & Activate; the actual
  /// enrolment history recordedBy is attributed at admitStudent() time.
  Future<Student?> _loadCurrentStudent() async {
    if (state.studentId == null) return null;
    final result = await studentRepository.getStudentById(state.studentId!);
    return result.fold((_) => null, (s) => s);
  }

  void _onBasicInfoUpdated(
    BasicInfoUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(
      state.copyWith(
        studentName: event.name,
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        religion: event.religion,
        nationality: event.nationality,
      ),
    );
  }

  void _onClassStreamSelected(
    ClassStreamSelected event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(
      state.copyWith(
        selectedClassId: event.classId,
        selectedStreamId: event.streamId,
        clearSelectedStreamId: event.streamId == null,
        // Keep the later Academic Placement step's classId/streamId in
        // sync so a student who never revisits step 6 still lands on the
        // class picked here.
        classId: event.classId,
        streamId: event.streamId,
      ),
    );
  }

  void _onGuardiansListUpdated(
    GuardiansListUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(state.copyWith(guardians: event.guardians, guardiansLinked: false));
  }

  Future<void> _onGuardiansLinkRequested(
    GuardiansLinkRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    final allowed = await _allowed(
      Permission.enrollmentParentLink,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        state.copyWith(
          error: 'You do not have permission to link a parent/guardian.',
        ),
      );
      return;
    }
    if (state.studentId == null || state.guardians.isEmpty) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final codes = <String>[];
    for (final guardian in state.guardians) {
      final linkResult = await parentLinkingService.linkStudentToParent(
        studentId: state.studentId!,
        studentName: state.studentCode,
        schoolId: state.schoolId,
        phoneNumber: guardian.phoneNumber,
        parentName: guardian.name,
        createdBy: event.operatorUser.id,
      );
      final failure = linkResult.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(state.copyWith(isLoading: false, error: failure.message));
        return;
      }
      final code = linkResult.fold((_) => null, (c) => c);
      if (code != null) codes.add(code);

      await createRelationship(
        CreateRelationshipParams(
          schoolId: state.schoolId,
          studentId: state.studentId!,
          parentCode: code,
          type: guardian.type,
          isLegalGuardian: guardian.isLegalGuardian,
          isPrimaryGuardian: guardian.isPrimaryGuardian,
          createdBy: event.operatorUser.id,
          pickupAuthorized: guardian.pickupAuthorized,
        ),
      );
    }

    auditService?.record(
      schoolId: state.schoolId,
      action: 'enrollment_guardians_linked',
      studentId: state.studentId,
    );

    emit(
      state.copyWith(
        isLoading: false,
        guardiansLinked: true,
        parentAccessCodes: codes,
        // Mirror onto the later single-guardian Parent/Guardian step's
        // fields too so its already-linked branch renders and Review's
        // "Parent linked" check is satisfied without asking twice.
        parentLinked: true,
        parentAccessCode: codes.isNotEmpty ? codes.first : null,
      ),
    );
  }

  void _onSiblingLinkRequested(
    SiblingLinkRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(state.copyWith(siblingStudentId: event.siblingStudentId));
  }

  Future<void> _onHealthInfoUpdated(
    HealthInfoUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        medicalInfo: event.medicalInfo,
        emergencyContacts: event.emergencyContacts,
      ),
    );
    final current = await _loadCurrentStudent();
    if (current == null) return;
    await studentRepository.updateStudent(
      current.copyWith(
        medicalInfo: event.medicalInfo,
        emergencyContacts: event.emergencyContacts,
      ),
      recordedBy: state.schoolId,
    );
  }

  Future<void> _onTransportInfoUpdated(
    TransportInfoUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    emit(state.copyWith(transportInfo: event.transportInfo));
    final current = await _loadCurrentStudent();
    if (current == null) return;
    await studentRepository.updateStudent(
      current.copyWith(transportInfo: event.transportInfo),
      recordedBy: state.schoolId,
    );
  }

  void _onAdmissionDetailsUpdated(
    AdmissionDetailsUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(
      state.copyWith(
        boardingType: event.boardingType,
        joiningStatus: event.joiningStatus,
      ),
    );
  }

  Future<void> _onAcademicPlacementUpdated(
    AcademicPlacementUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    emit(
      state.copyWith(
        classId: event.classId,
        streamId: event.streamId,
        academicYearId: event.academicYearId,
      ),
    );
  }

  void _onFinanceDetailsUpdated(
    FinanceDetailsUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(
      state.copyWith(
        feeStructureId: event.feeStructureId,
        term: event.term,
        totalBilled: event.totalBilled,
      ),
    );

    // Best-effort: land the computed bill in the same
    // StudentFinancialAccount collection the bursar dashboard already
    // reads from (BursarStudentProjectionService), so this student shows
    // up billed without a separate finance-side data entry step. Fire and
    // forget - Finance isn't required to complete the wizard, and a write
    // failure here shouldn't block enrollment.
    final financeRepo = financeRepository;
    final studentId = state.studentId;
    if (financeRepo == null ||
        studentId == null ||
        event.feeStructureId == null ||
        event.totalBilled == null) {
      return;
    }
    unawaited(
      financeRepo.updateStudentFinancialAccount(
        StudentFinancialAccount(
          studentId: studentId,
          schoolId: state.schoolId,
          academicYear: state.academicYearId,
          term: event.term ?? '',
          feeStructureId: event.feeStructureId!,
          discountAmount: event.discountAmount ?? 0,
          totalBilled: event.totalBilled!,
          totalPaid: 0,
          paymentHistory: const [],
        ),
      ),
    );
  }

  /// Records the result of `findMatchingFeePlan` for the review step and
  /// eventual `issueStudentBill` call. Unlike [_onFinanceDetailsUpdated],
  /// this never writes into the legacy fee_structures/student_financials
  /// collections - a matched (or absent) fee plan is a read-only snapshot
  /// until activation actually issues a bill.
  void _onFeePlanMatchUpdated(
    FeePlanMatchUpdated event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(
      state.copyWith(
        matchedFeePlanId: event.planId,
        clearMatchedFeePlanId: event.planId == null,
        matchedFeePlanVersionId: event.versionId,
        matchedFeePlanName: event.planName,
        matchedFeePlanTotalUgx: event.totalUgx,
        clearMatchedFeePlanTotalUgx: event.totalUgx == null,
        matchedFeePlanLines: event.lines,
        billingPending: event.billingPending,
      ),
    );
  }

  Future<void> _onScholarshipAwardRequested(
    ScholarshipAwardRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    if (event.type == ScholarshipAwardType.none) return;

    final allowed = await _allowed(
      Permission.enrollmentBursaryAssign,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        state.copyWith(
          error: 'You do not have permission to assign a scholarship/discount.',
        ),
      );
      return;
    }

    if (state.studentId == null) return;
    emit(state.copyWith(isLoading: true, clearError: true));

    final award = ScholarshipAward(
      id: '',
      schoolId: state.schoolId,
      studentId: state.studentId!,
      type: event.type,
      amountOrPercentage: event.amountOrPercentage,
      isPercentage: event.isPercentage,
      effectiveStart: event.effectiveStart,
      effectiveEnd: event.effectiveEnd,
      approvedBy: event.operatorUser.id,
      reason: event.reason,
      supportingDocumentUrl: event.supportingDocumentUrl,
      createdAt: DateTime.now(),
    );

    final result = await enrollmentSetupRepository.createScholarshipAward(
      award,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        auditService?.record(
          schoolId: state.schoolId,
          action: 'enrollment_bursary_assigned',
          studentId: state.studentId,
          reason: event.reason,
        );
        emit(state.copyWith(isLoading: false, hasScholarshipAward: true));
      },
    );
  }

  void _onHouseSelected(
    HouseSelected event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(state.copyWith(houseId: event.houseId));
  }

  Future<void> _onDormitoryAssignmentRequested(
    DormitoryAssignmentRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    final allowed = await _allowed(
      Permission.enrollmentBoardingAssign,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        state.copyWith(
          error: 'You do not have permission to assign boarding placement.',
        ),
      );
      return;
    }
    if (state.studentId == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final assignment = DormitoryAssignment(
      id: '',
      studentId: state.studentId!,
      schoolId: state.schoolId,
      hostelId: event.hostelId,
      roomId: event.roomId,
      bed: event.bed,
      assignedAt: DateTime.now(),
      assignedBy: event.operatorUser.id,
    );

    final result = await enrollmentSetupRepository.assignDormitory(assignment);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (saved) => emit(
        state.copyWith(
          isLoading: false,
          hostelId: saved.hostelId,
          roomId: saved.roomId,
          bed: saved.bed,
          dormitoryAssigned: true,
        ),
      ),
    );
  }

  void _onClubMembershipToggled(
    ClubMembershipToggled event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    final updated = Set<String>.from(state.selectedClubIds);
    if (event.join) {
      updated.add(event.clubId);
    } else {
      updated.remove(event.clubId);
    }
    emit(state.copyWith(selectedClubIds: updated, clubsSaved: false));
  }

  Future<void> _onClubMembershipsSaveRequested(
    ClubMembershipsSaveRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    if (state.studentId == null || state.selectedClubIds.isEmpty) {
      emit(state.copyWith(clubsSaved: true));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));

    for (final clubId in state.selectedClubIds) {
      final membership = StudentClubMembership(
        id: '',
        studentId: state.studentId!,
        schoolId: state.schoolId,
        clubId: clubId,
        joinedAt: DateTime.now(),
      );
      final result = await enrollmentSetupRepository.joinClub(membership);
      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(state.copyWith(isLoading: false, error: failure.message));
        return;
      }
    }
    emit(state.copyWith(isLoading: false, clubsSaved: true));
  }

  Future<void> _onIdentityPreviewRequested(
    IdentityPreviewRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    final allowed = await _allowed(
      Permission.enrollmentIdentityManage,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        state.copyWith(
          error: 'You do not have permission to view identity setup.',
        ),
      );
      return;
    }
    if (state.studentId == null) return;

    // getStudentIdentity issues-or-loads rather than returning null when
    // none exists yet, so a Right here always means "identity now exists
    // (freshly issued or previously issued)" - this step is display/
    // preview only per spec, so this is safe to call for the preview.
    final result = await identityRepository.getStudentIdentity(
      state.studentId!,
    );
    result.fold(
      (_) => emit(state.copyWith(identityExists: false)),
      (identity) => emit(
        state.copyWith(identityExists: true, qrCodeData: identity.qrCodeData),
      ),
    );
  }

  Future<void> _onNfcRegistrationRequested(
    NfcRegistrationRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    final allowed = await _allowed(
      Permission.enrollmentCardGenerate,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        state.copyWith(
          error: 'You do not have permission to register an NFC card.',
        ),
      );
      return;
    }
    if (state.studentId == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final existing = await nfcCredentialRepository.findAssignedCredential(
      identityId: state.studentId!,
      schoolId: state.schoolId,
    );
    final alreadyAssigned = existing.fold((_) => null, (v) => v);
    if (alreadyAssigned != null) {
      emit(state.copyWith(isLoading: false, nfcRegistered: true));
      return;
    }

    final result = await nfcCredentialRepository.assign(
      credentialValue: event.credentialValue,
      identityId: state.studentId!,
      identityType: 'student',
      schoolId: state.schoolId,
      studentId: state.studentId,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, nfcRegistered: true)),
    );
  }

  void _onNfcRegistrationSkipped(
    NfcRegistrationSkipped event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(state.copyWith(nfcSkipped: true));
  }

  Future<void> _onActivationRequested(
    ActivationRequested event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) async {
    // Idempotency: disable on first press. A second dispatch while already
    // activating/activated is a no-op.
    if (state.isActivating || state.activated) return;

    final allowed = await _allowed(
      Permission.enrollmentActivate,
      event.operatorUser,
    );
    if (!allowed) {
      emit(
        state.copyWith(
          error: 'You do not have permission to activate this student.',
        ),
      );
      return;
    }
    if (state.studentId == null || !state.canActivate) {
      emit(
        state.copyWith(error: 'Complete the required steps before activating.'),
      );
      return;
    }

    emit(state.copyWith(isActivating: true, clearError: true));

    // Deliberately omits feeStructureId/totalBilled: new enrolments no
    // longer write through the legacy free-text financial-initialization
    // path (InitializeStudentFinancials / student_financials collection).
    // enrollStudent() only calls that usecase when both are non-null, so
    // leaving them unset here is what retires it for this path - the
    // usecase itself is left intact for any other legacy caller. Billing
    // for this student instead happens via issueStudentBill below, driven
    // by state.matchedFeePlanId from the Finance step's findMatchingFeePlan
    // call.
    final result = await admissionService.enrollStudent(
      state.studentId!,
      schoolId: state.schoolId,
      uniqueSystemId: state.uniqueSystemId,
      studentCode: state.studentCode,
      academicYear: state.academicYearId,
      term: state.term,
    );

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(isActivating: false, error: failure.message));
      return;
    }

    auditService?.record(
      schoolId: state.schoolId,
      action: 'enrollment_activated',
      studentId: state.studentId,
    );

    // Issue the bill only when a published fee plan actually matched during
    // the Finance step - a billingPending student is a real, allowed state
    // (see EnrollmentSetupWizardState.billingPending) and simply gets no
    // bill yet. The idempotency key mirrors the backend's own default
    // ('${studentId}_${planId}') exactly so a retry of this same activation
    // (e.g. app restarted after this call failed) can never create a
    // duplicate bill - issueStudentBill's transaction is a no-op if a bill
    // with this id already exists. Done before emitting `activated: true` so
    // any billing-failure message lands in the same state as activation
    // succeeding - the UI pops on `activated`, so an emit after that point
    // would never be seen.
    String? billingInfoMessage;
    final billing = feeBillingRepository;
    final matchedPlanId = state.matchedFeePlanId;
    if (billing != null && matchedPlanId != null && state.studentId != null) {
      final billResult = await billing.issueStudentBill(
        schoolId: state.schoolId,
        studentId: state.studentId!,
        planId: matchedPlanId,
        idempotencyKey: '${state.studentId}_$matchedPlanId',
      );
      final billFailure = billResult.fold((f) => f, (_) => null);
      if (billFailure != null) {
        // Best-effort: activation itself already succeeded and must not be
        // rolled back for a billing hiccup.
        billingInfoMessage =
            'Student activated, but billing could not be issued yet '
            '(${billFailure.message}). Retry from the student account.';
      }
    }

    emit(
      state.copyWith(
        isActivating: false,
        activated: true,
        infoMessage: billingInfoMessage,
      ),
    );

    // Only notify the parent if one was actually linked during the wizard -
    // studentParents resolves recipients server-side from
    // parent_student_relationships, so an unlinked/skipped student simply
    // reaches nobody rather than erroring.
    if (state.parentLinked && state.studentId != null) {
      notificationSender?.send(
        sender: event.operatorUser,
        audience: NotificationAudience(
          kind: NotificationAudienceKind.studentParents,
          studentIds: [state.studentId!],
        ),
        category: NotificationCategory.others,
        type: NotificationType.custom,
        title: 'Enrollment complete',
        body: '${state.studentCode} has been fully enrolled and activated.',
        sourceModule: 'enrollment',
        sourceEntityId: state.studentId,
        relatedStudentId: state.studentId,
      );
    }

    // Activation succeeded - the wizard's job is done, so the local resume
    // draft is no longer needed. Best-effort: a failure to delete it isn't
    // worth surfacing to the operator (getDraft on a future launch simply
    // won't find one worth resuming once StudentStatus is no longer
    // enrollmentInProgress).
    final ds = draftLocalDataSource;
    if (ds != null && state.studentId != null && state.schoolId.isNotEmpty) {
      await ds.deleteDraft(
        schoolId: state.schoolId,
        studentId: state.studentId!,
      );
    }
  }
}
