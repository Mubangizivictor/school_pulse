import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart' show SubjectAssignment;

/// One role's contextual scope, gathered in Step 6 (Configure Role) and
/// reviewed in Step 7 (Roles Summary). Only the fields relevant to [role]
/// are ever populated - which fields those are is decided by
/// RoleAssignmentConfigRegistry, not by this class.
class RoleAssignmentDraft {
  final UserRole role;
  String? academicYearId;
  String? classId;
  String? className;
  String? streamId;
  String? streamName;
  List<SubjectAssignment> subjectAssignments;
  String? departmentId;
  String? dormitoryWing;
  String? routeId;
  String? facilityId;
  String? approvalScope;
  DateTime? startDate;
  DateTime? endDate;

  RoleAssignmentDraft({
    required this.role,
    this.academicYearId,
    this.classId,
    this.className,
    this.streamId,
    this.streamName,
    List<SubjectAssignment>? subjectAssignments,
    this.departmentId,
    this.dormitoryWing,
    this.routeId,
    this.facilityId,
    this.approvalScope,
    this.startDate,
    this.endDate,
  }) : subjectAssignments = subjectAssignments ?? [];

  Map<String, dynamic> toJson() => {
        'role': role.name,
        if (academicYearId != null) 'academicYearId': academicYearId,
        if (classId != null) 'classId': classId,
        if (className != null) 'className': className,
        if (streamId != null) 'streamId': streamId,
        if (streamName != null) 'streamName': streamName,
        if (subjectAssignments.isNotEmpty)
          'subjectAssignments': subjectAssignments.map((s) => s.toJson()).toList(),
        if (departmentId != null) 'departmentId': departmentId,
        if (dormitoryWing != null) 'dormitoryWing': dormitoryWing,
        if (routeId != null) 'routeId': routeId,
        if (facilityId != null) 'facilityId': facilityId,
        if (approvalScope != null) 'approvalScope': approvalScope,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };

  factory RoleAssignmentDraft.fromJson(Map<String, dynamic> json) {
    return RoleAssignmentDraft(
      role: UserRole.values.firstWhere((r) => r.name == json['role']),
      academicYearId: json['academicYearId'] as String?,
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      streamId: json['streamId'] as String?,
      streamName: json['streamName'] as String?,
      subjectAssignments: (json['subjectAssignments'] as List<dynamic>?)
              ?.map((e) => SubjectAssignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      departmentId: json['departmentId'] as String?,
      dormitoryWing: json['dormitoryWing'] as String?,
      routeId: json['routeId'] as String?,
      facilityId: json['facilityId'] as String?,
      approvalScope: json['approvalScope'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
    );
  }
}
