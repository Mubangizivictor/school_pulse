import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Lightweight staff-picker row, sourced directly from the `users`
/// collection rather than the full auth UserEntity - the booking wizard
/// only ever needs id/name/role to render and filter a picker list.
class StaffSummary extends Equatable {
  final String id;
  final String name;
  final UserRole role;

  const StaffSummary({required this.id, required this.name, required this.role});

  @override
  List<Object?> get props => [id, name, role];
}
