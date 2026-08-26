import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/institution/presentation/screens/institution_switcher_sheet.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_sync_service.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Personal account and app preferences only. Operational modules belong in
/// School or Work, never in More.
class ProfileMoreScreen extends StatelessWidget {
  const ProfileMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    if (state is! AuthAuthenticated) return const SizedBox.shrink();
    return _MorePage(user: state.user);
  }
}

class _MorePage extends StatelessWidget {
  const _MorePage({required this.user});
  final UserEntity user;

  List<Widget> get _accountRows => [
    _Row(
      icon: Icons.person_outline,
      title: 'Profile',
      subtitle: 'Photo, name and contact details',
      onTap: (context) => context.push('/staff/more/edit-profile'),
    ),
    _Row(
      icon: Icons.shield_outlined,
      title: 'Security',
      subtitle: 'Password and sign-in methods',
      onTap: (context) => context.push('/staff/more/security-privacy'),
    ),
    _MembershipRow(user: user),
  ];

  List<Widget> get _preferenceRows => [
    _Row(
      icon: Icons.notifications_none_outlined,
      title: 'Notifications',
      value: 'Manage',
      onTap: (context) =>
          context.push('/staff/more/notification-preferences'),
    ),
    _AppearanceRow(user: user),
    _Row(
      icon: Icons.cloud_outlined,
      title: 'Offline & storage',
      value: 'Manage',
      onTap: (context) => context.push('/staff/more/offline-data'),
    ),
    const _Row(
      icon: Icons.language_outlined,
      title: 'Language & region',
      value: 'English · Uganda',
      onTap: null,
    ),
  ];

  List<Widget> get _supportRows => [
    _Row(
      icon: Icons.help_outline,
      title: 'Help centre',
      onTap: (context) => context.push('/staff/more/help-center'),
    ),
    _Row(
      icon: Icons.headset_mic_outlined,
      title: 'Contact support',
      onTap: (context) => context.push('/staff/more/help-center'),
    ),
    _Row(
      icon: Icons.info_outline,
      title: 'About School Pulse',
      value: 'v1.0.0',
      onTap: (context) => context.push('/staff/more/about'),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ResponsiveBuilder(
        builder: (context, layout) => layout == ResponsiveLayout.mobile
            ? _MobileMore(
                user: user,
                accountRows: _accountRows,
                preferenceRows: _preferenceRows,
                supportRows: _supportRows,
              )
            : _WideMore(
                user: user,
                layout: layout,
                accountRows: _accountRows,
                preferenceRows: _preferenceRows,
                supportRows: _supportRows,
              ),
      ),
    ),
  );
}

class _MobileMore extends StatelessWidget {
  const _MobileMore({
    required this.user,
    required this.accountRows,
    required this.preferenceRows,
    required this.supportRows,
  });
  final UserEntity user;
  final List<Widget> accountRows, preferenceRows, supportRows;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
    children: [
      Row(
        children: [
          const Text(
            'More',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/staff/more/security-privacy'),
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
        ],
      ),
      const SizedBox(height: 22),
      _IdentityRow(user: user),
      const SizedBox(height: 30),
      _Section(title: 'ACCOUNT', children: accountRows),
      const SizedBox(height: 26),
      _Section(title: 'PREFERENCES', children: preferenceRows),
      const SizedBox(height: 26),
      _Section(title: 'SUPPORT', children: supportRows),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () => _signOut(context, user),
        icon: const Icon(Icons.logout_outlined, size: 20),
        label: const Text('Sign out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink(context),
          side: BorderSide(color: _ink(context)),
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    ],
  );
}

/// Desktop (>=1024) and tablet (600-1023) layout: same rows/callbacks as
/// mobile, arranged as a bounded profile card plus a two-column section grid.
class _WideMore extends StatelessWidget {
  const _WideMore({
    required this.user,
    required this.layout,
    required this.accountRows,
    required this.preferenceRows,
    required this.supportRows,
  });
  final UserEntity user;
  final ResponsiveLayout layout;
  final List<Widget> accountRows, preferenceRows, supportRows;

  @override
  Widget build(BuildContext context) {
    final isDesktop = layout == ResponsiveLayout.desktop;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(title: 'ACCOUNT', children: accountRows),
        const SizedBox(height: 24),
        _Section(title: 'SUPPORT', children: supportRows),
      ],
    );
    final right = _Section(title: 'PREFERENCES', children: preferenceRows);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 32 : 20,
        24,
        isDesktop ? 32 : 20,
        48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'More',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Settings',
                    child: IconButton(
                      onPressed: () =>
                          context.push('/staff/more/security-privacy'),
                      icon: const Icon(Icons.settings_outlined, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _IdentityRow(user: user),
              const SizedBox(height: 28),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 24),
                    Expanded(child: right),
                  ],
                )
              else ...[
                left,
                const SizedBox(height: 24),
                right,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityRow extends StatefulWidget {
  const _IdentityRow({required this.user});
  final UserEntity user;

  @override
  State<_IdentityRow> createState() => _IdentityRowState();
}

class _IdentityRowState extends State<_IdentityRow> {
  bool _photoLoadFailed = false;

  UserEntity get user => widget.user;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/staff/more/edit-profile'),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: _ink(context)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _paper(context),
            foregroundColor: _ink(context),
            backgroundImage: user.photoUrl == null || _photoLoadFailed
                ? null
                : NetworkImage(user.photoUrl!),
            onBackgroundImageError: user.photoUrl == null || _photoLoadFailed
                ? null
                : (_, _) {
                    if (mounted) setState(() => _photoLoadFailed = true);
                  },
            child: user.photoUrl == null || _photoLoadFailed
                ? Text(
                    _initials(user.name),
                    style: const TextStyle(fontSize: 15),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${UserRoleDisplay.name(user.role)} · ${user.schoolName ?? 'Active school'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: _ink(context)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    ),
  );
}

class _MembershipRow extends StatelessWidget {
  const _MembershipRow({required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) =>
      FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: di
            .sl<FirebaseFirestore>()
            .collection('institution_memberships')
            .where('userId', isEqualTo: user.id)
            .where('status', isEqualTo: 'active')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 0);
          }
          if (snapshot.hasError || (snapshot.data?.docs.length ?? 0) <= 1) {
            return const SizedBox(height: 0);
          }
          return _Row(
            icon: Icons.domain_outlined,
            title: 'Switch school',
            subtitle: 'Choose another organisation',
            onTap: (context) => InstitutionSwitcherSheet.show(context),
          );
        },
      );
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final label = switch (theme.themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
    return _Row(
      icon: Icons.brightness_6_outlined,
      title: 'Appearance',
      value: label,
      onTap: (context) => _appearancePicker(context, theme),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: .7,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: _ink(context)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: children),
      ),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle, value;
  final void Function(BuildContext context)? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap == null ? null : () => onTap!(context),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _paper(context),
              border: Border.all(color: _ink(context)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _ink(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 14, color: _ink(context)),
                  ),
                ],
              ],
            ),
          ),
          if (value != null)
            Text(value!, style: TextStyle(fontSize: 13, color: _ink(context))),
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    ),
  );
}

Future<void> _appearancePicker(
  BuildContext context,
  ThemeProvider theme,
) async {
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

Future<void> _signOut(BuildContext context, UserEntity user) async {
  final pending = await di.sl<SubjectSyncService>().pending(
    schoolId: user.schoolId,
  );
  if (!context.mounted) return;
  final message = pending.isEmpty
      ? 'Sign out of this device? Local tenant data will be securely cleared.'
      : '${pending.length} offline change${pending.length == 1 ? '' : 's'} still need to sync. Sign out anyway? Those changes will remain queued until this account signs in again.';
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign out?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: _ink(context))),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, true),
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink(context),
            side: BorderSide(color: _ink(context)),
          ),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
  if (confirm == true && context.mounted) {
    context.read<AuthBloc>().add(LogoutPressed());
    context.go('/welcome');
  }
}

String _initials(String name) => name
    .trim()
    .split(RegExp(r'\\s+'))
    .take(2)
    .map((part) => part.isEmpty ? '' : part[0])
    .join()
    .toUpperCase();

Color _ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;
Color _paper(BuildContext context) => Theme.of(context).colorScheme.surface;
