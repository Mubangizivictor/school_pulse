import 'package:flutter/material.dart';
import '../widgets/super_admin_logout_button.dart';
import 'platform_settings_screen.dart';
import 'feature_management_screen.dart';
import 'users_roles_screen.dart';
import 'api_management_screen.dart';
import 'security_center_screen.dart';
import 'system_health_screen.dart';
import 'support_tickets_screen.dart';
import 'data_export_screen.dart';
import 'announcements_screen.dart';

class SuperAdminMoreScreen extends StatelessWidget {
  const SuperAdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildTitleSection(context),
          const SizedBox(height: 24),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _buildMoreTile(
                context,
                icon: Icons.settings_rounded,
                title: 'Platform Settings',
                subtitle: 'Configure global platform settings',
                color: const Color(0xFF818CF8),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlatformSettingsScreen(),
                  ),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.extension_rounded,
                title: 'Feature Management',
                subtitle: 'Manage modules and features',
                color: const Color(0xFF3B82F6),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeatureManagementScreen(),
                  ),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.people_alt_rounded,
                title: 'Users & Roles',
                subtitle: 'Manage platform users and roles',
                color: const Color(0xFF10B981),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersRolesScreen()),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.api_rounded,
                title: 'API Management',
                subtitle: 'Manage API keys and integrations',
                color: const Color(0xFFF59E0B),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ApiManagementScreen(),
                  ),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.security_rounded,
                title: 'Security Center',
                subtitle: 'Security settings and controls',
                color: const Color(0xFFEF4444),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SecurityCenterScreen(),
                  ),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.monitor_heart_rounded,
                title: 'System Health',
                subtitle: 'Monitor system performance',
                color: const Color(0xFF06B6D4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SystemHealthScreen()),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.cloud_download_rounded,
                title: 'Data & Export',
                subtitle: 'Export data and reports',
                color: const Color(0xFFEC4899),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DataExportScreen()),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.headset_mic_rounded,
                title: 'Support & Tickets',
                subtitle: 'Manage support tickets',
                color: const Color(0xFFF97316),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportTicketsScreen(),
                  ),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.campaign_rounded,
                title: 'Announcements',
                subtitle: 'Send platform-wide announcements',
                color: const Color(0xFF6366F1),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementsScreen(),
                  ),
                ),
              ),
              _buildMoreTile(
                context,
                icon: Icons.description_rounded,
                title: 'Documentation',
                subtitle: 'View guides and documentation',
                color: const Color(0xFF94A3B8),
              ),
              _buildMoreTile(
                context,
                icon: Icons.info_rounded,
                title: 'About School Pulse',
                subtitle: 'Platform information and updates',
                color: const Color(0xFF64748B),
              ),
              const SizedBox(height: 12),
              _buildMoreTile(
                context,
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                color: const Color(0xFFEF4444),
                onTap: () => handleSuperAdminLogout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More Hub',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Settings & Configuration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
