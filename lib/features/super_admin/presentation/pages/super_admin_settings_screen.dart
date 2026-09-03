import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../../data/services/custom_domain_service.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import 'super_admin_profile_screen.dart';

/// Settings control centre for the SaaS owner console.
///
/// Two columns on desktop, stacked on tablet/mobile:
///  - Left: My Account, Appearance, Security.
///  - Right: a Platform Configuration card grid (School onboarding, Custom
///    domains, Branding & communications, Integrations & API access, Data
///    retention & exports, Support & legal).
///
/// Duplicated navigation is deliberately absent: billing / payment methods
/// live only in the Billing section, audit logs only in Activity. Sign out
/// is not offered here — it lives once, in the sidebar footer account row on
/// desktop and the account menu in this screen's header on mobile.
class SuperAdminSettingsScreen extends StatelessWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final ownerName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()
        : 'SaaS Owner';
    final ownerEmail = (user?.email.trim().isNotEmpty ?? false)
        ? user!.email.trim()
        : 'Not signed in';
    final ownerPhone = user?.phoneNumber?.trim();
    final photoUrl = user?.photoUrl;
    final wide = isSuperAdminWide(context);

    void openProfile() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuperAdminProfileScreen()),
    );

    final leftColumn = <Widget>[
      _AccountCard(
        name: ownerName,
        email: ownerEmail,
        phone: ownerPhone,
        photoUrl: photoUrl,
        onEdit: openProfile,
      ),
      const _AppearanceCard(),
      const _SecurityCard(),
    ];

    final rightColumn = <Widget>[_PlatformConfigurationCard(wide: wide)];

    if (wide) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onOpenAccountMenu: null,
                name: ownerName,
                email: ownerEmail,
                photoUrl: photoUrl,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 380,
                      child: Column(
                        children: [
                          for (final w in leftColumn) ...[
                            w,
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          for (final w in rightColumn) ...[
                            w,
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Header(
              onOpenAccountMenu: () => _showAccountMenu(context),
              name: ownerName,
              email: ownerEmail,
              photoUrl: photoUrl,
            ),
            const SizedBox(height: 20),
            for (final w in [...leftColumn, ...rightColumn]) ...[
              w,
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountMenu(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textPrimary(sheetContext),
              ),
              title: const Text('Edit profile'),
              onTap: () => Navigator.pop(sheetContext, 'profile'),
            ),
            Divider(height: 1, color: AppColors.border(sheetContext)),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: AppColors.danger(sheetContext),
              ),
              title: Text(
                'Sign out',
                style: TextStyle(
                  color: AppColors.danger(sheetContext),
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () => Navigator.pop(sheetContext, 'signout'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SuperAdminProfileScreen()),
        );
      case 'signout':
        await handleSuperAdminLogout(context);
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.onOpenAccountMenu,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  /// When non-null a compact avatar button is shown that opens the account
  /// menu (mobile — there is no sidebar footer to carry sign out).
  final VoidCallback? onOpenAccountMenu;
  final String name;
  final String email;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
                'Manage your platform configuration, security, and preferences.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        if (onOpenAccountMenu != null) ...[
          const SizedBox(width: 12),
          _AvatarMenuButton(
            name: name,
            photoUrl: photoUrl,
            onTap: onOpenAccountMenu!,
          ),
        ],
      ],
    );
  }
}

class _AvatarMenuButton extends StatelessWidget {
  const _AvatarMenuButton({
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  final String name;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.informationSurface(context),
            backgroundImage: (photoUrl?.isNotEmpty ?? false)
                ? NetworkImage(photoUrl!)
                : null,
            child: (photoUrl?.isNotEmpty ?? false)
                ? null
                : Text(
                    _initials(name),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.information(context),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card scaffold
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Left column: My Account
// ---------------------------------------------------------------------------

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'My account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.informationSurface(context),
                backgroundImage: (photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(photoUrl!)
                    : null,
                child: (photoUrl?.isNotEmpty ?? false)
                    ? null
                    : Text(
                        _initials(name),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.information(context),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Badge(
                      label: 'Platform Owner',
                      color: AppColors.information(context),
                      surface: AppColors.informationSurface(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (phone?.isNotEmpty ?? false) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phone!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.information(context),
                side: BorderSide(color: AppColors.border(context)),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Left column: Appearance
// ---------------------------------------------------------------------------

/// Light/Dark/System theme picker, backed by the app-wide [ThemeProvider]
/// (the same one main.dart feeds into MaterialApp.themeMode) so a choice
/// made here affects the whole app immediately and persists across
/// restarts via SharedPreferences, not just this screen's own state.
class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().themeMode;
    return _SettingsCard(
      title: 'Appearance',
      subtitle: 'Choose how the platform looks',
      child: _ThemeSegmentedControl(
        mode: mode,
        onChanged: (value) =>
            context.read<ThemeProvider>().setThemeMode(value),
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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Row(
      children: [
        for (final option in ThemeMode.values)
          Expanded(
            child: _ThemeSegment(
              mode: option,
              selected: mode == option,
              onTap: () => onChanged(option),
            ),
          ),
      ],
    ),
  );
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({
    required this.mode,
    required this.selected,
    required this.onTap,
  });
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  ({String label, IconData icon}) get _meta => switch (mode) {
    ThemeMode.light => (label: 'Light', icon: Icons.light_mode_outlined),
    ThemeMode.dark => (label: 'Dark', icon: Icons.dark_mode_outlined),
    ThemeMode.system => (label: 'System', icon: Icons.desktop_windows_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    return Material(
      color: selected ? AppColors.surfaceElevated(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? AppColors.information(context)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                meta.icon,
                size: 15,
                color: selected
                    ? AppColors.information(context)
                    : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  meta.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: selected
                        ? AppColors.information(context)
                        : AppColors.textSecondary(context),
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

// ---------------------------------------------------------------------------
// Left column: Security
// ---------------------------------------------------------------------------

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) {
    void openSecurity() => context.push('/super-admin/settings/security');

    return _SettingsCard(
      title: 'Security',
      child: Column(
        children: [
          _RowItem(
            icon: Icons.verified_user_outlined,
            title: 'Two-factor authentication',
            subtitle: 'Secure your account with 2FA',
            onTap: openSecurity,
          ),
          _Sep(),
          _RowItem(
            icon: Icons.devices_outlined,
            title: 'Active sessions',
            subtitle: 'Review and revoke signed-in devices',
            onTap: openSecurity,
          ),
          _Sep(),
          _RowItem(
            icon: Icons.lock_outline_rounded,
            title: 'Change password',
            subtitle: 'Update the password for this account',
            onTap: openSecurity,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Right column: Platform configuration grid
// ---------------------------------------------------------------------------

class _PlatformConfigurationCard extends StatelessWidget {
  const _PlatformConfigurationCard({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Platform configuration',
      subtitle: 'Configure how your platform operates and integrates.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoUp = constraints.maxWidth >= 520;
          final tileWidth = twoUp
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final tile in _tiles(context))
                SizedBox(width: tileWidth, child: tile),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _tiles(BuildContext context) => [
    _ConfigTile(
      icon: Icons.school_outlined,
      title: 'School onboarding',
      description:
          'Review applications and onboard new schools onto the platform.',
      onTap: () => context.push('/super-admin/schools'),
    ),
    _ConfigTile(
      icon: Icons.language_outlined,
      title: 'Custom domains',
      description:
          "Verify and activate schools' custom portal hostnames.",
      status: const _CustomDomainsStatus(),
      onTap: () => context.push('/super-admin/settings/custom-domains'),
    ),
    _ConfigTile(
      icon: Icons.alternate_email_outlined,
      title: 'Subdomain change requests',
      description: "Review schools' requests to change their subdomain.",
      onTap: () =>
          context.push('/super-admin/settings/subdomain-requests'),
    ),
    _ConfigTile(
      icon: Icons.campaign_outlined,
      title: 'Branding & communications',
      description:
          'Platform branding, transactional emails and notifications.',
      onTap: () => context.push('/super-admin/settings/support'),
    ),
    _ConfigTile(
      icon: Icons.monitor_heart_outlined,
      title: 'Platform health',
      description: 'Live service status and platform-wide diagnostics.',
      onTap: () => context.push('/super-admin/platform-health'),
    ),
    _ConfigTile(
      icon: Icons.shield_outlined,
      title: 'Support & legal',
      description: 'Help center, terms of service and privacy policy.',
      onTap: () => context.push('/super-admin/settings/support'),
    ),
  ];
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.icon,
    required this.title,
    required this.description,
    this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.informationSurface(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 19,
                      color: AppColors.information(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: 12),
                status!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Real status for the Custom domains tile — a live count from the same
/// stream the Custom Domains screen renders. No row = nothing to report.
class _CustomDomainsStatus extends StatelessWidget {
  const _CustomDomainsStatus();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomDomainRequest>>(
      stream: CustomDomainService().watchRequests(),
      builder: (context, snapshot) {
        final requests = snapshot.data;
        if (requests == null) return const SizedBox.shrink();
        final active = requests.where((r) => r.isActive).length;
        final pending =
            requests.where((r) => r.isPending || r.isVerified).length;
        if (active == 0 && pending == 0) return const SizedBox.shrink();
        if (active > 0) {
          return _StatusDot(
            color: AppColors.success(context),
            label: active == 1 ? '1 domain active' : '$active domains active',
          );
        }
        return _StatusDot(
          color: AppColors.information(context),
          label: pending == 1
              ? '1 request pending'
              : '$pending requests pending',
        );
      },
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small shared pieces
// ---------------------------------------------------------------------------

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.informationSurface(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.information(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: AppColors.border(context));
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.surface,
  });

  final String label;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _initials(String value) => value
    .trim()
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .take(2)
    .map((part) => part[0].toUpperCase())
    .join();
