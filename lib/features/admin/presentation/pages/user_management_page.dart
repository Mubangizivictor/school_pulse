import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../../data/models/audit_log.dart';
import '../../data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/delete_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/update_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../screens/role_management_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

class UserManagementPage extends StatefulWidget {
  final String? initialTab;
  const UserManagementPage({super.key, this.initialTab});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late int _currentTab;

  static const _tabIndexByKey = {'overview': 0, 'staff': 1, 'students': 2, 'parents': 3};

  @override
  void initState() {
    super.initState();
    _currentTab = _tabIndexByKey[widget.initialTab] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Account Management', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTabSwitcher(),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: [
                const UsersOverviewView(),
                const StaffListView(),
                const StudentsListView(),
                const ParentCodesListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Overview',
              isSelected: _currentTab == 0,
              onTap: () => setState(() => _currentTab = 0),
            ),
            _TabItem(
              label: 'Staff',
              isSelected: _currentTab == 1,
              onTap: () => setState(() => _currentTab = 1),
            ),
            _TabItem(
              label: 'Students',
              isSelected: _currentTab == 2,
              onTap: () => setState(() => _currentTab = 2),
            ),
            _TabItem(
              label: 'Parents',
              isSelected: _currentTab == 3,
              onTap: () => setState(() => _currentTab = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class UsersOverviewView extends StatelessWidget {
  const UsersOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
        : '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStats(context),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        QuickActionGrid(
          items: [
            QuickActionItem(
              label: 'Add Staff',
              icon: Icons.person_add_outlined,
              color: AppColors.primary(context),
              onTap: () {
                // This is a bit tricky since the dialog is inside _StaffListViewState.
                // We should probably move the creation logic to a shared place or use a key.
                // For now, we'll just navigate to the Staff tab.
              },
            ),
            QuickActionItem(
              label: 'Add Student',
              icon: Icons.school_outlined,
              color: AppColors.secondary(context),
              onTap: () {},
            ),
            QuickActionItem(
              label: 'Access Codes',
              icon: Icons.vpn_key_outlined,
              color: AppColors.success(context),
              onTap: () {},
            ),
            QuickActionItem(
              label: 'Roles',
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.warning(context),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoleManagementScreen()),
              ),
            ),
            QuickActionItem(
              label: 'Security',
              icon: Icons.security_outlined,
              color: AppColors.danger(context),
              onTap: () {},
            ),
            QuickActionItem(
              label: 'Audit Logs',
              icon: Icons.history_outlined,
              color: Colors.purple,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 32),
        SectionHeader(
          title: 'Recent Activity',
          actionLabel: 'View All',
          onActionPressed: () {},
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AuditLog>>(
          stream: di.sl<AuditRepository>().watchRecentLogs(schoolId: schoolId, limit: 5),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ));
            }
            final logs = snapshot.data!;
            if (logs.isEmpty) {
              return const AppCard(
                child: Center(
                  child: Text('No recent activity found'),
                ),
              );
            }
            return Column(
              children: logs.map<Widget>((log) => _ActivityItem(log: log)).toList(),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return FutureBuilder(
      future: di.sl<GetAdminDashboardStats>()(NoParams()),
      builder: (context, snapshot) {
        final stats = snapshot.data?.getOrElse(
          () => const AdminDashboardStats(
            activeStaffCount: 0,
            totalStudentsCount: 0,
            totalParentsCount: 0,
            visitorsTodayCount: 0,
            activeVisitorsCount: 0,
            systemHealth: 100,
          ),
        );

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: UserStatCard(
                    label: 'Total Staff',
                    count: stats?.activeStaffCount.toString() ?? '...',
                    icon: Icons.people_alt_outlined,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UserStatCard(
                    label: 'Students',
                    count: stats?.totalStudentsCount.toString() ?? '...',
                    icon: Icons.school_outlined,
                    color: AppColors.secondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: UserStatCard(
                    label: 'Parents',
                    count: stats?.totalParentsCount.toString() ?? '...',
                    icon: Icons.family_restroom_outlined,
                    color: AppColors.success(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UserStatCard(
                    label: 'System Health',
                    count: '${stats?.systemHealth.round() ?? 100}%',
                    icon: Icons.bolt_outlined,
                    color: AppColors.information(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final AuditLog log;
  const _ActivityItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(int.parse('0x${log.colorHex}')).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconData(log.iconName),
              color: Color(int.parse('0x${log.colorHex}')),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  log.description,
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTimestamp(log.timestamp),
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 11),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'person_add': return Icons.person_add;
      case 'gpp_maybe': return Icons.gpp_maybe;
      case 'edit': return Icons.edit;
      case 'delete': return Icons.delete;
      case 'lock_reset': return Icons.lock_reset;
      default: return Icons.info_outline;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}';
  }
}


class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? AppColors.primary(context) : AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}

class StaffListView extends StatefulWidget {
  const StaffListView({super.key});

  @override
  State<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends State<StaffListView> {
  late Future<List<UserEntity>> _future;
  String _searchQuery = '';
  String _statusFilter = 'Active'; // 'Active', 'Disabled', 'All'

  final _structureRepository = di.sl<StructureRepository>();
  List<String> _classNames = [];
  List<String> _subjectNames = [];
  StreamSubscription<List<SchoolClass>>? _classesSub;
  StreamSubscription<List<Subject>>? _subjectsSub;

  @override
  void initState() {
    super.initState();
    _future = _load();
    
    // Get schoolId from AuthBloc state
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : '';

    _classesSub = _structureRepository.watchClasses(schoolId).listen((classes) {
      if (mounted) setState(() => _classNames = classes.map((c) => c.name).toList());
    });
    _subjectsSub = _structureRepository.watchSubjects(schoolId).listen((subjects) {
      if (mounted) setState(() => _subjectNames = subjects.map((s) => s.name).toList());
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    _subjectsSub?.cancel();
    super.dispose();
  }

  Future<List<UserEntity>> _load() async {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : '';
    final result = await di.sl<GetStaffMembers>()(schoolId);
    return result.fold((failure) => throw failure, (staff) => staff);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _showStudentActions(BuildContext context, Student student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AvatarInitials(name: student.name, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${student.studentCode} • ${student.className}', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ActionTile(
              label: 'View Profile',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pop(context);
                _showStudentDetails(context, student);
              },
            ),
            _ActionTile(
              label: 'Academic Records',
              icon: Icons.analytics_outlined,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to records
              },
            ),
            _ActionTile(
              label: 'Attendance History',
              icon: Icons.calendar_today_outlined,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to attendance
              },
            ),
            _ActionTile(
              label: 'Manage Parent Links',
              icon: Icons.family_restroom_outlined,
              onTap: () {
                Navigator.pop(context);
                // TODO: Link to parent management
              },
            ),
            const Divider(height: 32),
            _ActionTile(
              label: 'Archive Student',
              icon: Icons.archive_outlined,
              color: AppColors.warning(context),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement archive
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        AvatarInitials(name: student.name, size: 64),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                              Text('Student ID: ${student.studentCode}', style: TextStyle(color: AppColors.textSecondary(context))),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: student.status.name,
                          color: student.status == StudentStatus.active ? AppColors.success(context) : AppColors.danger(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AppCard(
                      child: Column(
                        children: [
                          _DetailRow(label: 'Class', value: student.className, icon: Icons.class_outlined),
                          const Divider(),
                          _DetailRow(label: 'Date of Birth', value: '${student.dateOfBirth.year}-${student.dateOfBirth.month.toString().padLeft(2, '0')}-${student.dateOfBirth.day.toString().padLeft(2, '0')}', icon: Icons.cake_outlined),
                          const Divider(),
                          _DetailRow(label: 'Gender', value: student.gender.name, icon: Icons.person_outline),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary(context))),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: student.emergencyContacts.isEmpty
                            ? [const _DetailRow(label: 'Contact', value: 'None on file', icon: Icons.family_restroom)]
                            : student.emergencyContacts.expand((contact) => [
                                  _DetailRow(label: contact.relationship, value: contact.name, icon: Icons.family_restroom),
                                  const Divider(),
                                  _DetailRow(label: 'Phone', value: contact.phoneNumber, icon: Icons.phone_outlined),
                                ]).toList()
                              ..removeLast(),
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: 'Academic Records',
                      icon: Icons.analytics_outlined,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Student Health Card',
                      icon: Icons.health_and_safety_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(UserEntity member) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.isActive ? 'Disable Account' : 'Enable Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to ${member.isActive ? 'disable' : 'enable'} access for ${member.name}?'),
            if (member.isActive) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for deactivation',
                  hintText: 'e.g., Staff left school, Suspended',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(member.isActive ? 'Disable' : 'Enable', style: TextStyle(color: member.isActive ? AppColors.danger(context) : AppColors.success(context))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final activating = !member.isActive;
      await di.sl<ToggleStaffStatus>()(
        member.id,
        activating,
        reason: member.isActive ? reasonController.text.trim() : null,
      );
      await di.sl<AuditRepository>().logAction(
        schoolId: member.schoolId,
        title: activating ? 'Staff Account Enabled' : 'Staff Account Disabled',
        description: activating
            ? '${member.name} was re-enabled.'
            : '${member.name} was disabled${reasonController.text.trim().isNotEmpty ? ' - ${reasonController.text.trim()}' : ''}.',
        iconName: 'gpp_maybe',
        colorHex: activating ? 'FF4CAF50' : 'FFF44336',
        userId: FirebaseAuth.instance.currentUser?.uid,
      );
      _refresh();
    }
  }

  Future<void> _deleteStaff(UserEntity member) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Delete Account',
      message: 'Are you sure you want to PERMANENTLY delete the account for ${member.name}? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await di.sl<DeleteStaffMember>()(member.id);
      await di.sl<AuditRepository>().logAction(
        schoolId: member.schoolId,
        title: 'Staff Account Deleted',
        description: '${member.name} (${member.email}) was permanently deleted.',
        iconName: 'gpp_maybe',
        colorHex: 'FFF44336',
        userId: FirebaseAuth.instance.currentUser?.uid,
      );
      _refresh();
    }
  }

  Future<void> _editStaff(UserEntity member) async {
    final nameController = TextEditingController(text: member.name);
    final emailController = TextEditingController(text: member.email);
    Set<UserRole> selectedRoles = member.roles.toSet();
    String? assignedClass = member.assignedClass;
    List<SubjectAssignment> subjects = List.from(member.subjects ?? []);

    final roles = UserRole.values.where((r) => r != UserRole.parent).toList();
    final isMobile = MediaQuery.of(context).size.width < 700;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit Staff Member'),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                  const SizedBox(height: 16),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Address')),
                  const SizedBox(height: 16),
                  const Text('System Roles (select all that apply)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(
                    'One login can hold several roles - e.g. Class Teacher + Subject Teacher + Discipline Head.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: roles.map((role) {
                      final selected = selectedRoles.contains(role);
                      return FilterChip(
                        label: Text(UserRoleDisplay.name(role)),
                        selected: selected,
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              if (role == UserRole.boardingMatron) {
                                selectedRoles.remove(UserRole.boardingPatron);
                              } else if (role == UserRole.boardingPatron) {
                                selectedRoles.remove(UserRole.boardingMatron);
                              }
                              
                              selectedRoles.add(role);
                              if (role == UserRole.classTeacher && _classNames.isNotEmpty) {
                                assignedClass ??= _classNames.first;
                              }
                            } else {
                              selectedRoles.remove(role);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (selectedRoles.contains(UserRole.classTeacher)) ...[
                    const SizedBox(height: 16),
                    if (_classNames.isEmpty)
                      Text(
                        'No classes registered yet. Add classes in School Structure first.',
                        style: TextStyle(fontSize: 12, color: AppColors.danger(context)),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: assignedClass,
                        decoration: const InputDecoration(labelText: 'Assigned Class'),
                        items: _classNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setDialogState(() => assignedClass = val),
                      ),
                  ],
                  if (selectedRoles.contains(UserRole.subjectTeacher)) ...[
                    const SizedBox(height: 24),
                    const Text('Subject Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...subjects.map((assignment) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: Text('${assignment.subjectName} (${assignment.className})')),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: AppColors.danger(context)),
                                onPressed: () => setDialogState(() => subjects.remove(assignment)),
                              ),
                            ],
                          ),
                        )),
                    TextButton.icon(
                      onPressed: () async {
                        final newAssignment = await _showAddSubjectDialog(dialogContext);
                        if (newAssignment != null) {
                          setDialogState(() => subjects.add(newAssignment));
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subject & Class'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: selectedRoles.isEmpty ? null : () => Navigator.pop(dialogContext, true),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final updated = UserEntity(
        id: member.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        schoolId: member.schoolId,
        roles: selectedRoles.toList(),
        assignedClass: selectedRoles.contains(UserRole.classTeacher) ? assignedClass : null,
        subjects: selectedRoles.contains(UserRole.subjectTeacher) ? subjects : null,
        isActive: member.isActive,
        mustChangePassword: member.mustChangePassword,
        studentIds: member.studentIds,
        phoneNumber: member.phoneNumber,
        photoUrl: member.photoUrl,
        deactivationReason: member.deactivationReason,
      );
      await di.sl<UpdateStaffMember>()(updated);
      _refresh();
    }
  }

  Future<SubjectAssignment?> _showAddSubjectDialog(BuildContext context) async {
    if (_subjectNames.isEmpty || _classNames.isEmpty) {
      return showDialog<SubjectAssignment>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nothing to assign yet'),
          content: const Text(
            'Register at least one class and one subject in School Structure before assigning a subject teacher.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }

    String selectedSub = _subjectNames.first;
    String selectedCls = _classNames.first;

    return showDialog<SubjectAssignment>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSub,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: _subjectNames.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedSub = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCls,
                decoration: const InputDecoration(labelText: 'Class'),
                items: _classNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCls = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, SubjectAssignment(subjectName: selectedSub, className: selectedCls)),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateStaffDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    Set<UserRole> selectedRoles = {UserRole.classTeacher};
    String? assignedClass;
    List<SubjectAssignment> subjects = [];

    void generatePassword() {
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
      final rand = DateTime.now().microsecondsSinceEpoch;
      final pass = List.generate(8, (i) => chars[(rand + i * 31) % chars.length]).join();
      passwordController.text = pass;
    }

    generatePassword();

    final roles = UserRole.values.where((r) => r != UserRole.parent && r != UserRole.schoolAdmin && r != UserRole.director && r != UserRole.headTeacher).toList();
    final isMobile = MediaQuery.of(context).size.width < 700;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Create Staff Account'),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: 'Used for login and notifications.',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Temporary Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            helperText: 'Required on first login.',
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setDialogState(generatePassword),
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Regenerate',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('System Roles (select all that apply)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text(
                    'One login can hold several roles - e.g. Class Teacher + Subject Teacher + Discipline Head.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: roles.map((role) {
                      final selected = selectedRoles.contains(role);
                      return FilterChip(
                        label: Text(UserRoleDisplay.name(role)),
                        selected: selected,
                        onSelected: (val) {
                          setDialogState(() {
                            if (val) {
                              if (role == UserRole.boardingMatron) {
                                selectedRoles.remove(UserRole.boardingPatron);
                              } else if (role == UserRole.boardingPatron) {
                                selectedRoles.remove(UserRole.boardingMatron);
                              }

                              selectedRoles.add(role);
                              if (role == UserRole.classTeacher && _classNames.isNotEmpty) {
                                assignedClass ??= _classNames.first;
                              }
                            } else {
                              selectedRoles.remove(role);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (selectedRoles.contains(UserRole.classTeacher)) ...[
                    const SizedBox(height: 16),
                    if (_classNames.isEmpty)
                      Text(
                        'No classes registered yet. Add classes in School Structure first.',
                        style: TextStyle(fontSize: 12, color: AppColors.danger(context)),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: assignedClass,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Class',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                        items: _classNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setDialogState(() => assignedClass = val),
                      ),
                  ],
                  if (selectedRoles.contains(UserRole.subjectTeacher)) ...[
                    const SizedBox(height: 24),
                    const Text('Subject Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...subjects.map((assignment) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(child: Text('${assignment.subjectName} (${assignment.className})')),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: AppColors.danger(context)),
                                onPressed: () => setDialogState(() => subjects.remove(assignment)),
                              ),
                            ],
                          ),
                        )),
                    TextButton.icon(
                      onPressed: () async {
                        final newAssignment = await _showAddSubjectDialog(dialogContext);
                        if (newAssignment != null) {
                          setDialogState(() => subjects.add(newAssignment));
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subject & Class'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    selectedRoles.isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final createResult = await di.sl<CreateStaffAccount>()(CreateStaffAccountParams(
      email: emailController.text.trim(),
      name: nameController.text.trim(),
      schoolId: context.read<AuthBloc>().state is AuthAuthenticated
          ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
          : '',
      roles: selectedRoles.toList(),
      password: passwordController.text.trim(),
      assignedClass: selectedRoles.contains(UserRole.classTeacher) ? assignedClass : null,
      subjects: selectedRoles.contains(UserRole.subjectTeacher) ? subjects : null,
    ));

    if (!mounted) return;
    Navigator.pop(context);

    createResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${failure.message}'), backgroundColor: AppColors.danger(context)),
      ),
      (tempPassword) {
        _refresh();
        di.sl<AuditRepository>().logAction(
          schoolId: context.read<AuthBloc>().state is AuthAuthenticated
              ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
              : '',
          title: 'Staff Account Created',
          description: '${nameController.text.trim()} was added as ${selectedRoles.map(UserRoleDisplay.name).join(', ')}.',
          iconName: 'person_add',
          colorHex: 'FF2196F3',
          userId: FirebaseAuth.instance.currentUser?.uid,
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success(context)),
                const SizedBox(width: 8),
                const Expanded(child: Text('Staff Created')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account for ${nameController.text} has been provisioned.'),
                const SizedBox(height: 16),
                const Text('Temporary Password:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(tempPassword, style: const TextStyle(fontFamily: 'monospace'))),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => Clipboard.setData(ClipboardData(text: tempPassword)),
                      ),
                    ],
                  ),
                ),
                const Text('The user will be prompted to change this password on their first login.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search staff...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceContainer(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _openCreateStaffDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Active'),
                      selected: _statusFilter == 'Active',
                      onSelected: (val) => setState(() => _statusFilter = 'Active'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Disabled'),
                      selected: _statusFilter == 'Disabled',
                      onSelected: (val) => setState(() => _statusFilter = 'Disabled'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _statusFilter == 'All',
                      onSelected: (val) => setState(() => _statusFilter = 'All'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<UserEntity>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final staff = snapshot.data!;
              
              final filteredStaff = staff.where((s) {
                final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                     s.email.toLowerCase().contains(_searchQuery.toLowerCase());
                
                bool matchesStatus;
                if (_statusFilter == 'Active') {
                  matchesStatus = s.isActive;
                } else if (_statusFilter == 'Disabled') {
                  matchesStatus = !s.isActive;
                } else {
                  matchesStatus = true;
                }
                
                return matchesSearch && matchesStatus;
              }).toList();

              if (filteredStaff.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No staff found',
                  message: 'Try adjusting your search or filters.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filteredStaff.length,
                itemBuilder: (context, index) {
                  final member = filteredStaff[index];
                  return FadeInSlide(
                    delay: Duration(milliseconds: 30 * index),
                    direction: FadeInDirection.bt,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(context), width: 0.5),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: AvatarInitials(
                          name: member.name,
                          size: 40,
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.email,
                              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: member.roles
                                  .map((r) => _CompactRoleChip(role: UserRoleDisplay.name(r)))
                                  .toList(),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!member.isActive)
                              StatusBadge(label: 'Disabled', color: AppColors.danger(context), isCompact: true),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onPressed: () => _showUserActions(context, member),
                            ),
                          ],
                        ),
                        onTap: () => _showStaffDetails(context, member),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showUserActions(BuildContext context, UserEntity member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AvatarInitials(name: member.name, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(member.email, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ActionTile(
              label: 'View Profile',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pop(context);
                _showStaffDetails(context, member);
              },
            ),
            _ActionTile(
              label: 'Edit Account',
              icon: Icons.edit_outlined,
              onTap: () {
                Navigator.pop(context);
                _editStaff(member);
              },
            ),
            _ActionTile(
              label: member.isActive ? 'Suspend Account' : 'Activate Account',
              icon: member.isActive ? Icons.block : Icons.check_circle_outline,
              color: member.isActive ? AppColors.warning(context) : AppColors.success(context),
              onTap: () {
                Navigator.pop(context);
                _toggleStatus(member);
              },
            ),
            _ActionTile(
              label: 'Reset Password',
              icon: Icons.lock_reset,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement reset password
              },
            ),
            const Divider(height: 32),
            _ActionTile(
              label: 'Delete Permanent',
              icon: Icons.delete_outline,
              color: AppColors.danger(context),
              onTap: () {
                Navigator.pop(context);
                _deleteStaff(member);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffDetails(BuildContext context, UserEntity member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarInitials(name: member.name, size: 72),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Text(member.email, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15)),
                              const SizedBox(height: 12),
                              StatusBadge(
                                label: member.isActive ? 'ACTIVE ACCOUNT' : 'SUSPENDED',
                                color: member.isActive ? AppColors.success(context) : AppColors.danger(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Account Information'),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _DetailRow(label: 'Staff ID', value: member.staffCode ?? '--', icon: Icons.badge_outlined),
                          const Divider(height: 1),
                          _DetailRow(label: 'Phone Number', value: member.phoneNumber ?? 'Not set', icon: Icons.phone_outlined),
                          const Divider(height: 1),
                          _DetailRow(label: 'Date Joined', value: 'Oct 24, 2023', icon: Icons.calendar_today_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Roles & Access'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: member.roles.map((r) => _CompactRoleChip(role: UserRoleDisplay.name(r), isLarge: true)).toList(),
                    ),
                    if (member.assignedClass != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary(context).withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.meeting_room_outlined, color: AppColors.primary(context)),
                            const SizedBox(width: 12),
                            const Text('Class Teacher of ', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(member.assignedClass!, style: TextStyle(color: AppColors.primary(context), fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'System Activity'),
                    const SizedBox(height: 12),
                    _ActivityItem(
                      log: AuditLog(
                        id: '1',
                        title: 'Password Reset',
                        description: 'System-forced password change',
                        timestamp: DateTime.now().subtract(const Duration(days: 2)),
                        iconName: 'lock_reset',
                        colorHex: 'FF9800',
                      ),
                    ),
                    _ActivityItem(
                      log: AuditLog(
                        id: '2',
                        title: 'Profile Updated',
                        description: 'Updated phone number',
                        timestamp: DateTime.now().subtract(const Duration(days: 5)),
                        iconName: 'edit',
                        colorHex: '2196F3',
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: 'Edit Staff Member',
                      icon: Icons.edit_outlined,
                      onPressed: () => _editStaff(member),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Account Settings',
                      icon: Icons.settings_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactRoleChip extends StatelessWidget {
  final String role;
  final bool isLarge;
  const _CompactRoleChip({required this.role, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 6, vertical: isLarge ? 6 : 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 4),
        border: Border.all(color: AppColors.border(context), width: 0.5),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: isLarge ? 12 : 9,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary(context)),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary(context)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}

class StudentsListView extends StatefulWidget {
  const StudentsListView({super.key});

  @override
  State<StudentsListView> createState() => _StudentsListViewState();
}

class _StudentsListViewState extends State<StudentsListView> {
  late Future<List<Student>> _future;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Student>> _load() async {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : null;
    final result = await di.sl<GetAllStudents>()(schoolId: schoolId);
    return result.fold((failure) => throw failure, (students) => students);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _showStudentActions(BuildContext context, Student student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AvatarInitials(name: student.name, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${student.studentCode} • ${student.className}', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ActionTile(
              label: 'View Profile',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pop(context);
                _showStudentDetails(context, student);
              },
            ),
            _ActionTile(
              label: 'Academic Records',
              icon: Icons.analytics_outlined,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to records
              },
            ),
            _ActionTile(
              label: 'Attendance History',
              icon: Icons.calendar_today_outlined,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to attendance
              },
            ),
            _ActionTile(
              label: 'Manage Parent Links',
              icon: Icons.family_restroom_outlined,
              onTap: () {
                Navigator.pop(context);
                // TODO: Link to parent management
              },
            ),
            const Divider(height: 32),
            _ActionTile(
              label: 'Archive Student',
              icon: Icons.archive_outlined,
              color: AppColors.warning(context),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement archive
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        AvatarInitials(name: student.name, size: 64),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                              Text('Student ID: ${student.studentCode}', style: TextStyle(color: AppColors.textSecondary(context))),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: student.status.name,
                          color: student.status == StudentStatus.active ? AppColors.success(context) : AppColors.danger(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AppCard(
                      child: Column(
                        children: [
                          _DetailRow(label: 'Class', value: student.className, icon: Icons.class_outlined),
                          const Divider(),
                          _DetailRow(label: 'Date of Birth', value: '${student.dateOfBirth.year}-${student.dateOfBirth.month.toString().padLeft(2, '0')}-${student.dateOfBirth.day.toString().padLeft(2, '0')}', icon: Icons.cake_outlined),
                          const Divider(),
                          _DetailRow(label: 'Gender', value: student.gender.name, icon: Icons.person_outline),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary(context))),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: student.emergencyContacts.isEmpty
                            ? [const _DetailRow(label: 'Contact', value: 'None on file', icon: Icons.family_restroom)]
                            : student.emergencyContacts.expand((contact) => [
                                  _DetailRow(label: contact.relationship, value: contact.name, icon: Icons.family_restroom),
                                  const Divider(),
                                  _DetailRow(label: 'Phone', value: contact.phoneNumber, icon: Icons.phone_outlined),
                                ]).toList()
                              ..removeLast(),
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: 'Academic Records',
                      icon: Icons.analytics_outlined,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Student Health Card',
                      icon: Icons.health_and_safety_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search students by name or code...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceContainer(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement student registration or link to it
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Student>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final students = snapshot.data ?? [];
              final filteredStudents = students.where((s) {
                final query = _searchQuery.toLowerCase();
                return s.name.toLowerCase().contains(query) ||
                    s.studentCode.toLowerCase().contains(query) ||
                    s.admissionNumber.toLowerCase().contains(query);
              }).toList();

              if (filteredStudents.isEmpty) {
                return const EmptyState(
                  icon: Icons.school_outlined,
                  title: 'No students found',
                  message: 'Try adjusting your search query.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: 30 * index),
                      direction: FadeInDirection.bt,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context), width: 0.5),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: AvatarInitials(name: student.name, size: 40),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${student.studentCode} • ${student.className}',
                            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(
                                label: student.status.name,
                                color: student.status == StudentStatus.active
                                    ? AppColors.success(context)
                                    : AppColors.disabled(context),
                                isCompact: true,
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onPressed: () => _showStudentActions(context, student),
                              ),
                            ],
                          ),
                          onTap: () => _showStudentDetails(context, student),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ParentCodesListView extends StatefulWidget {
  const ParentCodesListView({super.key});

  @override
  State<ParentCodesListView> createState() => _ParentCodesListViewState();
}

class _ParentCodesListViewState extends State<ParentCodesListView> {
  late Future<List<ParentAccessCode>> _future;
  String _searchQuery = '';
  String _statusFilter = 'Active'; // 'Active', 'Inactive', 'All'

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ParentAccessCode>> _load() async {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : null;
    final result = await di.sl<GetAllAccessCodes>()(schoolId: schoolId);
    return result.fold((failure) => throw failure, (codes) => codes);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _toggleStatus(ParentAccessCode code) async {
    final result = await di.sl<ToggleAccessCodeStatus>()(
      code.parentCode,
      !code.isActive,
    );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${failure.message}'), backgroundColor: AppColors.danger(context)),
      ),
      (_) => _refresh(),
    );
  }

  Future<void> _deleteCode(ParentAccessCode code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete Code?'),
        content: Text('This cannot be undone. ${code.parentName ?? code.parentCode} will lose access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.danger(context))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await di.sl<DeleteAccessCode>()(code.parentCode);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${failure.message}'), backgroundColor: AppColors.danger(context)),
      ),
      (_) => _refresh(),
    );
  }

  Future<void> _generateNewCode() async {
    final phoneController = TextEditingController();
    final parentNameController = TextEditingController();
    final Set<String> selectedStudentIds = {};

    final studentsResult = await di.sl<GetAllStudents>()(
      schoolId: context.read<AuthBloc>().state is AuthAuthenticated
          ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
          : null,
    );
    if (!mounted) return;
    final students = studentsResult.fold((failure) => <Student>[], (list) => list);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isPhoneValid = PhoneFormatter.toE164(phoneController.text).length >= 10;
          return AlertDialog(
            title: const Text('Generate Access Code'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: parentNameController,
                    decoration: const InputDecoration(labelText: 'Parent/Guardian Name (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select Student(s)', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return CheckboxListTile(
                          value: selectedStudentIds.contains(student.id),
                          title: Text(student.name),
                          subtitle: Text(student.studentCode),
                          onChanged: (checked) => setDialogState(() {
                            if (checked ?? false) {
                              selectedStudentIds.add(student.id);
                            } else {
                              selectedStudentIds.remove(student.id);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: selectedStudentIds.isEmpty || !isPhoneValid ? null : () => Navigator.pop(context, true),
                child: const Text('Generate Code'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      final codeResult = await di.sl<CreateAccessCode>()(
        studentIds: selectedStudentIds.toList(),
        schoolId: context.read<AuthBloc>().state is AuthAuthenticated
            ? (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId
            : '',
        phoneNumber: PhoneFormatter.toE164(phoneController.text),
        parentName: parentNameController.text.isEmpty ? null : parentNameController.text,
      );

      if (!mounted) return;
      codeResult.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${failure.message}'), backgroundColor: AppColors.danger(context)),
        ),
        (newCode) {
          _refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Access code generated: $newCode')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search codes by parent or student...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceContainer(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.vpn_key, color: Colors.white),
                      onPressed: _generateNewCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Active'),
                      selected: _statusFilter == 'Active',
                      onSelected: (val) => setState(() => _statusFilter = 'Active'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Inactive'),
                      selected: _statusFilter == 'Inactive',
                      onSelected: (val) => setState(() => _statusFilter = 'Inactive'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _statusFilter == 'All',
                      onSelected: (val) => setState(() => _statusFilter = 'All'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ParentAccessCode>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final codes = snapshot.data ?? [];

              final filteredCodes = codes.where((c) {
                final matchesSearch = (c.parentName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) || 
                                     c.parentCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                     c.studentNames.any((n) => n.toLowerCase().contains(_searchQuery.toLowerCase()));
                
                bool matchesStatus;
                if (_statusFilter == 'Active') {
                  matchesStatus = c.isActive;
                } else if (_statusFilter == 'Inactive') {
                  matchesStatus = !c.isActive;
                } else {
                  matchesStatus = true;
                }
                return matchesSearch && matchesStatus;
              }).toList();

              if (filteredCodes.isEmpty) {
                return const EmptyState(
                  icon: Icons.vpn_key_outlined,
                  title: 'No codes found',
                  message: 'Try adjusting your filters or search query.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredCodes.length,
                  itemBuilder: (context, index) {
                    final code = filteredCodes[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: 30 * index),
                      direction: FadeInDirection.bt,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(context), width: 0.5),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          title: Row(
                            children: [
                              Text(
                                code.parentCode,
                                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              const Spacer(),
                              StatusBadge(
                                label: code.isActive ? 'ACTIVE' : 'INACTIVE',
                                color: code.isActive ? AppColors.success(context) : AppColors.disabled(context),
                                isCompact: true,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                code.parentName ?? 'Unnamed Parent',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: code.studentNames
                                    .map((n) => _CompactRoleChip(role: n))
                                    .toList(),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onPressed: () => _showCodeDetails(context, code),
                          ),
                          onTap: () => _showCodeDetails(context, code),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCodeDetails(BuildContext context, ParentAccessCode code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.vpn_key_outlined, color: AppColors.primary(context), size: 32),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(code.parentCode, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2, fontFamily: 'monospace')),
                              const SizedBox(height: 4),
                              Text(code.parentName ?? 'Unnamed Parent', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              StatusBadge(
                                label: code.isActive ? 'ACTIVE CODE' : 'DEACTIVATED',
                                color: code.isActive ? AppColors.success(context) : AppColors.danger(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Access Information'),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _DetailRow(label: 'Phone Number', value: code.phoneNumber ?? 'Not set', icon: Icons.phone_outlined),
                          const Divider(height: 1),
                          _DetailRow(label: 'Created On', value: 'Oct 28, 2023', icon: Icons.calendar_today_outlined),
                          const Divider(height: 1),
                          _DetailRow(label: 'Usage Limit', value: '1 Device', icon: Icons.devices_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Linked Students'),
                    const SizedBox(height: 12),
                    ...code.studentNames.map((name) => AppCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          AvatarInitials(name: name, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Student Profile linked', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted(context)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Security Logs'),
                    const SizedBox(height: 12),
                    _ActivityItem(
                      log: AuditLog(
                        id: 'a1',
                        title: 'Code Generated',
                        description: 'System generated for ${code.parentName}',
                        timestamp: DateTime.now().subtract(const Duration(days: 1)),
                        iconName: 'vpn_key',
                        colorHex: '4CAF50',
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: 'Share Access Code',
                      icon: Icons.share_outlined,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'Your School Pulse Access Code is: ${code.parentCode}'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
                      },
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: code.isActive ? 'Suspend Access' : 'Restore Access',
                      icon: code.isActive ? Icons.block : Icons.check_circle_outline,
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleStatus(code);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteCode(code);
                      },
                      child: Text('Permanently Delete Code', style: TextStyle(color: AppColors.danger(context), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
