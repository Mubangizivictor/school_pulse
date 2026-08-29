import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/add_staff_draft.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// The five visible wizard stages, matching the reference design's stepper:
/// Profile -> Work -> Roles -> Access -> Review. `success` is a sixth,
/// unlabeled state reached only after a successful submit from `review`.
enum WizardStage { profile, work, roles, access, review, success }

const List<WizardStage> kWizardStages = [
  WizardStage.profile,
  WizardStage.work,
  WizardStage.roles,
  WizardStage.access,
  WizardStage.review,
];

const List<String> kWizardStageLabels = [
  'Profile',
  'Work',
  'Roles',
  'Access',
  'Review',
];

int stageIndexFor(WizardStage stage) {
  final i = kWizardStages.indexOf(stage);
  return i == -1 ? 0 : i;
}

/// Sub-position within the Roles stage, which - like the reference design's
/// "Role 1 of 2" screen - internally holds three screens: pick roles,
/// configure each selected role one at a time, then a summary.
enum RolesSubStep { select, configure, summary }

/// Holds the Add Staff wizard's accumulating draft, current stage, and the
/// submit() call that actually creates the account. A plain ChangeNotifier
/// (not bloc) to match the imperative StatefulWidget+Either.fold convention
/// already used for staff creation in user_management_page.dart.
class AddStaffWizardController extends ChangeNotifier {
  final String schoolId;
  final String adminUid;
  final String? currentAcademicYearId;

  AddStaffWizardController({
    required this.schoolId,
    required this.adminUid,
    this.currentAcademicYearId,
  });

  final AddStaffDraft draft = AddStaffDraft();
  WizardStage _stage = WizardStage.profile;
  WizardStage get stage => _stage;

  RolesSubStep _rolesSubStep = RolesSubStep.select;
  RolesSubStep get rolesSubStep => _rolesSubStep;

  /// When configuring roles one at a time within the Roles stage, this is
  /// the role currently being configured.
  int _configureRoleIndex = 0;
  int get configureRoleIndex => _configureRoleIndex;

  bool submitting = false;
  String? submitError;
  // Deprecated: no plaintext password is ever generated or returned by
  // createStaffAccount - kept only so any external reference doesn't break
  // the build. Always null after submit(); not read by the success screen.
  String? resultTempPassword;
  String? resultStaffCode;
  String? resultUid;

  /// Admin-set initial password must be at least 8 chars. Enforced before
  /// leaving the Access stage and mirrored by the field validators in the UI.
  bool get isInitialPasswordValid => draft.initialPassword.trim().length >= 8;

  List<UserRole> get rolesNeedingConfig => draft.selectedRoles
      .where(
        (r) =>
            r == UserRole.classTeacher ||
            r == UserRole.subjectTeacher ||
            _rolesWithScope.contains(r),
      )
      .toList();

  static const _rolesWithScope = {
    UserRole.deanOfStudies,
    UserRole.bursar,
    UserRole.librarian,
    UserRole.nurse,
    UserRole.boardingMatron,
    UserRole.boardingPatron,
    UserRole.transportCoordinator,
    UserRole.guidanceDiscipline,
    UserRole.storeInventory,
    UserRole.gatekeeper,
    UserRole.securityHead,
    UserRole.gamesMaster,
    UserRole.cateringManager,
    UserRole.religiousLeader,
    UserRole.receptionist,
    UserRole.hrOfficer,
  };

  void goToStage(WizardStage stage) {
    _stage = stage;
    if (stage == WizardStage.roles) _rolesSubStep = RolesSubStep.select;
    notifyListeners();
    _persistDraft();
  }

  void next() {
    switch (_stage) {
      case WizardStage.profile:
        _stage = WizardStage.work;
        break;
      case WizardStage.work:
        _stage = WizardStage.roles;
        _rolesSubStep = RolesSubStep.select;
        break;
      case WizardStage.roles:
        _rolesNext();
        break;
      case WizardStage.access:
        if (!isInitialPasswordValid) return;
        _stage = WizardStage.review;
        break;
      case WizardStage.review:
        _stage = WizardStage.success;
        break;
      case WizardStage.success:
        break;
    }
    notifyListeners();
    _persistDraft();
  }

  void _rolesNext() {
    switch (_rolesSubStep) {
      case RolesSubStep.select:
        _configureRoleIndex = 0;
        _rolesSubStep = rolesNeedingConfig.isNotEmpty
            ? RolesSubStep.configure
            : RolesSubStep.summary;
        break;
      case RolesSubStep.configure:
        if (_configureRoleIndex < rolesNeedingConfig.length - 1) {
          _configureRoleIndex++;
        } else {
          _rolesSubStep = RolesSubStep.summary;
        }
        break;
      case RolesSubStep.summary:
        _stage = WizardStage.access;
        break;
    }
  }

  void back() {
    switch (_stage) {
      case WizardStage.profile:
        break;
      case WizardStage.work:
        _stage = WizardStage.profile;
        break;
      case WizardStage.roles:
        _rolesBack();
        break;
      case WizardStage.access:
        _stage = WizardStage.roles;
        _rolesSubStep = RolesSubStep.summary;
        break;
      case WizardStage.review:
        _stage = WizardStage.access;
        break;
      case WizardStage.success:
        break;
    }
    notifyListeners();
    _persistDraft();
  }

  void _rolesBack() {
    switch (_rolesSubStep) {
      case RolesSubStep.select:
        _stage = WizardStage.work;
        break;
      case RolesSubStep.configure:
        if (_configureRoleIndex > 0) {
          _configureRoleIndex--;
        } else {
          _rolesSubStep = RolesSubStep.select;
        }
        break;
      case RolesSubStep.summary:
        if (rolesNeedingConfig.isNotEmpty) {
          _rolesSubStep = RolesSubStep.configure;
          _configureRoleIndex = rolesNeedingConfig.length - 1;
        } else {
          _rolesSubStep = RolesSubStep.select;
        }
        break;
    }
  }

  /// Jump back into role configuration to edit a specific role, from the
  /// Roles Summary screen's "Edit" links.
  void editRole(UserRole role) {
    final idx = rolesNeedingConfig.indexOf(role);
    if (idx == -1) return;
    _configureRoleIndex = idx;
    _rolesSubStep = RolesSubStep.configure;
    notifyListeners();
  }

  void notifyDraftChanged() {
    notifyListeners();
    _persistDraft();
  }

  String get _draftKey => 'add_staff_draft_${schoolId}_$adminUid';

  Future<void> _persistDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'savedAt': DateTime.now().toIso8601String(),
        'draft': draft.toJson(),
      };
      await prefs.setString(_draftKey, jsonEncode(payload));
    } catch (_) {
      // Draft persistence is best-effort; never block the wizard on it.
    }
  }

  Future<bool> restoreDraftIfPresent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null) return false;
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(payload['savedAt'] as String? ?? '');
      if (savedAt == null || DateTime.now().difference(savedAt).inHours > 24) {
        await prefs.remove(_draftKey);
        return false;
      }
      final restored = AddStaffDraft.fromJson(
        payload['draft'] as Map<String, dynamic>,
      );
      draft
        ..firstName = restored.firstName
        ..middleName = restored.middleName
        ..lastName = restored.lastName
        ..gender = restored.gender
        ..email = restored.email
        ..phoneNumber = restored.phoneNumber
        ..alternatePhone = restored.alternatePhone
        ..address = restored.address
        ..nationality = restored.nationality
        ..emergencyContactName = restored.emergencyContactName
        ..emergencyContactRelationship = restored.emergencyContactRelationship
        ..emergencyContactPhone = restored.emergencyContactPhone
        ..emergencyContactAlternatePhone =
            restored.emergencyContactAlternatePhone
        ..idempotencyKey = restored.idempotencyKey
        ..employmentType = restored.employmentType
        ..department = restored.department
        ..departmentId = restored.departmentId
        ..designation = restored.designation
        ..designationId = restored.designationId
        ..campusId = restored.campusId
        ..dateJoined = restored.dateJoined
        ..selectedRoles = restored.selectedRoles
        ..roleConfigs = restored.roleConfigs
        ..forcePasswordChange = restored.forcePasswordChange
        ..sendLoginDetailsViaEmail = restored.sendLoginDetailsViaEmail;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {
      // Best-effort.
    }
  }

  /// True when the signed-in admin's own roles actually permit staff
  /// creation server-side (director/headTeacher/schoolAdmin). Deputy Head
  /// can navigate the wizard but must not be allowed to submit - the
  /// Cloud Function rejects them, so the UI disables Confirm instead of
  /// letting that fail silently at the end.
  static bool canSubmit(List<UserRole> adminRoles) =>
      adminRoles.contains(UserRole.director) ||
      adminRoles.contains(UserRole.headTeacher) ||
      adminRoles.contains(UserRole.schoolAdmin);

  /// Mirrors the Cloud Function's own precondition so an incomplete
  /// Class/Subject Teacher configuration is caught here, before spending a
  /// round trip on a request the server would reject anyway. Null means the
  /// draft is complete enough to submit.
  String? get assignmentValidationError {
    if (draft.selectedRoles.contains(UserRole.classTeacher)) {
      final config = draft.roleConfigs[UserRole.classTeacher];
      if (config == null ||
          (config.className == null || config.className!.isEmpty)) {
        return 'Select a class for the Class Teacher role before continuing.';
      }
    }
    if (draft.selectedRoles.contains(UserRole.subjectTeacher)) {
      final config = draft.roleConfigs[UserRole.subjectTeacher];
      if (config == null || config.subjectAssignments.isEmpty) {
        return 'Add at least one subject and class for the Subject Teacher role before continuing.';
      }
    }
    return null;
  }

  Future<Either<Failure, String>> submit() async {
    final validationError = assignmentValidationError;
    if (validationError != null) {
      submitError = validationError;
      notifyListeners();
      return Left(ValidationFailure(validationError));
    }

    submitting = true;
    submitError = null;
    notifyListeners();

    final classTeacherConfig = draft.roleConfigs[UserRole.classTeacher];
    final subjectTeacherConfig = draft.roleConfigs[UserRole.subjectTeacher];

    final result = await di.sl<CreateStaffAccount>()(
      CreateStaffAccountParams(
        email: draft.email.trim(),
        name: draft.fullName,
        schoolId: schoolId,
        roles: draft.selectedRoles.toList(),
        password: draft.initialPassword,
        assignedClass: classTeacherConfig?.className,
        subjects: subjectTeacherConfig?.subjectAssignments,
        academicYearId: currentAcademicYearId,
        // Department is intentionally not part of staff onboarding. Role
        // scope is configured separately in the following Roles stage.
        departmentId: null,
        designationId: draft.designationId,
        campusId: draft.campusId,
        employmentType: draft.employmentType,
        dateJoined: draft.dateJoined,
        idempotencyKey: draft.idempotencyKey ??= const Uuid().v4(),
        forcePasswordChange: draft.forcePasswordChange,
        sendLoginDetailsViaEmail: draft.sendLoginDetailsViaEmail,
        staffData: {
          'gender': draft.gender,
          'phoneNumber': draft.phoneNumber,
          'alternatePhone': draft.alternatePhone,
          'address': draft.address,
          'nationality': draft.nationality,
          'selectedPayComponentIds': draft.selectedPayComponentIds.toList(),
          if (draft.emergencyContactName.trim().isNotEmpty)
            'emergencyContact': {
              'name': draft.emergencyContactName.trim(),
              'relationship': draft.emergencyContactRelationship.trim(),
              'phone': draft.emergencyContactPhone.trim(),
              'alternatePhone': draft.emergencyContactAlternatePhone.trim(),
            },
        },
        roleConfigs: draft.roleConfigs.map(
          (key, value) => MapEntry(key.name, value.toJson()),
        ),
      ),
    );

    submitting = false;

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      submitError = failure.message;
      notifyListeners();
      return result;
    }

    // result's payload is the staffCode (no plaintext password is ever
    // generated) - resultStaffCode/resultUid come from the authoritative
    // Firestore lookup below instead, so the callable's return value here
    // isn't otherwise needed.
    resultStaffCode = await _lookupStaffCodeAndUid();
    await clearDraft();

    notifyListeners();
    return result;
  }

  /// The Cloud Function response only surfaces the temp password through
  /// the shared AuthRepository/CreateStaffAccount contract (used by other
  /// callers), not the created uid/staffCode - so this wizard looks the new
  /// user doc up by its now-unique email instead of widening that shared
  /// interface. Best-effort: a lookup failure never fails staff creation,
  /// it only means Documents can't upload and Success won't show the code.
  Future<String?> _lookupStaffCodeAndUid() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('schoolId', isEqualTo: schoolId)
          .where('email', isEqualTo: draft.email.trim())
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      resultUid = doc.id;
      return doc.data()['staffCode'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> logAudit() async {
    try {
      await di.sl<AuditRepository>().logAction(
        schoolId: schoolId,
        title: 'Staff Account Created',
        description:
            '${draft.fullName} was added as ${draft.selectedRoles.map(UserRoleDisplay.name).join(', ')}.',
        iconName: 'person_add',
        colorHex: 'FF2196F3',
        userId: adminUid,
      );
    } catch (error, stackTrace) {
      // Creation is already committed; retain diagnostics without exposing
      // Firebase internals to the administrator or turning success into fail.
      debugPrint('Staff enrolment audit failed: $error\n$stackTrace');
    }
  }
}
