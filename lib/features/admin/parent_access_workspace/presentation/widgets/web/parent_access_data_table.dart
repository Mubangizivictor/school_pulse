import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../../domain/entities/parent_access_invite.dart';
import '../status_chip.dart';

enum ParentAccessSortColumn { name, phone, learners, status }

/// Sortable web table shared by both tabs - [showCodeStatusColumn] switches
/// the trailing status label vocabulary between the Parents tab (simple
/// Linked/Revoked) and the Access-codes tab (Linked/Pending/Expiring
/// soon/Revoked), matching the two reference screenshots' distinct copy for
/// the same underlying invite status.
class ParentAccessDataTable extends StatelessWidget {
  final List<ParentAccessInvite> rows;
  final bool showCodeStatusColumn;
  final ParentAccessSortColumn sortColumn;
  final bool sortAscending;
  final ValueChanged<ParentAccessSortColumn> onSort;
  final void Function(ParentAccessInvite invite)? onRowTap;

  const ParentAccessDataTable({
    super.key,
    required this.rows,
    this.showCodeStatusColumn = false,
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
          DataColumn(
            label: Text(showCodeStatusColumn ? 'Latest code status' : 'Portal access'),
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
              DataCell(
                showCodeStatusColumn
                    ? AccessCodeStatusChip(invite: invite)
                    : ParentAccessStatusChip(invite: invite),
              ),
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
