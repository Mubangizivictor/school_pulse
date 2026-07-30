import 'package:school_pulse/core/user_roles.dart';
import '../../domain/entities/appointment_type.dart';

class AppointmentTypeModel extends AppointmentType {
  const AppointmentTypeModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.department,
    super.category,
    super.defaultDurationMinutes,
    super.requiresApproval,
    super.active,
    super.targetRoles,
  });

  factory AppointmentTypeModel.fromEntity(AppointmentType type) {
    return AppointmentTypeModel(
      id: type.id,
      schoolId: type.schoolId,
      name: type.name,
      department: type.department,
      category: type.category,
      defaultDurationMinutes: type.defaultDurationMinutes,
      requiresApproval: type.requiresApproval,
      active: type.active,
      targetRoles: type.targetRoles,
    );
  }

  factory AppointmentTypeModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentTypeModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      category: AppointmentCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => AppointmentCategory.parentStaff,
      ),
      defaultDurationMinutes: map['defaultDurationMinutes'] ?? 20,
      requiresApproval: map['requiresApproval'] ?? true,
      active: map['active'] ?? true,
      targetRoles: ((map['targetRoles'] as List?) ?? const [])
          .map((r) => UserRole.values.firstWhere((v) => v.name == r, orElse: () => UserRole.schoolAdmin))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'department': department,
      'category': category.name,
      'defaultDurationMinutes': defaultDurationMinutes,
      'requiresApproval': requiresApproval,
      'active': active,
      'targetRoles': targetRoles.map((r) => r.name).toList(),
    };
  }
}
