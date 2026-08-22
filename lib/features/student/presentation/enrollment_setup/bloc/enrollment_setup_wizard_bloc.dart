import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/dormitory_assignment.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/student_club_membership.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
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

  EnrollmentSetupWizardBloc({
    required this.studentRepository,
    required this.admissionService,
    required this.enrollmentSetupRepository,
    required this.parentLinkingService,
    required this.createRelationship,
    required this.identityRepository,
    required this.nfcCredentialRepository,
    required this.permissionEvaluator,
  }) : super(const EnrollmentSetupWizardState()) {
    on<WizardStarted>(_onWizardStarted);
    on<WizardNextStep>(_onNextStep);
    on<WizardPreviousStep>(_onPreviousStep);
    on<AdmissionDetailsUpdated>(_onAdmissionDetailsUpdated);
    on<AcademicPlacementUpdated>(_onAcademicPlacementUpdated);
    on<FinanceDetailsUpdated>(_onFinanceDetailsUpdated);
    on<ScholarshipAwardRequested>(_onScholarshipAwardRequested);
    on<HouseSelected>(_onHouseSelected);
    on<DormitoryAssignmentRequested>(_onDormitoryAssignmentRequested);
    on<ClubMembershipToggled>(_onClubMembershipToggled);
    on<ClubMembershipsSaveRequested>(_onClubMembershipsSaveRequested);
    on<ParentLinkRequested>(_onParentLinkRequested);
    on<ParentLinkSkipped>(_onParentLinkSkipped);
    on<IdentityPreviewRequested>(_onIdentityPreviewRequested);
    on<NfcRegistrationRequested>(_onNfcRegistrationRequested);
    on<NfcRegistrationSkipped>(_onNfcRegistrationSkipped);
    on<ActivationRequested>(_onActivationRequested);
  }

  Future<bool> _allowed(String permissionId, dynamic operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((failure) => false, (value) => value);
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

    emit(state.copyWith(isLoading: false));
  }

  void _onNextStep(
    WizardNextStep event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    if (state.isLastStep) return;
    emit(
      state.copyWith(
        currentStep: state.currentStep + 1,
        clearError: true,
        clearInfoMessage: true,
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
      (failure) => emit(
        state.copyWith(isLoading: false, error: failure.message),
      ),
      (_) => emit(
        state.copyWith(isLoading: false, hasScholarshipAward: true),
      ),
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

    final result = await enrollmentSetupRepository.assignDormitory(
      assignment,
    );
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

  Future<void> _onParentLinkRequested(
    ParentLinkRequested event,
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
    if (state.studentId == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final linkResult = await parentLinkingService.linkStudentToParent(
      studentId: state.studentId!,
      studentName: state.studentCode,
      schoolId: state.schoolId,
      phoneNumber: event.phoneNumber,
      parentName: event.parentName,
      createdBy: event.operatorUser.id,
    );

    final failure = linkResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(isLoading: false, error: failure.message));
      return;
    }
    final code = linkResult.fold((_) => null, (c) => c);

    // linkStudentToParent's own _recordRelationship call already creates a
    // base relationship with default access flags. If the wizard captured
    // stronger role flags than that default, create a supplementary
    // relationship carrying them via CreateRelationship directly - additive,
    // never mutating the one linkStudentToParent already wrote.
    if (event.isLegalGuardian ||
        event.isPrimaryGuardian ||
        event.financialAccess ||
        event.pickupAuthorized) {
      await createRelationship(
        CreateRelationshipParams(
          schoolId: state.schoolId,
          studentId: state.studentId!,
          parentCode: code,
          type: RelationshipType.parent,
          isLegalGuardian: event.isLegalGuardian,
          isPrimaryGuardian: event.isPrimaryGuardian,
          createdBy: event.operatorUser.id,
          financialAccess: event.financialAccess,
          pickupAuthorized: event.pickupAuthorized,
        ),
      );
    }

    emit(
      state.copyWith(
        isLoading: false,
        parentLinked: true,
        parentAccessCode: code,
      ),
    );
  }

  void _onParentLinkSkipped(
    ParentLinkSkipped event,
    Emitter<EnrollmentSetupWizardState> emit,
  ) {
    emit(state.copyWith(parentLinkSkippedFlag: true));
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
      (_) => emit(state.copyWith(identityExists: true)),
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
        state.copyWith(
          error: 'Complete the required steps before activating.',
        ),
      );
      return;
    }

    emit(state.copyWith(isActivating: true, clearError: true));

    final result = await admissionService.enrollStudent(
      state.studentId!,
      schoolId: state.schoolId,
      uniqueSystemId: state.uniqueSystemId,
      studentCode: state.studentCode,
      academicYear: state.academicYearId,
      term: state.term,
      feeStructureId: state.feeStructureId,
      totalBilled: state.totalBilled,
    );

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(isActivating: false, error: failure.message));
      return;
    }

    emit(state.copyWith(isActivating: false, activated: true));
  }
}
