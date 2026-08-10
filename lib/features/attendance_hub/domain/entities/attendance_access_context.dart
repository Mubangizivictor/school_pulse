import 'package:equatable/equatable.dart';
import 'attendance_category.dart';

/// The reason a scope check failed, kept structured (not a raw string) so
/// the UI can decide its own copy per case rather than parroting a resolver
/// message that might leak scope names an operator isn't meant to see.
enum AttendanceRestrictionReason {
  none,
  noResponsibility,
  categoryNotPermitted,
  outOfScope,
  crossTenant,
}

/// What one authenticated operator is currently allowed to do in Attendance,
/// derived from their role permissions + every currently-valid
/// `staff_role_assignments` row they hold (unioned - see
/// AttendanceParticipantResolver) - never from a hardcoded role-name check.
///
/// This is the single object every attendance surface (dropdown, scope
/// selector, manual roster, NFC/QR validation, Previous Attendance, Sheets
/// export) must consult. None of them may derive their own participant list.
class AttendanceAccessContext extends Equatable {
  final String userId;
  final String schoolId;

  /// Categories this operator may mark or view at all, independent of scope.
  final Set<AttendanceCategory> allowedDomains;

  /// Categories where [allowedDomains] came from an institution-wide grant
  /// (attendance.override, or the admin-role Firestore-rules bypass) rather
  /// than a specific scoped assignment - these categories skip scope
  /// filtering entirely per [canViewAllForCategory].
  final Set<AttendanceCategory> institutionWideDomains;

  /// classIds this operator may take/view attendance for under the
  /// `students` category, resolved from Class Teacher assignments.
  final Set<String> allowedClassIds;

  /// subjectId -> the classIds that subject is taught to by this operator,
  /// resolved from Subject Teacher assignments. A class only appears here
  /// alongside the subject it was actually assigned with.
  final Map<String, Set<String>> allowedSubjectClassIds;

  /// Dormitory/hostel ids (Matron/Patron `houseId` on their assignment).
  final Set<String> allowedDormitoryIds;

  /// classId/dormitoryId -> the staff_role_assignments doc id that grants
  /// access to it, so a write can name the specific assignment it is
  /// claimed under (see AttendanceRecord.roleAssignmentId) rather than the
  /// server having to search for one - Firestore rules cannot query "any
  /// assignment matching this scope", only verify a named one.
  final Map<String, String> assignmentIdByClassId;
  final Map<String, String> assignmentIdByDormitoryId;

  /// Gate ids this operator is allowed to record movement at. Empty means
  /// "no gate-scoping data was configured" - Gate's own
  /// assignedOfficerIds/allowedUserRoles remain the authority (see
  /// PermissionEvaluatorImpl._passesGateScoping), this set is advisory only
  /// for the picker.
  final Set<String> allowedGateIds;

  final bool canCreateSession;
  final bool canCorrectAttendance;
  final bool canExportToGoogleSheets;

  final AttendanceRestrictionReason reasonForRestriction;

  const AttendanceAccessContext({
    required this.userId,
    required this.schoolId,
    this.allowedDomains = const {},
    this.institutionWideDomains = const {},
    this.allowedClassIds = const {},
    this.allowedSubjectClassIds = const {},
    this.allowedDormitoryIds = const {},
    this.assignmentIdByClassId = const {},
    this.assignmentIdByDormitoryId = const {},
    this.allowedGateIds = const {},
    this.canCreateSession = false,
    this.canCorrectAttendance = false,
    this.canExportToGoogleSheets = false,
    this.reasonForRestriction = AttendanceRestrictionReason.none,
  });

  bool get hasAnyAccess => allowedDomains.isNotEmpty;

  bool canViewAllForCategory(AttendanceCategory category) =>
      institutionWideDomains.contains(category);

  /// Every classId this operator may act on for `students`, whether via a
  /// Class Teacher assignment or as one of the classes a Subject Teacher
  /// assignment names.
  Set<String> get allScopedClassIds => {
    ...allowedClassIds,
    for (final classIds in allowedSubjectClassIds.values) ...classIds,
  };

  /// Whether a specific class scope is authorised for `students`. Always
  /// true when this operator has institution-wide students access.
  bool canAccessClass(String classId) {
    if (canViewAllForCategory(AttendanceCategory.students)) return true;
    return allScopedClassIds.contains(classId);
  }

  bool canAccessDormitory(String dormitoryId) {
    if (canViewAllForCategory(AttendanceCategory.hostel)) return true;
    return allowedDormitoryIds.contains(dormitoryId);
  }

  /// The assignment id a write to (category, scopeId) should be stamped
  /// with, or null when the operator's access to this scope is
  /// institution-wide (no single assignment to name - the Firestore rule
  /// takes the schoolAcademicAdmin()/attendance.override path instead).
  String? assignmentIdForScope(AttendanceCategory category, String scopeId) {
    switch (category) {
      case AttendanceCategory.students:
        return assignmentIdByClassId[scopeId];
      case AttendanceCategory.hostel:
        return assignmentIdByDormitoryId[scopeId];
      case AttendanceCategory.staff:
      case AttendanceCategory.gate:
      case AttendanceCategory.meals:
      case AttendanceCategory.library:
      case AttendanceCategory.transport:
      case AttendanceCategory.visitors:
      case AttendanceCategory.custom:
        return null;
    }
  }

  /// The authorisation check every marking/viewing surface must call before
  /// accepting a record scoped to (category, scopeId). Credential validity
  /// (a QR/NFC decoded successfully) is never sufficient on its own - this
  /// is the separate recorder-authorisation check the spec requires.
  bool canActOnScope(AttendanceCategory category, String scopeId) {
    if (!allowedDomains.contains(category)) return false;
    if (canViewAllForCategory(category)) return true;
    switch (category) {
      case AttendanceCategory.students:
        return allScopedClassIds.contains(scopeId);
      case AttendanceCategory.hostel:
        return allowedDormitoryIds.contains(scopeId);
      case AttendanceCategory.gate:
        // No configured gate scope means "not restricted by this
        // resolver" - Gate-resource-level scoping (assignedOfficerIds/
        // allowedUserRoles) is enforced separately by PermissionEvaluator.
        return allowedGateIds.isEmpty || allowedGateIds.contains(scopeId);
      case AttendanceCategory.staff:
      case AttendanceCategory.meals:
      case AttendanceCategory.library:
      case AttendanceCategory.transport:
      case AttendanceCategory.visitors:
      case AttendanceCategory.custom:
        // Not modeled with scoped assignment data this pass - category-level
        // permission (already checked above) is the only gate.
        return true;
    }
  }

  AttendanceAccessContext copyWith({
    Set<AttendanceCategory>? allowedDomains,
    Set<AttendanceCategory>? institutionWideDomains,
    Set<String>? allowedClassIds,
    Map<String, Set<String>>? allowedSubjectClassIds,
    Set<String>? allowedDormitoryIds,
    Map<String, String>? assignmentIdByClassId,
    Map<String, String>? assignmentIdByDormitoryId,
    Set<String>? allowedGateIds,
    bool? canCreateSession,
    bool? canCorrectAttendance,
    bool? canExportToGoogleSheets,
    AttendanceRestrictionReason? reasonForRestriction,
  }) {
    return AttendanceAccessContext(
      userId: userId,
      schoolId: schoolId,
      allowedDomains: allowedDomains ?? this.allowedDomains,
      institutionWideDomains:
          institutionWideDomains ?? this.institutionWideDomains,
      allowedClassIds: allowedClassIds ?? this.allowedClassIds,
      allowedSubjectClassIds:
          allowedSubjectClassIds ?? this.allowedSubjectClassIds,
      allowedDormitoryIds: allowedDormitoryIds ?? this.allowedDormitoryIds,
      assignmentIdByClassId:
          assignmentIdByClassId ?? this.assignmentIdByClassId,
      assignmentIdByDormitoryId:
          assignmentIdByDormitoryId ?? this.assignmentIdByDormitoryId,
      allowedGateIds: allowedGateIds ?? this.allowedGateIds,
      canCreateSession: canCreateSession ?? this.canCreateSession,
      canCorrectAttendance: canCorrectAttendance ?? this.canCorrectAttendance,
      canExportToGoogleSheets:
          canExportToGoogleSheets ?? this.canExportToGoogleSheets,
      reasonForRestriction: reasonForRestriction ?? this.reasonForRestriction,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    schoolId,
    allowedDomains,
    institutionWideDomains,
    allowedClassIds,
    allowedSubjectClassIds,
    allowedDormitoryIds,
    assignmentIdByClassId,
    assignmentIdByDormitoryId,
    allowedGateIds,
    canCreateSession,
    canCorrectAttendance,
    canExportToGoogleSheets,
    reasonForRestriction,
  ];
}
