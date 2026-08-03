import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
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
import 'package:school_pulse/injection_container.dart' as di;

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildOverviewStats(),
          _buildTabSwitcher(),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: const [
                StaffListView(),
                StudentsListView(),
                ParentCodesListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: UserStatCard(
              label: 'Staff',
              count: '24',
              icon: Icons.people_alt_outlined,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: UserStatCard(
              label: 'Students',
              count: '412',
              icon: Icons.school_outlined,
              color: AppColors.secondary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: UserStatCard(
              label: 'Parents',
              count: '380',
              icon: Icons.family_restroom_outlined,
              color: AppColors.success(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Staff',
              isSelected: _currentTab == 0,
              onTap: () => setState(() => _currentTab = 0),
            ),
            _TabItem(
              label: 'Students',
              isSelected: _currentTab == 1,
              onTap: () => setState(() => _currentTab = 1),
            ),
            _TabItem(
              label: 'Parents',
              isSelected: _currentTab == 2,
              onTap: () => setState(() => _currentTab = 2),
            ),
          ],
        ),
      ),
    );
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
  String _roleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<UserEntity>> _load() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    return result.fold((failure) => throw failure, (staff) => staff);
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
                  onPressed: () {},
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
              final staff = snapshot.data!
                  .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: staff.length,
                itemBuilder: (context, index) {
                  final member = staff[index];
                  return FadeInSlide(
                    delay: Duration(milliseconds: 50 * index),
                    direction: FadeInDirection.bt,
                    child: AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      onTap: () => _showStaffDetails(context, member),
                      child: Row(
                        children: [
                          AvatarInitials(
                            name: member.name,
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: member.roles
                                      .take(2)
                                      .map((r) => RoleChip(role: UserRoleDisplay.name(r), isCompact: true))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge(
                                label: member.isActive ? 'Active' : 'Disabled',
                                color: member.isActive ? AppColors.success(context) : AppColors.disabled(context),
                              ),
                              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                            ],
                          ),
                        ],
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

  void _showStaffDetails(BuildContext context, UserEntity member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  AvatarInitials(name: member.name, size: 64),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                        Text(member.email, style: TextStyle(color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SectionHeader(title: 'Account Overview'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow(label: 'Staff ID', value: member.staffCode ?? 'Not Assigned', icon: Icons.badge_outlined),
                    const Divider(height: 24),
                    _DetailRow(label: 'Primary Role', value: UserRoleDisplay.name(member.role), icon: Icons.work_outline),
                    const Divider(height: 24),
                    _DetailRow(label: 'Phone', value: member.phoneNumber ?? 'Not Set', icon: Icons.phone_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Roles & Assignments'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: member.roles.map((r) => RoleChip(role: UserRoleDisplay.name(r))).toList(),
              ),
              if (member.assignedClass != null) ...[
                const SizedBox(height: 16),
                AppCard(
                  color: AppColors.primarySoft(context),
                  showBorder: false,
                  child: Row(
                    children: [
                      const Icon(Icons.meeting_room_outlined),
                      const SizedBox(width: 12),
                      Text('Class Teacher: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(member.assignedClass!),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const SectionHeader(title: 'Security & Actions'),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Edit Profile',
                icon: Icons.edit_outlined,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: member.isActive ? 'Suspend Account' : 'Activate Account',
                icon: member.isActive ? Icons.block : Icons.check_circle_outline,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.delete_outline, color: AppColors.danger(context)),
                label: Text('Permanently Delete', style: TextStyle(color: AppColors.danger(context))),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary(context)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary(context))),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class StudentsListView extends StatelessWidget {
  const StudentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Students List Component'));
  }
}

class ParentCodesListView extends StatelessWidget {
  const ParentCodesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Parent Codes Component'));
  }
}
