import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AdminAppBar(
          title: 'Staff Profile',
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Roles & Responsibilities'),
            ],
          ),
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: SchoolPulseLoader());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const EmptyState(
                icon: Icons.person_off_outlined,
                title: 'Staff member not found',
                message: 'This profile may have been removed.',
              );
            }
            final user = UserModel.fromJson({
              ...snapshot.data!.data()!,
              'id': widget.uid,
            });

            return TabBarView(
              controller: _tabController,
              children: [
                _ProfileTab(user: user),
                _RolesTab(staff: user),
              ],
            );
          },
        ),
      ),
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

/// Primary Role card + All Active Roles list, matching the target design's
/// staff profile Roles & Responsibilities tab.
class _RolesTab extends StatefulWidget {
  const _RolesTab({required this.staff});
  final UserModel staff;

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
              Text(
                'Roles & Responsibilities',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '${_firstNameOrFallback(widget.staff.name)} has '
                '${assignments.length} active role'
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
