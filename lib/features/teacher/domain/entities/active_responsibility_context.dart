import 'package:equatable/equatable.dart';

import 'staff_role_assignment.dart';

/// The single immutable answer to "who is this teacher acting as right now".
///
/// Every Subject Teacher read and write derives its academic coordinates from
/// this object rather than from whatever the widget tree happened to be
/// holding. Screens never pass a `subjectId` or `classId` of their own into a
/// repository - they pass this context, which was built from a verified
/// assignment, so a tampered or stale UI value cannot widen the query.
class ActiveResponsibilityContext extends Equatable {
  final String schoolId;
  final String campusId;
  final String academicYearId;
  final String academicYearName;
  final String termId;
  final String termName;
  final String staffId;
  final String userId;
  final String roleAssignmentId;
  final StaffResponsibilityType roleType;
  final String? subjectId;
  final String? subjectName;
  final String? classId;
  final String? className;
  final String? streamId;
  final String? streamName;
  final String? departmentId;
  final PermissionScope permissionScope;
  final DateTime assignmentStartDate;
  final DateTime? assignmentEndDate;
  final AssignmentStatus assignmentStatus;
  final bool isSubstitute;

  const ActiveResponsibilityContext({
    required this.schoolId,
    this.campusId = '',
    required this.academicYearId,
    this.academicYearName = '',
    this.termId = '',
    this.termName = '',
    required this.staffId,
    required this.userId,
    required this.roleAssignmentId,
    required this.roleType,
    this.subjectId,
    this.subjectName,
    this.classId,
    this.className,
    this.streamId,
    this.streamName,
    this.departmentId,
    this.permissionScope = const PermissionScope(),
    required this.assignmentStartDate,
    this.assignmentEndDate,
    this.assignmentStatus = AssignmentStatus.active,
    this.isSubstitute = false,
  });

  /// Builds the context from a verified assignment plus the resolved academic
  /// calendar. The term is supplied separately because an assignment usually
  /// spans a whole year while the panel always works inside the current term.
  factory ActiveResponsibilityContext.fromAssignment(
    StaffRoleAssignment assignment, {
    required String termId,
    String termName = '',
    String academicYearName = '',
  }) {
    return ActiveResponsibilityContext(
      schoolId: assignment.schoolId,
      campusId: assignment.campusId,
      academicYearId: assignment.academicYearId,
      academicYearName: academicYearName,
      termId: assignment.termId ?? termId,
      termName: termName,
      staffId: assignment.staffId,
      userId: assignment.userId,
      roleAssignmentId: assignment.id,
      roleType: assignment.roleType,
      subjectId: assignment.subjectId,
      subjectName: assignment.subjectName,
      classId: assignment.classId,
      className: assignment.className,
      streamId: assignment.streamId,
      streamName: assignment.streamName,
      departmentId: assignment.departmentId,
      permissionScope: assignment.permissionScope,
      assignmentStartDate: assignment.startDate,
      assignmentEndDate: assignment.endDate,
      assignmentStatus: assignment.status,
      isSubstitute: assignment.isSubstitute,
    );
  }

  bool get isSubjectTeacher => roleType == StaffResponsibilityType.subjectTeacher;
  bool get isClassTeacher => roleType == StaffResponsibilityType.classTeacher;

  /// Whether the active assignment grants [permissionId] and, if academic
  /// coordinates are supplied, whether the record they describe is inside the
  /// assignment's scope. Both halves must pass.
  bool can(
    String permissionId, {
    String? subjectId,
    String? classId,
    String? streamId,
    String? academicYearId,
    String? termId,
  }) {
    if (assignmentStatus != AssignmentStatus.active) return false;
    if (!permissionScope.grants(permissionId)) return false;
    return permissionScope.covers(
      subjectId: subjectId,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
    );
  }

  /// Human label for the responsibility currently in effect, used by the
  /// header and the switcher.
  String get responsibilityLabel {
    final classLabel = [className, streamName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' ');
    return switch (roleType) {
      StaffResponsibilityType.subjectTeacher =>
        'Subject Teacher${subjectName == null ? '' : ' • $subjectName'}',
      StaffResponsibilityType.classTeacher =>
        'Class Teacher${classLabel.isEmpty ? '' : ' • $classLabel'}',
      _ => roleType.label,
    };
  }

  /// "Grade 10A (Science) • Term 2, 2024/2025" - the subtitle the approved
  /// dashboard context card renders.
  String get academicSubtitle {
    final classPart = [
      className,
      if (streamName != null && streamName!.isNotEmpty) '($streamName)',
    ].where((e) => e != null && e.isNotEmpty).join(' ');
    final calendarPart = [termName, academicYearName]
        .where((e) => e.isNotEmpty)
        .join(', ');
    return [classPart, calendarPart].where((e) => e.isNotEmpty).join(' • ');
  }

  ActiveResponsibilityContext copyWith({
    String? termId,
    String? termName,
    String? academicYearName,
    PermissionScope? permissionScope,
    AssignmentStatus? assignmentStatus,
  }) {
    return ActiveResponsibilityContext(
      schoolId: schoolId,
      campusId: campusId,
      academicYearId: academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      termId: termId ?? this.termId,
      termName: termName ?? this.termName,
      staffId: staffId,
      userId: userId,
      roleAssignmentId: roleAssignmentId,
      roleType: roleType,
      subjectId: subjectId,
      subjectName: subjectName,
      classId: classId,
      className: className,
      streamId: streamId,
      streamName: streamName,
      departmentId: departmentId,
      permissionScope: permissionScope ?? this.permissionScope,
      assignmentStartDate: assignmentStartDate,
      assignmentEndDate: assignmentEndDate,
      assignmentStatus: assignmentStatus ?? this.assignmentStatus,
      isSubstitute: isSubstitute,
    );
  }

  @override
  List<Object?> get props => [
        schoolId,
        campusId,
        academicYearId,
        academicYearName,
        termId,
        termName,
        staffId,
        userId,
        roleAssignmentId,
        roleType,
        subjectId,
        subjectName,
        classId,
        className,
        streamId,
        streamName,
        departmentId,
        permissionScope,
        assignmentStartDate,
        assignmentEndDate,
        assignmentStatus,
        isSubstitute,
      ];
}
