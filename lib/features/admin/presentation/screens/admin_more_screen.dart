import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_sync_service.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// School administration hub for School Admin / Head Teacher / Deputy Head /
/// Director (see [UserRoleRouting.adminConsoleRoles]). Every operational
/// destination linked here owns its own route-level role gate; this screen
/// only decides which tiles are worth *offering*, never re-implements
/// authorization.
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is! AuthAuthenticated) return const SizedBox.shrink();
    return _AdminMorePage(user: state.user);
  }
}

class _AdminTool {
  const _AdminTool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.roles,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final List<UserRole> roles;
}

const _adminTools = [
  _AdminTool(
    icon: Icons.account_tree_outlined,
    title: 'School structure',
    subtitle: 'Manage classrooms, grades & groups',
    route: '/staff/admin/structure',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.people_alt_outlined,
    title: 'Roles & access',
    subtitle: 'Manage staff roles and permissions',
    route: '/staff/admin/users',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.bar_chart_outlined,
    title: 'Reports',
    subtitle: 'View analytics and export data',
    route: '/staff/admin/reports',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.settings_outlined,
    title: 'School settings',
    subtitle: 'School settings and preferences',
    route: '/staff/admin/school-setup',
    roles: [
      UserRole.schoolAdmin,
      UserRole.headTeacher,
      UserRole.deputyHead,
      UserRole.director,
    ],
  ),
  _AdminTool(
    icon: Icons.storage_outlined,
    title: 'Data management',
    subtitle: 'Import, export and manage school data',
    route: '/staff/admin/data-management',
    roles: [UserRole.schoolAdmin, UserRole.headTeacher, UserRole.director],
  ),
  _AdminTool(
    icon: Icons.health_and_safety_outlined,
    title: 'Institution health',
    subtitle: 'Setup completeness and data integrity checks',
    route: '/staff/admin/institution-health',
    roles: [UserRole.schoolAdmin, UserRole.headTeacher, UserRole.director],
  ),
  _AdminTool(
    icon: Icons.sms_outlined,
    title: 'Broadcast SMS',
    subtitle: 'Send bulk SMS to parents or staff',
    route: '/staff/admin/broadcast-sms',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.history_outlined,
    title: 'Broadcast history',
    subtitle: 'Past SMS and announcement campaigns',
    route: '/staff/admin/broadcast-history',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.tune_outlined,
    title: 'System config',
    subtitle: 'Platform-wide configuration options',
    route: '/staff/admin/config',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.extension_outlined,
    title: 'Integrations',
    subtitle: 'Connected providers and API access',
    route: '/staff/admin/integrations',
    roles: [UserRole.schoolAdmin, UserRole.headTeacher, UserRole.director],
  ),
  _AdminTool(
    icon: Icons.badge_outlined,
    title: 'Batch ID cards',
    subtitle: 'Print ID cards for many learners at once',
    route: '/staff/admin/batch-id-cards',
    roles: [
      UserRole.schoolAdmin,
      UserRole.director,
      UserRole.headTeacher,
      UserRole.deputyHead,
      UserRole.deanOfStudies,
      UserRole.receptionist,
      UserRole.hrOfficer,
    ],
  ),
  _AdminTool(
    icon: Icons.how_to_reg_outlined,
    title: 'Admissions',
    subtitle: 'Review and process new applications',
    route: '/staff/admin/admissions',
    roles: [
      UserRole.schoolAdmin,
      UserRole.director,
      UserRole.headTeacher,
      UserRole.deputyHead,
      UserRole.deanOfStudies,
      UserRole.receptionist,
      UserRole.hrOfficer,
    ],
  ),
  _AdminTool(
    icon: Icons.fact_check_outlined,
    title: 'Audit log',
    subtitle: 'Track changes made across the system',
    route: '/staff/admin/audit-log',
    roles: [UserRole.director, UserRole.headTeacher, UserRole.schoolAdmin],
  ),
  _AdminTool(
    icon: Icons.support_agent_outlined,
    title: 'Support centre',
    subtitle: 'Internal support tickets and resources',
    route: '/staff/admin/support',
    roles: [UserRole.director, UserRole.headTeacher, UserRole.schoolAdmin],
  ),
  _AdminTool(
    icon: Icons.campaign_outlined,
    title: 'Communication centre',
    subtitle: 'Compose and track announcements',
    route: '/staff/admin/communication-center',
    roles: [
      UserRole.director,
      UserRole.headTeacher,
      UserRole.schoolAdmin,
      UserRole.deputyHead,
      UserRole.securityHead,
    ],
  ),
  _AdminTool(
    icon: Icons.security_outlined,
    title: 'Security centre',
    subtitle: 'Access logs and security settings',
    route: '/staff/admin/security',
    roles: [UserRole.director, UserRole.headTeacher, UserRole.schoolAdmin],
  ),
  _AdminTool(
    icon: Icons.workspace_premium_outlined,
    title: 'Subscription',
    subtitle: 'Plan, billing and usage',
    route: '/staff/admin/subscription',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
  _AdminTool(
    icon: Icons.link_outlined,
    title: 'School subdomain',
    subtitle: 'Manage your school\'s web address',
    route: '/staff/admin/school-subdomain',
    roles: UserRoleDisplay.adminConsoleRoles,
  ),
];

class _AdminMorePage extends StatelessWidget {
  const _AdminMorePage({required this.user});
  final UserEntity user;

  List<_AdminTool> get _authorizedTools =>
      _adminTools.where((t) => user.roles.any(t.roles.contains)).toList();

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.background(context),
    child: SafeArea(
      child: ResponsiveBuilder(
        builder: (context, layout) => layout == ResponsiveLayout.mobile
            ? _MobileMore(user: user, tools: _authorizedTools)
            : _WideMore(user: user, layout: layout, tools: _authorizedTools),
      ),
    ),
  );
}

class _MobileMore extends StatelessWidget {
  const _MobileMore({required this.user, required this.tools});
  final UserEntity user;
  final List<_AdminTool> tools;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
    children: [
      Row(
        children: [
          Text(
            'More',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/staff/more/security-privacy'),
            icon: Icon(
              Icons.settings_outlined,
              size: 22,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _AccountCard(user: user),
      if (tools.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.x3l),
        const _SectionTitle('School administration'),
        const SizedBox(height: AppSpacing.m),
        _ToolGrid(tools: tools),
      ],
      const SizedBox(height: AppSpacing.x3l),
      const _SectionTitle('Personal'),
      const SizedBox(height: AppSpacing.m),
      _RowGroup(rows: _personalRows(user)),
      const SizedBox(height: AppSpacing.x3l),
      const _SectionTitle('Support'),
      const SizedBox(height: AppSpacing.m),
      _RowGroup(rows: _supportRows()),
      const SizedBox(height: AppSpacing.x3l),
      const _LogoutRow(),
    ],
  );
}

class _WideMore extends StatelessWidget {
  const _WideMore({required this.user, required this.layout, required this.tools});
  final UserEntity user;
  final ResponsiveLayout layout;
  final List<_AdminTool> tools;

  @override
  Widget build(BuildContext context) {
    final isDesktop = layout == ResponsiveLayout.desktop;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tools.isNotEmpty) ...[
          const _SectionTitle('School administration'),
          const SizedBox(height: AppSpacing.m),
          _ToolGrid(tools: tools),
        ],
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Personal'),
        const SizedBox(height: AppSpacing.m),
        _RowGroup(rows: _personalRows(user)),
      ],
    );
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 20, 24, isDesktop ? 32 : 20, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 24),
              _AccountCard(user: user, wide: true),
              const SizedBox(height: 28),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: left),
                    if (tools.isNotEmpty) const SizedBox(width: 24),
                    Expanded(flex: 2, child: right),
                  ],
                )
              else ...[
                left,
                if (tools.isNotEmpty) const SizedBox(height: 24),
                right,
              ],
              const SizedBox(height: AppSpacing.x3l),
              const _SectionTitle('Support'),
              const SizedBox(height: AppSpacing.m),
              _SupportRow(),
              const SizedBox(height: AppSpacing.x3l),
              const _LogoutRow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Offline & storage is gated on the actual platform ([kIsWeb]), not on
/// screen width - a real tablet/desktop build of the mobile app still has
/// Isar-backed offline sync, while any web build (regardless of viewport)
/// does not.
List<Widget> _personalRows(UserEntity user) => [
  _MoreRow(
    icon: Icons.person_outline,
    title: 'Profile',
    subtitle: 'Photo, name and contact details',
    onTap: (context) => context.push('/staff/more/edit-profile'),
  ),
  _MoreRow(
    icon: Icons.shield_outlined,
    title: 'Security',
    subtitle: 'Password and sign-in methods',
    onTap: (context) => context.push('/staff/more/security-privacy'),
  ),
  _MoreRow(
    icon: Icons.notifications_none_outlined,
    title: 'Notifications',
    subtitle: 'Manage your notification preferences',
    onTap: (context) => context.push('/staff/more/notification-preferences'),
  ),
  const _AppearanceRow(),
  kIsWeb
      ? const _MoreRow(
          icon: Icons.cloud_outlined,
          title: 'Offline & storage',
          subtitle: 'Available in the mobile app',
          onTap: null,
          locked: true,
        )
      : _MoreRow(
          icon: Icons.cloud_outlined,
          title: 'Offline & storage',
          subtitle: 'Sync status and cached data',
          onTap: (context) => context.push('/staff/more/offline-data'),
        ),
];

List<Widget> _supportRows() => [
  _MoreRow(
    icon: Icons.help_outline,
    title: 'Help centre',
    subtitle: 'Guides and frequently asked questions',
    onTap: (context) => context.push('/staff/more/help-center'),
  ),
  _MoreRow(
    icon: Icons.headset_mic_outlined,
    title: 'Contact support',
    subtitle: 'Get in touch with our support team',
    onTap: (context) => context.push('/staff/more/help-center'),
  ),
  const _AboutRow(),
];

class _AccountCard extends StatefulWidget {
  const _AccountCard({required this.user, this.wide = false});
  final UserEntity user;
  final bool wide;

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _photoLoadFailed = false;

  UserEntity get user => widget.user;

  @override
  Widget build(BuildContext context) {
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    final roleLabel = user.roles.isEmpty
        ? UserRoleDisplay.name(user.role)
        : UserRoleDisplay.name(user.roles.first);
    return AppCard(
      onTap: () => context.push('/staff/more/edit-profile'),
      padding: EdgeInsets.all(widget.wide ? AppSpacing.l : AppSpacing.m),
      child: Row(
        children: [
          CircleAvatar(
            radius: widget.wide ? 28 : 24,
            backgroundColor: AppColors.surfaceContainer(context),
            backgroundImage: user.photoUrl?.isNotEmpty == true && !_photoLoadFailed
                ? NetworkImage(user.photoUrl!)
                : null,
            onBackgroundImageError: user.photoUrl?.isNotEmpty == true && !_photoLoadFailed
                ? (_, _) {
                    if (mounted) setState(() => _photoLoadFailed = true);
                  }
                : null,
            child: user.photoUrl?.isNotEmpty == true && !_photoLoadFailed
                ? null
                : Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleLabel,
                  style: TextStyle(
                    fontSize: widget.wide ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.schoolName?.isNotEmpty == true ? user.schoolName! : 'Active school',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                ),
                if (user.isActive) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active',
                        style: TextStyle(fontSize: 12, color: AppColors.success(context)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (widget.wide)
            OutlinedButton.icon(
              onPressed: () => context.push('/staff/more/edit-profile'),
              icon: const Icon(Icons.person_outline, size: 18),
              label: const Text('Account profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.border(context)),
              ),
            )
          else
            Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
        ],
      ),
    );
  }
}

/// Two-per-row tool grid whose cards hug their content instead of
/// stretching to a forced aspect ratio, so a short title/subtitle pair
/// doesn't leave dead space at the bottom of the card.
class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.tools});
  final List<_AdminTool> tools;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tools.length; i += 2) {
      final second = i + 1 < tools.length ? tools[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ToolCard(tool: tools[i])),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: second == null
                    ? const SizedBox.shrink()
                    : _ToolCard(tool: second),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < tools.length) rows.add(const SizedBox(height: AppSpacing.m));
    }
    return Column(children: rows);
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _AdminTool tool;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: () => context.push(tool.route),
    padding: const EdgeInsets.all(AppSpacing.l),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.informationSurface(context),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(tool.icon, size: 18, color: AppColors.information(context)),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary(context)),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          tool.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tool.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      letterSpacing: .3,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary(context),
    ),
  );
}

class _RowGroup extends StatelessWidget {
  const _RowGroup({required this.rows});
  final List<Widget> rows;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: List.generate(
        rows.length,
        (index) => Column(
          children: [
            rows[index],
            if (index < rows.length - 1) Divider(height: 1, color: AppColors.border(context)),
          ],
        ),
      ),
    ),
  );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
    this.locked = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle, value;
  final void Function(BuildContext context)? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final textColor = disabled
        ? AppColors.textSecondary(context)
        : AppColors.textPrimary(context);
    return InkWell(
      onTap: disabled ? null : () => onTap!(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer(context),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: textColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              Text(value!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
              const SizedBox(width: 4),
            ],
            Icon(
              locked ? Icons.lock_outline : Icons.chevron_right,
              size: locked ? 18 : 16,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow();
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final label = switch (theme.themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
    return _MoreRow(
      icon: Icons.palette_outlined,
      title: 'Appearance',
      subtitle: 'App theme and display options',
      value: label,
      onTap: (context) => _appearancePicker(context, theme),
    );
  }
}

class _AboutRow extends StatefulWidget {
  const _AboutRow();
  @override
  State<_AboutRow> createState() => _AboutRowState();
}

class _AboutRowState extends State<_AboutRow> {
  String? _version;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}');
    });
  }

  @override
  Widget build(BuildContext context) => _MoreRow(
    icon: Icons.info_outline,
    title: 'About School Pulse',
    subtitle: 'Learn more about the app',
    value: _version,
    onTap: (context) => context.push('/staff/more/about'),
  );
}

Future<void> _appearancePicker(BuildContext context, ThemeProvider theme) async {
  final mode = await showModalBottomSheet<ThemeMode>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ThemeMode.values
            .map(
              (mode) => ListTile(
                leading: Icon(
                  theme.themeMode == mode
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                }),
                onTap: () => Navigator.pop(context, mode),
              ),
            )
            .toList(),
      ),
    ),
  );
  if (mode != null) await theme.setThemeMode(mode);
}

/// Full-width bordered card row matching the reference: icon, title +
/// subtitle, chevron - all in the destructive red, not a plain button.
class _LogoutRow extends StatelessWidget {
  const _LogoutRow();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final danger = AppColors.danger(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: danger),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _signOut(context, auth.user),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 20, color: danger),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: danger,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Sign out of School Pulse',
                      style: TextStyle(fontSize: 12, color: danger.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: danger),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal 3-up support row for tablet/desktop, matching the reference.
class _SupportRow extends StatelessWidget {
  const _SupportRow();

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _supportRows()[0]),
          VerticalDivider(width: 1, color: AppColors.border(context)),
          Expanded(child: _supportRows()[1]),
          VerticalDivider(width: 1, color: AppColors.border(context)),
          Expanded(child: _supportRows()[2]),
        ],
      ),
    ),
  );
}

Future<void> _signOut(BuildContext context, UserEntity user) async {
  final pending = await di.sl<SubjectSyncService>().pending(schoolId: user.schoolId);
  if (!context.mounted) return;
  final message = pending.isEmpty
      ? 'Sign out of this device? Local tenant data will be securely cleared.'
      : '${pending.length} offline change${pending.length == 1 ? '' : 's'} still need to sync. Sign out anyway? Those changes will remain queued until this account signs in again.';
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log out?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary(context))),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger(context)),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (confirm == true && context.mounted) {
    context.read<AuthBloc>().add(LogoutPressed());
    context.go('/welcome');
  }
}
