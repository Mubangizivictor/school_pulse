import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

enum _StatusFilter { all, active, inactive }

enum _SortBy { recentlyAdded, name, role }

/// Staff directory - the screen School Admin lands on immediately after
/// tapping Staff from the dashboard. Replaces the old Account Management
/// landing page for this entry point (see `UserManagementPage`, still used
/// for the audit/quick-actions overview but no longer the default
/// `/staff/admin/users` destination).
///
/// Data note: staff accounts here are created directly (see
/// `createStaffAccount` / the Add Staff wizard), there is no separate
/// email-invite step, and Firestore staff docs carry no "last login" concept
/// beyond `lastActiveAt`. So this screen only ever shows Active/Inactive plus
/// a real last-active timestamp - it deliberately has no "invitations
/// pending" bucket or resend/cancel-invite actions, since that state doesn't
/// exist in the data model.
class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final _searchController = TextEditingController();
  String _query = '';
  _StatusFilter _status = _StatusFilter.all;
  String? _departmentId;
  String? _designationId;
  String? _employmentType;
  _SortBy _sortBy = _SortBy.recentlyAdded;

  int _page = 0;
  static const int _pageSize = 10;

  late Future<List<UserEntity>> _staffFuture;

  @override
  void initState() {
    super.initState();
    _staffFuture = _loadStaff();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
        _page = 0;
      });
    });
  }

  Future<List<UserEntity>> _loadStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    return result.fold((failure) => throw failure, (staff) => staff);
  }

  Future<void> _refresh() async {
    final future = _loadStaff();
    setState(() {
      _staffFuture = future;
      _page = 0;
    });
    await future;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount =>
      (_status != _StatusFilter.all ? 1 : 0) +
      (_departmentId != null ? 1 : 0) +
      (_designationId != null ? 1 : 0) +
      (_employmentType != null ? 1 : 0);

  List<UserEntity> _applyFilters(List<UserEntity> staff) {
    final filtered = staff.where((s) {
      if (_status == _StatusFilter.active && !s.isActive) return false;
      if (_status == _StatusFilter.inactive && s.isActive) return false;
      if (_departmentId != null && s.departmentId != _departmentId) {
        return false;
      }
      if (_designationId != null && s.designationId != _designationId) {
        return false;
      }
      if (_employmentType != null && s.employmentType != _employmentType) {
        return false;
      }
      if (_query.isNotEmpty) {
        final haystack = [
          s.name,
          s.email,
          s.staffCode ?? '',
          ...s.roles.map(UserRoleDisplay.name),
        ].join(' ').toLowerCase();
        if (!haystack.contains(_query)) return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case _SortBy.recentlyAdded:
        // Firestore order already reflects insertion order for accounts
        // without a dateJoined; fall back to name for stability otherwise.
        filtered.sort((a, b) {
          final ad = a.dateJoined;
          final bd = b.dateJoined;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });
        break;
      case _SortBy.name:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case _SortBy.role:
        filtered.sort((a, b) {
          final ar = a.roles.isEmpty ? '' : UserRoleDisplay.name(a.roles.first);
          final br = b.roles.isEmpty ? '' : UserRoleDisplay.name(b.roles.first);
          return ar.toLowerCase().compareTo(br.toLowerCase());
        });
        break;
    }
    return filtered;
  }

  bool _canInviteStaff(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return authState is AuthAuthenticated &&
        authState.user.roles.any(UserRoleDisplay.adminRoles.contains);
  }

  @override
  Widget build(BuildContext context) {
    final canInviteStaff = _canInviteStaff(context);
    return BlocProvider(
      create: (_) => di.sl<StructureBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AdminAppBar(
          title: 'Staff',
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Filters',
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _openFilters(context),
                ),
                if (_activeFilterCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: _CountBadge(count: _activeFilterCount),
                  ),
              ],
            ),
            if (canInviteStaff)
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 4),
                child: FilledButton.icon(
                  onPressed: () => context.push('/staff/admin/users/add-staff'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.background(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add staff'),
                ),
              ),
          ],
        ),
        body: FutureBuilder<List<UserEntity>>(
          future: _staffFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SchoolPulseLoader());
            }
            if (snapshot.hasError) {
              return _buildErrorState(context);
            }
            final all = snapshot.data ?? const [];
            final filtered = _applyFilters(all);
            return ResponsiveBuilder(
              builder: (context, layout) {
                final isWeb = layout == ResponsiveLayout.desktop;
                return Column(
                  children: [
                    _buildHeaderControls(
                      context,
                      all: all,
                      isWeb: isWeb,
                      canInviteStaff: canInviteStaff,
                    ),
                    Expanded(
                      child: all.isEmpty
                          ? _buildEmptyState(
                              context,
                              title: 'No staff yet',
                              message:
                                  'Add your first staff member to get started.',
                              showAddAction: true,
                            )
                          : filtered.isEmpty
                          ? _buildEmptyState(
                              context,
                              title: 'No matching staff',
                              message: 'Try a different search or filter.',
                              showAddAction: false,
                            )
                          : RefreshIndicator(
                              onRefresh: _refresh,
                              child: isWeb
                                  ? _StaffTable(
                                      staff: _paginate(filtered),
                                      total: filtered.length,
                                      page: _page,
                                      pageSize: _pageSize,
                                      onPageChanged: (p) =>
                                          setState(() => _page = p),
                                      departmentName: (id) =>
                                          _departmentNameFor(context, id),
                                      onTap: (s) => context.push(
                                        '/staff/admin/users/${s.id}',
                                      ),
                                    )
                                  : _StaffList(
                                      staff: filtered,
                                      departmentName: (id) =>
                                          _departmentNameFor(context, id),
                                      onTap: (s) => context.push(
                                        '/staff/admin/users/${s.id}',
                                      ),
                                    ),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<UserEntity> _paginate(List<UserEntity> staff) {
    final start = _page * _pageSize;
    if (start >= staff.length) return const [];
    final end = (start + _pageSize).clamp(0, staff.length);
    return staff.sublist(start, end);
  }

  Widget _buildHeaderControls(
    BuildContext context, {
    required List<UserEntity> all,
    required bool isWeb,
    required bool canInviteStaff,
  }) {
    final activeCount = all.where((s) => s.isActive).length;
    final inactiveCount = all.where((s) => !s.isActive).length;

    return Container(
      padding: EdgeInsets.fromLTRB(isWeb ? 24 : 16, 12, isWeb ? 24 : 16, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${all.length} staff member${all.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryStat(
                count: activeCount,
                label: 'active',
                color: AppColors.success(context),
              ),
              const SizedBox(width: 20),
              _SummaryStat(
                count: inactiveCount,
                label: 'inactive',
                color: AppColors.textMuted(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  hintText: 'Search staff name, role or department',
                  controller: _searchController,
                ),
              ),
              if (isWeb) ...[
                const SizedBox(width: 12),
                _SortDropdown(
                  value: _sortBy,
                  onChanged: (v) => setState(() => _sortBy = v),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _buildFilterChipsRow(context),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusChip(
            label: 'All',
            selected: _status == _StatusFilter.all,
            onTap: () => setState(() => _status = _StatusFilter.all),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Active',
            selected: _status == _StatusFilter.active,
            onTap: () => setState(() => _status = _StatusFilter.active),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Inactive',
            selected: _status == _StatusFilter.inactive,
            onTap: () => setState(() => _status = _StatusFilter.inactive),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'More filters',
            selected: _departmentId != null ||
                _designationId != null ||
                _employmentType != null,
            icon: Icons.tune,
            onTap: () => _openFilters(context),
          ),
        ],
      ),
    );
  }

  String? _departmentNameFor(BuildContext context, String? departmentId) {
    if (departmentId == null) return null;
    final departments = context.read<StructureBloc>().state.departments;
    return departments.where((d) => d.id == departmentId).firstOrNull?.name;
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String message,
    required bool showAddAction,
  }) {
    final canInviteStaff = _canInviteStaff(context);
    final showCta = showAddAction && canInviteStaff;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 48),
        EmptyState(
          icon: Icons.people_outline,
          title: title,
          message: message,
          ctaLabel: showCta ? 'Add Staff' : null,
          onCtaPressed: showCta
              ? () => context.push('/staff/admin/users/add-staff')
              : null,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 48),
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Couldn\'t load staff',
          message: 'Check your connection and try again.',
          ctaLabel: 'Retry',
          onCtaPressed: _refresh,
        ),
      ],
    );
  }

  void _openFilters(BuildContext context) {
    final structureBloc = context.read<StructureBloc>();
    final all = _staffFuture;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: structureBloc,
          child: FutureBuilder<List<UserEntity>>(
            future: all,
            builder: (context, snapshot) {
              final employmentTypes = (snapshot.data ?? const <UserEntity>[])
                  .map((s) => s.employmentType)
                  .whereType<String>()
                  .where((e) => e.trim().isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
              return _FiltersSheet(
                initialDepartmentId: _departmentId,
                initialDesignationId: _designationId,
                initialEmploymentType: _employmentType,
                employmentTypes: employmentTypes,
                onApply: (departmentId, designationId, employmentType) {
                  setState(() {
                    _departmentId = departmentId;
                    _designationId = designationId;
                    _employmentType = employmentType;
                    _page = 0;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.information(context),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _SortBy value;
  final ValueChanged<_SortBy> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SortBy>(
          value: value,
          onChanged: (v) => v != null ? onChanged(v) : null,
          items: const [
            DropdownMenuItem(
              value: _SortBy.recentlyAdded,
              child: Text('Recently added'),
            ),
            DropdownMenuItem(value: _SortBy.name, child: Text('Name')),
            DropdownMenuItem(value: _SortBy.role, child: Text('Role')),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? AppColors.background(context)
                    : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.background(context)
                    : AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffList extends StatelessWidget {
  const _StaffList({
    required this.staff,
    required this.departmentName,
    required this.onTap,
  });

  final List<UserEntity> staff;
  final String? Function(String?) departmentName;
  final void Function(UserEntity) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: staff.length,
      itemBuilder: (context, index) {
        final s = staff[index];
        return _StaffCard(
          staff: s,
          departmentName: departmentName(s.departmentId),
          onTap: () => onTap(s),
        );
      },
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.departmentName,
    required this.onTap,
  });

  final UserEntity staff;
  final String? departmentName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final roleLabel = staff.roles.isEmpty
        ? '—'
        : UserRoleDisplay.name(staff.roles.first);
    final subtitle = [roleLabel, ?departmentName].join(' • ');

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(
        children: [
          AvatarInitials(name: staff.name, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  staff.email,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(
            label: staff.isActive ? 'Active' : 'Inactive',
            color: staff.isActive
                ? AppColors.success(context)
                : AppColors.textMuted(context),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            color: AppColors.textMuted(context),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _StaffTable extends StatelessWidget {
  const _StaffTable({
    required this.staff,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
    required this.departmentName,
    required this.onTap,
  });

  final List<UserEntity> staff;
  final int total;
  final int page;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final String? Function(String?) departmentName;
  final void Function(UserEntity) onTap;

  @override
  Widget build(BuildContext context) {
    final pageCount = (total / pageSize).ceil().clamp(1, 999999);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.4),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2.2),
                  3: FlexColumnWidth(1.4),
                  4: FlexColumnWidth(0.6),
                },
                children: [
                  _headerRow(context),
                  for (final s in staff) _dataRow(context, s),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${page + 1} of $pageCount',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: page + 1 < pageCount
                        ? () => onPageChanged(page + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _headerRow(BuildContext context) {
    TextStyle style = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: AppColors.textSecondary(context),
    );
    Widget cell(String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(label, style: style),
    );
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border(context)),
        ),
      ),
      children: [
        cell('Staff member'),
        cell('Role · Department'),
        cell('Contact'),
        cell('Account status'),
        const SizedBox.shrink(),
      ],
    );
  }

  TableRow _dataRow(BuildContext context, UserEntity s) {
    final roleLabel = s.roles.isEmpty ? '—' : UserRoleDisplay.name(s.roles.first);
    final dept = departmentName(s.departmentId);
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border(context)),
        ),
      ),
      children: [
        _rowCell(
          context,
          onTap: () => onTap(s),
          child: Row(
            children: [
              AvatarInitials(name: s.name, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (s.staffCode != null)
                      Text(
                        'ID: ${s.staffCode}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _rowCell(
          context,
          onTap: () => onTap(s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(roleLabel, style: TextStyle(color: AppColors.textPrimary(context))),
              if (dept != null)
                Text(
                  dept,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
            ],
          ),
        ),
        _rowCell(
          context,
          onTap: () => onTap(s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.email,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (s.phoneNumber != null)
                Text(
                  s.phoneNumber!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
            ],
          ),
        ),
        _rowCell(
          context,
          onTap: () => onTap(s),
          child: StatusBadge(
            label: s.isActive ? 'Active' : 'Inactive',
            color: s.isActive
                ? AppColors.success(context)
                : AppColors.textMuted(context),
          ),
        ),
        _rowCell(
          context,
          onTap: () => onTap(s),
          child: Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }

  Widget _rowCell(
    BuildContext context, {
    required Widget child,
    required VoidCallback onTap,
  }) {
    return TableRowInkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: child,
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.initialDepartmentId,
    required this.initialDesignationId,
    required this.initialEmploymentType,
    required this.employmentTypes,
    required this.onApply,
  });

  final String? initialDepartmentId;
  final String? initialDesignationId;
  final String? initialEmploymentType;
  final List<String> employmentTypes;
  final void Function(
    String? departmentId,
    String? designationId,
    String? employmentType,
  )
  onApply;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String? _departmentId;
  String? _designationId;
  String? _employmentType;

  @override
  void initState() {
    super.initState();
    _departmentId = widget.initialDepartmentId;
    _designationId = widget.initialDesignationId;
    _employmentType = widget.initialEmploymentType;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StructureBloc>().state;
    final departments = state.departments;
    final designations = state.designations;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _departmentId = null;
                      _designationId = null;
                      _employmentType = null;
                    }),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Department',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _departmentId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('All Departments'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Departments'),
                  ),
                  ...departments.map(
                    (Department d) => DropdownMenuItem<String?>(
                      value: d.id,
                      child: Text(d.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _departmentId = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Role',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _designationId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('All Roles'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Roles'),
                  ),
                  ...designations.map(
                    (StaffDesignation d) => DropdownMenuItem<String?>(
                      value: d.id,
                      child: Text(d.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _designationId = value),
              ),
              if (widget.employmentTypes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Employment type',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _employmentType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('All Types'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...widget.employmentTypes.map(
                      (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _employmentType = value),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_departmentId, _designationId, _employmentType);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
