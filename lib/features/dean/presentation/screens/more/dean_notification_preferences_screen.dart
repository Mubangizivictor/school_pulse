import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class DeanNotificationPreferencesScreen extends StatefulWidget {
  const DeanNotificationPreferencesScreen({super.key});

  @override
  State<DeanNotificationPreferencesScreen> createState() =>
      _DeanNotificationPreferencesScreenState();
}

class _DeanNotificationPreferencesScreenState
    extends State<DeanNotificationPreferencesScreen> {
  bool _missedLessons = true;
  bool _overdueMarks = true;
  bool _moderationRequests = true;
  bool _interventionReminders = true;
  bool _academicMeetings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildToggle(
            context,
            'Missed lessons',
            'Alert when a scheduled lesson is not delivered',
            _missedLessons,
            (v) => setState(() => _missedLessons = v),
          ),
          _buildToggle(
            context,
            'Overdue marks',
            'Alert when marks entry passes its deadline',
            _overdueMarks,
            (v) => setState(() => _overdueMarks = v),
          ),
          _buildToggle(
            context,
            'Moderation requests',
            'Alert when marks are submitted for your review',
            _moderationRequests,
            (v) => setState(() => _moderationRequests = v),
          ),
          _buildToggle(
            context,
            'Intervention reminders',
            'Alert when an intervention is due for follow-up',
            _interventionReminders,
            (v) => setState(() => _interventionReminders = v),
          ),
          _buildToggle(
            context,
            'Academic meetings',
            'Alert before scheduled academic meetings',
            _academicMeetings,
            (v) => setState(() => _academicMeetings = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
