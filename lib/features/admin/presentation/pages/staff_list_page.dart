import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_breakpoints.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_invitation.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Masks a contact string (email or phone) down to a short recognisable
/// prefix, e.g. "amina.k@school.edu" -> "ami***@school.edu" and
/// "+256701234567" -> "+256 ••• ••• 567" - mirrors the mockup's masked
/// contact column so full contact details are only ever visible to roles
/// permitted to see them (see [_StaffListPageState._canViewContactDetails]).
String _maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return email;
  final local = email.substring(0, at);
  final domain = email.substring(at);
  final visible = local.length <= 2 ? local : local.substring(0, 2);
  return '$visible${'*' * (local.length - visible.length).clamp(2, 6)}$domain';
}

String _maskPhone(String phone) {
  final digitsOnly = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digitsOnly.length <= 4) return phone;
  final last3 = digitsOnly.substring(digitsOnly.length - 3);
  final prefix = digitsOnly.startsWith('+')
      ? digitsOnly.substring(0, digitsOnly.length > 4 ? 4 : digitsOnly.length)
      : '';
  return '$prefix ••• ••• $last3'.trim();
}

enum _StatusFilter { all, active, invited, inactive }

enum _SortBy { recentlyAdded, name, role }

/// A staff account's account status is derived, not stored as one field:
/// `isActive` covers active/inactive, while a pending sign-in invitation
/// (`invitationStatus == "sent"` on the user doc, mirrored from the
/// `staff_invitations` collection by `createStaffInvitation` /
/// `cancelStaffInvitation` in functions/index.js) takes priority display-wise
/// over a merely-inactive account, matching how invited staff have no
/// completed account yet.
_StatusFilter _statusOf(UserEntity s) {
  if (s.invitationStatus == 'sent') return _StatusFilter.invited;
  return s.isActive ? _StatusFilter.active : _StatusFilter.inactive;
}

/// Staff directory - the screen School Admin lands on immediately after
/// tapping Staff from the dashboard. Replaces the old Account Management
/// landing page for this entry point (see `UserManagementPage`, still used
/// for the audit/quick-actions overview but no longer the default
/// `/staff/admin/users` destination).
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
  String? _campusId;
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
      (_employmentType != null ? 1 : 0) +
      (_campusId != null ? 1 : 0);

  void _clearFilters() {
    setState(() {
      _status = _StatusFilter.all;
      _departmentId = null;
      _designationId = null;
      _employmentType = null;
      _campusId = null;
      _page = 0;
    });
  }

  List<UserEntity> _applyFilters(List<UserEntity> staff) {
    final filtered = staff.where((s) {
      if (_status != _StatusFilter.all && _statusOf(s) != _status) {
        return false;
      }
      if (_departmentId != null && s.departmentId != _departmentId) {
        return false;
      }
      if (_designationId != null && s.designationId != _designationId) {
        return false;
      }
      if (_employmentType != null && s.employmentType != _employmentType) {
        return false;
      }
      if (_campusId != null && s.campusId != _campusId) {
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

  bool _canManageStaffAccess(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated &&
        authState.user.roles.any(UserRoleDisplay.adminRoles.contains);
  }

  Future<void> _resendInvitation(BuildContext context, UserEntity s) async {
    final confirmed = await _confirm(
      context,
      title: 'Resend invitation?',
      message: 'A new sign-in link will be sent to ${s.email}.',
      confirmLabel: 'Resend',
    );
    if (confirmed != true) return;
    final result = await di.sl<CreateStaffInvitation>()(s.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => _showSnack(context, 'Couldn\'t resend invitation.'),
      (_) {
        _showSnack(context, 'Invitation resent to ${s.email}.');
        _refresh();
      },
    );
  }

  Future<void> _cancelInvitation(BuildContext context, UserEntity s) async {
    final confirmed = await _confirm(
      context,
      title: 'Revoke invitation?',
      message:
          '${s.name} will no longer be able to use the sign-in link sent to them.',
      confirmLabel: 'Revoke',
      isDestructive: true,
    );
    if (confirmed != true) return;
    final result = await di.sl<CancelStaffInvitation>()(s.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => _showSnack(context, 'Couldn\'t revoke invitation.'),
      (_) {
        _showSnack(context, 'Invitation revoked.');
        _refresh();
      },
    );
  }

  Future<void> _toggleActive(BuildContext context, UserEntity s) async {
    final activating = !s.isActive;
    final confirmed = await _confirm(
      context,
      title: activating ? 'Activate staff account?' : 'Deactivate account?',
      message: activating
          ? '${s.name} will regain access to School Pulse.'
          : '${s.name} will immediately lose access to School Pulse.',
      confirmLabel: activating ? 'Activate' : 'Deactivate',
      isDestructive: !activating,
    );
    if (confirmed != true) return;
    final result = await di.sl<ToggleStaffStatus>()(s.id, activating);
    if (!context.mounted) return;
    result.fold(
      (failure) => _showSnack(context, 'Couldn\'t update account status.'),
      (_) {
        _showSnack(
          context,
          activating ? 'Account activated.' : 'Account deactivated.',
        );
        _refresh();
      },
    );
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Full email/phone are HR-sensitive; only admin-console roles (the same
  /// set permitted to navigate this console at all - see the `users` route
  /// guard in router.dart) see them unmasked. Everyone else sees a masked
  /// contact column, never the raw value.
  bool _canViewContactDetails(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return authState is AuthAuthenticated &&
        authState.user.roles.any(UserRoleDisplay.adminConsoleRoles.contains);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<StructureBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop =
                      constraints.maxWidth >= AppBreakpoints.smallDesktop;
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? AppSpacing.x3l : AppSpacing.xl,
                        AppSpacing.x2l,
                        isDesktop ? AppSpacing.x3l : AppSpacing.xl,
                        AppSpacing.x4l,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 1280 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _header(context, all, isDesktop),
                              if (!isDesktop) ...[
                                const SizedBox(height: AppSpacing.l),
                                _searchBox(context),
                              ],
                              const SizedBox(height: AppSpacing.l),
                              _summaryStrip(context, all),
                              const SizedBox(height: AppSpacing.l),
                              _filterChipsRow(context, all),
                              const SizedBox(height: AppSpacing.xl),
                              if (all.isEmpty)
                                _buildEmptyState(
                                  context,
                                  title: 'No staff yet',
                                  message:
                                      'Add your first staff member to get started.',
                                  showAddAction: true,
                                )
                              else if (filtered.isEmpty)
                                _buildEmptyState(
                                  context,
                                  title: 'No matching staff',
                                  message: 'Try a different search or filter.',
                                  showAddAction: false,
                                )
                              else if (isDesktop)
                                _StaffTable(
                                  staff: _paginate(filtered),
                                  total: filtered.length,
                                  page: _page,
                                  pageSize: _pageSize,
                                  onPageChanged: (p) =>
                                      setState(() => _page = p),
                                  departmentName: (id) =>
                                      _departmentNameFor(context, id),
                                  canViewContact: _canViewContactDetails(
                                    context,
                                  ),
                                  canManageAccess: _canManageStaffAccess(
                                    context,
                                  ),
                                  onTap: (s) => context.push(
                                    '/staff/admin/users/${s.id}',
                                  ),
                                  onResendInvitation: (s) =>
                                      _resendInvitation(context, s),
                                  onCancelInvitation: (s) =>
                                      _cancelInvitation(context, s),
                                  onToggleActive: (s) =>
                                      _toggleActive(context, s),
                                )
                              else
                                _StaffList(
                                  staff: filtered,
                                  departmentName: (id) =>
                                      _departmentNameFor(context, id),
                                  canViewContact: _canViewContactDetails(
                                    context,
                                  ),
                                  canManageAccess: _canManageStaffAccess(
                                    context,
                                  ),
                                  onTap: (s) => context.push(
                                    '/staff/admin/users/${s.id}',
                                  ),
                                  onResendInvitation: (s) =>
                                      _resendInvitation(context, s),
                                  onCancelInvitation: (s) =>
                                      _cancelInvitation(context, s),
                                  onToggleActive: (s) =>
                                      _toggleActive(context, s),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
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

  Widget _header(BuildContext context, List<UserEntity> all, bool isDesktop) {
    final canInviteStaff = _canInviteStaff(context);
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          '${all.length} staff member${all.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );

    final addButton = canInviteStaff ? _addStaffButton(context) : null;

    // Desktop keeps the inline search box, filters, refresh and Add all in
    // the sticky header row (room for it). Mobile/tablet collapse search to
    // a full-width field below the title and filters to a compact icon
    // button, matching the Students directory's established pattern.
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          SizedBox(width: 320, child: _searchBox(context)),
          const SizedBox(width: AppSpacing.m),
          _filterButton(context),
          const SizedBox(width: AppSpacing.m),
          _iconAction(
            context,
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
          if (addButton != null) ...[
            const SizedBox(width: AppSpacing.m),
            addButton,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        _iconAction(
          context,
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: _refresh,
        ),
        const SizedBox(width: AppSpacing.s),
        _filterButton(context),
        if (addButton != null) ...[
          const SizedBox(width: AppSpacing.s),
          addButton,
        ],
      ],
    );
  }

  Widget _addStaffButton(BuildContext context) => ElevatedButton.icon(
    onPressed: () => context.push('/staff/admin/users/add-staff'),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary(context),
      foregroundColor: AppColors.background(context),
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    ),
    icon: const Icon(Icons.add),
    label: const Text('Add staff'),
  );

  Widget _iconAction(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) => IconButton(
    tooltip: tooltip,
    icon: Icon(icon),
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size(48, 48),
      side: BorderSide(color: AppColors.border(context)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    ),
  );

  Widget _filterButton(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      _iconAction(
        context,
        icon: Icons.tune,
        tooltip: 'Filters',
        onPressed: () => _openFilters(context),
      ),
      if (_activeFilterCount > 0)
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.information(context),
              borderRadius: AppRadius.full,
            ),
            child: Text(
              '$_activeFilterCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _searchBox(BuildContext context) => TextField(
    controller: _searchController,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      hintText: 'Search staff name, role or department',
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(borderRadius: AppRadius.medium),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.medium,
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
    ),
  );

  Widget _summaryStrip(BuildContext context, List<UserEntity> all) {
    final activeCount = all
        .where((s) => _statusOf(s) == _StatusFilter.active)
        .length;
    final invitedCount = all
        .where((s) => _statusOf(s) == _StatusFilter.invited)
        .length;
    final inactiveCount = all
        .where((s) => _statusOf(s) == _StatusFilter.inactive)
        .length;
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: [
        _SummaryStat(
          count: activeCount,
          label: 'active',
          color: AppColors.success(context),
        ),
        _SummaryStat(
          count: invitedCount,
          label: 'invited',
          color: AppColors.warning(context),
        ),
        _SummaryStat(
          count: inactiveCount,
          label: 'inactive',
          color: AppColors.textMuted(context),
        ),
      ],
    );
  }

  Widget _filterChipsRow(BuildContext context, List<UserEntity> all) {
    final allCount = all.length;
    final activeCount = all
        .where((s) => _statusOf(s) == _StatusFilter.active)
        .length;
    final invitedCount = all
        .where((s) => _statusOf(s) == _StatusFilter.invited)
        .length;
    final inactiveCount = all
        .where((s) => _statusOf(s) == _StatusFilter.inactive)
        .length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusChip(
            label: 'All',
            count: allCount,
            selected: _status == _StatusFilter.all,
            onTap: () => setState(() => _status = _StatusFilter.all),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Active',
            count: activeCount,
            selected: _status == _StatusFilter.active,
            onTap: () => setState(() => _status = _StatusFilter.active),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Invited',
            count: invitedCount,
            selected: _status == _StatusFilter.invited,
            onTap: () => setState(() => _status = _StatusFilter.invited),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Inactive',
            count: inactiveCount,
            selected: _status == _StatusFilter.inactive,
            onTap: () => setState(() => _status = _StatusFilter.inactive),
          ),
          const SizedBox(width: 8),
          _SortDropdown(
            value: _sortBy,
            onChanged: (v) => setState(() => _sortBy = v),
          ),
          if (_activeFilterCount > 0) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            ),
          ],
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
    // Embedded directly in the page's own outer SingleChildScrollView (see
    // build()), so this must lay out as a plain Column rather than a
    // ListView - see the same fix on _StaffList above.
    final canInviteStaff = _canInviteStaff(context);
    final showCta = showAddAction && canInviteStaff;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
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
      ),
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
              final employmentTypes =
                  (snapshot.data ?? const <UserEntity>[])
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
                initialCampusId: _campusId,
                employmentTypes: employmentTypes,
                onApply:
                    (departmentId, designationId, employmentType, campusId) {
                      setState(() {
                        _departmentId = departmentId;
                        _designationId = designationId;
                        _employmentType = employmentType;
                        _campusId = campusId;
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
        Text(label, style: TextStyle(color: AppColors.textSecondary(context))),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _SortBy value;
  final ValueChanged<_SortBy> onChanged;

  static const _labels = {
    _SortBy.recentlyAdded: 'Recently added',
    _SortBy.name: 'Name',
    _SortBy.role: 'Role',
  };

  @override
  Widget build(BuildContext context) {
    // DropdownButton sizes its closed state to the WIDEST item in `items`
    // regardless of selectedItemBuilder, so "Recently added" always drives
    // its intrinsic width - wrapping it in Flexible alone does not stop it
    // overflowing a narrow row. Cap it to a fixed max width instead and let
    // the selected label ellipsize inside that.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<_SortBy>(
            value: value,
            isDense: true,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            onChanged: (v) => v != null ? onChanged(v) : null,
            selectedItemBuilder: (context) => _labels.values
                .map(
                  (label) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                )
                .toList(),
            items: _labels.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedFg = AppColors.information(context);
    final unselectedFg = AppColors.textSecondary(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.informationSurface(context)
              : AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? selectedFg : AppColors.border(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedFg : unselectedFg,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: selected ? selectedFg : unselectedFg,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Relative/short-date label for a staff member's last activity, e.g.
/// "Today, 2:14 PM", "Yesterday, 4:27 PM" or "Apr 28, 2025". Returns "—" when
/// unknown rather than guessing.
String _lastActivityLabel(DateTime? at) {
  if (at == null) return '—';
  final local = at.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  final time = '$hour:$minute $period';
  if (day == today) return 'Today, $time';
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Yesterday, $time';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

/// Label/color for a staff account's derived status badge, shared by the
/// mobile card list and the desktop table.
(String, Color) _statusBadgeStyle(BuildContext context, UserEntity s) {
  switch (_statusOf(s)) {
    case _StatusFilter.invited:
      return ('Invitation pending', AppColors.warning(context));
    case _StatusFilter.inactive:
      return ('Inactive', AppColors.textMuted(context));
    case _StatusFilter.active:
    case _StatusFilter.all:
      return ('Active', AppColors.success(context));
  }
}

class _StaffList extends StatelessWidget {
  const _StaffList({
    required this.staff,
    required this.departmentName,
    required this.canViewContact,
    required this.canManageAccess,
    required this.onTap,
    required this.onResendInvitation,
    required this.onCancelInvitation,
    required this.onToggleActive,
  });

  final List<UserEntity> staff;
  final String? Function(String?) departmentName;
  final bool canViewContact;
  final bool canManageAccess;
  final void Function(UserEntity) onTap;
  final void Function(UserEntity) onResendInvitation;
  final void Function(UserEntity) onCancelInvitation;
  final void Function(UserEntity) onToggleActive;

  @override
  Widget build(BuildContext context) {
    // Embedded directly in the page's own outer SingleChildScrollView (see
    // StaffListPage.build), so this must lay out as a plain Column rather
    // than a ListView - a ListView here would be an unbounded-height
    // viewport nested inside another scrollable.
    return Column(
      children: [
        for (final s in staff)
          _StaffCard(
            staff: s,
            departmentName: departmentName(s.departmentId),
            canViewContact: canViewContact,
            canManageAccess: canManageAccess,
            onTap: () => onTap(s),
            onResendInvitation: () => onResendInvitation(s),
            onCancelInvitation: () => onCancelInvitation(s),
            onToggleActive: () => onToggleActive(s),
          ),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.departmentName,
    required this.canViewContact,
    required this.canManageAccess,
    required this.onTap,
    required this.onResendInvitation,
    required this.onCancelInvitation,
    required this.onToggleActive,
  });

  final UserEntity staff;
  final String? departmentName;
  final bool canViewContact;
  final bool canManageAccess;
  final VoidCallback onTap;
  final VoidCallback onResendInvitation;
  final VoidCallback onCancelInvitation;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final roleLabel = staff.roles.isEmpty
        ? '—'
        : UserRoleDisplay.name(staff.roles.first);
    final subtitle = [roleLabel, ?departmentName].join(' • ');
    final contact = canViewContact ? staff.email : _maskEmail(staff.email);
    final (statusLabel, statusColor) = _statusBadgeStyle(context, staff);

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
                  contact,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _lastActivityLabel(staff.lastActiveAt),
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: StatusBadge(label: statusLabel, color: statusColor),
            ),
          ),
          if (canManageAccess) ...[
            const SizedBox(width: 4),
            _StaffActionsMenu(
              staff: staff,
              onResendInvitation: onResendInvitation,
              onCancelInvitation: onCancelInvitation,
              onToggleActive: onToggleActive,
            ),
          ] else ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}

/// Authorised row actions - view is always available via the row tap;
/// invite/access actions only render for roles that can manage staff access
/// (gated by [StaffListPage._canManageStaffAccess], the same admin-role set
/// permitted to reach this console at all).
class _StaffActionsMenu extends StatelessWidget {
  const _StaffActionsMenu({
    required this.staff,
    required this.onResendInvitation,
    required this.onCancelInvitation,
    required this.onToggleActive,
  });

  final UserEntity staff;
  final VoidCallback onResendInvitation;
  final VoidCallback onCancelInvitation;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final status = _statusOf(staff);
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textMuted(context)),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      iconSize: 20,
      tooltip: 'Actions',
      onSelected: (value) {
        switch (value) {
          case 'resend':
            onResendInvitation();
            break;
          case 'cancel':
            onCancelInvitation();
            break;
          case 'toggle':
            onToggleActive();
            break;
        }
      },
      itemBuilder: (context) => [
        if (status == _StatusFilter.invited) ...[
          const PopupMenuItem(
            value: 'resend',
            child: Text('Resend invitation'),
          ),
          const PopupMenuItem(
            value: 'cancel',
            child: Text('Revoke invitation'),
          ),
        ] else
          PopupMenuItem(
            value: 'toggle',
            child: Text(staff.isActive ? 'Deactivate' : 'Activate'),
          ),
      ],
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
    required this.canViewContact,
    required this.canManageAccess,
    required this.onTap,
    required this.onResendInvitation,
    required this.onCancelInvitation,
    required this.onToggleActive,
  });

  final List<UserEntity> staff;
  final int total;
  final int page;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final String? Function(String?) departmentName;
  final bool canViewContact;
  final bool canManageAccess;
  final void Function(UserEntity) onTap;
  final void Function(UserEntity) onResendInvitation;
  final void Function(UserEntity) onCancelInvitation;
  final void Function(UserEntity) onToggleActive;

  @override
  Widget build(BuildContext context) {
    // Embedded directly in the page's own outer SingleChildScrollView, so
    // this only needs its own *horizontal* scroller for narrow desktop
    // widths - vertical scrolling is handled by the page, not here (an
    // Expanded/vertical SingleChildScrollView pair here would need a
    // bounded height that no longer exists once this isn't the sole
    // Expanded child of a Scaffold body Column).
    final pageCount = (total / pageSize).ceil().clamp(1, 999999);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 900),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.4),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2.2),
                3: FlexColumnWidth(1.6),
                4: FlexColumnWidth(1.6),
                5: FlexColumnWidth(0.8),
              },
              children: [
                _headerRow(context),
                for (final s in staff) _dataRow(context, s),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      children: [
        cell('Staff member'),
        cell('Role · Department'),
        cell('Contact'),
        cell('Account status'),
        cell('Last activity'),
        cell('Actions'),
      ],
    );
  }

  TableRow _dataRow(BuildContext context, UserEntity s) {
    final roleLabel = s.roles.isEmpty
        ? '—'
        : UserRoleDisplay.name(s.roles.first);
    final dept = departmentName(s.departmentId);
    final email = canViewContact ? s.email : _maskEmail(s.email);
    final phone = s.phoneNumber == null
        ? null
        : (canViewContact ? s.phoneNumber! : _maskPhone(s.phoneNumber!));
    final (statusLabel, statusColor) = _statusBadgeStyle(context, s);
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
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
              Text(
                roleLabel,
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
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
                email,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (phone != null)
                Text(
                  phone,
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
          child: StatusBadge(label: statusLabel, color: statusColor),
        ),
        _rowCell(
          context,
          onTap: () => onTap(s),
          child: Text(
            _lastActivityLabel(s.lastActiveAt),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: canManageAccess
              ? _StaffActionsMenu(
                  staff: s,
                  onResendInvitation: () => onResendInvitation(s),
                  onCancelInvitation: () => onCancelInvitation(s),
                  onToggleActive: () => onToggleActive(s),
                )
              : Icon(
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
    required this.initialCampusId,
    required this.employmentTypes,
    required this.onApply,
  });

  final String? initialDepartmentId;
  final String? initialDesignationId;
  final String? initialEmploymentType;
  final String? initialCampusId;
  final List<String> employmentTypes;
  final void Function(
    String? departmentId,
    String? designationId,
    String? employmentType,
    String? campusId,
  )
  onApply;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String? _departmentId;
  String? _designationId;
  String? _employmentType;
  String? _campusId;

  @override
  void initState() {
    super.initState();
    _departmentId = widget.initialDepartmentId;
    _designationId = widget.initialDesignationId;
    _employmentType = widget.initialEmploymentType;
    _campusId = widget.initialCampusId;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StructureBloc>().state;
    final departments = state.departments;
    final designations = state.designations;
    final campuses = state.campuses;

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
                      _campusId = null;
                    }),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              if (campuses.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Campus',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _campusId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('All Campuses'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Campuses'),
                    ),
                    ...campuses.map(
                      (Campus c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _campusId = value),
                ),
              ],
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
                      (t) =>
                          DropdownMenuItem<String?>(value: t, child: Text(t)),
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
                    widget.onApply(
                      _departmentId,
                      _designationId,
                      _employmentType,
                      _campusId,
                    );
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
