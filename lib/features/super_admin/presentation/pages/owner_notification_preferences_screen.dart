import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_preferences.dart';

/// SaaS Owner "Notification settings" — an owner-only nested route under
/// Settings, with the persistent owner bottom navigation still visible.
///
/// Compact grouped rows matching the redesign:
///   Delivery      · In-app · Push
///   Categories    · Payments · Platform health · Schools · Security ·
///                   Weekly digest
///   Preferences   · Quiet hours · Digest frequency
///
/// One compact blue "Save preferences" button, shown only when a change is
/// pending. All reads/writes go through the owner-only preference callables
/// via [OwnerNotificationService].
class OwnerNotificationPreferencesScreen extends StatefulWidget {
  const OwnerNotificationPreferencesScreen({super.key, this.service});

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

  OwnerNotificationPreferences? _saved;
  OwnerNotificationPreferences? _draft;

  String? get _ownerId => _service.currentOwnerId;
  bool get _dirty =>
      _saved != null && _draft != null && !_saved!.sameAs(_draft!);

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
        _saved = prefs;
        _draft = prefs;
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

  void _update(OwnerNotificationPreferences next) =>
      setState(() => _draft = next);

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    setState(() => _saving = true);
    try {
      final result = await _service.savePreferences(draft);
      if (mounted) {
        setState(() {
          _saved = result;
          _draft = result;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _togglePush(bool value) async {
    final draft = _draft;
    if (draft == null) return;
    if (kIsWeb && value) {
      final granted = await NotificationService().requestWebPushPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Browser notifications were blocked. Enable them in your '
                "browser's site settings.",
              ),
            ),
          );
        }
        return;
      }
    }
    _update(draft.copyWith(pushEnabled: value));
  }

  String _friendlyError(Object error) {
    final v = error.toString();
    if (v.contains('permission-denied')) {
      return 'Only the School Pulse SaaS Owner can change these settings.';
    }
    if (v.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    if (v.contains('not-found')) {
      return 'The owner notification backend is not deployed yet.';
    }
    return 'Could not save your changes. Please try again.';
  }

  static String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        title: const Text('Notification settings'),
      ),
      body: _ownerId == null
          ? const Center(child: Text('Sign in to manage notifications'))
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _ErrorState(message: _error!, onRetry: _load)
                  : _body(context, _draft!),
    );
  }

  Widget _body(BuildContext context, OwnerNotificationPreferences p) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _sectionLabel('DELIVERY'),
              _group([
                _switchRow(
                  'In-app notifications',
                  p.inAppEnabled,
                  (v) => _update(p.copyWith(inAppEnabled: v)),
                ),
                _divider(),
                _switchRow(
                  'Push notifications',
                  p.pushEnabled,
                  (v) => _togglePush(v),
                ),
              ]),
              const SizedBox(height: 18),
              _sectionLabel('CATEGORIES'),
              _group([
                _switchRow(
                  'Payments',
                  p.paymentAlerts,
                  (v) => _update(p.copyWith(paymentAlerts: v)),
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.warning(context),
                ),
                _divider(),
                _switchRow(
                  'Platform health',
                  p.platformHealthAlerts,
                  (v) => _update(p.copyWith(platformHealthAlerts: v)),
                  icon: Icons.monitor_heart_rounded,
                  iconColor: AppColors.danger(context),
                ),
                _divider(),
                _switchRow(
                  'Schools',
                  p.schoolAlerts,
                  (v) => _update(p.copyWith(schoolAlerts: v)),
                  icon: Icons.school_rounded,
                  iconColor: AppColors.information(context),
                ),
                _divider(),
                _switchRow(
                  'Security',
                  p.securityAlerts,
                  (v) => _update(p.copyWith(securityAlerts: v)),
                  icon: Icons.shield_rounded,
                  iconColor: AppColors.success(context),
                ),
                _divider(),
                _switchRow(
                  'Weekly digest',
                  p.weeklyDigestEnabled,
                  (v) => _update(p.copyWith(weeklyDigestEnabled: v)),
                  icon: Icons.summarize_rounded,
                  iconColor: AppColors.textMuted(context),
                ),
              ]),
              const SizedBox(height: 18),
              _sectionLabel('QUIET HOURS'),
              _group([
                _navRow(
                  'Quiet hours',
                  p.quietHoursEnabled
                      ? '${_fmtTime(p.quietHoursStart)} – ${_fmtTime(p.quietHoursEnd)}'
                      : 'Off',
                  () => _pickQuietHours(p),
                  icon: Icons.bedtime_outlined,
                ),
              ]),
              const SizedBox(height: 18),
              _sectionLabel('DIGEST FREQUENCY'),
              _group([
                _navRow(
                  'Digest frequency',
                  p.frequency == OwnerNotificationFrequency.dailyDigest
                      ? 'Daily'
                      : 'Weekly',
                  () => _pickFrequency(p),
                  icon: Icons.mail_outline_rounded,
                ),
              ]),
              const SizedBox(height: 16),
              _PrivacyCard(),
            ],
          ),
        ),
        if (_dirty)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.information(context),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save preferences',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickQuietHours(OwnerNotificationPreferences p) async {
    if (p.quietHoursEnabled) {
      final choice = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Change times'),
                onTap: () => Navigator.pop(ctx, 'change'),
              ),
              ListTile(
                title: const Text('Turn off quiet hours'),
                onTap: () => Navigator.pop(ctx, 'off'),
              ),
            ],
          ),
        ),
      );
      if (choice == 'off') {
        _update(p.copyWith(quietHoursEnabled: false));
        return;
      }
      if (choice != 'change') return;
    }
    if (!mounted) return;
    final start = await showTimePicker(
      context: context,
      initialTime: p.quietHoursStart,
      helpText: 'Quiet hours start',
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: p.quietHoursEnd,
      helpText: 'Quiet hours end',
    );
    if (end == null) return;
    _update(p.copyWith(
      quietHoursEnabled: true,
      quietHoursStart: start,
      quietHoursEnd: end,
    ));
  }

  Future<void> _pickFrequency(OwnerNotificationPreferences p) async {
    final choice = await showModalBottomSheet<OwnerNotificationFrequency>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in OwnerNotificationFrequency.values)
              ListTile(
                title: Text(
                  f == OwnerNotificationFrequency.dailyDigest
                      ? 'Daily'
                      : 'Weekly',
                ),
                trailing: f == p.frequency
                    ? Icon(Icons.check_rounded,
                        color: AppColors.information(context))
                    : null,
                onTap: () => Navigator.pop(ctx, f),
              ),
          ],
        ),
      ),
    );
    if (choice != null) _update(p.copyWith(frequency: choice));
  }

  // --- compact row primitives ------------------------------------------

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textMuted(context),
          ),
        ),
      );

  Widget _group(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border(context),
      );

  Widget _switchRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: _saving ? null : onChanged,
            activeTrackColor: AppColors.information(context),
          ),
        ],
      ),
    );
  }

  Widget _navRow(
    String title,
    String value,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: _saving ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.textSecondary(context)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.information(context).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.information(context).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.information(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Owner notifications are private to Super Admin devices.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
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
              color: AppColors.danger(context),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
