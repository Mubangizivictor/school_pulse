import 'package:flutter/material.dart';

import 'branding_settings_screen.dart';

class PlatformSettingsScreen extends StatelessWidget {
  const PlatformSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Platform Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle('General Settings'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Platform Information',
            subtitle: 'View and update platform details',
            color: const Color(0xFF818CF8),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Branding & Appearance',
            subtitle: 'Manage platform logo, colors, and theme',
            color: const Color(0xFFA855F7),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BrandingSettingsScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.tune_rounded,
            title: 'Default Settings',
            subtitle: 'Set default configurations for new schools',
            color: const Color(0xFFF59E0B),
          ),
          _buildMaintenanceModeTile(),
          const SizedBox(height: 24),
          _buildSectionTitle('Communication'),
          _buildSettingsTile(
            context,
            icon: Icons.email_outlined,
            title: 'Email Settings',
            subtitle: 'Configure email templates and settings',
            color: const Color(0xFF3B82F6),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.sms_outlined,
            title: 'SMS Settings',
            subtitle: 'Configure SMS gateways and templates',
            color: const Color(0xFF06B6D4),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Push Notifications',
            subtitle: 'Manage push notification settings',
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Policies & Legal'),
          _buildSettingsTile(
            context,
            icon: Icons.gavel_rounded,
            title: 'Terms & Conditions',
            subtitle: 'Manage platform terms and conditions',
            color: const Color(0xFF6366F1),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Manage privacy policy',
            color: const Color(0xFF10B981),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.storage_rounded,
            title: 'Data Retention Policy',
            subtitle: 'Configure data retention rules',
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
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
          borderRadius: BorderRadius.circular(16),
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

  Widget _buildMaintenanceModeTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maintenance Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Enable or disable maintenance mode',
                  style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: false,
            onChanged: (val) {},
            activeThumbColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
