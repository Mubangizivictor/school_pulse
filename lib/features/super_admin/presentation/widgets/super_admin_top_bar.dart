import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

import '../pages/super_admin_profile_screen.dart';
import 'super_admin_logout_button.dart';

/// Desktop top bar shown above the content area in the Super Admin shell:
/// a global search field, the unread-notifications bell, a theme toggle and
/// the owner's profile menu. Mirrors the attached reference images' header.
class SuperAdminTopBar extends StatefulWidget implements PreferredSizeWidget {
  const SuperAdminTopBar({
    super.key,
    required this.onSearchSubmitted,
    this.searchHint = 'Search schools, applications, payments...',
  });

  final ValueChanged<String> onSearchSubmitted;
  final String searchHint;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<SuperAdminTopBar> createState() => _SuperAdminTopBarState();
}

class _SuperAdminTopBarState extends State<SuperAdminTopBar> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Expanded(child: _buildSearchField(context)),
          const SizedBox(width: AppSpacing.l),
          const _NotificationBellButton(),
          const SizedBox(width: AppSpacing.m),
          const _ThemeToggleButton(),
          const SizedBox(width: AppSpacing.m),
          const _ProfileMenuButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const _FocusSearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const _FocusSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) {
              _searchFocus.requestFocus();
              return null;
            },
          ),
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onSubmitted: widget.onSearchSubmitted,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: widget.searchHint,
              hintStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary(context),
                size: 20,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer(context),
                      borderRadius: AppRadius.small,
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Text(
                      '⌘K',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ),
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceContainer(context),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: BorderSide(
                  color: AppColors.primary(context),
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

/// Bell icon showing a live unread-count badge from
/// `super_admin_notifications`, opening the Notifications screen on tap.
class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OwnerNotification>>(
      stream: OwnerNotificationService().watchNotifications(),
      builder: (context, snapshot) {
        final unread = snapshot.data?.where((n) => n.isUnread).length ?? 0;
        return Tooltip(
          message: 'Notifications',
          child: Material(
            color: AppColors.surfaceContainer(context),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.medium,
              side: BorderSide(color: AppColors.border(context)),
            ),
            child: InkWell(
              borderRadius: AppRadius.medium,
              // Real owner route (not a bare push) so the persistent
              // navigation stays visible - Overview stays highlighted.
              onTap: () => context.go('/super-admin/notifications'),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textSecondary(context),
                        size: 20,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.surfaceElevated(context),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cycles Light -> Dark -> System, reusing the app-wide [ThemeProvider] so
/// the preference stays in sync with mobile.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final (icon, label) = switch (themeProvider.themeMode) {
      ThemeMode.light => (Icons.light_mode_rounded, 'Light theme'),
      ThemeMode.dark => (Icons.dark_mode_rounded, 'Dark theme'),
      ThemeMode.system => (Icons.brightness_auto_rounded, 'System theme'),
    };
    return Tooltip(
      message: '$label — tap to change',
      child: Material(
        color: AppColors.surfaceContainer(context),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: AppColors.border(context)),
        ),
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: () {
            const order = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
            final next =
                order[(order.indexOf(themeProvider.themeMode) + 1) %
                    order.length];
            themeProvider.setThemeMode(next);
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar + name dropdown offering "Edit Profile" and "Sign Out", reusing
/// the same confirmation dialog used by the sidebar's logout item.
class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final ownerLabel = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email?.trim().isNotEmpty ?? false)
        ? user!.email!.trim()
        : 'SaaS Owner';

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      itemBuilder: (menuContext) => [
        PopupMenuItem(
          value: 'profile',
          child: const Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 18),
              SizedBox(width: AppSpacing.m),
              Text('Edit Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.danger(menuContext),
              ),
              const SizedBox(width: AppSpacing.m),
              Text(
                'Sign Out',
                style: TextStyle(color: AppColors.danger(menuContext)),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SuperAdminProfileScreen(),
              ),
            );
          case 'logout':
            handleSuperAdminLogout(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary(context),
              child: Text(
                _initialsOf(ownerLabel),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                'SaaS Owner',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  String _initialsOf(String label) {
    final parts = label
        .split(RegExp(r'[\s@.]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SO';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
