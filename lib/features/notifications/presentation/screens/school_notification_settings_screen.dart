import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../../data/mappers/notification_preferences_mapper.dart';
import '../../domain/entities/notification_category_config.dart';
import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';

/// School-wide notification policy editor.
///
/// Sits above user preferences: what a school disables here cannot be re-enabled
/// by a user, and what it marks mandatory cannot be muted by one. Restricted to
/// roles holding `notification.manage_settings`.
class SchoolNotificationSettingsScreen extends StatefulWidget {
  const SchoolNotificationSettingsScreen({super.key});

  @override
  State<SchoolNotificationSettingsScreen> createState() =>
      _SchoolNotificationSettingsScreenState();
}

class _SchoolNotificationSettingsScreenState
    extends State<SchoolNotificationSettingsScreen> {
  /// Categories a school can meaningfully govern. The always-mandatory ones
  /// (emergency, medical, attendance, gate, security) are listed but locked -
  /// showing them makes the policy legible rather than hiding why they cannot
  /// be switched off.
  static const _categories = <NotificationCategory>[
    NotificationCategory.emergency,
    NotificationCategory.medical,
    NotificationCategory.attendance,
    NotificationCategory.gate,
    NotificationCategory.security,
    NotificationCategory.announcements,
    NotificationCategory.finance,
    NotificationCategory.results,
    NotificationCategory.homework,
    NotificationCategory.examinations,
    NotificationCategory.transport,
    NotificationCategory.library,
    NotificationCategory.appointments,
    NotificationCategory.visitors,
    NotificationCategory.discipline,
    NotificationCategory.counselling,
    NotificationCategory.hostel,
    NotificationCategory.catering,
    NotificationCategory.events,
    NotificationCategory.clubs,
    NotificationCategory.sports,
    NotificationCategory.messages,
  ];

  SchoolNotificationPolicy? _policy;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final result = await di.sl<NotificationRepository>().getSchoolPolicy(
      user.schoolId,
    );
    if (!mounted) return;
    setState(() {
      _policy = result.fold(
        (_) => SchoolNotificationPolicy.defaults(user.schoolId),
        (policy) => policy,
      );
      _loading = false;
    });
  }

  /// Writes the policy directly.
  ///
  /// Goes through Firestore rather than the notification repository because
  /// the repository deliberately exposes policy as read-only - only an admin
  /// writes it, and that path is gated by the rules on this collection.
  Future<void> _save(SchoolNotificationPolicy updated) async {
    final previous = _policy;
    setState(() {
      _policy = updated;
      _saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('schools')
          .doc(updated.schoolId)
          .collection('notification_policy')
          .doc('policy')
          .set(
            NotificationPreferencesMapper.policyToFirestore(updated),
            SetOptions(merge: true),
          );
    } catch (e) {
      if (!mounted) return;
      // Roll back so the switch does not lie about what is stored.
      setState(() => _policy = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save. Your change was not applied.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;

    if (user == null) {
      return const _SettingsScaffold(
        saving: false,
        child: Center(
          child: Text(
            'Sign in to manage school notification settings',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final granted = RolePermissionDefaults.permissionsFor(user.roles);
    if (!granted.contains(Permission.notificationManageSettings)) {
      return const _SettingsScaffold(
        saving: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Only school leadership may change notification settings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    if (_loading) {
      return const _SettingsScaffold(
        saving: false,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    final policy = _policy!;
    return _SettingsScaffold(
      saving: _saving,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Categories'),
          const SizedBox(height: 4),
          const Text(
            'Switching a category off stops it reaching anyone at this school. '
            'Safety categories cannot be switched off.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ..._categories.map((category) => _categoryTile(policy, category)),

          const SizedBox(height: 24),
          _sectionTitle('Content'),
          const SizedBox(height: 12),
          _switchTile(
            'Allow images',
            'Senders may attach images to notifications',
            policy.allowImages,
            (value) => _save(_copy(policy, allowImages: value)),
          ),
          _switchTile(
            'Allow attachments',
            'Senders may attach files to notifications',
            policy.allowAttachments,
            (value) => _save(_copy(policy, allowAttachments: value)),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Privacy'),
          const SizedBox(height: 4),
          const Text(
            'The most detail any user may show on a locked screen. Users may '
            'choose to show less, never more.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _actionTile(
            'Maximum lock screen detail',
            _previewLabel(policy.maxLockScreenPreview),
            () => _pickPreview(policy),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Quiet hours'),
          const SizedBox(height: 4),
          const Text(
            'Applies to users who have not set their own. Emergency alerts '
            'always override quiet hours.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _actionTile(
            'School quiet hours',
            policy.quietHoursStart == null || policy.quietHoursEnd == null
                ? 'Not set'
                : '${_fmt(policy.quietHoursStart!)} – ${_fmt(policy.quietHoursEnd!)}',
            () => _pickQuietHours(policy),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Retention and limits'),
          const SizedBox(height: 12),
          _actionTile(
            'Retention override',
            policy.retentionDaysOverride == null
                ? 'Per category'
                : '${policy.retentionDaysOverride} days',
            () => _pickRetention(policy),
          ),
          _actionTile(
            'Sender rate limit',
            policy.senderRateLimitPerHour == null
                ? 'No limit'
                : '${policy.senderRateLimitPerHour}/hour',
            () => _pickRateLimit(policy),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Visibility'),
          const SizedBox(height: 12),
          _switchTile(
            'Parents',
            'Parents receive notifications',
            policy.parentVisibility,
            (value) => _save(_copy(policy, parentVisibility: value)),
          ),
          _switchTile(
            'Students',
            'Students receive notifications',
            policy.studentVisibility,
            (value) => _save(_copy(policy, studentVisibility: value)),
          ),
          _switchTile(
            'Staff',
            'Staff receive notifications',
            policy.staffVisibility,
            (value) => _save(_copy(policy, staffVisibility: value)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _categoryTile(
    SchoolNotificationPolicy policy,
    NotificationCategory category,
  ) {
    final config = NotificationCategoryCatalog.of(category);
    final alwaysOn = config.isMandatory;
    final disabled = policy.disabledCategories.contains(category);
    final mandatory = alwaysOn || policy.mandatoryCategories.contains(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(config.icon, color: config.color, size: 20),
        ),
        title: Text(
          config.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          alwaysOn
              ? 'Required — cannot be disabled or muted'
              : mandatory
              ? 'Mandatory — users cannot mute this'
              : disabled
              ? 'Disabled for this school'
              : 'Users may mute this',
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        trailing: alwaysOn
            ? const Icon(Icons.lock_outline, color: Colors.white38, size: 20)
            : PopupMenuButton<String>(
                enabled: !_saving,
                color: const Color(0xFF1E293B),
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onSelected: (choice) =>
                    _applyCategoryChoice(policy, category, choice),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'optional',
                    child: Text(
                      'Users may mute',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'mandatory',
                    child: Text(
                      'Mandatory for everyone',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'disabled',
                    child: Text(
                      'Disable school-wide',
                      style: TextStyle(color: Color(0xFFE11D48)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _applyCategoryChoice(
    SchoolNotificationPolicy policy,
    NotificationCategory category,
    String choice,
  ) {
    // Disabled and mandatory are mutually exclusive - a category cannot be
    // both off for everyone and unmutable, so each choice clears the other.
    final disabled = {...policy.disabledCategories}..remove(category);
    final mandatory = {...policy.mandatoryCategories}..remove(category);

    switch (choice) {
      case 'mandatory':
        mandatory.add(category);
        break;
      case 'disabled':
        disabled.add(category);
        break;
    }

    _save(
      _copy(
        policy,
        disabledCategories: disabled,
        mandatoryCategories: mandatory,
      ),
    );
  }

  Future<void> _pickPreview(SchoolNotificationPolicy policy) async {
    final choice = await _sheet<LockScreenPreview>(
      'Maximum lock screen detail',
      LockScreenPreview.values,
      _previewLabel,
      policy.maxLockScreenPreview,
    );
    if (choice != null) _save(_copy(policy, maxLockScreenPreview: choice));
  }

  Future<void> _pickRetention(SchoolNotificationPolicy policy) async {
    final choice = await _sheet<int>(
      'Keep notifications for',
      const [0, 30, 90, 180, 365, 730],
      (days) => days == 0 ? 'Use per-category defaults' : '$days days',
      policy.retentionDaysOverride ?? 0,
    );
    if (choice != null) {
      _save(
        _copy(
          policy,
          retentionDaysOverride: choice == 0 ? null : choice,
          clearRetention: choice == 0,
        ),
      );
    }
  }

  Future<void> _pickRateLimit(SchoolNotificationPolicy policy) async {
    final choice = await _sheet<int>(
      'Maximum sends per sender per hour',
      const [0, 5, 10, 25, 50, 100],
      (limit) => limit == 0 ? 'No limit' : '$limit per hour',
      policy.senderRateLimitPerHour ?? 0,
    );
    if (choice != null) {
      _save(
        _copy(
          policy,
          senderRateLimitPerHour: choice == 0 ? null : choice,
          clearRateLimit: choice == 0,
        ),
      );
    }
  }

  Future<void> _pickQuietHours(SchoolNotificationPolicy policy) async {
    final start = await showTimePicker(
      context: context,
      initialTime:
          policy.quietHoursStart ?? const TimeOfDay(hour: 21, minute: 0),
      helpText: 'School quiet hours start',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: policy.quietHoursEnd ?? const TimeOfDay(hour: 6, minute: 0),
      helpText: 'School quiet hours end',
    );
    if (end == null) return;

    _save(_copy(policy, quietHoursStart: start, quietHoursEnd: end));
  }

  Future<T?> _sheet<T>(
    String title,
    List<T> options,
    String Function(T) labelFor,
    T? current,
  ) {
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

  /// SchoolNotificationPolicy has no copyWith, and adding one would mean
  /// threading `clear` flags through the domain entity for two fields only this
  /// screen edits. Kept local instead.
  SchoolNotificationPolicy _copy(
    SchoolNotificationPolicy p, {
    Set<NotificationCategory>? disabledCategories,
    Set<NotificationCategory>? mandatoryCategories,
    bool? allowImages,
    bool? allowAttachments,
    LockScreenPreview? maxLockScreenPreview,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    int? retentionDaysOverride,
    bool clearRetention = false,
    int? senderRateLimitPerHour,
    bool clearRateLimit = false,
    bool? parentVisibility,
    bool? studentVisibility,
    bool? staffVisibility,
  }) {
    return SchoolNotificationPolicy(
      schoolId: p.schoolId,
      disabledCategories: disabledCategories ?? p.disabledCategories,
      mandatoryCategories: mandatoryCategories ?? p.mandatoryCategories,
      allowImages: allowImages ?? p.allowImages,
      allowAttachments: allowAttachments ?? p.allowAttachments,
      maxLockScreenPreview: maxLockScreenPreview ?? p.maxLockScreenPreview,
      quietHoursStart: quietHoursStart ?? p.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? p.quietHoursEnd,
      retentionDaysOverride: clearRetention
          ? null
          : (retentionDaysOverride ?? p.retentionDaysOverride),
      senderRateLimitPerHour: clearRateLimit
          ? null
          : (senderRateLimitPerHour ?? p.senderRateLimitPerHour),
      parentVisibility: parentVisibility ?? p.parentVisibility,
      studentVisibility: studentVisibility ?? p.studentVisibility,
      staffVisibility: staffVisibility ?? p.staffVisibility,
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  );

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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

  Widget _actionTile(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: _saving ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white)),
            ),
            Text(value, style: const TextStyle(color: Colors.white60)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  static String _previewLabel(LockScreenPreview preview) {
    switch (preview) {
      case LockScreenPreview.full:
        return 'Full content allowed';
      case LockScreenPreview.senderAndTitle:
        return 'Sender and title only';
      case LockScreenPreview.hidden:
        return 'Hide all content';
    }
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _SettingsScaffold extends StatelessWidget {
  final Widget child;
  final bool saving;

  const _SettingsScaffold({required this.child, required this.saving});

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
          'School Notification Settings',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: [
          if (saving)
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
      body: child,
    );
  }
}
