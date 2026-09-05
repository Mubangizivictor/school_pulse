import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../../domain/entities/parent_access_invite.dart';
import '../status_chip.dart';

enum ParentAccessSortColumn { name, phone, learners, status }

/// Sortable web table matching the reference screenshot's five columns:
/// Parent | Phone | Linked learners | Portal access (pill badge) | Latest
/// code status (dot + label). Both status columns always render - the
/// reference shows both together, one summarizing sign-in access, the other
/// the underlying invite's code state.
class ParentAccessDataTable extends StatelessWidget {
  final List<ParentAccessInvite> rows;
  final ParentAccessSortColumn sortColumn;
  final bool sortAscending;
  final ValueChanged<ParentAccessSortColumn> onSort;
  final void Function(ParentAccessInvite invite)? onRowTap;

  const ParentAccessDataTable({
    super.key,
    required this.rows,
    this.sortColumn = ParentAccessSortColumn.name,
    this.sortAscending = true,
    required this.onSort,
    this.onRowTap,
  });

  int _columnIndex(ParentAccessSortColumn column) {
    switch (column) {
      case ParentAccessSortColumn.name:
        return 0;
      case ParentAccessSortColumn.phone:
        return 1;
      case ParentAccessSortColumn.learners:
        return 2;
      case ParentAccessSortColumn.status:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _columnIndex(sortColumn),
        sortAscending: sortAscending,
        headingRowColor: WidgetStatePropertyAll(
          AppColors.surfaceContainer(context),
        ),
        columns: [
          DataColumn(
            label: const Text('Parent'),
            onSort: (_, __) => onSort(ParentAccessSortColumn.name),
          ),
          DataColumn(
            label: const Text('Phone'),
            onSort: (_, __) => onSort(ParentAccessSortColumn.phone),
          ),
          DataColumn(
            label: const Text('Linked learners'),
            onSort: (_, __) => onSort(ParentAccessSortColumn.learners),
          ),
          const DataColumn(label: Text('Portal access')),
          DataColumn(
            label: const Text('Latest code status'),
            onSort: (_, __) => onSort(ParentAccessSortColumn.status),
          ),
          const DataColumn(label: Text('')),
        ],
        rows: rows.map((invite) {
          return DataRow(
            onSelectChanged: onRowTap == null ? null : (_) => onRowTap!(invite),
            cells: [
              DataCell(Text(invite.parentName)),
              DataCell(Text(invite.maskedPhone)),
              DataCell(Text('${invite.learnerCount} learner${invite.learnerCount == 1 ? '' : 's'}')),
              DataCell(_PortalAccessPill(invite: invite)),
              DataCell(AccessCodeStatusChip(invite: invite)),
              DataCell(
                Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted(context)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Filled pill badge (Active/Pending/Revoked) for the "Portal access"
/// column - visually distinct from the dot+label "Latest code status"
/// column, matching the reference's two different status treatments.
class _PortalAccessPill extends StatelessWidget {
  final ParentAccessInvite invite;

  const _PortalAccessPill({required this.invite});

  @override
  Widget build(BuildContext context) {
    final (label, color, surface) = switch (invite.status) {
      ParentInviteStatus.revoked => (
          'Revoked',
          AppColors.danger(context),
          AppColors.dangerSurface(context),
        ),
      ParentInviteStatus.expired => (
          'Revoked',
          AppColors.danger(context),
          AppColors.dangerSurface(context),
        ),
      ParentInviteStatus.active when invite.expiringSoon => (
          'Pending',
          AppColors.warning(context),
          AppColors.warningSurface(context),
        ),
      ParentInviteStatus.active => (
          'Active',
          AppColors.success(context),
          AppColors.successSurface(context),
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
