import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

import '../../domain/entities/staff_role_assignment.dart';

/// The "Switch Active Role" sheet behind the dashboard's responsibility
/// control.
///
/// Lists every responsibility type the teacher holds - Subject/Class Teacher
/// via [subjectAssignments], everything else (Patron, HOD, Bursar, ...) via
/// [otherResponsibilities] - the caller passes assignments already filtered
/// to active, in-date rows, so there is nothing here to select that would
/// then be refused. Rendering is generic over [StaffResponsibilityType]: it
/// does not special-case any role beyond the subject-teacher icon/section
/// split, so no change is needed here as new responsibility types are
/// assigned elsewhere in the app. Styled from the existing AppColors tokens
/// so it reads as part of the approved dashboard rather than a new surface.
class ResponsibilitySwitcherSheet extends StatelessWidget {
  final List<StaffRoleAssignment> subjectAssignments;
  final List<StaffRoleAssignment> otherResponsibilities;
  final String? activeAssignmentId;

  const ResponsibilitySwitcherSheet({
    super.key,
    required this.subjectAssignments,
    this.otherResponsibilities = const [],
    this.activeAssignmentId,
  });

  /// Returns the chosen assignment id, or null if the teacher dismissed it.
  static Future<String?> show(
    BuildContext context, {
    required List<StaffRoleAssignment> subjectAssignments,
    List<StaffRoleAssignment> otherResponsibilities = const [],
    String? activeAssignmentId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ResponsibilitySwitcherSheet(
        subjectAssignments: subjectAssignments,
        otherResponsibilities: otherResponsibilities,
        activeAssignmentId: activeAssignmentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Material, not a decorated Container: ListTile paints its ink splash on
      // the nearest Material ancestor, so a plain coloured box above them
      // swallows the ripple.
      child: Material(
        color: AppColors.surfaceElevated(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.s),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Switch Active Role',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    if (subjectAssignments.isNotEmpty)
                      _sectionLabel(context, 'My subjects'),
                    ...subjectAssignments.map((a) => _tile(context, a)),
                    if (otherResponsibilities.isNotEmpty) ...[
                      _sectionLabel(context, 'Other responsibilities'),
                      ...otherResponsibilities.map((a) => _tile(context, a)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, StaffRoleAssignment assignment) {
    final isActive = assignment.id == activeAssignmentId;
    return ListTile(
      onTap: isActive ? null : () => Navigator.of(context).pop(assignment.id),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          assignment.roleType == StaffResponsibilityType.subjectTeacher
              ? Icons.menu_book_outlined
              : Icons.badge_outlined,
          color: AppColors.primary(context),
          size: 20,
        ),
      ),
      title: Text(
        assignment.displayLabel,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        // Substitute cover is called out: the teacher is acting for someone
        // else and their access ends when the cover does.
        assignment.isSubstitute
            ? 'Covering • ${assignment.roleType.label}'
            : assignment.roleType.label,
        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
      ),
      trailing: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Current Role',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }
}
