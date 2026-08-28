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
import 'package:school_pulse/features/auth/domain/usecases/admin_reset_staff_password.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
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
    show staffDesignationIcon;
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
    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
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
                        icon: const Icon(Icons.qr_code_2_outlined),
                        tooltip: 'Staff ID and QR code',
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
                  Tab(text: 'Overview'),
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
                    _ProfileTab(
                      user: user,
                      onChanged: () => setState(_loadUser),
                    ),
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
  const _ProfileTab({required this.user, required this.onChanged});
  final UserModel user;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final structure = context.watch<StructureBloc>().state;
    final department = structure.departments
        .where((item) => item.id == user.departmentId)
        .firstOrNull
        ?.name;
    final designation = structure.designations
        .where((item) => item.id == user.designationId)
        .firstOrNull
        ?.name;
    final campus = structure.campuses
        .where((item) => item.id == user.campusId)
        .firstOrNull
        ?.name;
    final roleLabel =
        designation ??
        (user.roles.isNotEmpty ? UserRoleDisplay.name(user.roles.first) : null);
    final emergency = user.emergencyContact;
    final contactRows = <_DetailRowData>[
      _DetailRowData(Icons.email_outlined, 'Email', user.email),
      if (_hasValue(user.phoneNumber))
        _DetailRowData(
          Icons.phone_outlined,
          'Primary phone',
          user.phoneNumber!,
        ),
      if (_hasValue(user.alternatePhone))
        _DetailRowData(
          Icons.phone_android_outlined,
          'Alternate phone',
          user.alternatePhone!,
        ),
    ];
    final employmentRows = <_DetailRowData>[
      if (_hasValue(campus ?? user.schoolName))
        _DetailRowData(
          Icons.location_city_outlined,
          'Campus',
          campus ?? user.schoolName!,
        ),
      if (_hasValue(department))
        _DetailRowData(Icons.account_tree_outlined, 'Department', department!),
      if (_hasValue(designation))
        _DetailRowData(Icons.badge_outlined, 'Designation', designation!),
      if (_hasValue(user.employmentType))
        _DetailRowData(
          Icons.work_outline,
          'Employment type',
          user.employmentType!,
        ),
      _DetailRowData(
        user.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
        'Employment status',
        user.isActive ? 'Active' : 'Inactive',
      ),
    ];
    final emergencyRows = <_DetailRowData>[
      if (emergency != null && _hasValue(emergency.name))
        _DetailRowData(Icons.person_outline, 'Name', emergency.name),
      if (emergency != null && _hasValue(emergency.relationship))
        _DetailRowData(
          Icons.people_outline,
          'Relationship',
          emergency.relationship,
        ),
      if (emergency != null && _hasValue(emergency.phoneNumber))
        _DetailRowData(Icons.phone_outlined, 'Phone', emergency.phoneNumber),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IdentityHeader(user: user, roleLabel: roleLabel),
              const SizedBox(height: 20),
              AppCard(
                color: AppColors.surfaceElevated(context),
                showShadow: false,
                borderColor: AppColors.border(context),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 700;
                    final contact = _InformationSection(
                      title: 'Contact',
                      icon: Icons.phone_outlined,
                      rows: contactRows,
                    );
                    final employment = _InformationSection(
                      title: 'Employment',
                      icon: Icons.work_outline,
                      rows: employmentRows,
                    );
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: contact),
                              const SizedBox(width: 28),
                              Expanded(child: employment),
                            ],
                          )
                        : Column(
                            children: [
                              contact,
                              const Divider(height: 32),
                              employment,
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _AccountOnboardingCard(user: user, onChanged: onChanged),
              if (emergencyRows.isNotEmpty) ...[
                const SizedBox(height: 12),
                AppCard(
                  color: AppColors.surfaceElevated(context),
                  showShadow: false,
                  borderColor: AppColors.border(context),
                  child: _InformationSection(
                    title: 'Emergency contact',
                    icon: Icons.contact_emergency_outlined,
                    rows: emergencyRows,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.user, required this.roleLabel});
  final UserModel user;
  final String? roleLabel;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${user.name}, ${user.isActive ? 'active' : 'inactive'} staff member',
    child: Row(
      children: [
        _StaffAvatar(user: user),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              if (user.staffCode?.isNotEmpty == true)
                Text(
                  user.staffCode!,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 15,
                  ),
                ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 10,
                runSpacing: 7,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (roleLabel != null) _BlackPill(label: roleLabel!),
                  _StatusLabel(
                    active: user.isActive,
                    pending: user.mustChangePassword,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar({required this.user});
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    final fallback = AvatarInitials(
      name: user.name,
      size: 72,
      ringColor: AppColors.textPrimary(context),
    );
    if (user.photoUrl == null || user.photoUrl!.trim().isEmpty) return fallback;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary(context), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        user.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _BlackPill extends StatelessWidget {
  const _BlackPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.textPrimary(context),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
    ),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppColors.background(context),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.active, required this.pending});
  final bool active;
  final bool pending;
  @override
  Widget build(BuildContext context) {
    final label = !active
        ? 'Inactive'
        : pending
        ? 'Pending setup'
        : 'Active';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textPrimary(context),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

class _InformationSection extends StatelessWidget {
  const _InformationSection({
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<_DetailRowData> rows;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 21, color: AppColors.textPrimary(context)),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      ...rows.map(
        (row) => _InfoRow(icon: row.icon, label: row.label, value: row.value),
      ),
    ],
  );
}

/// Onboarding/account-lifecycle state plus the two admin actions that only
/// make sense from here: force a password reset (the staff member forgot
/// their temporary password, or it should be rotated) and
/// deactivate/reactivate the account. Deliberately excludes "last login" -
/// nothing in the login path writes that field today, and displaying a
/// fabricated or perpetually-null value would be worse than omitting it.
class _AccountOnboardingCard extends StatefulWidget {
  const _AccountOnboardingCard({required this.user, required this.onChanged});
  final UserModel user;
  final VoidCallback onChanged;

  @override
  State<_AccountOnboardingCard> createState() => _AccountOnboardingCardState();
}

class _AccountOnboardingCardState extends State<_AccountOnboardingCard> {
  bool _working = false;

  bool _canManage(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return authState is AuthAuthenticated &&
        authState.user.id != widget.user.id &&
        AddStaffWizardController.canSubmit(authState.user.roles);
  }

  Future<void> _resetPassword() async {
    setState(() => _working = true);
    final result = await di.sl<AdminResetStaffPassword>()(widget.user.id);
    if (!mounted) return;
    setState(() => _working = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset request completed.')),
      ),
    );
  }

  Future<void> _toggleActive() async {
    final activating = !widget.user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(activating ? 'Reactivate staff?' : 'Deactivate staff?'),
        content: Text(
          activating
              ? '${widget.user.name} will regain access to their account.'
              : '${widget.user.name} will immediately lose access to their '
                    'account. This can be reversed later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(activating ? 'Reactivate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _working = true);
    final result = await di.sl<ToggleStaffStatus>()(widget.user.id, activating);
    if (!mounted) return;
    setState(() => _working = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        widget.onChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activating
                  ? 'Staff account reactivated.'
                  : 'Staff account deactivated.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _canManage(context);
    return AppCard(
      color: AppColors.surfaceElevated(context),
      showShadow: false,
      borderColor: AppColors.border(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(width: 10),
              Text(
                'Account access',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.user.isActive
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      !widget.user.isActive
                          ? 'Account inactive'
                          : widget.user.mustChangePassword
                          ? 'Setup pending'
                          : 'Account active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      !widget.user.isActive
                          ? 'This staff member cannot sign in.'
                          : widget.user.mustChangePassword
                          ? 'The staff member has not completed account setup yet.'
                          : 'Account access is active.',
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canManage) ...[
            if (widget.user.isActive) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _working ? null : _resetPassword,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(
                    widget.user.mustChangePassword
                        ? 'Send password setup link'
                        : 'Send password reset link',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary(context),
                    foregroundColor: AppColors.background(context),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _working ? null : _toggleActive,
                icon: Icon(
                  widget.user.isActive
                      ? Icons.person_off_outlined
                      : Icons.person_add_alt_1_outlined,
                ),
                label: Text(
                  widget.user.isActive
                      ? 'Deactivate staff account'
                      : 'Reactivate staff account',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary(context),
                  minimumSize: const Size.fromHeight(44),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
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

          final missingClassTeacher =
              widget.staff.roles.contains(UserRole.classTeacher) &&
              !assignments.any(
                (a) =>
                    a.roleType == StaffResponsibilityType.classTeacher &&
                    a.classId != null,
              );
          final missingSubjectTeacher =
              widget.staff.roles.contains(UserRole.subjectTeacher) &&
              !assignments.any(
                (a) =>
                    a.roleType == StaffResponsibilityType.subjectTeacher &&
                    a.classId != null,
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (missingClassTeacher || missingSubjectTeacher) ...[
                AlertBanner(
                  title: 'Incomplete role assignment',
                  message: [
                    if (missingClassTeacher)
                      'Class Teacher role has no class assigned.',
                    if (missingSubjectTeacher)
                      'Subject Teacher role has no subject/class assigned.',
                  ].join(' '),
                  color: AppColors.warning(context),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${assignments.length} active role${assignments.length == 1 ? '' : 's'}',
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
                        label: const Text('Edit role'),
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
                    .map((r) => _BlackPill(label: UserRoleDisplay.name(r)))
                    .toList(),
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'Teaching assignments',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                'Access limited to assigned classes and subjects.',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
              const SizedBox(height: 16),
              if (assignments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No teaching responsibilities assigned yet.'),
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
        label: const Text('Assign role'),
        backgroundColor: AppColors.textPrimary(context),
        foregroundColor: AppColors.background(context),
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
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
              ),
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
                style: TextStyle(
                  color: AppColors.danger(context),
                  fontSize: 12,
                ),
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
    final isTeaching =
        assignment.subjectId != null || assignment.classId != null;
    final label = isTeaching
        ? assignment.displayLabel
        : role?.name ?? assignment.displayLabel;
    final scopes = <String>[
      if (assignment.campusId.isNotEmpty) 'Campus scope configured',
      if (assignment.departmentId?.isNotEmpty == true ||
          assignment.permissionScope.departmentId?.isNotEmpty == true)
        'Department scope configured',
      if (assignment.className?.isNotEmpty == true)
        'Class: ${assignment.className}${assignment.streamName?.isNotEmpty == true ? ' ${assignment.streamName}' : ''}',
      if (assignment.subjectName?.isNotEmpty == true)
        'Subject: ${assignment.subjectName}',
      if (assignment.houseId?.isNotEmpty == true)
        'House / dormitory scope configured',
      if (assignment.permissionScope.termIds.isNotEmpty)
        'Term approval scope configured',
      if (assignment.permissionScope.permissions.isNotEmpty)
        'Approval scope: ${assignment.permissionScope.permissions.length} permission${assignment.permissionScope.permissions.length == 1 ? '' : 's'}',
      ...assignment.extraScope.entries.map(
        (entry) => '${_scopeName(entry.key)}: ${entry.value}',
      ),
    ];

    return AppCard(
      color: AppColors.surfaceElevated(context),
      showShadow: false,
      borderColor: AppColors.border(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textPrimary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (isPrimary) const _BlackPill(label: 'Primary'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${role?.name ?? assignment.roleType.label}${assignment.campusId.isNotEmpty ? ' · Campus scope' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (scopes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Whole-school scope',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            )
          else
            ...scopes.map(
              (scope) => Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, size: 17),
                    Expanded(
                      child: Text(scope, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _scopeName(String key) {
    final words = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('Id', '')
        .trim();
    return words.isEmpty
        ? 'Scope'
        : '${words[0].toUpperCase()}${words.substring(1)}';
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
