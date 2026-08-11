import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_category_config.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_preferences.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notification_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  /// The categories offered as switches. Same seven the screen always showed,
  /// now backed by the real category enum rather than display strings.
  static const _categories = <NotificationCategory>[
    NotificationCategory.announcements,
    NotificationCategory.attendance,
    NotificationCategory.finance,
    NotificationCategory.transport,
    NotificationCategory.homework,
    NotificationCategory.library,
    NotificationCategory.messages,
  ];

  NotificationPreferences? _preferences;
  SchoolNotificationPolicy? _policy;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  UserEntity? get _user {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  NotificationRepository get _repository => di.sl<NotificationRepository>();

  Future<void> _load() async {
    final user = _user;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final prefsResult = await _repository.getPreferences(
      schoolId: user.schoolId,
      userId: user.id,
    );
    final policyResult = await _repository.getSchoolPolicy(user.schoolId);

    if (!mounted) return;
    setState(() {
      _preferences = prefsResult.fold(
        (_) => NotificationPreferences.defaults(
          userId: user.id,
          schoolId: user.schoolId,
        ),
        (prefs) => prefs,
      );
      _policy = policyResult.fold((_) => null, (policy) => policy);
      _loading = false;
    });
  }

  /// Persists [updated] optimistically, restoring the previous value if the
  /// save fails - a switch that silently springs back with no explanation is
  /// worse than one that never moved.
  Future<void> _save(NotificationPreferences updated) async {
    final previous = _preferences;
    setState(() {
      _preferences = updated;
      _saving = true;
    });

    final result = await _repository.savePreferences(updated);

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold((failure) {
      setState(() => _preferences = previous);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }, (_) => null);
  }

  /// Whether [category] may be switched off at all.
  ///
  /// Safety and legally-required categories stay on regardless of preference,
  /// so a parent cannot mute an emergency or attendance alert.
  bool _isMandatory(NotificationCategory category) {
    if (NotificationCategoryCatalog.of(category).isMandatory) return true;
    return _policy?.mandatoryCategories.contains(category) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notification Preferences',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: SchoolPulseLoader())
          : _preferences == null
          ? const Center(
              child: Text(
                'Sign in to manage your notification preferences',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : _buildBody(_preferences!),
    );
  }

  Widget _buildBody(NotificationPreferences prefs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._categories.map((category) {
            final config = NotificationCategoryCatalog.of(category);
            final mandatory = _isMandatory(category);
            final enabled = mandatory
                ? true
                : (prefs.categoryEnabled[category] ?? true);

            return _buildPreferenceTile(
              config.displayName,
              mandatory
                  ? 'Always on — required by your school'
                  : _descriptionFor(category),
              config.icon,
              config.color,
              enabled,
              locked: mandatory,
              onChanged: (value) {
                final updated = Map<NotificationCategory, bool>.from(
                  prefs.categoryEnabled,
                )..[category] = value;
                _save(prefs.copyWith(categoryEnabled: updated));
              },
            );
          }),
          const SizedBox(height: 32),
          const Text(
            'Alert Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Sound',
            'Play a sound for new notifications',
            prefs.soundEnabled,
            (value) => _save(prefs.copyWith(soundEnabled: value)),
          ),
          _buildSwitchTile(
            'Vibration',
            'Vibrate for new notifications',
            prefs.vibrationEnabled,
            (value) => _save(prefs.copyWith(vibrationEnabled: value)),
          ),
          _buildActionTile(
            'Lock Screen',
            _previewLabel(prefs.lockScreenPreview),
            onTap: () => _pickLockScreenPreview(prefs),
          ),
          _buildActionTile(
            'Image Downloads',
            _imagePolicyLabel(prefs.imageDownloadPolicy),
            onTap: () => _pickImagePolicy(prefs),
          ),
          _buildActionTile(
            'Quiet Hours',
            prefs.quietHoursConfigured
                ? '${_formatTime(prefs.quietHoursStart!)} – ${_formatTime(prefs.quietHoursEnd!)}'
                : 'Off',
            onTap: () => _pickQuietHours(prefs),
          ),
          _buildSwitchTile(
            'Daily Digest',
            'Group low-priority notices into one daily summary',
            prefs.dailyDigest,
            (value) => _save(prefs.copyWith(dailyDigest: value)),
          ),
          _buildSwitchTile(
            'Email Copies',
            'Also send notifications to your email',
            prefs.emailCopies,
            (value) => _save(prefs.copyWith(emailCopies: value)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Emergency, medical, attendance and security alerts cannot be '
            'switched off.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickLockScreenPreview(NotificationPreferences prefs) async {
    // A school may cap how much detail is allowed; offer only what it permits.
    final ceiling = _policy?.maxLockScreenPreview ?? LockScreenPreview.full;
    final options = LockScreenPreview.values
        .where((p) => p.index >= ceiling.index)
        .toList();

    final choice = await _showOptionSheet<LockScreenPreview>(
      title: 'Lock screen preview',
      options: options,
      labelFor: _previewLabel,
      current: prefs.lockScreenPreview,
    );
    if (choice != null) _save(prefs.copyWith(lockScreenPreview: choice));
  }

  Future<void> _pickImagePolicy(NotificationPreferences prefs) async {
    final choice = await _showOptionSheet<ImageDownloadPolicy>(
      title: 'Download images',
      options: ImageDownloadPolicy.values,
      labelFor: _imagePolicyLabel,
      current: prefs.imageDownloadPolicy,
    );
    if (choice != null) _save(prefs.copyWith(imageDownloadPolicy: choice));
  }

  Future<void> _pickQuietHours(NotificationPreferences prefs) async {
    if (prefs.quietHoursConfigured) {
      final clear = await _showOptionSheet<bool>(
        title: 'Quiet hours',
        options: const [true, false],
        labelFor: (value) => value ? 'Change times' : 'Turn off quiet hours',
        current: null,
      );
      if (clear == false) {
        _save(prefs.copyWith(clearQuietHours: true));
        return;
      }
      if (clear == null) return;
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

    _save(prefs.copyWith(quietHoursStart: start, quietHoursEnd: end));
  }

  Future<T?> _showOptionSheet<T>({
    required String title,
    required List<T> options,
    required String Function(T) labelFor,
    required T? current,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...options.map(
              (option) => ListTile(
                title: Text(
                  labelFor(option),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: option == current
                    ? const Icon(Icons.check, color: Color(0xFF6366F1))
                    : null,
                onTap: () => Navigator.pop(sheetContext, option),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value, {
    bool locked = false,
    ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        // A locked category shows a padlock rather than a switch that would
        // spring back, so the reason is visible instead of feeling broken.
        trailing: locked
            ? const Icon(Icons.lock_outline, color: Colors.white38, size: 20)
            : Switch(
                value: value,
                onChanged: _saving ? null : onChanged,
                activeThumbColor: const Color(0xFF6366F1),
              ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: _saving ? null : onChanged,
          activeThumbColor: const Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: _saving ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white)),
            Row(
              children: [
                Text(value, style: const TextStyle(color: Colors.white60)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _previewLabel(LockScreenPreview preview) {
    switch (preview) {
      case LockScreenPreview.full:
        return 'Show full content';
      case LockScreenPreview.senderAndTitle:
        return 'Sender and title only';
      case LockScreenPreview.hidden:
        return 'Hide content';
    }
  }

  static String _imagePolicyLabel(ImageDownloadPolicy policy) {
    switch (policy) {
      case ImageDownloadPolicy.always:
        return 'Always';
      case ImageDownloadPolicy.wifiOnly:
        return 'Wi-Fi only';
      case ImageDownloadPolicy.never:
        return 'Never';
    }
  }

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  static String _descriptionFor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.announcements:
        return 'Receive all school announcements';
      case NotificationCategory.attendance:
        return 'Alerts about attendance & absences';
      case NotificationCategory.finance:
        return 'Fees, payments & receipts';
      case NotificationCategory.transport:
        return 'Bus route & transport updates';
      case NotificationCategory.homework:
        return 'Homework, assignments & tasks';
      case NotificationCategory.library:
        return 'Books, due dates & reminders';
      case NotificationCategory.messages:
        return 'Direct messages from staff';
      default:
        return '';
    }
  }
}
