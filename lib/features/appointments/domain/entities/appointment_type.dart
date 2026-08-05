import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Who a booking of this type is between - drives which picker steps the
/// parent/staff booking wizard shows (e.g. external appointments skip the
/// "student" step).
enum AppointmentCategory { parentStaff, internalStaff, external }

class AppointmentType extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String department;
  final AppointmentCategory category;
  final int defaultDurationMinutes;
  final bool requiresApproval;
  final bool active;

  /// Staff roles eligible to host this type (e.g. Bursar, Nurse). Empty
  /// means any staff member can be picked as host - used for ad-hoc
  /// internal/external meetings that aren't tied to a fixed office.
  final List<UserRole> targetRoles;

  const AppointmentType({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.department,
    this.category = AppointmentCategory.parentStaff,
    this.defaultDurationMinutes = 20,
    this.requiresApproval = true,
    this.active = true,
    this.targetRoles = const [],
  });

  AppointmentType copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? department,
    AppointmentCategory? category,
    int? defaultDurationMinutes,
    bool? requiresApproval,
    bool? active,
    List<UserRole>? targetRoles,
  }) {
    return AppointmentType(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      department: department ?? this.department,
      category: category ?? this.category,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      active: active ?? this.active,
      targetRoles: targetRoles ?? this.targetRoles,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    department,
    category,
    defaultDurationMinutes,
    requiresApproval,
    active,
    targetRoles,
  ];
}
