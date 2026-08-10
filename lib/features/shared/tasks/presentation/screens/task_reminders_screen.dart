import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TaskRemindersScreen extends StatefulWidget {
  const TaskRemindersScreen({super.key});

  @override
  State<TaskRemindersScreen> createState() => _TaskRemindersScreenState();
}

class _TaskRemindersScreenState extends State<TaskRemindersScreen> {
  bool _enableReminders = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  double _reminderMinutes = 15;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        title: const Text('Task Reminders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(context, 'Global Settings', [
            _buildSwitchTile(
              context,
              'Enable Reminders',
              'Get notified before tasks are due',
              _enableReminders,
              (v) => setState(() => _enableReminders = v),
            ),
          ]),
          const SizedBox(height: 24),
          if (_enableReminders) ...[
            _buildSection(context, 'Notification Methods', [
              _buildSwitchTile(
                context,
                'Push Notifications',
                'Instant alerts on your device',
                _pushNotifications,
                (v) => setState(() => _pushNotifications = v),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildSwitchTile(
                context,
                'Email Notifications',
                'Daily summary of tasks',
                _emailNotifications,
                (v) => setState(() => _emailNotifications = v),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection(context, 'Reminder Timing', [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remind me',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_reminderMinutes.toInt()} minutes before',
                          style: TextStyle(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _reminderMinutes,
                      min: 5,
                      max: 60,
                      divisions: 11,
                      activeColor: AppColors.primary(context),
                      onChanged: (v) => setState(() => _reminderMinutes = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5m',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '60m',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Save Changes',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder settings saved')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderColor: isDark ? AppColors.borderDark : AppColors.borderLight,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary(context),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
      ),
    );
  }
}
