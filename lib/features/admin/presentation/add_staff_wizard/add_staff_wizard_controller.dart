import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/add_staff_draft.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Internal wizard steps, in order. "Select Method" and "Success" bookend
/// the 10 numbered steps shown in the progress bar (WizardScaffold shows
/// `stepNumberFor(step)` of 10, not the raw index into this list).
enum WizardStep {
  selectMethod,
  personalInfo,
  contactInfo,
  employmentInfo,
  selectRoles,
  configureRole,
  rolesSummary,
  accessPreview,
  loginSecurity,
  documents,
  reviewConfirm,
  success,
}

/// Maps a WizardStep to its "Step N of 10" label, matching the reference
/// design (Select Method and Success aren't counted).
int stepNumberFor(WizardStep step) {
  const numbered = [
    WizardStep.personalInfo,
    WizardStep.contactInfo,
    WizardStep.employmentInfo,
    WizardStep.selectRoles,
    WizardStep.configureRole,
    WizardStep.rolesSummary,
    WizardStep.accessPreview,
    WizardStep.loginSecurity,
    WizardStep.documents,
    WizardStep.reviewConfirm,
  ];
  final i = numbered.indexOf(step);
  return i == -1 ? 1 : i + 1;
}

const int kWizardTotalSteps = 10;

/// Holds the Add Staff wizard's accumulating draft, current step, and the
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
  WizardStep _step = WizardStep.selectMethod;
  WizardStep get step => _step;

  /// When configuring roles one at a time (Step 6), this is the role
  /// currently being configured.
  int _configureRoleIndex = 0;
  int get configureRoleIndex => _configureRoleIndex;

  bool submitting = false;
  String? submitError;
  String? resultTempPassword;
  String? resultStaffCode;
  String? resultUid;

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

  void goTo(WizardStep step) {
    _step = step;
    notifyListeners();
    _persistDraft();
  }

  void next() {
    switch (_step) {
      case WizardStep.selectMethod:
        _step = WizardStep.personalInfo;
        break;
      case WizardStep.personalInfo:
        _step = WizardStep.contactInfo;
        break;
      case WizardStep.contactInfo:
        _step = WizardStep.employmentInfo;
        break;
      case WizardStep.employmentInfo:
        _step = WizardStep.selectRoles;
        break;
      case WizardStep.selectRoles:
        _configureRoleIndex = 0;
        _step = rolesNeedingConfig.isNotEmpty
            ? WizardStep.configureRole
            : WizardStep.rolesSummary;
        break;
      case WizardStep.configureRole:
        if (_configureRoleIndex < rolesNeedingConfig.length - 1) {
          _configureRoleIndex++;
        } else {
          _step = WizardStep.rolesSummary;
        }
        break;
      case WizardStep.rolesSummary:
        _step = WizardStep.accessPreview;
        break;
      case WizardStep.accessPreview:
        _step = WizardStep.loginSecurity;
        break;
      case WizardStep.loginSecurity:
        _step = WizardStep.documents;
        break;
      case WizardStep.documents:
        _step = WizardStep.reviewConfirm;
        break;
      case WizardStep.reviewConfirm:
        _step = WizardStep.success;
        break;
      case WizardStep.success:
        break;
    }
    notifyListeners();
    _persistDraft();
  }

  void back() {
    switch (_step) {
      case WizardStep.selectMethod:
        break;
      case WizardStep.personalInfo:
        _step = WizardStep.selectMethod;
        break;
      case WizardStep.contactInfo:
        _step = WizardStep.personalInfo;
        break;
      case WizardStep.employmentInfo:
        _step = WizardStep.contactInfo;
        break;
      case WizardStep.selectRoles:
        _step = WizardStep.employmentInfo;
        break;
      case WizardStep.configureRole:
        if (_configureRoleIndex > 0) {
          _configureRoleIndex--;
        } else {
          _step = WizardStep.selectRoles;
        }
        break;
      case WizardStep.rolesSummary:
        _step = rolesNeedingConfig.isNotEmpty
            ? WizardStep.configureRole
            : WizardStep.selectRoles;
        if (_step == WizardStep.configureRole)
          _configureRoleIndex = rolesNeedingConfig.length - 1;
        break;
      case WizardStep.accessPreview:
        _step = WizardStep.rolesSummary;
        break;
      case WizardStep.loginSecurity:
        _step = WizardStep.accessPreview;
        break;
      case WizardStep.documents:
        _step = WizardStep.loginSecurity;
        break;
      case WizardStep.reviewConfirm:
        _step = WizardStep.documents;
        break;
      case WizardStep.success:
        break;
    }
    notifyListeners();
    _persistDraft();
  }

  /// Jump back into Step 6 to edit a specific role's config, from the Roles
  /// Summary screen's "Edit" links.
  void editRole(UserRole role) {
    final idx = rolesNeedingConfig.indexOf(role);
    if (idx == -1) return;
    _configureRoleIndex = idx;
    _step = WizardStep.configureRole;
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
        ..employmentType = restored.employmentType
        ..department = restored.department
        ..designation = restored.designation
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

  Future<Either<Failure, String>> submit() async {
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
        password:
            '', // server always generates its own; see AuthRemoteDataSource.
        assignedClass: classTeacherConfig?.className,
        subjects: subjectTeacherConfig?.subjectAssignments,
        academicYearId: currentAcademicYearId,
      ),
    );

    submitting = false;

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      submitError = failure.message;
      notifyListeners();
      return result;
    }

    final tempPassword = result.fold((_) => null, (p) => p);
    resultTempPassword = tempPassword;
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
    await di.sl<AuditRepository>().logAction(
      title: 'Staff Account Created',
      description:
          '${draft.fullName} was added as ${draft.selectedRoles.map(UserRoleDisplay.name).join(', ')}.',
      iconName: 'person_add',
      colorHex: 'FF2196F3',
      userId: adminUid,
    );
  }
}
