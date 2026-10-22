import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../../domain/entities/notification_model.dart';
import 'notification_test_service.dart';

/// Authorised notification delivery test screen.
///
/// Deliberately loud about being a test tool: every notification it sends is
/// prefixed `[TEST]`, and the screen carries a persistent banner. It can only
/// ever reach the signed-in user's own devices - the Cloud Function behind
/// [NotificationTestService.sendPush] targets the caller's tokens and verifies
/// their school, so there is no path from here to a school-wide broadcast.
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  NotificationCategory _category = NotificationCategory.announcements;
  NotificationPriority _priority = NotificationPriority.medium;
  bool _withImage = false;
  bool _respectPreferences = false;

  final List<_LogEntry> _log = [];
  bool _busy = false;

  static const _testImageUrl =
      'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800';

  UserEntity? get _user {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  void _record(String label, bool success, String message) {
    if (!mounted) return;
    setState(() {
      _log.insert(
        0,
        _LogEntry(label: label, success: success, detail: message),
      );
      if (_log.length > 20) _log.removeLast();
    });
  }

  /// Runs [action] with the busy flag set, so a slow network call cannot be
  /// fired twice by an impatient second tap.
  Future<void> _run(
    String label,
    Future<TestDeliveryResult> Function() action,
  ) async {
    if (_busy) return;
    final user = _user;
    if (user == null) {
      _record(label, false, 'Not signed in.');
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await action();
      _record(label, result.success, result.message);
    } catch (e) {
      _record(label, false, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  NotificationTestService get _service => di.sl<NotificationTestService>();

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notification delivery test',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _TestModeBanner(),
          const SizedBox(height: 16),

          if (user == null)
            const _Card(
              child: Text(
                'Sign in to run delivery tests.',
                style: TextStyle(color: Colors.white),
              ),
            )
          else ...[
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Notification shape'),
                  const SizedBox(height: 12),
                  _categoryDropdown(),
                  const SizedBox(height: 12),
                  _priorityDropdown(),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _withImage,
                    onChanged: (v) => setState(() => _withImage = v),
                    title: const Text(
                      'Include image',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Tests big-picture style and Data Saver behaviour',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _respectPreferences,
                    onChanged: (v) => setState(() => _respectPreferences = v),
                    title: const Text(
                      'Apply my preferences',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Verifies quiet hours and category mutes actually suppress',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Local rendering'),
                  const SizedBox(height: 4),
                  const Text(
                    'Renders through the same presenter push uses. Proves '
                    'channels, images, sound and redaction work on this device '
                    '- but does NOT prove FCM delivery.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _TestButton(
                    label: 'Show local notification',
                    icon: Icons.notifications_active,
                    enabled: !_busy,
                    onPressed: () => _run(
                      'Local notification',
                      () => _service.showLocal(
                        schoolId: user.schoolId,
                        userId: user.id,
                        category: _category,
                        priority: _priority,
                        imageUrl: _withImage ? _testImageUrl : null,
                        respectPreferences: _respectPreferences,
                        requiresAcknowledgment:
                            _category == NotificationCategory.emergency,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TestButton(
                    label: 'Schedule in 15 seconds',
                    icon: Icons.schedule,
                    enabled: !_busy,
                    onPressed: () =>
                        _run('Scheduled local', () => _service.scheduleLocal()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Real push (end to end)'),
                  const SizedBox(height: 4),
                  const Text(
                    'Sends through FCM to your own registered devices only. '
                    'Run this three times: app open, app backgrounded, and app '
                    'fully closed.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _TestButton(
                    label: 'Send real push to my devices',
                    icon: Icons.cloud_upload,
                    primary: true,
                    enabled: !_busy,
                    onPressed: () => _run(
                      'Real push',
                      () => _service.sendPush(
                        schoolId: user.schoolId,
                        category: _category,
                        priority: _priority,
                        imageUrl: _withImage ? _testImageUrl : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Housekeeping'),
                  const SizedBox(height: 12),
                  _TestButton(
                    label: 'Dismiss all notifications',
                    icon: Icons.clear_all,
                    enabled: !_busy,
                    onPressed: () async {
                      await _service.dismissAll();
                      _record('Dismiss all', true, 'Cleared the tray.');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_log.isNotEmpty) _logCard(),
          ],
        ],
      ),
    );
  }

  Widget _logCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Results'),
          const SizedBox(height: 8),
          ..._log.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    entry.success ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: entry.success ? Colors.black : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          entry.detail,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryDropdown() {
    // Only the categories worth exercising by hand; the full catalogue would
    // make the picker unusable.
    const options = [
      NotificationCategory.announcements,
      NotificationCategory.attendance,
      NotificationCategory.finance,
      NotificationCategory.messages,
      NotificationCategory.medical,
      NotificationCategory.transport,
      NotificationCategory.emergency,
    ];

    return DropdownButtonFormField<NotificationCategory>(
      initialValue: _category,
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white),
      decoration: _fieldDecoration('Category'),
      items: options
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _category = value);
      },
    );
  }

  Widget _priorityDropdown() {
    return DropdownButtonFormField<NotificationPriority>(
      initialValue: _priority,
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white),
      decoration: _fieldDecoration('Priority'),
      items: NotificationPriority.values
          .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _priority = value);
      },
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}

class _LogEntry {
  final String label;
  final bool success;
  final String detail;

  const _LogEntry({
    required this.label,
    required this.success,
    required this.detail,
  });
}

/// Persistent reminder that this screen sends real notifications.
class _TestModeBanner extends StatelessWidget {
  const _TestModeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          const Icon(Icons.science, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test mode',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  kReleaseMode
                      ? 'Notifications sent from here reach only your own devices.'
                      : 'Debug build. Notifications reach only your own devices.',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;
  final bool enabled;

  const _TestButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? Colors.black : Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
