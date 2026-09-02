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

/// Delivery-channel, category and scheduling preferences for the SaaS
/// Owner.
///
/// All reads and writes go through the owner-only preference callables
/// (`getOwnerNotificationPreferences` / `updateOwnerNotificationPreferences`)
/// via [OwnerNotificationService] - never a direct Firestore write. The
/// backing document is Admin-SDK-only, so this screen is pull-based: it
/// loads once, and re-applies the server's sanitised result after every
/// successful save so a value never appears to "revert".
///
/// Critical categories (security, payment failure, platform outage) are
/// never offered as switches here - [OwnerNotificationPreferences] has no
/// field that could gate them.
class OwnerNotificationPreferencesScreen extends StatefulWidget {
  const OwnerNotificationPreferencesScreen({super.key, this.service});

  /// Injectable for tests; production uses the default [OwnerNotificationService].
  final OwnerNotificationService? service;

  @override
  State<OwnerNotificationPreferencesScreen> createState() =>
      _OwnerNotificationPreferencesScreenState();
}

class _OwnerNotificationPreferencesScreenState
    extends State<OwnerNotificationPreferencesScreen> {
  late final OwnerNotificationService _service =
      widget.service ?? OwnerNotificationService();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  OwnerNotificationPreferences? _prefs;

  String? get _ownerId => _service.currentOwnerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ownerId = _ownerId;
    if (ownerId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await _service.getPreferences(ownerId);
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

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
    setState(() {
      _saving = true;
      // Optimistic: reflect the change immediately, reconcile with the
      // server's sanitised copy when the callable returns.
      _prefs = updated;
    });
    try {
      final saved = await _service.savePreferences(updated);
      if (mounted) setState(() => _prefs = saved);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
      // Roll back to the server's truth on failure.
      await _load();
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
    if (value.contains('not-found')) {
      return 'The notification backend has not been deployed yet.';
    }
    return 'Could not save your changes. Please try again.';
  }

  Future<void> _pickQuietHours(OwnerNotificationPreferences prefs) async {
    if (prefs.quietHoursEnabled) {
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
        await _save(prefs.copyWith(quietHoursEnabled: false));
        return;
      }
      if (choice != 'change') return;
    }

    if (!mounted) return;
    final start = await showTimePicker(
      context: context,
      initialTime: prefs.quietHoursStart,
      helpText: 'Quiet hours start',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: prefs.quietHoursEnd,
      helpText: 'Quiet hours end',
    );
    if (end == null) return;

    await _save(
      prefs.copyWith(
        quietHoursEnabled: true,
        quietHoursStart: start,
        quietHoursEnd: end,
      ),
    );
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
                subtitle: Text(_frequencyDescription(option, prefs)),
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
      case OwnerNotificationFrequency.dailyDigest:
        return 'Daily digest';
    }
  }

  static String _frequencyDescription(
    OwnerNotificationFrequency f,
    OwnerNotificationPreferences prefs,
  ) {
    switch (f) {
      case OwnerNotificationFrequency.realtime:
        return 'Deliver alerts as they happen';
      case OwnerNotificationFrequency.dailyDigest:
        return prefs.dailyDigestDelivered
            ? 'Bundle non-critical alerts into one delivery per day'
            : 'Saved as your preference; delivered in real time until digest '
                  'sending is switched on';
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
          : _loading
          ? const Center(child: SchoolPulseLoader())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _load)
          : _body(context, _prefs ?? OwnerNotificationPreferences.defaults(ownerId)),
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
          subtitle: 'Always on – the owner notification centre is the '
              'durable record and is never silenced',
          value: true,
          onChanged: null,
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
          'Categories',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        _channelTile(
          context,
          icon: Icons.school_outlined,
          title: 'School applications',
          subtitle: 'New schools applying to join the platform',
          value: prefs.schoolApplicationAlerts,
          onChanged: (v) => _save(prefs.copyWith(schoolApplicationAlerts: v)),
        ),
        _channelTile(
          context,
          icon: Icons.payments_outlined,
          title: 'Payments',
          subtitle: 'Manual subscription payments awaiting verification',
          value: prefs.paymentAlerts,
          onChanged: (v) => _save(prefs.copyWith(paymentAlerts: v)),
        ),
        _channelTile(
          context,
          icon: Icons.receipt_long_outlined,
          title: 'Billing',
          subtitle: 'Renewals, plan changes and billing events',
          value: prefs.billingAlerts,
          onChanged: (v) => _save(prefs.copyWith(billingAlerts: v)),
        ),
        _channelTile(
          context,
          icon: Icons.insights_outlined,
          title: 'Platform activity',
          subtitle: 'Other non-critical platform events',
          value: prefs.platformActivityAlerts,
          onChanged: (v) => _save(prefs.copyWith(platformActivityAlerts: v)),
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
          value: prefs.quietHoursEnabled
              ? '${_formatTime(prefs.quietHoursStart)} – ${_formatTime(prefs.quietHoursEnd)}'
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
    required ValueChanged<bool>? onChanged,
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
          Switch(
            value: value,
            onChanged: (_saving || onChanged == null) ? null : onChanged,
          ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
