import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/delete_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/update_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/features/admin/data/models/school_class.dart';
import 'package:school_pulse/features/admin/data/repositories/school_structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:go_router/go_router.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _appliedDeepLinkTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only honor the ?tab= deep link once, on first build - otherwise any
    // rebuild (e.g. after editing/deactivating/deleting a parent code) would
    // re-read the URL and snap the user back to tab 0.
    if (_appliedDeepLinkTab) return;
    _appliedDeepLinkTab = true;
    final uri = GoRouterState.of(context).uri;
    final tabIndex = int.tryParse(uri.queryParameters['tab'] ?? '0') ?? 0;
    if (tabIndex >= 0 && tabIndex < 2) {
      _tabController.index = tabIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Account Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Staff Accounts'),
            Tab(icon: Icon(Icons.vpn_key_outlined), text: 'Parent Access'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StaffTab(),
          _ParentCodesTab(),
        ],
      ),
    );
  }
}

class _StaffTab extends StatefulWidget {
  const _StaffTab();

  @override
  State<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<_StaffTab> {
  late Future<List<UserEntity>> _future;
  String _searchQuery = '';
  String _statusFilter = 'Active'; // 'Active', 'Disabled', 'All'

  final _structureRepository = di.sl<SchoolStructureRepository>();
  List<String> _classNames = [];
  List<String> _subjectNames = [];
  StreamSubscription<List<SchoolClass>>? _classesSub;
  StreamSubscription<List<SchoolSubject>>? _subjectsSub;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _classesSub = _structureRepository.watchClasses().listen((classes) {
      setState(() => _classNames = classes.map((c) => c.name).toList());
    });
    _subjectsSub = _structureRepository.watchSubjects().listen((subjects) {
      setState(() => _subjectNames = subjects.map((s) => s.name).toList());
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    _subjectsSub?.cancel();
    super.dispose();
  }

  Future<List<UserEntity>> _load() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    return result.fold((failure) => throw failure, (staff) => staff);
  }

  void _refresh() {
    final newFuture = _load();
    setState(() {
      _future = newFuture;
    });
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
            child: Text(member.isActive ? 'Disable' : 'Enable', style: TextStyle(color: member.isActive ? Colors.red : Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await di.sl<ToggleStaffStatus>()(
        member.id, 
        !member.isActive,
        reason: member.isActive ? reasonController.text.trim() : null,
      );
      _refresh();
    }
  }

  Future<void> _deleteStaff(UserEntity member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to PERMANENTLY delete the account for ${member.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await di.sl<DeleteStaffMember>()(member.id);
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
                      const Text(
                        'No classes registered yet. Add classes in School Structure first.',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: assignedClass,
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
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
                initialValue: selectedSub,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: _subjectNames.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedSub = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCls,
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

    // Initialize with a generated password
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
                      const Text(
                        'No classes registered yet. Add classes in School Structure first.',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: assignedClass,
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
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
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

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final createResult = await di.sl<CreateStaffAccount>()(CreateStaffAccountParams(
      email: emailController.text.trim(),
      name: nameController.text.trim(),
      roles: selectedRoles.toList(),
      password: passwordController.text.trim(),
      assignedClass: selectedRoles.contains(UserRole.classTeacher) ? assignedClass : null,
      subjects: selectedRoles.contains(UserRole.subjectTeacher) ? subjects : null,
    ));

    if (!mounted) return;
    Navigator.pop(context); // Remove loading indicator

    createResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${failure.message}'), backgroundColor: Colors.red),
      ),
      (tempPassword) {
        _refresh();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Staff Created'),
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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateStaffDialog,
        icon: const Icon(Icons.person_add),
        label: isMobile ? const Text('Add') : const Text('Add Staff'),
      ),
      body: FutureBuilder<List<UserEntity>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final staff = snapshot.data ?? [];

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

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: isMobile ? 'Search...' : 'Search staff by name or email...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (value) => setState(() => _searchQuery = value),
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
                child: isMobile 
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStaff.length,
                    itemBuilder: (context, index) {
                      final member = filteredStaff[index];
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            AvatarInitials(name: member.name, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          member.name.isEmpty ? member.email : member.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration: member.isActive ? null : TextDecoration.lineThrough,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!member.isActive) ...[
                                        const SizedBox(width: 8),
                                        StatusBadge(label: 'Disabled', color: Theme.of(context).colorScheme.outline),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    UserRoleDisplay.name(member.role),
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showStaffActions(member),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Staff Roster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('${filteredStaff.length} members', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: isMobile ? 0 : 800),
                            child: DataTable(
                              columnSpacing: isMobile ? 12 : 24,
                              columns: const [
                                DataColumn(label: Text('Staff Member')),
                                DataColumn(label: Text('System Role')),
                                DataColumn(label: Text('Account Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredStaff.map((member) => DataRow(
                              color: member.isActive ? null : WidgetStateProperty.all(Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.05)),
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      AvatarInitials(name: member.name, size: 36),
                                      const SizedBox(width: 12),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(member.name.isEmpty ? member.email : member.name, 
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration: member.isActive ? null : TextDecoration.lineThrough,
                                            )),
                                          Text(member.email, style: Theme.of(context).textTheme.bodySmall),
                                        ],
                                      ),
                                    ],
                                  )),
                                  DataCell(StatusBadge(
                                    label: UserRoleDisplay.name(member.role),
                                    color: Theme.of(context).colorScheme.secondary,
                                  )),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!member.isActive)
                                        StatusBadge(label: 'Disabled', color: Theme.of(context).colorScheme.outline)
                                      else if (member.mustChangePassword)
                                        const StatusBadge(label: 'Invite Sent', color: Colors.orange)
                                      else
                                        const StatusBadge(label: 'Active', color: Colors.green),
                                    ],
                                  )),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(member.isActive ? Icons.block : Icons.check_circle_outline, 
                                          color: member.isActive ? Theme.of(context).colorScheme.error : Colors.green),
                                        tooltip: member.isActive ? 'Disable Access' : 'Restore Access',
                                        onPressed: () => _toggleStatus(member),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Edit Details',
                                        onPressed: () => _editStaff(member),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                        tooltip: 'Delete Account',
                                        onPressed: () => _deleteStaff(member),
                                      ),
                                    ],
                                  )),
                                ],
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStaffActions(UserEntity member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                _editStaff(member);
              },
            ),
            ListTile(
              leading: Icon(member.isActive ? Icons.block : Icons.check_circle_outline, 
                color: member.isActive ? Colors.red : Colors.green),
              title: Text(member.isActive ? 'Disable Access' : 'Restore Access'),
              onTap: () {
                Navigator.pop(context);
                _toggleStatus(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
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
}

class _ParentCodesTab extends StatefulWidget {
  const _ParentCodesTab();

  @override
  State<_ParentCodesTab> createState() => _ParentCodesTabState();
}

class _ParentCodesTabState extends State<_ParentCodesTab> {
  late Future<List<ParentAccessCode>> _future;
  String _searchQuery = '';
  String _statusFilter = 'Active'; // 'Active', 'Inactive', 'All'

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ParentAccessCode>> _load() async {
    final result = await di.sl<GetAllAccessCodes>()();
    return result.fold((failure) => throw failure, (codes) => codes);
  }

  void _refresh() {
    final newFuture = _load();
    setState(() {
      _future = newFuture;
    });
  }

  Future<void> _toggleStatus(ParentAccessCode code) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(code.isActive ? 'Deactivate Code' : 'Restore Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to ${code.isActive ? 'deactivate' : 'restore'} the access code ${code.code}? ${code.isActive ? 'Parents using this code will lose access.' : ''}'),
            if (code.isActive) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for deactivation',
                  hintText: 'e.g., Unpaid fees, Misuse',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(code.isActive ? 'Deactivate' : 'Restore', 
              style: TextStyle(color: code.isActive ? Colors.red : Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await di.sl<ToggleAccessCodeStatus>()(
        code.code, 
        !code.isActive,
        reason: code.isActive ? reasonController.text.trim() : null,
      );
      _refresh();
    }
  }

  Future<void> _deleteCode(ParentAccessCode code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Access Code'),
        content: Text('Are you sure you want to delete the code ${code.code}? Parents currently using this code will not be disconnected, but the code will no longer work for new signups.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await di.sl<DeleteAccessCode>()(code.code);
      _refresh();
    }
  }

  Future<void> _editCode(ParentAccessCode code) async {
    final studentsResult = await di.sl<GetAllStudents>()();
    final codesResult = await di.sl<GetAllAccessCodes>()();
    
    if (!mounted) return;
    if (studentsResult.isLeft() || codesResult.isLeft()) return;
    
    final allStudents = studentsResult.getOrElse(() => []);
    final allCodes = codesResult.getOrElse(() => []);

    // Map student IDs to their current parent count
    final studentParentCounts = <String, int>{};
    for (final c in allCodes) {
      for (final studentId in c.studentIds) {
        studentParentCounts[studentId] = (studentParentCounts[studentId] ?? 0) + 1;
      }
    }

    final selectedStudentIds = List<String>.from(code.studentIds);
    final parentNameController = TextEditingController(text: code.parentName);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Access Code'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: parentNameController,
                  decoration: const InputDecoration(labelText: 'Parent Name (Optional)'),
                ),
                const SizedBox(height: 16),
                const Text('Linked Students:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allStudents.length,
                    itemBuilder: (context, index) {
                      final s = allStudents[index];
                      final currentCount = studentParentCounts[s.id] ?? 0;
                      final isAlreadyInThisCode = selectedStudentIds.contains(s.id);
                      // Can add if not already in this code AND total parents < 1
                      final canAdd = isAlreadyInThisCode || currentCount < 1;

                      return CheckboxListTile(
                        title: Text(s.name),
                        subtitle: Text('${s.className} • ${currentCount > 0 ? "Already linked to a parent" : "Available"}'),
                        value: isAlreadyInThisCode,
                        enabled: canAdd,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedStudentIds.add(s.id);
                            } else {
                              selectedStudentIds.remove(s.id);
                            }
                          });
                        },
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
              onPressed: selectedStudentIds.isEmpty ? null : () => Navigator.pop(context, true),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final updatedStudents = allStudents.where((s) => selectedStudentIds.contains(s.id)).toList();
      final updated = ParentAccessCode(
        code: code.code,
        studentIds: selectedStudentIds,
        studentNames: updatedStudents.map((s) => s.name).toList(),
        parentName: parentNameController.text.isEmpty ? null : parentNameController.text,
        isActive: code.isActive,
        phoneNumber: code.phoneNumber,
        pin: code.pin,
        mustChangePin: code.mustChangePin,
        deactivationReason: code.deactivationReason,
      );
      await di.sl<UpdateAccessCode>()(updated);
      _refresh();
    }
  }

  Future<void> _generateNewCode() async {
    final studentsResult = await di.sl<GetAllStudents>()();
    final codesResult = await di.sl<GetAllAccessCodes>()();
    
    if (!mounted) return;
    if (studentsResult.isLeft() || codesResult.isLeft()) return;
    
    final allStudents = studentsResult.getOrElse(() => []);
    final allCodes = codesResult.getOrElse(() => []);

    // Map student IDs to their current parent count
    final studentParentCounts = <String, int>{};
    for (final c in allCodes) {
      for (final studentId in c.studentIds) {
        studentParentCounts[studentId] = (studentParentCounts[studentId] ?? 0) + 1;
      }
    }

    final selectedStudentIds = <String>[];
    final parentNameController = TextEditingController();
    String studentSearchQuery = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredStudents = allStudents.where((s) =>
            s.name.toLowerCase().contains(studentSearchQuery.toLowerCase()) ||
            s.className.toLowerCase().contains(studentSearchQuery.toLowerCase())
          ).toList();

          return AlertDialog(
            title: const Text('Generate Parent Access Code'),
            content: SizedBox(
              width: 400,
              height: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: parentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Parent Name (Optional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Link Siblings:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setDialogState(() => studentSearchQuery = val),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final s = filteredStudents[index];
                          final currentCount = studentParentCounts[s.id] ?? 0;
                          final canAdd = currentCount < 1;

                          return CheckboxListTile(
                            title: Text(s.name, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('${s.className} • ${currentCount >= 1 ? "Parent already assigned" : "Available"}',
                              style: TextStyle(
                                fontSize: 12, 
                                color: currentCount >= 1 ? Colors.red : null,
                                fontWeight: currentCount >= 1 ? FontWeight.bold : null,
                              )),
                            value: selectedStudentIds.contains(s.id),
                            dense: true,
                            enabled: canAdd || selectedStudentIds.contains(s.id),
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedStudentIds.add(s.id);
                                } else {
                                  selectedStudentIds.remove(s.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: selectedStudentIds.isEmpty ? null : () => Navigator.pop(context, true),
                child: const Text('Generate Code'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final codeResult = await di.sl<CreateAccessCode>()(
        studentIds: selectedStudentIds,
        parentName: parentNameController.text.isEmpty ? null : parentNameController.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // Remove loading

      codeResult.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${failure.message}'), backgroundColor: Colors.red),
        ),
        (newCode) {
          _refresh();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.vpn_key, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Access Code Generated'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code for ${parentNameController.text.isEmpty ? "this parent" : parentNameController.text} is ready.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            newCode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: newCode));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Share this code with the parent. They can use it to link their mobile app to their children\'s records.', 
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
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
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateNewCode,
        icon: const Icon(Icons.vpn_key),
        label: isMobile ? const Text('New') : const Text('Generate Code'),
      ),
      body: FutureBuilder<List<ParentAccessCode>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final codes = snapshot.data ?? [];

          final filteredCodes = codes.where((c) {
            final matchesSearch = (c.parentName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) || 
                                 c.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
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

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: isMobile ? 'Search codes...' : 'Search by parent name, code, or student...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (value) => setState(() => _searchQuery = value),
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
                child: isMobile 
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filteredCodes.length,
                    itemBuilder: (context, index) => AppCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildCodeCardContent(context, filteredCodes[index], true),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: filteredCodes.length,
                    itemBuilder: (context, index) => AppCard(
                      child: _buildCodeCardContent(context, filteredCodes[index], false),
                    ),
                  ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCodeCardContent(BuildContext context, ParentAccessCode code, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SelectableText(code.code, 
              style: TextStyle(
                fontFamily: 'monospace', 
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                decoration: code.isActive ? null : TextDecoration.lineThrough,
              )),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 18), 
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
                  },
                ),
                if (!isMobile) ...[
                  IconButton(
                    icon: Icon(code.isActive ? Icons.block : Icons.check_circle_outline, 
                      size: 18, 
                      color: code.isActive ? Theme.of(context).colorScheme.error : Colors.green),
                    tooltip: code.isActive ? 'Deactivate' : 'Restore',
                    onPressed: () => _toggleStatus(code),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit Code',
                    onPressed: () => _editCode(code),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                    tooltip: 'Delete Code',
                    onPressed: () => _deleteCode(code),
                  ),
                ] else
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showCodeActions(code),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                code.parentName ?? 'Unnamed Parent', 
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!code.isActive) ...[
              const SizedBox(width: 8),
              StatusBadge(label: 'Inactive', color: Theme.of(context).colorScheme.outline),
            ],
          ],
        ),
        const SizedBox(height: 12),
        const Text('Linked Students:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: code.studentNames.map((n) => StatusBadge(
            label: n, 
            color: code.isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          )).toList(),
        ),
      ],
    );
  }

  void _showCodeActions(ParentAccessCode code) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Code'),
              onTap: () {
                Navigator.pop(context);
                _editCode(code);
              },
            ),
            ListTile(
              leading: Icon(code.isActive ? Icons.block : Icons.check_circle_outline, 
                color: code.isActive ? Colors.red : Colors.green),
              title: Text(code.isActive ? 'Deactivate' : 'Restore'),
              onTap: () {
                Navigator.pop(context);
                _toggleStatus(code);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Code', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteCode(code);
              },
            ),
          ],
        ),
      ),
    );
  }
}
