import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import 'audit_logs_screen.dart';
import 'manual_payment_config_screen.dart';
import 'super_admin_profile_screen.dart';

/// Real (non-placeholder) Settings screen for the SaaS owner console,
/// scoped to what's honestly supportable right now: account identity,
/// notifications, a link to the manual payment configuration info screen,
/// a link to Audit Logs for security visibility, and logout. School
/// deletion is deliberately not offered here — it's a per-school action
/// that lives in School Details, not a global platform setting.
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
    final wide = isSuperAdminWide(context);

    List<PlatformSettingsRow> tiles({required bool standalone}) => [
      PlatformSettingsRow(
        standalone: standalone,
        icon: Icons.credit_card_outlined,
        title: 'Billing & payment methods',
        subtitle: 'Manage subscriptions, invoices and payment methods',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManualPaymentConfigScreen()),
        ),
      ),
      PlatformSettingsRow(
        standalone: standalone,
        icon: Icons.notifications_outlined,
        title: 'Notification delivery',
        subtitle: 'Configure how and when notifications are delivered',
        onTap: () => context.push('/super-admin/settings/notifications'),
      ),
      PlatformSettingsRow(
        standalone: standalone,
        icon: Icons.shield_outlined,
        title: 'Security & sessions',
        subtitle: 'Password, two-factor authentication and active sessions',
        onTap: () => context.push('/super-admin/settings/security'),
      ),
      PlatformSettingsRow(
        standalone: standalone,
        icon: Icons.dns_outlined,
        title: 'Custom domains',
        subtitle: 'Verify and activate schools\' custom portal hostnames',
        onTap: () => context.push('/super-admin/settings/custom-domains'),
      ),
      PlatformSettingsRow(
        standalone: standalone,
        icon: Icons.assignment_outlined,
        title: 'Platform audit logs',
        subtitle: 'View system-wide audit logs and activity',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
        ),
      ),
      PlatformSettingsRow(
        standalone: standalone,
        icon: Icons.headset_mic_outlined,
        title: 'Support & legal',
        subtitle: 'Help center, terms of service and privacy policy',
        onTap: () => context.push('/super-admin/settings/support'),
      ),
    ];

    if (wide) {
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x2l,
            AppSpacing.xl,
            AppSpacing.x2l,
            AppSpacing.x3l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your platform settings and preferences.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _DesktopAccountCard(
                name: ownerName,
                email: ownerEmail,
                phone: ownerPhone,
                photoUrl: photoUrl,
                totalSchools: schools.length,
                activeSchools: activeSchools,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuperAdminProfileScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const ThemeModeSelector(),
              const SizedBox(height: AppSpacing.xl),
              for (final tile in tiles(standalone: true))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: tile,
                ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Row(
              children: [
                Text('Settings', style: _pageTitle(context)),
                const Spacer(),
                _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SuperAdminProfileScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PlatformSettingsProfileCard(
              name: ownerName,
              email: ownerEmail,
              photoUrl: photoUrl,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SuperAdminProfileScreen(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Column(
                children: [
                  for (final (i, tile) in tiles(standalone: false).indexed) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.border(context)),
                    tile,
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const ThemeModeSelector(),
            const SizedBox(height: 14),
            _CompactDangerButton(
              icon: Icons.logout_rounded,
              label: 'Log out',
              onTap: () => handleSuperAdminLogout(context),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'You will be signed out of School Pulse on this device.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop-styled owner profile card matching the reference: avatar +
/// name + role badge + Edit Profile at top, phone/email/stat strip below.
class _DesktopAccountCard extends StatelessWidget {
  const _DesktopAccountCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.totalSchools,
    required this.activeSchools,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final int totalSchools;
  final int activeSchools;
  final VoidCallback onEdit;

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

    final avatar = CircleAvatar(
      radius: 32,
      backgroundColor: primary,
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
    );

    final identity = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s,
            runSpacing: 4,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  'Super Admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Platform Owner',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (phone?.isNotEmpty ?? false) ...[
            _ContactRow(icon: Icons.phone_outlined, value: phone!),
            const SizedBox(height: AppSpacing.xs),
          ],
          _ContactRow(icon: Icons.email_outlined, value: email),
        ],
      ),
    );

    final statsAndEdit = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.m,
      children: [
        _AccountStat(label: 'Schools', value: '$totalSchools'),
        _AccountStat(label: 'Active', value: '$activeSchools'),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit Profile'),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatar,
                    const SizedBox(width: AppSpacing.l),
                    identity,
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Divider(height: 1, color: AppColors.border(context)),
                const SizedBox(height: AppSpacing.l),
                statsAndEdit,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: AppSpacing.l),
              identity,
              const SizedBox(width: AppSpacing.xl),
              Container(width: 1, height: 64, color: AppColors.border(context)),
              const SizedBox(width: AppSpacing.xl),
              statsAndEdit,
            ],
          );
        },
      ),
    );
  }
}

/// Compact profile card matching the reference: avatar/initials, name,
/// "Platform Owner" role, verified email, chevron to full profile screen.
class PlatformSettingsProfileCard extends StatelessWidget {
  const PlatformSettingsProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.onTap,
  });

  final String name;
  final String email;
  final String? photoUrl;
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceElevated(context),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.informationSurface(context),
              backgroundImage: photoUrl?.isNotEmpty == true ? NetworkImage(photoUrl!) : null,
              child: photoUrl?.isNotEmpty == true
                  ? null
                  : Text(
                      _initials(name),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.information(context),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 16,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Platform Owner',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
          ],
        ),
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

/// Light/Dark/System theme picker, backed by the app-wide [ThemeProvider]
/// (the same one main.dart feeds into MaterialApp.themeMode) so a choice
/// made here affects the whole app immediately and persists across
/// restarts via SharedPreferences, not just this screen's own state.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().themeMode;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final selector = _ThemeSegmentedControl(
            mode: mode,
            onChanged: (value) => context.read<ThemeProvider>().setThemeMode(value),
          );
          final label = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Appearance',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Choose how the app looks',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          );
          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [label, const SizedBox(height: 10), selector],
            );
          }
          return Row(
            children: [
              Expanded(child: label),
              const SizedBox(width: 12),
              selector,
            ],
          );
        },
      ),
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  const _ThemeSegmentedControl({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer(context),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in ThemeMode.values)
          _ThemeSegment(
            mode: option,
            selected: mode == option,
            onTap: () => onChanged(option),
          ),
      ],
    ),
  );
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.mode, required this.selected, required this.onTap});
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  String get _label => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.surfaceElevated(context) : Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.information(context) : Colors.transparent,
          ),
        ),
        child: Text(
          _label,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: selected ? AppColors.information(context) : AppColors.textSecondary(context),
          ),
        ),
      ),
    ),
  );
}

/// Compact settings row: icon, title, one-line subtitle, chevron. Used
/// standalone (its own bordered card, desktop) or grouped inside a shared
/// bordered container with dividers between rows (mobile).
class PlatformSettingsRow extends StatelessWidget {
  const PlatformSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.standalone = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final row = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: standalone ? 14 : 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.informationSurface(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.information(context), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
    if (!standalone) return row;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: row,
    );
  }
}

TextStyle _pageTitle(BuildContext c) => AppTypography.headlineMedium.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 24,
  fontWeight: FontWeight.w800,
);

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        ),
      ),
    ),
  );
}
