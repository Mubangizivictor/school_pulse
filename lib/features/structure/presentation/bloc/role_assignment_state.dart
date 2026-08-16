import 'package:equatable/equatable.dart';

import '../../../teacher/domain/entities/staff_role_assignment.dart';

/// State for [RoleAssignmentCubit]. Holds whichever list was last loaded -
/// either every assignment for one staff member (staff profile's Roles &
/// Responsibilities tab) or every assignment for one role definition (Role
/// Details' Assignments tab) - the cubit is reused for both queries rather
/// than duplicated, since both are "a list of StaffRoleAssignment plus a
/// pending/error flag for one in-flight mutation".
abstract class RoleAssignmentState extends Equatable {
  const RoleAssignmentState();

  @override
  List<Object?> get props => [];
}

class RoleAssignmentInitial extends RoleAssignmentState {
  const RoleAssignmentInitial();
}

class RoleAssignmentLoading extends RoleAssignmentState {
  const RoleAssignmentLoading();
}

class RoleAssignmentLoaded extends RoleAssignmentState {
  final List<StaffRoleAssignment> assignments;

  /// Set only while a mutation (assign/end/reactivate) is in flight, so the
  /// UI can disable the acting control without losing the list underneath.
  final bool isMutating;

  const RoleAssignmentLoaded(this.assignments, {this.isMutating = false});

  RoleAssignmentLoaded copyWith({
    List<StaffRoleAssignment>? assignments,
    bool? isMutating,
  }) {
    return RoleAssignmentLoaded(
      assignments ?? this.assignments,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => [assignments, isMutating];
}

class RoleAssignmentError extends RoleAssignmentState {
  final String message;

  const RoleAssignmentError(this.message);

  @override
  List<Object?> get props => [message];
}
