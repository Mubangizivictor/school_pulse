import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

/// An admin's customization of the default permission set for one
/// existing [UserRole] within their school. Does not create new role
/// names - only changes which permissions an existing role grants. When
/// no override exists for a role, `RolePermissionDefaults.defaults` is the
/// effective set.
class RolePermissionOverride extends Equatable {
  final UserRole role;
  final Set<String> permissions;
  final String updatedBy;
  final DateTime updatedAt;

  const RolePermissionOverride({
    required this.role,
    required this.permissions,
    required this.updatedBy,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [role, permissions, updatedBy, updatedAt];
}
