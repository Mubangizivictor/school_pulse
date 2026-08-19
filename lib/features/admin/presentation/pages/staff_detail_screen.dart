import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/add_staff_wizard_controller.dart';
import 'package:school_pulse/features/admin/presentation/pages/edit_staff_screen.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_id_card_screen.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/admin/presentation/widgets/assignable_staff_roles.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/usecases/update_staff_member.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/staff_identity_bloc.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/role_assignment_cubit.dart';
import 'package:school_pulse/features/structure/presentation/bloc/role_assignment_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/screens/assign_staff_role_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/people_forms_screen.dart'
    show staffDesignationIcon, staffDesignationColor;
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Admin-facing read view of another staff member's profile - personal/
/// employment info plus Roles & Responsibilities - reached from the Add
/// Staff wizard's Success screen and from Structure's Staff Roles list.
/// Distinct from staff_profile_screen.dart, which is a self-view screen
/// driven by the currently signed-in user.
class StaffDetailScreen extends StatefulWidget {
  final String uid;
  const StaffDetailScreen({super.key, required this.uid});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }

  void _loadUser() {
    _userFuture =
        FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RoleAssignmentCubit>(),
      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userFuture,
        builder: (context, snapshot) {
          UserModel? user;
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data!.exists) {
            user = UserModel.fromJson({
              ...snapshot.data!.data()!,
              'id': widget.uid,
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: AdminAppBar(
              title: 'Staff Profile',
              actions: user == null
                  ? null
                  : [
                      IconButton(
                        icon: const Icon(Icons.badge_outlined),
                        tooltip: 'Staff ID Card',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => di.sl<StaffIdentityBloc>(),
                              child: StaffIdCardScreen(staff: user!),
                            ),
                          ),
                        ),
                      ),
                      _EditStaffAction(
                        user: user,
                        onSaved: () => setState(_loadUser),
                      ),
                    ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Roles & Responsibilities'),
                ],
              ),
            ),
            body: Builder(
              builder: (context) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: SchoolPulseLoader());
                }
                if (user == null) {
                  return const EmptyState(
                    icon: Icons.person_off_outlined,
                    title: 'Staff member not found',
                    message: 'This profile may have been removed.',
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _ProfileTab(user: user),
                    _RolesTab(
                      staff: user,
                      onStaffChanged: (_) => setState(_loadUser),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Edit action shown in Profile-tab context, gated to the same admin
/// roles allowed to submit staff changes via the Add Staff wizard.
class _EditStaffAction extends StatelessWidget {
  const _EditStaffAction({required this.user, required this.onSaved});
  final UserModel user;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated ||
        !AddStaffWizardController.canSubmit(authState.user.roles)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.edit_outlined),
      tooltip: 'Edit Staff',
      onPressed: () async {
        final saved = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => EditStaffScreen(user: user)),
        );
        if (saved == true) onSaved();
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                AvatarInitials(name: user.name, size: 80),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.staffCode ?? '',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  alignment: WrapAlignment.center,
                  children: user.roles
                      .map(
                        (r) => StatusBadge(
                          label: UserRoleDisplay.name(r),
                          color: AppColors.primary(context),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phoneNumber ?? '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employment Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.apartment_outlined,
                  label: 'School',
                  value: user.schoolName ?? '—',
                ),
                if (user.assignedClass != null)
                  _InfoRow(
                    icon: Icons.meeting_room_outlined,
                    label: 'Assigned Class',
                    value: user.assignedClass!,
                  ),
                _InfoRow(
                  icon: Icons.circle,
                  label: 'Status',
                  value: user.isActive ? 'Active' : 'Inactive',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Account Roles (the real UserEntity.roles - Deputy Head/School Admin/Dean
/// of Studies etc., editable here) plus the Structure module's Class/
/// Subject Assignments (a separate system: which class/subject a Class or
/// Subject Teacher role is actually attached to). These are deliberately
/// kept as two clearly-labeled sections rather than merged, since they are
/// two different data models with different edit paths.
class _RolesTab extends StatefulWidget {
  const _RolesTab({required this.staff, required this.onStaffChanged});
  final UserModel staff;
  final ValueChanged<UserModel> onStaffChanged;

  @override
  State<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<_RolesTab> {
  static String _firstNameOrFallback(String name) {
    final first = name.trim().split(' ').firstOrNull ?? '';
    return first.isEmpty || first.endsWith('.') ? 'This staff member' : first;
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RoleAssignmentCubit>().loadForStaff(
        authState.user.schoolId,
        widget.staff.id,
      );
    }
  }

  Future<void> _editAccountRoles() async {
    final updated = await showModalBottomSheet<UserModel>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AccountRolesEditorSheet(staff: widget.staff),
    );
    if (updated != null) widget.onStaffChanged(updated);
  }

  Future<void> _openAssign() async {
    final assigned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<RoleAssignmentCubit>()),
            BlocProvider.value(value: context.read<StructureBloc>()),
          ],
          child: AssignStaffRoleScreen(preselectedStaff: widget.staff),
        ),
      ),
    );
    if (assigned == true && mounted) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<RoleAssignmentCubit>().loadForStaff(
          authState.user.schoolId,
          widget.staff.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RoleAssignmentCubit, RoleAssignmentState>(
        builder: (context, state) {
          if (state is RoleAssignmentLoading ||
              state is RoleAssignmentInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state is RoleAssignmentError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load roles',
              message: state.message,
            );
          }
          final assignments = (state as RoleAssignmentLoaded).assignments
              .where((a) => a.isCurrentlyValid())
              .toList();
          final designations = context
              .watch<StructureBloc>()
              .state
              .designations;

          StaffDesignation? roleFor(StaffRoleAssignment a) =>
              designations.where((d) => d.id == a.roleDefinitionId).firstOrNull;

          final primary = assignments.where((a) => a.isPrimary).firstOrNull;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Roles',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final authState = context.watch<AuthBloc>().state;
                      final isSelf =
                          authState is AuthAuthenticated &&
                          authState.user.id == widget.staff.id;
                      final canEdit =
                          authState is AuthAuthenticated &&
                          !isSelf &&
                          AddStaffWizardController.canSubmit(
                            authState.user.roles,
                          );
                      if (!canEdit) return const SizedBox.shrink();
                      return TextButton.icon(
                        onPressed: _editAccountRoles,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                      );
                    },
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  final authState = context.watch<AuthBloc>().state;
                  final isSelf =
                      authState is AuthAuthenticated &&
                      authState.user.id == widget.staff.id;
                  if (!isSelf) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "You can't edit your own roles - ask another "
                      'Director, Head Teacher, or School Admin to make '
                      'this change.',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                },
              ),
              Text(
                widget.staff.roles.isEmpty
                    ? 'No account roles assigned.'
                    : '${_firstNameOrFallback(widget.staff.name)} holds '
                          '${widget.staff.roles.length} account role'
                          '${widget.staff.roles.length == 1 ? '' : 's'}.',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.staff.roles
                    .map(
                      (r) => StatusBadge(
                        label: UserRoleDisplay.name(r),
                        color: AppColors.primary(context),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Class / Subject Assignments',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '${_firstNameOrFallback(widget.staff.name)} has '
                '${assignments.length} active assignment'
                '${assignments.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 16),
              if (primary != null) ...[
                Text(
                  'PRIMARY ROLE',
                  style: TextStyle(
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 8),
                _RoleCard(
                  assignment: primary,
                  role: roleFor(primary),
                  isPrimary: true,
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'ALL ACTIVE ROLES',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 8),
              if (assignments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No active roles assigned yet.'),
                )
              else
                ...assignments.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RoleCard(
                      assignment: a,
                      role: roleFor(a),
                      isPrimary: a.isPrimary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAssign,
        icon: const Icon(Icons.add),
        label: const Text('Assign New Role'),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Lets an admin add/remove this staff member's account-level roles
/// (Deputy Head, Dean of Studies, Class Teacher, etc.). schoolAdmin is
/// deliberately not offered - see assignable_staff_roles.dart and the
/// matching firestore.rules users/{uid} comment: School Admin is
/// provisioned only through SaaS school registration, never reassignable
/// in-app, to avoid a staff-editing-staff privilege-escalation path.
class _AccountRolesEditorSheet extends StatefulWidget {
  const _AccountRolesEditorSheet({required this.staff});
  final UserModel staff;

  @override
  State<_AccountRolesEditorSheet> createState() =>
      _AccountRolesEditorSheetState();
}

class _AccountRolesEditorSheetState extends State<_AccountRolesEditorSheet> {
  late Set<UserRole> _selected;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.staff.roles.toSet();
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one role.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final updated = widget.staff.copyWith(roles: _selected.toList());
    final result = await di.sl<UpdateStaffMember>()(updated);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _saving = false;
        _error = failure.message.contains('permission-denied')
            ? "You don't have permission to make this change. "
                  'Ask a Director, Head Teacher, or School Admin.'
            : failure.message;
      }),
      (_) => Navigator.of(context).pop(UserModel.fromEntity(updated)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Edit Account Roles',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'One login can hold several roles - e.g. Deputy Head + Dean of Studies.',
              style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: assignableStaffRoleGroups.entries.expand((group) {
                    final roles = group.value
                        .where(assignableStaffRoles.contains)
                        .toList();
                    if (roles.isEmpty) return const <Widget>[];
                    return [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          group.key.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                      ...roles.map(
                        (role) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(UserRoleDisplay.name(role)),
                          value: _selected.contains(role),
                          onChanged: (checked) => setState(() {
                            if (checked == true) {
                              _selected.add(role);
                            } else {
                              _selected.remove(role);
                            }
                          }),
                        ),
                      ),
                    ];
                  }).toList(),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: AppColors.danger(context), fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Roles'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.assignment,
    required this.role,
    required this.isPrimary,
  });
  final StaffRoleAssignment assignment;
  final StaffDesignation? role;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final icon = role != null
        ? staffDesignationIcon(role!.iconName)
        : Icons.badge_outlined;
    final color = role != null
        ? staffDesignationColor(role!.colorHex)
        : Theme.of(context).colorScheme.primary;
    final label = role?.name ?? assignment.displayLabel;
    final scope = assignment.scopeSummaryLabel;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (scope.isNotEmpty)
                  Text(scope, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Primary',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted(context)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
