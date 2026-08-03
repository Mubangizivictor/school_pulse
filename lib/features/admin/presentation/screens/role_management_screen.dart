import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_role_permission_overrides.dart';
import 'package:school_pulse/features/admin/domain/usecases/save_role_permission_override.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  UserRole _selectedRole = UserRole.schoolAdmin;
  late Map<UserRole, Set<String>> _rolePermissions;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSaving = false;

  String get _schoolId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    _rolePermissions = {
      for (final entry in RolePermissionDefaults.defaults.entries) entry.key: {...entry.value},
    };
    _loadOverrides();
  }

  Future<void> _loadOverrides() async {
    final result = await di.sl<GetRolePermissionOverrides>()(_schoolId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (overrides) {
        setState(() {
          for (final entry in overrides.entries) {
            _rolePermissions[entry.key] = {...entry.value.permissions};
          }
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final userId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';
    final result = await di.sl<SaveRolePermissionOverride>()(SaveRolePermissionOverrideParams(
      schoolId: _schoolId,
      role: _selectedRole,
      permissions: _rolePermissions[_selectedRole] ?? {},
      updatedBy: userId,
    ));
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${failure.message}'), backgroundColor: AppColors.danger(context)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permissions updated successfully'),
          backgroundColor: AppColors.success(context),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Role Permissions', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                if (MediaQuery.of(context).size.width > 800)
                  _buildSidebar()
                else
                  const SizedBox.shrink(),
                Expanded(
                  child: Column(
                    children: [
                      if (MediaQuery.of(context).size.width <= 800)
                        _buildRoleDropdown(),
                      _buildSearchAndFilters(),
                      Expanded(
                        child: _buildPermissionList(),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border(context), width: 0.5)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: UserRole.values.length,
        itemBuilder: (context, index) {
          final role = UserRole.values[index];
          final isSelected = _selectedRole == role;
          return ListTile(
            title: Text(
              UserRoleDisplay.name(role),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primary(context) : AppColors.textPrimary(context),
              ),
            ),
            selected: isSelected,
            selectedTileColor: AppColors.primary(context).withValues(alpha: 0.05),
            onTap: () => setState(() => _selectedRole = role),
          );
        },
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<UserRole>(
        initialValue: _selectedRole,
        decoration: InputDecoration(
          labelText: 'Select Role to Edit',
          filled: true,
          fillColor: AppColors.surfaceContainer(context),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: UserRole.values.map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(UserRoleDisplay.name(role)),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedRole = val!),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search permissions...',
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
    );
  }

  Widget _buildPermissionList() {
    final filtered = Permission.all
        .where((p) => p.$2.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final grouped = <String, List<String>>{};
    for (final (category, id) in filtered) {
      grouped.putIfAbsent(category, () => []).add(id);
    }

    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: items.map((p) {
                  final isLast = items.last == p;
                  final hasPermission = _rolePermissions[_selectedRole]?.contains(p) ?? false;
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          _formatPermissionName(p),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(p, style: TextStyle(fontSize: 11, color: AppColors.textMuted(context))),
                        value: hasPermission,
                        activeColor: AppColors.primary(context),
                        onChanged: (val) {
                          setState(() {
                            final current = _rolePermissions[_selectedRole] ?? {};
                            if (val == true) {
                              _rolePermissions[_selectedRole] = {...current, p};
                            } else {
                              _rolePermissions[_selectedRole] = current.where((item) => item != p).toSet();
                            }
                          });
                        },
                      ),
                      if (!isLast) const Divider(height: 1, indent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context), width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.information(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_outline, size: 20, color: AppColors.information(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Role Update Impact',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary(context)),
                ),
                Text(
                  'Changes here will affect all users assigned the ${UserRoleDisplay.name(_selectedRole)} role immediately.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: Text('Discard', style: TextStyle(color: AppColors.textSecondary(context))),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatPermissionName(String id) {
    final parts = id.split('.');
    if (parts.length < 2) return id;
    final name = parts.skip(1).join(' ').replaceAll('_', ' ');
    return name[0].toUpperCase() + name.substring(1);
  }
}
