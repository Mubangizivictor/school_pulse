import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'General'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () => context.push('/staff/more/settings/notifications'),
                ),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'App Theme',
                  trailing: Text(
                    'Dark',
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
                  ),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Offline'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.sync_rounded,
                  title: 'Offline Sync',
                  trailing: Switch.adaptive(value: true, onChanged: (v) {}),
                ),
                _SettingsTile(
                  icon: Icons.storage_rounded,
                  title: 'Storage Usage',
                  trailing: Text(
                    '43.2 MB',
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Privacy & Security'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  onTap: () => context.push('/staff/more/settings/change-password'),
                ),
                _SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric / PIN',
                  trailing: Text(
                    'ON',
                    style: TextStyle(color: AppColors.primary(context), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          AppCard(
            padding: EdgeInsets.zero,
            child: _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              trailing: Text(
                'v.2.1.0',
                style: TextStyle(color: AppColors.textMuted(context), fontSize: 13),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.textPrimary(context), size: 22),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: onTap,
          dense: true,
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
