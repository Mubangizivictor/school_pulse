import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/staff_id_card_service.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  Future<void> _printIdCard(BuildContext context, UserEntity user) async {
    final idCardService = GetIt.I<StaffIdCardService>();
    final schoolName = context.read<ThemeProvider>().config?.schoolName ?? 'School Pulse Academy';
    try {
      final pdfData = await idCardService.generateStaffIdCardPdf(
        schoolName: schoolName,
        staffName: user.name,
        staffCode: user.staffCode ?? user.id,
        roleLabel: UserRoleDisplay.name(user.role),
      );
      await idCardService.printIdCard(pdfData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to print ID card: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = state.user;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: const Text('My Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.badge_outlined, color: AppColors.primary(context)),
                tooltip: 'Print Staff ID Card',
                onPressed: () => _printIdCard(context, user),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(child: AvatarInitials(name: user.name, size: 80)),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  UserRoleDisplay.name(user.role),
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoCard(context, [
                  _InfoRow(label: 'Email Address', value: user.email),
                  _InfoRow(label: 'Phone Number', value: user.phoneNumber ?? '—'),
                  if (user.assignedClass != null) _InfoRow(label: 'Assigned Class', value: user.assignedClass!),
                  if (user.subjects != null && user.subjects!.isNotEmpty)
                    _InfoRow(
                      label: 'Subjects',
                      value: user.subjects!.map((s) => '${s.subjectName} (${s.className})').join(', '),
                    ),
                ]),
                const SizedBox(height: 24),
                _buildThemeToggle(context),
                const SizedBox(height: 24),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.lock_outline, color: AppColors.textPrimary(context)),
                    title: Text(
                      'Security Settings',
                      style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted(context)),
                    onTap: () => context.push('/staff/security-settings'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            activeColor: AppColors.primary(context),
            onChanged: (value) {
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> rows) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final idx = entry.key;
          final row = entry.value;
          return Column(
            children: [
              row,
              if (idx < rows.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}
