import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffMoreScreen extends StatelessWidget {
  const StaffMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('More'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _buildProfileHeader(context, authState),
          const SizedBox(height: 24),
          Text(
            'More Options:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MoreMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  onTap: () => context.push('/staff/profile'),
                ),
                _MoreMenuItem(
                  icon: Icons.menu_book_outlined,
                  title: 'My Subjects',
                  onTap: () => context.push('/staff/more/subjects'),
                ),
                _MoreMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Timetable',
                  onTap: () => context.push('/staff/more/timetable'),
                ),
                _MoreMenuItem(
                  icon: Icons.campaign_outlined,
                  title: 'Announcements',
                  onTap: () => context.push('/staff/more/announcements'),
                ),
                _MoreMenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Messages',
                  onTap: () => context.push('/staff/messages'),
                ),
                _MoreMenuItem(
                  icon: Icons.assignment_outlined,
                  title: 'Homework Center',
                  onTap: () => context.push('/staff/homework'),
                ),
                _MoreMenuItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'Reports',
                  onTap: () => context.push('/staff/reports'),
                ),
                _MoreMenuItem(
                  icon: Icons.file_download_outlined,
                  title: 'Downloads',
                  onTap: () => context.push('/staff/more/downloads'),
                ),
                _MoreMenuItem(
                  icon: Icons.event_busy_outlined,
                  title: 'Leave Requests',
                  onTap: () => context.push('/staff/more/leave-requests'),
                ),
                _MoreMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => context.push('/staff/more/settings'),
                ),
                _MoreMenuItem(
                  icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  title: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  onTap: () {
                    final provider = context.read<ThemeProvider>();
                    provider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () => context.push('/staff/more/support'),
                ),
                _MoreMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About School Pulse',
                  onTap: () => context.push('/staff/more/about'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: Icon(Icons.logout_rounded, color: AppColors.danger(context)),
              label: Text(
                'Logout',
                style: TextStyle(color: AppColors.danger(context), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.danger(context)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: AppColors.danger(context))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    }
  }

  Widget _buildProfileHeader(BuildContext context, AuthState state) {
    String name = 'Mrs. Achieng Mary';
    String role = 'Class Teacher - P3 East';
    
    if (state is AuthAuthenticated) {
      name = state.user.name;
      role = '${state.user.role.name} ${state.user.assignedClass != null ? "- ${state.user.assignedClass}" : ""}';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary(context).withValues(alpha: 0.1),
          child: Icon(Icons.person, size: 40, color: AppColors.primary(context)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/staff/profile'),
                child: Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.textPrimary(context), size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: onTap,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        Divider(
          height: 1,
          indent: 56,
          endIndent: 16,
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
