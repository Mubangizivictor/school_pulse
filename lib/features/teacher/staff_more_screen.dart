import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffMoreScreen extends StatelessWidget {
  const StaffMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String name = 'Staff Member';
    String role = 'Department';
    String? profileImageUrl;

    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      role = authState.user.role.name;
      // In a real app, you'd get the actual image URL
      profileImageUrl = 'https://i.pravatar.cc/150?img=47';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                  backgroundColor: const Color(0xFF151929),
                  child: profileImageUrl == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context.push('/staff/profile'),
                        child: Text(
                          'Edit Profile',
                          style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('ACCOUNT'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              onTap: () => context.push('/staff/profile'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () => context.push('/staff/notifications'),
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Security & Privacy',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('SCHOOL'),
            _buildMenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'School Calendar',
              onTap: () => context.push('/staff/calendar'),
            ),
            _buildMenuItem(
              icon: Icons.campaign_outlined,
              title: 'Announcements',
              onTap: () => context.push('/staff/more/announcements'),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'School Directory',
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('SETTINGS'),
            _buildMenuItem(
              icon: Icons.language,
              title: 'Language',
              trailing: 'English',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              isToggle: true,
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('SUPPORT'),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
            
            const SizedBox(height: 32),
            // Logout Button
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: InkWell(
                onTap: () => _handleLogout(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D161A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5E262D)),
                  ),
                  child: Center(
                    child: Text(
                      'Logout',
                      style: AppTypography.labelLarge.copyWith(
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: const Color(0xFF64748B),
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailing,
    bool isToggle = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151929),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isToggle 
          ? Switch.adaptive(
              value: true, 
              onChanged: (v) {},
              activeColor: const Color(0xFF3B82F6),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null)
                  Text(
                    trailing,
                    style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B)),
                  ),
                const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
              ],
            ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151929),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    }
  }
}
