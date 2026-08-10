import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () =>
                context.push('/staff/more/security-privacy/change-password'),
          ),
          _Tile(
            icon: Icons.verified_user_outlined,
            title: 'Two-Factor Authentication',
            onTap: () =>
                context.push('/staff/more/security-privacy/two-factor'),
          ),
          _Tile(
            icon: Icons.devices_outlined,
            title: 'Active Sessions',
            onTap: () =>
                context.push('/staff/more/security-privacy/active-sessions'),
          ),
          _Tile(
            icon: Icons.timeline_outlined,
            title: 'Account Activity',
            onTap: () =>
                context.push('/staff/more/security-privacy/account-activity'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.primary(context)),
          title: Text(
            title,
            style: TextStyle(color: AppColors.textPrimary(context)),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textMuted(context),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
