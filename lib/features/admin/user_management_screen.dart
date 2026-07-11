import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:go_router/go_router.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
  bool _showDisabled = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<UserEntity>> _load() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    return result.fold((failure) => throw failure, (staff) => staff);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _toggleStatus(UserEntity member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.isActive ? 'Disable Account' : 'Enable Account'),
        content: Text('Are you sure you want to ${member.isActive ? 'disable' : 'enable'} access for ${member.name}?'),
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
      final toggleStaffStatus = di.sl<ToggleStaffStatus>();
      await toggleStaffStatus(member.id, !member.isActive);
      _refresh();
    }
  }

  Future<void> _openCreateStaffDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.classTeacher;
    final roles = UserRole.values.where((r) => r != UserRole.parent && r != UserRole.schoolAdmin && r != UserRole.director && r != UserRole.headTeacher).toList();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Create Staff Account'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 16),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Address')),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Temporary Password',
                    helperText: 'Staff will be required to change this upon first login.',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'System Role'),
                  items: roles.map((role) => DropdownMenuItem(value: role, child: Text(UserRoleDisplay.name(role)))).toList(),
                  onChanged: (role) => setDialogState(() => selectedRole = role ?? selectedRole),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
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
    // Note: We need to update CreateStaffAccountParams to accept a password
    await di.sl<CreateStaffAccount>()(CreateStaffAccountParams(
      email: emailController.text,
      name: nameController.text,
      role: selectedRole,
      password: passwordController.text,
    ));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateStaffDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
      body: FutureBuilder<List<UserEntity>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final staff = snapshot.data ?? [];

          final filteredStaff = staff.where((s) {
            final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                 s.email.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _showDisabled ? true : s.isActive;
            return matchesSearch && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search staff by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilterChip(
                      label: const Text('Show Disabled'),
                      selected: _showDisabled,
                      onSelected: (val) => setState(() => _showDisabled = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 24,
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
                                      const StatusBadge(label: 'Disabled', color: Colors.grey)
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
                                      onPressed: () {
                                        // TODO: Implement edit staff details
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            )).toList(),
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
}

class _ParentCodesTab extends StatefulWidget {
  const _ParentCodesTab();

  @override
  State<_ParentCodesTab> createState() => _ParentCodesTabState();
}

class _ParentCodesTabState extends State<_ParentCodesTab> {
  late Future<List<ParentAccessCode>> _future;
  String _searchQuery = '';
  bool _showDisabled = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ParentAccessCode>> _load() async {
    final result = await di.sl<GetAllAccessCodes>()();
    return result.fold((failure) => throw failure, (codes) => codes);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _toggleStatus(ParentAccessCode code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(code.isActive ? 'Deactivate Code' : 'Restore Code'),
        content: Text('Are you sure you want to ${code.isActive ? 'deactivate' : 'restore'} the access code ${code.code}? ${code.isActive ? 'Parents using this code will lose access.' : ''}'),
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
      await di.sl<ToggleAccessCodeStatus>()(code.code, !code.isActive);
      _refresh();
    }
  }

  Future<void> _generateNewCode() async {
    final studentsResult = await di.sl<GetAllStudents>()();
    if (studentsResult.isLeft()) return;
    final allStudents = studentsResult.getOrElse(() => []);

    final selectedStudentIds = <String>[];
    final parentNameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate Parent Access Code'),
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
                const Text('Select Students:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allStudents.length,
                    itemBuilder: (context, index) {
                      final s = allStudents[index];
                      return CheckboxListTile(
                        title: Text(s.name),
                        subtitle: Text(s.className),
                        value: selectedStudentIds.contains(s.id),
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
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await di.sl<CreateAccessCode>()(
        studentIds: selectedStudentIds,
        parentName: parentNameController.text.isEmpty ? null : parentNameController.text,
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateNewCode,
        icon: const Icon(Icons.vpn_key),
        label: const Text('Generate Code'),
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
            final matchesStatus = _showDisabled ? true : c.isActive;
            return matchesSearch && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by parent name, code, or student...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilterChip(
                      label: const Text('Show Inactive'),
                      selected: _showDisabled,
                      onSelected: (val) => setState(() => _showDisabled = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: filteredCodes.length,
                  itemBuilder: (context, index) {
                    final code = filteredCodes[index];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  IconButton(
                                    icon: Icon(code.isActive ? Icons.block : Icons.check_circle_outline, 
                                      size: 18, 
                                      color: code.isActive ? Theme.of(context).colorScheme.error : Colors.green),
                                    onPressed: () => _toggleStatus(code),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(code.parentName ?? 'Unnamed Parent', style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (!code.isActive) ...[
                                const SizedBox(width: 8),
                                const StatusBadge(label: 'Inactive', color: Colors.grey),
                              ],
                            ],
                          ),
                          const Spacer(),
                          const Text('Linked Students:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: code.studentNames.map((n) => StatusBadge(
                              label: n, 
                              color: code.isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
                            )).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
