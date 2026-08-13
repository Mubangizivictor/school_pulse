import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_preferences.dart';

/// Delivery-channel and scheduling preferences for the SaaS Owner.
///
/// All toggles persist immediately to `super_admin_settings/{ownerId}` via
/// [OwnerNotificationService.savePreferences] and reload from the same
/// document, so a value never appears to "revert" after leaving the screen.
///
/// Critical categories (security, payment failure, platform outage) are
/// never offered as switches here - [OwnerNotificationPreferences] has no
/// field that could gate them, so there is nothing for this screen's
/// persistence logic to accidentally disable.
class OwnerNotificationPreferencesScreen extends StatefulWidget {
  const OwnerNotificationPreferencesScreen({super.key});

  @override
  State<OwnerNotificationPreferencesScreen> createState() =>
      _OwnerNotificationPreferencesScreenState();
}

class _OwnerNotificationPreferencesScreenState
    extends State<OwnerNotificationPreferencesScreen> {
  final OwnerNotificationService _service = OwnerNotificationService();
  bool _saving = false;

  String? get _ownerId => _service.currentOwnerId;

  /// Toggling Push on is the one explicit user action that's allowed to
  /// trigger the browser's notification-permission prompt on web (per the
  /// "never request at startup" requirement). If the owner declines, the
  /// preference is left off so the UI doesn't claim push is enabled when
  /// the browser will never actually deliver it.
  Future<void> _togglePush(
    OwnerNotificationPreferences prefs,
    bool value,
  ) async {
    if (kIsWeb && value) {
      final granted = await NotificationService().requestWebPushPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Browser notifications were blocked. Enable them in your '
                "browser's site settings to receive push alerts here.",
              ),
            ),
          );
        }
        return;
      }
    }
    await _save(prefs.copyWith(pushEnabled: value));
  }

  Future<void> _save(OwnerNotificationPreferences updated) async {
    setState(() => _saving = true);
    try {
      await _service.savePreferences(updated);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _friendlyError(Object error) {
    final value = error.toString();
    if (value.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (value.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    return 'Could not save your changes. Please try again.';
  }

  Future<void> _pickQuietHours(OwnerNotificationPreferences prefs) async {
    if (prefs.quietHoursConfigured) {
      final choice = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Change times'),
                onTap: () => Navigator.pop(sheetContext, 'change'),
              ),
              ListTile(
                title: const Text('Turn off quiet hours'),
                onTap: () => Navigator.pop(sheetContext, 'off'),
              ),
            ],
          ),
        ),
      );
      if (choice == 'off') {
        await _save(prefs.copyWith(clearQuietHours: true));
        return;
      }
      if (choice != 'change') return;
    }

    if (!mounted) return;
    final start = await showTimePicker(
      context: context,
      initialTime:
          prefs.quietHoursStart ?? const TimeOfDay(hour: 21, minute: 0),
      helpText: 'Quiet hours start',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: prefs.quietHoursEnd ?? const TimeOfDay(hour: 6, minute: 0),
      helpText: 'Quiet hours end',
    );
    if (end == null) return;

    await _save(prefs.copyWith(quietHoursStart: start, quietHoursEnd: end));
  }

  Future<void> _pickFrequency(OwnerNotificationPreferences prefs) async {
    final choice = await showModalBottomSheet<OwnerNotificationFrequency>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notification Frequency',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            for (final option in OwnerNotificationFrequency.values)
              ListTile(
                title: Text(_frequencyLabel(option)),
                subtitle: Text(_frequencyDescription(option)),
                trailing: option == prefs.frequency
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary(context),
                      )
                    : null,
                onTap: () => Navigator.pop(sheetContext, option),
              ),
          ],
        ),
      ),
    );
    if (choice != null) await _save(prefs.copyWith(frequency: choice));
  }

  static String _frequencyLabel(OwnerNotificationFrequency f) {
    switch (f) {
      case OwnerNotificationFrequency.realtime:
        return 'Real-time';
      case OwnerNotificationFrequency.hourlyDigest:
        return 'Hourly digest';
      case OwnerNotificationFrequency.dailyDigest:
        return 'Daily digest';
    }
  }

  static String _frequencyDescription(OwnerNotificationFrequency f) {
    switch (f) {
      case OwnerNotificationFrequency.realtime:
        return 'Deliver alerts as they happen';
      case OwnerNotificationFrequency.hourlyDigest:
        return 'Bundle non-critical alerts into one delivery per hour';
      case OwnerNotificationFrequency.dailyDigest:
        return 'Bundle non-critical alerts into one delivery per day';
    }
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = _ownerId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: ownerId == null
          ? const Center(child: Text('Sign in to manage notifications'))
          : StreamBuilder<OwnerNotificationPreferences>(
              stream: _service.watchPreferences(ownerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: SchoolPulseLoader());
                }
                final prefs =
                    snapshot.data ??
                    OwnerNotificationPreferences.defaults(ownerId);
                return _body(context, prefs);
              },
            ),
    );
  }

  Widget _body(BuildContext context, OwnerNotificationPreferences prefs) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          'Delivery Channels',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        _channelTile(
          context,
          icon: Icons.smartphone_outlined,
          title: 'In-App',
          subtitle: 'Show alerts in the owner notification center',
          value: prefs.inAppEnabled,
          onChanged: (value) => _save(prefs.copyWith(inAppEnabled: value)),
        ),
        _channelTile(
          context,
          icon: Icons.notifications_active_outlined,
          title: 'Push',
          subtitle: kIsWeb
              ? 'Send browser notifications to this device'
              : 'Send push notifications to this device',
          value: prefs.pushEnabled,
          onChanged: (value) => _togglePush(prefs, value),
        ),
        _channelTile(
          context,
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'Send a copy to the owner email address',
          value: prefs.emailEnabled,
          onChanged: (value) => _save(prefs.copyWith(emailEnabled: value)),
        ),
        const SizedBox(height: AppSpacing.l),
        AlertBanner(
          title: 'Critical alerts are always on',
          message:
              'Security alerts, payment failures and platform outages are '
              'delivered regardless of the channel settings above and cannot '
              'be turned off.',
          color: AppColors.information(context),
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: AppSpacing.x2l),
        Text(
          'Scheduling',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        _actionTile(
          context,
          icon: Icons.bedtime_outlined,
          title: 'Quiet Hours',
          value: prefs.quietHoursConfigured
              ? '${_formatTime(prefs.quietHoursStart!)} – ${_formatTime(prefs.quietHoursEnd!)}'
              : 'Off',
          onTap: () => _pickQuietHours(prefs),
        ),
        _actionTile(
          context,
          icon: Icons.schedule_outlined,
          title: 'Notification Frequency',
          value: _frequencyLabel(prefs.frequency),
          onTap: () => _pickFrequency(prefs),
        ),
      ],
    );
  }

  Widget _channelTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Icon(icon, color: AppColors.primary(context), size: 20),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: _saving ? null : onChanged),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: _saving ? null : onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Icon(icon, color: AppColors.primary(context), size: 20),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
