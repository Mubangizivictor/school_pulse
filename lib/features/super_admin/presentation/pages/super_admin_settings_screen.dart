import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../widgets/super_admin_logout_button.dart';
import 'audit_logs_screen.dart';
import 'manual_payment_config_screen.dart';
import 'school_detail_screen.dart';
import 'super_admin_profile_screen.dart';

/// Real (non-placeholder) Settings screen for the SaaS owner console,
/// scoped to what's honestly supportable right now: account identity,
/// notifications, a link to the manual payment configuration info screen,
/// a link to Audit Logs for security visibility, Delete School, and
/// logout. No fake toggles.
class SuperAdminSettingsScreen extends StatelessWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final ownerName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()
        : 'SaaS Owner';
    final ownerEmail = user?.email.trim().isNotEmpty ?? false
        ? user!.email.trim()
        : 'Not signed in';
    final ownerPhone = user?.phoneNumber?.trim();
    final photoUrl = user?.photoUrl;
    final schools = context.watch<SuperAdminBloc>().state.schools;
    final activeSchools = schools
        .where((s) => s.status == SchoolStatus.active)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        children: [
          _AccountCard(
            name: ownerName,
            email: ownerEmail,
            phone: ownerPhone,
            photoUrl: photoUrl,
            totalSchools: schools.length,
            activeSchools: activeSchools,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SuperAdminProfileScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Manual Payment Methods',
            subtitle: 'Edit the MTN MoMo and bank details schools pay to',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ManualPaymentConfigScreen(),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Payment submissions and platform activity',
            onTap: () => context.push('/super-admin/settings/notifications'),
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Security',
            subtitle: 'Change password and manage account security',
            onTap: () => context.push('/super-admin/settings/security'),
          ),
          _SettingsTile(
            icon: Icons.history_outlined,
            title: 'Audit Logs',
            subtitle: 'Review platform activity and owner actions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help, visit guides and contact support',
            onTap: () => context.push('/super-admin/settings/support'),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: _CompactDangerButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete School',
                  onTap: () => _pickSchoolToDelete(context),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: _CompactDangerButton(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  onTap: () => handleSuperAdminLogout(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickSchoolToDelete(BuildContext context) {
    final bloc = context.read<SuperAdminBloc>();
    final schools =
        bloc.state.schools
            .where((s) => s.status != SchoolStatus.archived)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    'Select a school to delete',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(sheetContext),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: schools.isEmpty
                      ? Center(
                          child: Text(
                            'No schools available.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary(sheetContext),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          itemCount: schools.length,
                          itemBuilder: (context, index) {
                            final school = schools[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(school.name),
                              subtitle: Text('ID: ${school.tenantId}'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                deleteSchoolDialog(context, school);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Hero card shown immediately below the Settings app bar: avatar, name,
/// Hero card shown immediately below the Settings app bar. Structure
/// mirrors a standard account-profile header: avatar + name + role at
/// top with an edit action, contact rows (phone/email), then a stat
/// strip. Tapping the edit action or the card opens the editable
/// profile screen. Reads live from AuthBloc/SuperAdminBloc so an
/// updated name/photo/school count shows up here immediately.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.totalSchools,
    required this.activeSchools,
    required this.onTap,
  });

  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final int totalSchools;
  final int activeSchools;
  final VoidCallback onTap;

  String _initials(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceElevated(context),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: primary.withValues(alpha: 0.15),
                backgroundImage: photoUrl?.isNotEmpty == true
                    ? NetworkImage(photoUrl!)
                    : null,
                child: photoUrl?.isNotEmpty == true
                    ? null
                    : Text(
                        _initials(name),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Platform Owner',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTap,
                tooltip: 'Edit profile',
                icon: Icon(Icons.edit_outlined, color: primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Divider(height: 1, color: AppColors.border(context)),
          const SizedBox(height: AppSpacing.m),
          if (phone?.isNotEmpty ?? false) ...[
            _ContactRow(icon: Icons.phone_outlined, value: phone!),
            const SizedBox(height: AppSpacing.s),
          ],
          _ContactRow(icon: Icons.email_outlined, value: email),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: _AccountStat(label: 'Schools', value: '$totalSchools'),
              ),
              Container(width: 1, height: 32, color: AppColors.border(context)),
              Expanded(
                child: _AccountStat(label: 'Active', value: '$activeSchools'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary(context)),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountStat extends StatelessWidget {
  const _AccountStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

/// Compact side-by-side button for the Delete School / Logout row.
class _CompactDangerButton extends StatelessWidget {
  const _CompactDangerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.danger(context);

    return Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable tile style for this screen's rows.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      color: AppColors.surfaceElevated(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded)
            : null,
      ),
    );
  }
}
