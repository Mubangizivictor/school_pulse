import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/policies/notification_delivery_policy.dart';
import '../../local/notification_presenter.dart';
import '../../push/payloads/notification_push_payload.dart';

/// Outcome of one delivery test, rendered in the test screen.
@immutable
class TestDeliveryResult {
  final bool success;
  final String message;

  /// Populated for real push tests: how many of this user's devices FCM
  /// accepted the message for.
  final int? deviceCount;
  final int? successCount;
  final int? failureCount;

  const TestDeliveryResult({
    required this.success,
    required this.message,
    this.deviceCount,
    this.successCount,
    this.failureCount,
  });
}

/// Drives the in-app notification delivery tests.
///
/// Two distinct kinds of test, deliberately kept separate because they prove
/// different things:
///
///  - **Local** ([showLocal]) renders a notification through the same
///    presenter the push pipeline uses. It proves channels, icons, images,
///    grouping, sound and lock-screen redaction work on this device. It does
///    NOT prove FCM delivery.
///  - **Real push** ([sendPush]) calls the `sendTestNotification` Cloud
///    Function, which fans out to this user's registered device tokens. This
///    is the only test that proves end-to-end delivery, and it is the one that
///    must be run in foreground, background and terminated states.
///
/// The Cloud Function targets only the caller's own devices, so nothing here
/// can broadcast to a school.
class NotificationTestService {
  final FlutterLocalNotificationsPlugin plugin;
  final NotificationPresenter presenter;
  final FirebaseFunctions functions;

  NotificationTestService({
    required this.plugin,
    required this.presenter,
    required this.functions,
  });

  /// Renders a notification locally, bypassing FCM.
  ///
  /// [respectPreferences] controls whether the user's own quiet hours and
  /// category mutes apply. Off by default, because the point of a test is to
  /// see the notification - but it can be switched on to verify that muting
  /// actually suppresses.
  Future<TestDeliveryResult> showLocal({
    required String schoolId,
    required String userId,
    required NotificationCategory category,
    required NotificationPriority priority,
    String? title,
    String? body,
    String? imageUrl,
    bool requiresAcknowledgment = false,
    NotificationPreferences? preferences,
    SchoolNotificationPolicy? schoolPolicy,
    bool respectPreferences = false,
  }) async {
    final item = NotificationItem(
      // Prefixed so a test notification is never mistaken for a real record.
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? '[TEST] ${_defaultTitleFor(category)}',
      description: body ??
          'This is a test notification sent from the delivery test screen.',
      senderName: 'Automated System',
      senderRole: 'Delivery test',
      timestamp: DateTime.now(),
      category: category,
      priority: priority,
      schoolId: schoolId,
      recipientUserId: userId,
      type: NotificationType.custom,
      sender: const NotificationSender.automated(
        module: 'notification_test',
        reason: 'Manual delivery test',
      ),
      sourceModule: 'notification_test',
      bannerImageUrl: imageUrl,
      requiresAcknowledgment: requiresAcknowledgment,
      metadata: const {'isTest': 'true'},
    );

    final effectivePreferences = preferences ??
        NotificationPreferences.defaults(userId: userId, schoolId: schoolId);

    final evaluation = respectPreferences
        ? NotificationDeliveryPolicy.evaluate(
            notification: item,
            preferences: effectivePreferences,
            schoolPolicy: schoolPolicy,
          )
        // Force display, so a test is not silently swallowed by the user's own
        // quiet hours while they are trying to check the plumbing works.
        : const DeliveryEvaluation(
            decision: DeliveryDecision.deliver,
            reason: 'test_forced',
            preview: LockScreenPreview.full,
            playSound: true,
            vibrate: true,
          );

    if (evaluation.decision == DeliveryDecision.suppress) {
      return TestDeliveryResult(
        success: false,
        message: 'Suppressed by policy: ${evaluation.reason}',
      );
    }

    try {
      await presenter.show(
        item: item,
        evaluation: evaluation,
        systemNotificationId: item.id.hashCode & 0x7fffffff,
      );
      return TestDeliveryResult(
        success: true,
        message: evaluation.decision == DeliveryDecision.deliverSilently
            ? 'Shown silently (${evaluation.reason}).'
            : 'Local notification shown.',
      );
    } catch (e) {
      return TestDeliveryResult(
        success: false,
        message: 'Failed to display: $e',
      );
    }
  }

  /// Sends a real push to this user's registered devices via the Cloud
  /// Function. The only test that exercises FCM end to end.
  Future<TestDeliveryResult> sendPush({
    required String schoolId,
    required NotificationCategory category,
    required NotificationPriority priority,
    String? title,
    String? body,
    String? imageUrl,
  }) async {
    try {
      final callable = functions.httpsCallable('sendTestNotification');
      final response = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'category': category.name,
        'priority': priority.name,
        'title': title ?? '[TEST] ${_defaultTitleFor(category)}',
        'body': body ?? 'Test push from School Pulse.',
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      final data = response.data;
      final deviceCount = (data['deviceCount'] as num?)?.toInt() ?? 0;
      final successCount = (data['successCount'] as num?)?.toInt() ?? 0;
      final failureCount = (data['failureCount'] as num?)?.toInt() ?? 0;

      if (deviceCount == 0) {
        return const TestDeliveryResult(
          success: false,
          message: 'No registered devices. Push permission may be denied, or '
              'this is a simulator without APNs.',
          deviceCount: 0,
        );
      }

      return TestDeliveryResult(
        success: successCount > 0,
        message: successCount > 0
            ? 'Sent to $successCount of $deviceCount device(s).'
            : 'Delivery failed on all $deviceCount device(s).',
        deviceCount: deviceCount,
        successCount: successCount,
        failureCount: failureCount,
      );
    } on FirebaseFunctionsException catch (e) {
      return TestDeliveryResult(
        success: false,
        message: 'Server rejected the test: ${e.message ?? e.code}',
      );
    } catch (e) {
      return TestDeliveryResult(
        success: false,
        message: 'Could not reach the server: $e',
      );
    }
  }

  /// Schedules a local notification a short way out, to verify the scheduling
  /// path (including that it still fires with the app backgrounded).
  Future<TestDeliveryResult> scheduleLocal({
    Duration delay = const Duration(seconds: 15),
    String? title,
    String? body,
  }) async {
    final fireAt = DateTime.now().add(delay);
    try {
      await plugin.zonedSchedule(
        id: (fireAt.millisecondsSinceEpoch ~/ 1000) & 0x7fffffff,
        title: title ?? '[TEST] Scheduled notification',
        body: body ??
            'Scheduled ${delay.inSeconds}s earlier from the test screen.',
        // tz.local is initialised by LocalNotificationService at startup.
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'general',
            'General',
            channelDescription: 'Other notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return TestDeliveryResult(
        success: true,
        message: 'Scheduled for ${delay.inSeconds}s from now. '
            'Background the app to verify it still fires.',
      );
    } catch (e) {
      return TestDeliveryResult(
        success: false,
        message: 'Could not schedule: $e',
      );
    }
  }

  /// Verifies payload parsing without involving the network - useful for
  /// checking a payload shape before wiring a new event type to it.
  TestDeliveryResult parsePayload(Map<String, dynamic> data) {
    final payload = NotificationPushPayload.tryParse(data);
    if (payload == null) {
      return const TestDeliveryResult(
        success: false,
        message: 'Payload rejected: no notificationId.',
      );
    }
    return TestDeliveryResult(
      success: true,
      message: 'Parsed as ${payload.type.name} / ${payload.category.name}, '
          'priority ${payload.priority.name}.',
    );
  }

  Future<void> dismissAll() => presenter.dismissAll();

  static String _defaultTitleFor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.emergency:
        return 'Emergency alert test';
      case NotificationCategory.medical:
        return 'Medical alert test';
      case NotificationCategory.finance:
        return 'Fee notification test';
      case NotificationCategory.messages:
        return 'Message notification test';
      default:
        return 'Notification test';
    }
  }
}
