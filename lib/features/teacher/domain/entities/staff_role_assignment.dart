import 'package:equatable/equatable.dart';

/// The kind of responsibility a staff member holds. One staff member holds
/// many of these at once against a single staff profile - a Subject Teacher
/// assignment per subject/class pair, plus (optionally) one Class Teacher
/// assignment, a department headship, and so on. These are never separate
/// user accounts.
enum StaffResponsibilityType {
  subjectTeacher,
  classTeacher,
  departmentHead,
  examinationOfficer,
  houseMaster,
  patron,
  matron,
  sportsLeader,
  religiousLeader,
  // Non-teaching responsibilities, added so this model can represent every
  // staff member's assignment (Phase 3), not only teaching staff.
  nurse,
  bursar,
  librarian,
  securityOfficer,
  transportCoordinator,
  storeInventoryManager,
  hrOfficer,
  receptionist,
  cateringManager,
  other;

  static StaffResponsibilityType fromId(String? id) {
    if (id == null) return StaffResponsibilityType.other;
    for (final t in StaffResponsibilityType.values) {
      if (t.name == id) return t;
    }
    return StaffResponsibilityType.other;
  }
}

extension StaffResponsibilityTypeDisplay on StaffResponsibilityType {
  String get label => switch (this) {
        StaffResponsibilityType.subjectTeacher => 'Subject Teacher',
        StaffResponsibilityType.classTeacher => 'Class Teacher',
        StaffResponsibilityType.departmentHead => 'Head of Department',
        StaffResponsibilityType.examinationOfficer => 'Examination Officer',
        StaffResponsibilityType.houseMaster => 'House Master',
        StaffResponsibilityType.patron => 'Patron',
        StaffResponsibilityType.matron => 'Matron',
        StaffResponsibilityType.sportsLeader => 'Sports Leader',
        StaffResponsibilityType.religiousLeader => 'Religious Leader',
        StaffResponsibilityType.nurse => 'Nurse',
        StaffResponsibilityType.bursar => 'Bursar',
        StaffResponsibilityType.librarian => 'Librarian',
        StaffResponsibilityType.securityOfficer => 'Security Officer',
        StaffResponsibilityType.transportCoordinator => 'Transport Coordinator',
        StaffResponsibilityType.storeInventoryManager => 'Store & Inventory Manager',
        StaffResponsibilityType.hrOfficer => 'HR Officer',
        StaffResponsibilityType.receptionist => 'Receptionist',
        StaffResponsibilityType.cateringManager => 'Catering Manager',
        StaffResponsibilityType.other => 'Staff',
      };
}

/// Lifecycle of a single assignment. Only [active] grants access, and only
/// then when the current date also falls inside the assignment's date range.
enum AssignmentStatus {
  active,
  suspended,
  expired,
  removed,
  pending;

  static AssignmentStatus fromId(String? id) {
    if (id == null) return AssignmentStatus.pending;
    for (final s in AssignmentStatus.values) {
      if (s.name == id) return s;
    }
    return AssignmentStatus.pending;
  }
}

/// The permissions an admin attached to one assignment, together with the
/// academic boundary they apply inside.
///
/// A permission ID on its own never authorises anything here: `can()` is
/// answered by "does this assignment grant the permission" AND "does the
/// record being touched fall inside this assignment's subject/class/stream/
/// year". That is what stops a Mathematics-10A teacher from touching
/// Mathematics-10B, which a role-name check could never do.
class PermissionScope extends Equatable {
  final Set<String> permissions;
  final String? subjectId;
  final String? classId;
  final String? streamId;
  final String? departmentId;
  final String academicYearId;

  /// When non-empty, restricts the assignment to specific terms. Empty means
  /// every term inside [academicYearId].
  final Set<String> termIds;

  const PermissionScope({
    this.permissions = const {},
    this.subjectId,
    this.classId,
    this.streamId,
    this.departmentId,
    this.academicYearId = '',
    this.termIds = const {},
  });

  bool grants(String permissionId) => permissions.contains(permissionId);

  /// Whether a record carrying these academic coordinates falls inside this
  /// scope. A null argument means "not applicable to this record" and is not
  /// treated as a match failure; a null field on the scope means the scope
  /// does not constrain that dimension.
  bool covers({
    String? subjectId,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? termId,
  }) {
    if (!_dimensionMatches(this.subjectId, subjectId)) return false;
    if (!_dimensionMatches(this.classId, classId)) return false;
    if (!_dimensionMatches(this.streamId, streamId)) return false;
    if (academicYearId != null &&
        this.academicYearId.isNotEmpty &&
        this.academicYearId != academicYearId) {
      return false;
    }
    if (termId != null && termIds.isNotEmpty && !termIds.contains(termId)) {
      return false;
    }
    return true;
  }

  static bool _dimensionMatches(String? scopeValue, String? recordValue) {
    if (scopeValue == null || scopeValue.isEmpty) return true;
    if (recordValue == null || recordValue.isEmpty) return true;
    return scopeValue == recordValue;
  }

  PermissionScope copyWith({
    Set<String>? permissions,
    String? subjectId,
    String? classId,
    String? streamId,
    String? departmentId,
    String? academicYearId,
    Set<String>? termIds,
  }) {
    return PermissionScope(
      permissions: permissions ?? this.permissions,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      streamId: streamId ?? this.streamId,
      departmentId: departmentId ?? this.departmentId,
      academicYearId: academicYearId ?? this.academicYearId,
      termIds: termIds ?? this.termIds,
    );
  }

  @override
  List<Object?> get props => [
        permissions,
        subjectId,
        classId,
        streamId,
        departmentId,
        academicYearId,
        termIds,
      ];
}

/// One responsibility an admin attached to a staff profile.
///
/// The same staff member has many of these rows - Mathematics/P5 East,
/// Mathematics/P6 West, ICT/P5 East, Class Teacher/P5 East - all pointing at
/// one [staffId]. Switching responsibility in the app switches which of these
/// rows is active; it never switches account.
class StaffRoleAssignment extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String staffId;
  final String userId;
  final StaffResponsibilityType roleType;
  final String academicYearId;
  final String? termId;
  final String? subjectId;
  final String? subjectName;
  final String? classId;
  final String? className;
  final String? streamId;
  final String? streamName;
  final String? departmentId;
  final String? houseId;
  final DateTime startDate;
  final DateTime? endDate;
  final AssignmentStatus status;
  final PermissionScope permissionScope;

  /// Set when this row exists because the staff member is covering for
  /// somebody else. Substitute rows expire on [endDate] like any other.
  final String? substituteForStaffId;

  final String assignedBy;
  final DateTime assignedAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  const StaffRoleAssignment({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.staffId,
    required this.userId,
    required this.roleType,
    required this.academicYearId,
    this.termId,
    this.subjectId,
    this.subjectName,
    this.classId,
    this.className,
    this.streamId,
    this.streamName,
    this.departmentId,
    this.houseId,
    required this.startDate,
    this.endDate,
    this.status = AssignmentStatus.active,
    this.permissionScope = const PermissionScope(),
    this.substituteForStaffId,
    this.assignedBy = '',
    required this.assignedAt,
    this.updatedBy,
    this.updatedAt,
  });

  bool get isSubstitute => substituteForStaffId != null;

  /// True only when the admin marked it active *and* today falls inside the
  /// date range. Temporary and substitute assignments therefore stop granting
  /// access on their end date with no server sweep required.
  bool isCurrentlyValid({DateTime? asOf}) {
    if (status != AssignmentStatus.active) return false;
    final now = asOf ?? DateTime.now();
    if (now.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
      return false;
    }
    final end = endDate;
    if (end != null && now.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59))) {
      return false;
    }
    return true;
  }

  /// Label the responsibility switcher shows, e.g. "Mathematics - Grade 10A"
  /// for a subject assignment or "Class Teacher - Grade 10A" for a class one.
  String get displayLabel {
    final classLabel = [className, streamName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' ');
    return switch (roleType) {
      StaffResponsibilityType.subjectTeacher =>
        [subjectName ?? 'Subject', if (classLabel.isNotEmpty) classLabel].join(' - '),
      StaffResponsibilityType.classTeacher =>
        ['Class Teacher', if (classLabel.isNotEmpty) classLabel].join(' - '),
      _ => roleType.label,
    };
  }

  StaffRoleAssignment copyWith({
    String? id,
    String? schoolId,
    String? campusId,
    String? staffId,
    String? userId,
    StaffResponsibilityType? roleType,
    String? academicYearId,
    String? termId,
    String? subjectId,
    String? subjectName,
    String? classId,
    String? className,
    String? streamId,
    String? streamName,
    String? departmentId,
    String? houseId,
    DateTime? startDate,
    DateTime? endDate,
    AssignmentStatus? status,
    PermissionScope? permissionScope,
    String? substituteForStaffId,
    String? assignedBy,
    DateTime? assignedAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return StaffRoleAssignment(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      campusId: campusId ?? this.campusId,
      staffId: staffId ?? this.staffId,
      userId: userId ?? this.userId,
      roleType: roleType ?? this.roleType,
      academicYearId: academicYearId ?? this.academicYearId,
      termId: termId ?? this.termId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      streamId: streamId ?? this.streamId,
      streamName: streamName ?? this.streamName,
      departmentId: departmentId ?? this.departmentId,
      houseId: houseId ?? this.houseId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      permissionScope: permissionScope ?? this.permissionScope,
      substituteForStaffId: substituteForStaffId ?? this.substituteForStaffId,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        campusId,
        staffId,
        userId,
        roleType,
        academicYearId,
        termId,
        subjectId,
        subjectName,
        classId,
        className,
        streamId,
        streamName,
        departmentId,
        houseId,
        startDate,
        endDate,
        status,
        permissionScope,
        substituteForStaffId,
        assignedBy,
        assignedAt,
        updatedBy,
        updatedAt,
      ];
}
