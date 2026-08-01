import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherNotificationSettingsScreen extends StatelessWidget {
  const TeacherNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Switch.adaptive(
                  value: true,
                  onChanged: (v) {},
                  activeColor: AppColors.primary(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notification Types',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _NotificationToggleTile(title: 'Announcements', value: true),
                _NotificationToggleTile(title: 'Messages', value: true),
                _NotificationToggleTile(title: 'Homework & Tasks', value: true),
                _NotificationToggleTile(title: 'Attendance Alerts', value: false),
                _NotificationToggleTile(title: 'Reports & Results', value: true),
                _NotificationToggleTile(title: 'Leave Requests', value: true),
                _NotificationToggleTile(title: 'General Notifications', value: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  final String title;
  final bool value;

  const _NotificationToggleTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          trailing: Switch.adaptive(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.primary(context),
          ),
          dense: true,
        ),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
