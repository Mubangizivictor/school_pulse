import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

/// The Bursar desktop console top bar: a `Finance / <section>` breadcrumb,
/// a global search field (⌘K / Ctrl-K focuses it; submit routes to
/// Students & fees / Approvals with the query), a term/year pill, the
/// messages icon + notification bell (both carrying their own live unread
/// badge, the same widgets the staff dashboards use), and a profile menu
/// with a theme toggle and Sign out.
///
/// Generalises `SuperAdminTopBar` for the finance module. Mono only.
class BursarTopBar extends StatefulWidget implements PreferredSizeWidget {
  final String sectionLabel;
  final String termLabel;

  const BursarTopBar({
    super.key,
    required this.sectionLabel,
    required this.termLabel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<BursarTopBar> createState() => _BursarTopBarState();
}

class _BursarTopBarState extends State<BursarTopBar> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _submitSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    // Route to the section most likely to answer it.
    final looksLikeVoucher = RegExp(
      r'(pv|rcp|inv)[- ]',
      caseSensitive: false,
    ).hasMatch(query);
    context.go(
      looksLikeVoucher
          ? '/staff/bursar/approvals?q=${Uri.encodeComponent(query)}'
          : '/staff/bursar/students?q=${Uri.encodeComponent(query)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          _Breadcrumb(section: widget.sectionLabel),
          const SizedBox(width: 28),
          Expanded(child: _buildSearch(context)),
          const SizedBox(width: 20),
          _TermPill(label: widget.termLabel),
          const SizedBox(width: 16),
          _circle(
            context,
            child: const MessagesNavIcon(
              icon: Icons.chat_bubble_outline_rounded,
              size: 18,
            ),
            onTap: () => context.push('/staff/messages'),
          ),
          const SizedBox(width: 8),
          _circle(context, child: const NotificationBellButton()),
          const SizedBox(width: 8),
          const _ProfileMenu(),
        ],
      ),
    );
  }

  Widget _circle(
    BuildContext context, {
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
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
            onSubmitted: _submitSearch,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'Search student, receipt or voucher',
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted(context),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.textSecondary(context),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  widthFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer(context),
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Text(
                      '⌘K',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ),
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceElevated(context),
              isDense: true,
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

class _Breadcrumb extends StatelessWidget {
  final String section;
  const _Breadcrumb({required this.section});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Finance',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '/',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted(context)),
          ),
        ),
        Text(
          section,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class _TermPill extends StatelessWidget {
  final String label;
  const _TermPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated ? auth.user.name : 'Bursar';
    final initials = name.trim().isEmpty
        ? 'B'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join();
    final themeProvider = context.watch<ThemeProvider>();
    final (themeIcon, themeLabel) = switch (themeProvider.themeMode) {
      ThemeMode.light => (Icons.light_mode_rounded, 'Theme: Light'),
      ThemeMode.dark => (Icons.dark_mode_rounded, 'Theme: Dark'),
      ThemeMode.system => (Icons.brightness_auto_rounded, 'Theme: System'),
    };

    return PopupMenuButton<String>(
      tooltip: name,
      offset: const Offset(0, 44),
      onSelected: (v) {
        switch (v) {
          case 'theme':
            final next = switch (themeProvider.themeMode) {
              ThemeMode.light => ThemeMode.dark,
              ThemeMode.dark => ThemeMode.system,
              ThemeMode.system => ThemeMode.light,
            };
            themeProvider.setThemeMode(next);
          case 'messages':
            context.push('/staff/messages');
          case 'logout':
            context.read<AuthBloc>().add(LogoutPressed());
            context.go('/welcome');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              Icon(themeIcon, size: 16),
              const SizedBox(width: 10),
              Text(themeLabel),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'messages',
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 16),
              SizedBox(width: 10),
              Text('Messages'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 16,
                color: AppColors.danger(context),
              ),
              const SizedBox(width: 10),
              Text(
                'Sign out',
                style: TextStyle(color: AppColors.danger(context)),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary(context),
        ),
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.background(context),
          ),
        ),
      ),
    );
  }
}
