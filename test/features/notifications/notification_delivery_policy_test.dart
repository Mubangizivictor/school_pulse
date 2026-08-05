import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_preferences.dart';
import 'package:school_pulse/features/notifications/domain/policies/notification_delivery_policy.dart';

NotificationItem _notification({
  NotificationCategory category = NotificationCategory.announcements,
  NotificationPriority priority = NotificationPriority.medium,
  NotificationPersistence persistence = NotificationPersistence.permanent,
}) {
  return NotificationItem(
    id: 'n1',
    title: 'Title',
    description: 'Body',
    senderName: 'Office',
    senderRole: 'Admin',
    timestamp: DateTime(2026, 8, 1),
    category: category,
    priority: priority,
    persistence: persistence,
  );
}

NotificationPreferences _prefs({
  Map<NotificationCategory, bool> categoryEnabled = const {},
  TimeOfDay? quietStart,
  TimeOfDay? quietEnd,
  bool soundEnabled = true,
  bool dailyDigest = false,
  LockScreenPreview preview = LockScreenPreview.full,
  ImageDownloadPolicy imagePolicy = ImageDownloadPolicy.wifiOnly,
}) {
  return NotificationPreferences(
    userId: 'u1',
    schoolId: 's1',
    categoryEnabled: categoryEnabled,
    quietHoursStart: quietStart,
    quietHoursEnd: quietEnd,
    soundEnabled: soundEnabled,
    dailyDigest: dailyDigest,
    lockScreenPreview: preview,
    imageDownloadPolicy: imagePolicy,
  );
}

void main() {
  group('mandatory categories', () {
    test('an emergency alert delivers even when the user muted it', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(
          category: NotificationCategory.emergency,
          priority: NotificationPriority.urgent,
        ),
        preferences: _prefs(
          categoryEnabled: {NotificationCategory.emergency: false},
        ),
      );

      expect(result.decision, DeliveryDecision.deliver);
      expect(result.playSound, isTrue);
    });

    test('an emergency alert overrides quiet hours', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(
          category: NotificationCategory.emergency,
          priority: NotificationPriority.urgent,
        ),
        preferences: _prefs(
          quietStart: const TimeOfDay(hour: 21, minute: 0),
          quietEnd: const TimeOfDay(hour: 6, minute: 0),
        ),
        now: DateTime(2026, 8, 1, 2, 30),
      );

      expect(result.decision, DeliveryDecision.deliver);
    });

    test('a school may not disable a mandatory category', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(category: NotificationCategory.medical),
        preferences: _prefs(),
        schoolPolicy: const SchoolNotificationPolicy(
          schoolId: 's1',
          disabledCategories: {NotificationCategory.medical},
        ),
      );

      expect(result.decision, DeliveryDecision.deliver);
    });
  });

  group('user and school opt-out', () {
    test('a user-disabled category is suppressed', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(category: NotificationCategory.clubs),
        preferences: _prefs(
          categoryEnabled: {NotificationCategory.clubs: false},
        ),
      );

      expect(result.decision, DeliveryDecision.suppress);
      expect(result.reason, 'disabled_by_user');
    });

    test('school policy beats a user opting in', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(category: NotificationCategory.clubs),
        preferences: _prefs(
          categoryEnabled: {NotificationCategory.clubs: true},
        ),
        schoolPolicy: const SchoolNotificationPolicy(
          schoolId: 's1',
          disabledCategories: {NotificationCategory.clubs},
        ),
      );

      expect(result.decision, DeliveryDecision.suppress);
      expect(result.reason, 'disabled_by_school');
    });

    test('a category absent from the preference map is enabled', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(category: NotificationCategory.events),
        preferences: _prefs(),
      );

      expect(result.decision, DeliveryDecision.deliver);
    });
  });

  group('quiet hours', () {
    test('downgrades to silent rather than suppressing', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(),
        preferences: _prefs(
          quietStart: const TimeOfDay(hour: 21, minute: 0),
          quietEnd: const TimeOfDay(hour: 6, minute: 0),
        ),
        now: DateTime(2026, 8, 1, 23, 0),
      );

      expect(result.decision, DeliveryDecision.deliverSilently);
      expect(
        result.shouldStore,
        isTrue,
        reason: 'it must still be waiting in the centre in the morning',
      );
      expect(result.playSound, isFalse);
    });

    test('handles an overnight window that crosses midnight', () {
      final inWindow = NotificationDeliveryPolicy.evaluate(
        notification: _notification(),
        preferences: _prefs(
          quietStart: const TimeOfDay(hour: 21, minute: 0),
          quietEnd: const TimeOfDay(hour: 6, minute: 0),
        ),
        now: DateTime(2026, 8, 1, 3, 0),
      );
      final outsideWindow = NotificationDeliveryPolicy.evaluate(
        notification: _notification(),
        preferences: _prefs(
          quietStart: const TimeOfDay(hour: 21, minute: 0),
          quietEnd: const TimeOfDay(hour: 6, minute: 0),
        ),
        now: DateTime(2026, 8, 1, 12, 0),
      );

      expect(inWindow.decision, DeliveryDecision.deliverSilently);
      expect(outsideWindow.decision, DeliveryDecision.deliver);
    });

    test('handles a same-day window', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(),
        preferences: _prefs(
          quietStart: const TimeOfDay(hour: 13, minute: 0),
          quietEnd: const TimeOfDay(hour: 14, minute: 0),
        ),
        now: DateTime(2026, 8, 1, 13, 30),
      );

      expect(result.decision, DeliveryDecision.deliverSilently);
    });
  });

  group('lock screen privacy', () {
    test('a sensitive category is never shown in full', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(category: NotificationCategory.finance),
        preferences: _prefs(preview: LockScreenPreview.full),
      );

      expect(result.preview, LockScreenPreview.senderAndTitle);
    });

    test('the stricter of user and school setting wins', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(),
        preferences: _prefs(preview: LockScreenPreview.full),
        schoolPolicy: const SchoolNotificationPolicy(
          schoolId: 's1',
          maxLockScreenPreview: LockScreenPreview.hidden,
        ),
      );

      expect(result.preview, LockScreenPreview.hidden);
    });

    test('a user may choose stricter than the school ceiling', () {
      final result = NotificationDeliveryPolicy.evaluate(
        notification: _notification(),
        preferences: _prefs(preview: LockScreenPreview.hidden),
        schoolPolicy: const SchoolNotificationPolicy(
          schoolId: 's1',
          maxLockScreenPreview: LockScreenPreview.full,
        ),
      );

      expect(result.preview, LockScreenPreview.hidden);
    });
  });

  group('data saver', () {
    test('wifiOnly blocks a full image download on mobile data', () {
      expect(
        NotificationDeliveryPolicy.mayDownloadFullImage(
          policy: ImageDownloadPolicy.wifiOnly,
          isOnWifi: false,
        ),
        isFalse,
      );
      expect(
        NotificationDeliveryPolicy.mayDownloadFullImage(
          policy: ImageDownloadPolicy.wifiOnly,
          isOnWifi: true,
        ),
        isTrue,
      );
    });

    test('never blocks regardless of connection', () {
      expect(
        NotificationDeliveryPolicy.mayDownloadFullImage(
          policy: ImageDownloadPolicy.never,
          isOnWifi: true,
        ),
        isFalse,
      );
    });
  });

  group('transient clearing', () {
    test('a message notification clears once its source is opened', () {
      final notification = _notification(
        category: NotificationCategory.messages,
        persistence: NotificationPersistence.transient,
      );

      expect(
        NotificationDeliveryPolicy.shouldClearOnOpen(notification),
        isTrue,
      );
    });

    test('an official announcement is retained after being opened', () {
      final notification = _notification(
        category: NotificationCategory.announcements,
      );

      expect(
        NotificationDeliveryPolicy.shouldClearOnOpen(notification),
        isFalse,
      );
    });
  });

  group('retention', () {
    test('emergency notices are retained indefinitely', () {
      expect(
        NotificationDeliveryPolicy.retentionCutoff(
          category: NotificationCategory.emergency,
        ),
        isNull,
      );
    });

    test('a school override replaces the category default', () {
      final cutoff = NotificationDeliveryPolicy.retentionCutoff(
        category: NotificationCategory.announcements,
        schoolPolicy: const SchoolNotificationPolicy(
          schoolId: 's1',
          retentionDaysOverride: 10,
        ),
        now: DateTime(2026, 8, 11),
      );

      expect(cutoff, DateTime(2026, 8, 1));
    });
  });
}
