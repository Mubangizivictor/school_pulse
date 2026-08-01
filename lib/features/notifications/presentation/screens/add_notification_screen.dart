import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_category_config.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AddNotificationScreen extends StatefulWidget {
  final bool isAnnouncement;
  const AddNotificationScreen({super.key, this.isAnnouncement = false});

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  String _selectedCategory = 'School Announcement';
  String _selectedAudience = 'All Students & Staff';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int _titleLength = 0;
  int _messageLength = 0;

  /// When set, the notification is queued for this time rather than sent now.
  DateTime? _scheduledAt;

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() => _titleLength = _titleController.text.length);
    });
    _messageController.addListener(() {
      setState(() => _messageLength = _messageController.text.length);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  UserEntity? get _user {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  /// Maps the "Send To" dropdown onto a typed audience the Cloud Function
  /// understands.
  NotificationAudience _audience() {
    switch (_selectedAudience) {
      case 'Parents Only':
        return const NotificationAudience.allParents();
      case 'Teachers Only':
        return const NotificationAudience(
          kind: NotificationAudienceKind.roles,
          roles: ['classTeacher', 'subjectTeacher'],
        );
      case 'Specific Class':
        // Class picking is not part of this screen yet; fall back to staff
        // rather than silently broadcasting school-wide.
        return const NotificationAudience.allStaff();
      case 'All Students & Staff':
      default:
        return const NotificationAudience.school();
    }
  }

  /// Maps the category dropdown onto the typed category and event kind, which
  /// together decide icon, channel, retention and deep-link destination.
  (NotificationCategory, NotificationType, NotificationPriority) _classify() {
    switch (_selectedCategory) {
      case 'Urgent Alert':
        return (
          NotificationCategory.emergency,
          NotificationType.emergencyAlert,
          NotificationPriority.urgent,
        );
      case 'Event':
        return (
          NotificationCategory.events,
          NotificationType.eventNotice,
          NotificationPriority.medium,
        );
      case 'Reminder':
        return (
          NotificationCategory.announcements,
          NotificationType.announcement,
          NotificationPriority.low,
        );
      case 'School Announcement':
      default:
        return (
          NotificationCategory.announcements,
          NotificationType.announcement,
          NotificationPriority.medium,
        );
    }
  }

  Future<void> _submitNotification() async {
    if (_sending) return;

    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _toast('Please fill in all required fields');
      return;
    }

    final user = _user;
    if (user == null) {
      _toast('Sign in to send notifications');
      return;
    }

    final (category, type, priority) = _classify();
    final audience = _audience();
    final granted = RolePermissionDefaults.permissionsFor(user.roles);

    // Checked here so an unauthorised sender is told plainly, rather than
    // having the write rejected by the security rules with a raw error. The
    // rules remain the actual boundary.
    if (!granted.contains(Permission.notificationSend)) {
      _toast('You do not have permission to send notifications');
      return;
    }
    if (category == NotificationCategory.emergency &&
        !granted.contains(Permission.notificationSendEmergency)) {
      _toast('Only school leadership may send emergency alerts');
      return;
    }
    if (audience.kind == NotificationAudienceKind.school &&
        !granted.contains(Permission.notificationBroadcast)) {
      _toast('You do not have permission to broadcast school-wide');
      return;
    }
    if (_scheduledAt != null &&
        !granted.contains(Permission.notificationSchedule)) {
      _toast('You do not have permission to schedule notifications');
      return;
    }

    // A broadcast is hard to take back once devices have it, so confirm who it
    // is about to reach before committing.
    final confirmed = await _confirmSend(audience, category);
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);

    final result = await di.sl<NotificationSendService>().send(
          sender: user,
          audience: audience,
          category: category,
          type: type,
          title: _titleController.text,
          body: _messageController.text,
          priority: priority,
          sourceModule: 'announcements',
          scheduledAt: _scheduledAt,
        );

    if (!mounted) return;
    setState(() => _sending = false);

    result.fold(
      (failure) => _toast(failure.userMessage),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _scheduledAt == null
                  ? 'Notification queued for delivery'
                  : 'Notification scheduled',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      },
    );
  }

  Future<bool?> _confirmSend(
    NotificationAudience audience,
    NotificationCategory category,
  ) {
    final isEmergency = category == NotificationCategory.emergency;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isEmergency ? 'Send emergency alert?' : 'Send notification?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isEmergency
              ? 'This will reach ${audience.description} immediately, '
                  'overriding quiet hours and notification mutes.'
              : 'This will be delivered to ${audience.description}.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              isEmergency ? 'Send alert' : 'Send',
              style: TextStyle(
                color: isEmergency
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledAt ?? DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows how the notification will appear before it is sent.
  ///
  /// Renders the same title/body/sender the recipient will see, so a typo in a
  /// school-wide broadcast is caught before it reaches thousands of devices.
  void _showPreview() {
    final user = _user;
    final (category, _, priority) = _classify();
    final config = NotificationCategoryCatalog.of(category);
    final title = _titleController.text.trim();
    final body = _messageController.text.trim();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'How this will appear to ${_audience().description}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(config.icon, color: config.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? 'Title goes here' : title,
                            style: TextStyle(
                              color: title.isEmpty
                                  ? Colors.white24
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body.isEmpty ? 'Message goes here' : body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: body.isEmpty
                                  ? Colors.white24
                                  : Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                user?.name ?? 'You',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              if (priority == NotificationPriority.urgent ||
                                  priority == NotificationPriority.high)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE11D48)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    priority.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFE11D48),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        title: Text(
          widget.isAnnouncement ? 'Add Announcement' : 'Add Notification',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : _showPreview,
            child: const Text('Preview', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField(
              widget.isAnnouncement ? 'Announcement Type' : 'Category',
              _selectedCategory,
              ['School Announcement', 'Urgent Alert', 'Event', 'Reminder'],
              (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              'Title',
              'Sports Day 2025',
              controller: _titleController,
              maxLength: 50,
              currentLength: _titleLength,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              'Message',
              'We are excited to inform you that our Annual Sports Day will take place on Saturday, 24th May 2025 at 8:00 AM. All students are expected to participate.',
              controller: _messageController,
              maxLines: 6,
              maxLength: 1000,
              currentLength: _messageLength,
            ),
            const SizedBox(height: 20),
            const Text('Add Image (Optional)', style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1577891729319-86adcd962860?q=80&w=2069&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.white60),
                      Text('Add Image', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              'Send To',
              _selectedAudience,
              ['All Students & Staff', 'Parents Only', 'Teachers Only', 'Specific Class'],
              (val) => setState(() => _selectedAudience = val!),
            ),
            const SizedBox(height: 20),
            // Schedule row. Sending immediately stays the default; this only
            // appears as a choice, so the common case is unchanged.
            InkWell(
              onTap: _sending ? null : _pickSchedule,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white60, size: 20),
                    const SizedBox(width: 12),
                    const Text('Delivery', style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    Text(
                      _scheduledAt == null
                          ? 'Send now'
                          : DateFormat('dd MMM, h:mm a').format(_scheduledAt!),
                      style: const TextStyle(color: Colors.white60),
                    ),
                    if (_scheduledAt != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                        onPressed: () => setState(() => _scheduledAt = null),
                      )
                    else
                      const Icon(Icons.chevron_right, color: Colors.white30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sending ? null : _submitNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _sending
                      ? 'Sending...'
                      : _scheduledAt == null
                          ? 'Send Notification'
                          : 'Schedule Notification',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {required TextEditingController controller, int maxLines = 1, int? maxLength, int currentLength = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            if (maxLength != null)
              Text('$currentLength/$maxLength', style: const TextStyle(color: Colors.white30, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
