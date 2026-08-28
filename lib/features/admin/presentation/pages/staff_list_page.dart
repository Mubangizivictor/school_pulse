import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

enum _StatusFilter { all, active, inactive }

/// Staff List - the screen School Admin lands on immediately after tapping
/// Staff from the dashboard. Replaces the old Account Management landing
/// page for this entry point (see `UserManagementPage`, still used for
/// the audit/quick-actions overview but no longer the default `/staff/admin/users`
/// destination).
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

  late Future<List<UserEntity>> _staffFuture;

  @override
  void initState() {
    super.initState();
    _staffFuture = _loadStaff();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
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
    });
    await future;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserEntity> _applyFilters(List<UserEntity> staff) {
    return staff.where((s) {
      if (_status == _StatusFilter.active && !s.isActive) return false;
      if (_status == _StatusFilter.inactive && s.isActive) return false;
      if (_departmentId != null && s.departmentId != _departmentId) {
        return false;
      }
      if (_designationId != null && s.designationId != _designationId) {
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<StructureBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AdminAppBar(
          title: 'Staff',
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _openFilters(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search staff name, role or department',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    onTap: () =>
                        setState(() => _status = _StatusFilter.inactive),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<UserEntity>>(
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
                    if (all.isEmpty) {
                      return _buildEmptyState(
                        context,
                        title: 'No staff yet',
                        message: 'Add your first staff member to get started.',
                        showAddAction: true,
                      );
                    }
                    if (filtered.isEmpty) {
                      return _buildEmptyState(
                        context,
                        title: 'No matching staff',
                        message: 'Try a different search or filter.',
                        showAddAction: false,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final staff = filtered[index];
                        return _StaffCard(
                          staff: staff,
                          departmentName: _departmentNameFor(
                            context,
                            staff.departmentId,
                          ),
                          onTap: () =>
                              context.push('/staff/admin/users/${staff.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/staff/admin/users/add-staff'),
          icon: const Icon(Icons.add),
          label: const Text('Add Staff'),
          backgroundColor: AppColors.primary(context),
          // Primary reverses between black and white by theme. Its matching
          // background is therefore the only colour that stays legible in
          // both appearances.
          foregroundColor: AppColors.background(context),
        ),
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 48),
        EmptyState(
          icon: Icons.people_outline,
          title: title,
          message: message,
          ctaLabel: showAddAction ? 'Add Staff' : null,
          onCtaPressed: showAddAction
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
          child: _FiltersSheet(
            initialDepartmentId: _departmentId,
            initialDesignationId: _designationId,
            onApply: (departmentId, designationId) {
              setState(() {
                _departmentId = departmentId;
                _designationId = designationId;
              });
            },
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.background(context)
                : AppColors.textSecondary(context),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
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
    final subtitle = [
      roleLabel,
      if (departmentName != null) departmentName!,
    ].join(' • ');

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
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.initialDepartmentId,
    required this.initialDesignationId,
    required this.onApply,
  });

  final String? initialDepartmentId;
  final String? initialDesignationId;
  final void Function(String? departmentId, String? designationId) onApply;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String? _departmentId;
  String? _designationId;

  @override
  void initState() {
    super.initState();
    _departmentId = widget.initialDepartmentId;
    _designationId = widget.initialDesignationId;
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_departmentId, _designationId);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
