import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../admin/data/repositories/audit_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../notifications/domain/entities/notification_model.dart';
import '../../../notifications/domain/services/notification_sender.dart';
import '../../../teacher/domain/entities/staff_role_assignment.dart';
import '../../../teacher/domain/repositories/staff_assignment_repository.dart';
import '../../domain/entities/structure_entities.dart';
import 'role_assignment_state.dart';

/// Assigns, ends and reactivates [StaffRoleAssignment] rows, and loads them
/// either per staff member or per role definition.
///
/// Lives under Structure/presentation even though the repository it wraps
/// (`StaffAssignmentRepository`) lives in the `teacher` feature - the
/// screens that consume this (Assign Role, Role Details, the staff profile's
/// Roles & Responsibilities tab) are all Structure/Admin-side, not the
/// teacher panel.
///
/// Audit logging and notification sending happen here, not in the
/// repository, which stays a pure data layer.
class RoleAssignmentCubit extends Cubit<RoleAssignmentState> {
  final StaffAssignmentRepository repository;
  final AuditRepository auditRepository;
  final NotificationSendService notificationSender;

  RoleAssignmentCubit({
    required this.repository,
    required this.auditRepository,
    required this.notificationSender,
  }) : super(const RoleAssignmentInitial());

  Future<void> loadForStaff(String schoolId, String userId) async {
    emit(const RoleAssignmentLoading());
    final result = await repository.getAssignments(
      schoolId: schoolId,
      userId: userId,
    );
    result.fold(
      (failure) => emit(RoleAssignmentError(failure.message)),
      (assignments) => emit(RoleAssignmentLoaded(assignments)),
    );
  }

  Future<void> loadForRole(String schoolId, String roleDefinitionId) async {
    emit(const RoleAssignmentLoading());
    final result = await repository.getAssignmentsForRole(
      schoolId: schoolId,
      roleDefinitionId: roleDefinitionId,
    );
    result.fold(
      (failure) => emit(RoleAssignmentError(failure.message)),
      (assignments) => emit(RoleAssignmentLoaded(assignments)),
    );
  }

  /// Creates [draft] as a new assignment, logs it, and notifies the staff
  /// member. [role] supplies the display name for both.
  Future<bool> assign({
    required StaffRoleAssignment draft,
    required StaffDesignation role,
    required UserEntity actor,
  }) async {
    final current = state;
    if (current is RoleAssignmentLoaded) {
      emit(current.copyWith(isMutating: true));
    }

    final result = await repository.createAssignment(draft);
    return result.fold(
      (failure) {
        emit(RoleAssignmentError(failure.message));
        return false;
      },
      (created) {
        final scopeLabel = created.scopeSummaryLabel;
        auditRepository.logAction(
          schoolId: created.schoolId,
          title: 'Role assigned',
          description:
              'Assigned ${role.name} to staff member ${created.staffId}'
              '${scopeLabel.isNotEmpty ? ' ($scopeLabel)' : ''}',
          iconName: role.iconName,
          colorHex: role.colorHex,
          userId: actor.id,
          relatedEntityId: created.id,
        );
        notificationSender.send(
          sender: actor,
          audience: NotificationAudience(
            kind: NotificationAudienceKind.users,
            userIds: [created.userId],
          ),
          category: NotificationCategory.others,
          type: NotificationType.custom,
          title: 'New role assigned',
          body:
              'You have been assigned as ${role.name}'
              '${scopeLabel.isNotEmpty ? ' for $scopeLabel' : ''}.',
          sourceModule: 'structure',
          sourceEntityId: created.id,
        );
        if (current is RoleAssignmentLoaded) {
          emit(
            current.copyWith(
              assignments: [...current.assignments, created],
              isMutating: false,
            ),
          );
        }
        return true;
      },
    );
  }

  Future<bool> endAssignment({
    required StaffRoleAssignment assignment,
    required StaffDesignation role,
    required UserEntity actor,
  }) async {
    final current = state;
    if (current is RoleAssignmentLoaded) {
      emit(current.copyWith(isMutating: true));
    }

    final result = await repository.endAssignment(
      schoolId: assignment.schoolId,
      assignmentId: assignment.id,
      endedBy: actor.id,
    );
    return result.fold(
      (failure) {
        emit(RoleAssignmentError(failure.message));
        return false;
      },
      (_) {
        auditRepository.logAction(
          schoolId: assignment.schoolId,
          title: 'Role assignment ended',
          description:
              'Ended ${role.name} for staff member '
              '${assignment.staffId}',
          iconName: role.iconName,
          colorHex: role.colorHex,
          userId: actor.id,
          relatedEntityId: assignment.id,
        );
        notificationSender.send(
          sender: actor,
          audience: NotificationAudience(
            kind: NotificationAudienceKind.users,
            userIds: [assignment.userId],
          ),
          category: NotificationCategory.others,
          type: NotificationType.custom,
          title: 'Role assignment ended',
          body: 'Your ${role.name} responsibility has ended.',
          sourceModule: 'structure',
          sourceEntityId: assignment.id,
        );
        if (current is RoleAssignmentLoaded) {
          emit(
            current.copyWith(
              assignments: current.assignments
                  .map(
                    (a) => a.id == assignment.id
                        ? a.copyWith(
                            status: AssignmentStatus.removed,
                            endDate: DateTime.now(),
                          )
                        : a,
                  )
                  .toList(),
              isMutating: false,
            ),
          );
        }
        return true;
      },
    );
  }

  Future<bool> reactivateAssignment({
    required StaffRoleAssignment assignment,
    required StaffDesignation role,
    required UserEntity actor,
  }) async {
    final current = state;
    if (current is RoleAssignmentLoaded) {
      emit(current.copyWith(isMutating: true));
    }

    final result = await repository.reactivateAssignment(
      schoolId: assignment.schoolId,
      assignmentId: assignment.id,
      reactivatedBy: actor.id,
    );
    return result.fold(
      (failure) {
        emit(RoleAssignmentError(failure.message));
        return false;
      },
      (_) {
        auditRepository.logAction(
          schoolId: assignment.schoolId,
          title: 'Role assignment reactivated',
          description:
              'Reactivated ${role.name} for staff member '
              '${assignment.staffId}',
          iconName: role.iconName,
          colorHex: role.colorHex,
          userId: actor.id,
          relatedEntityId: assignment.id,
        );
        if (current is RoleAssignmentLoaded) {
          emit(
            current.copyWith(
              assignments: current.assignments
                  .map(
                    (a) => a.id == assignment.id
                        ? a.copyWith(status: AssignmentStatus.active)
                        : a,
                  )
                  .toList(),
              isMutating: false,
            ),
          );
        }
        return true;
      },
    );
  }
}
