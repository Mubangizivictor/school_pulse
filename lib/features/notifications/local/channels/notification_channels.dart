import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/notification_category_config.dart';
import '../../domain/entities/notification_model.dart';

/// Android notification channels, one per category group.
///
/// Channels matter because on Android the user - not the app - controls a
/// channel's importance, sound and whether it appears on the lock screen. One
/// channel for everything would mean a parent who silences chat pings also
/// silences emergency alerts. Grouping by category keeps those controls
/// meaningful.
///
/// Channel ids are stable: Android ignores changes to an existing channel's
/// settings after creation, so renaming an id would silently create a second
/// channel and orphan the user's preference.
class NotificationChannels {
  const NotificationChannels._();

  /// Legacy channel from the previous implementation. Kept registered so
  /// notifications already scheduled against it still display.
  static const legacyChannelId = 'school_pulse_alerts';

  static const _definitions =
      <String, ({String name, String description, Importance importance})>{
        'emergency': (
          name: 'Emergency Alerts',
          description: 'School closures, security and safety alerts',
          importance: Importance.max,
        ),
        'attendance': (
          name: 'Attendance & Gate',
          description: 'Arrival, departure, absence and roll-call alerts',
          importance: Importance.high,
        ),
        'medical': (
          name: 'Medical',
          description: 'Nurse and health alerts',
          importance: Importance.high,
        ),
        'security': (
          name: 'Security',
          description: 'Visitor arrivals and security incidents',
          importance: Importance.high,
        ),
        'finance': (
          name: 'Fees & Payments',
          description: 'Fee reminders, receipts and payment confirmations',
          importance: Importance.defaultImportance,
        ),
        'academics': (
          name: 'Academics',
          description: 'Homework, assignments, results and examinations',
          importance: Importance.defaultImportance,
        ),
        'transport': (
          name: 'Transport',
          description: 'Bus boarding, drop-off and route alerts',
          importance: Importance.high,
        ),
        'messages': (
          name: 'Messages',
          description: 'Direct and group conversations',
          importance: Importance.high,
        ),
        'appointments': (
          name: 'Appointments',
          description: 'Appointment approvals, changes and reminders',
          importance: Importance.defaultImportance,
        ),
        'library': (
          name: 'Library',
          description: 'Loans, returns and overdue reminders',
          importance: Importance.low,
        ),
        'boarding': (
          name: 'Boarding',
          description: 'Dormitory and boarding notices',
          importance: Importance.defaultImportance,
        ),
        'welfare': (
          name: 'Welfare',
          description: 'Discipline and counselling communications',
          importance: Importance.defaultImportance,
        ),
        'announcements': (
          name: 'Announcements',
          description: 'Official school announcements',
          importance: Importance.defaultImportance,
        ),
        'platform': (
          name: 'System',
          description: 'Subscription, billing and maintenance notices',
          importance: Importance.low,
        ),
        'general': (
          name: 'General',
          description: 'Other notifications',
          importance: Importance.defaultImportance,
        ),
      };

  /// Registers every channel. Safe to call repeatedly - Android treats channel
  /// creation as idempotent once an id exists.
  static Future<void> registerAll(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    for (final entry in _definitions.entries) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          entry.key,
          entry.value.name,
          description: entry.value.description,
          importance: entry.value.importance,
          // Emergency alerts bypass the "do not disturb"-adjacent quieting
          // Android applies to lower-importance channels.
          enableVibration: true,
        ),
      );
    }

    // Keep the original channel alive so previously-scheduled notifications
    // are not orphaned.
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        legacyChannelId,
        'School Pulse Alerts',
        description: 'Broadcasts, announcements and direct notifications',
        importance: Importance.high,
      ),
    );
  }

  static String channelIdFor(NotificationCategory category) =>
      NotificationCategoryCatalog.of(category).channelId;

  static String channelNameFor(NotificationCategory category) {
    final id = channelIdFor(category);
    return _definitions[id]?.name ?? 'General';
  }

  static String? channelDescriptionFor(NotificationCategory category) {
    final id = channelIdFor(category);
    return _definitions[id]?.description;
  }

  /// Maps notification priority onto the Android importance/priority pair.
  static (Importance, Priority) androidPriorityFor(
    NotificationPriority priority,
  ) {
    switch (priority) {
      case NotificationPriority.urgent:
        return (Importance.max, Priority.max);
      case NotificationPriority.high:
        return (Importance.high, Priority.high);
      case NotificationPriority.medium:
        return (Importance.defaultImportance, Priority.defaultPriority);
      case NotificationPriority.low:
        return (Importance.low, Priority.low);
    }
  }

  /// Android group key, so several notifications of the same kind collapse
  /// into one stack rather than filling the shade.
  static String groupKeyFor(NotificationCategory category) =>
      'school_pulse_${channelIdFor(category)}';
}
