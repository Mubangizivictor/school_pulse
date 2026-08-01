import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/push/payloads/notification_push_payload.dart';

void main() {
  group('parsing', () {
    test('rejects a payload with no notification id', () {
      expect(
        NotificationPushPayload.tryParse({'title': 'Hello'}),
        isNull,
        reason: 'without an id there is nothing to fetch, mark read or route to',
      );
    });

    test('accepts the alternate "id" key', () {
      final payload = NotificationPushPayload.tryParse({'id': 'n1'});
      expect(payload?.notificationId, 'n1');
    });

    test('parses a full payload', () {
      final payload = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'schoolId': 'school-1',
        'recipientUserId': 'user-1',
        'title': 'Fees due',
        'body': 'A balance remains',
        'category': 'finance',
        'type': 'feeReminder',
        'priority': 'high',
        'senderName': 'Finance Office',
        'senderRole': 'Bursar',
        'relatedStudentId': 'student-1',
        'requiresAcknowledgment': 'true',
        'collapseKey': 'fee-2026-08',
      });

      expect(payload, isNotNull);
      expect(payload!.category, NotificationCategory.finance);
      expect(payload.type, NotificationType.feeReminder);
      expect(payload.priority, NotificationPriority.high);
      expect(payload.relatedStudentId, 'student-1');
      expect(payload.requiresAcknowledgment, isTrue);
    });

    test('derives the category from the type when absent', () {
      final payload = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'type': 'busDelayed',
      });

      expect(payload!.category, NotificationCategory.transport);
    });

    test('falls back to safe defaults for unknown enum names', () {
      final payload = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'type': 'somethingFromANewerAppVersion',
        'category': 'alsoUnknown',
        'priority': 'nonsense',
      });

      expect(payload!.type, NotificationType.custom);
      expect(payload.category, NotificationCategory.others);
      expect(payload.priority, NotificationPriority.medium);
    });

    test('treats blank strings as absent', () {
      final payload = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'senderName': '   ',
        'imageUrl': '',
      });

      expect(payload!.senderName, isNull);
      expect(payload.imageUrl, isNull);
    });

    test('parses FCM boolean strings', () {
      final asTrue = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'isAutomated': 'true',
      });
      final asOne = NotificationPushPayload.tryParse({
        'notificationId': 'n2',
        'isAutomated': '1',
      });
      final asFalse = NotificationPushPayload.tryParse({
        'notificationId': 'n3',
        'isAutomated': 'false',
      });

      expect(asTrue!.isAutomated, isTrue);
      expect(asOne!.isAutomated, isTrue);
      expect(asFalse!.isAutomated, isFalse);
    });

    test('inherits category defaults for acknowledgement', () {
      final payload = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'category': 'emergency',
      });

      expect(
        payload!.requiresAcknowledgment,
        isTrue,
        reason: 'emergency requires acknowledgement even if the payload omits it',
      );
    });
  });

  group('system notification id', () {
    test('is stable for the same collapse key', () {
      final first = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'collapseKey': 'evt-1',
      })!;
      final second = NotificationPushPayload.tryParse({
        'notificationId': 'n2',
        'collapseKey': 'evt-1',
      })!;

      expect(
        first.systemNotificationId,
        second.systemNotificationId,
        reason: 'a re-sent event must replace its banner, not stack a duplicate',
      );
    });

    test('differs without a collapse key', () {
      final first =
          NotificationPushPayload.tryParse({'notificationId': 'n1'})!;
      final second =
          NotificationPushPayload.tryParse({'notificationId': 'n2'})!;

      expect(
        first.systemNotificationId,
        isNot(second.systemNotificationId),
      );
    });

    test('always fits in a positive 32-bit int', () {
      // Android notification ids are signed 32-bit; a negative or oversized
      // value would be rejected at display time.
      for (final id in ['a', 'some-very-long-notification-id-abcdef', '12345']) {
        final payload =
            NotificationPushPayload.tryParse({'notificationId': id})!;
        expect(payload.systemNotificationId, greaterThanOrEqualTo(0));
        expect(payload.systemNotificationId, lessThanOrEqualTo(0x7fffffff));
      }
    });
  });

  group('provisional item', () {
    test('never attributes an automated push to a human sender', () {
      final payload = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
        'isAutomated': 'true',
        'sourceModule': 'attendance',
      })!;

      final item = payload.toProvisionalItem();

      expect(item.senderIdentity.isAutomated, isTrue);
      expect(item.senderName, 'Automated System');
      expect(item.senderIdentity.sourceModule, 'attendance');
    });

    test('marks itself provisional so it is not mistaken for the record', () {
      final item = NotificationPushPayload.tryParse({
        'notificationId': 'n1',
      })!.toProvisionalItem();

      expect(item.metadata['provisional'], 'true');
      expect(item.pushDeliveryStatus, NotificationDeliveryStatus.delivered);
      expect(item.deliveredAt, isNotNull);
    });
  });
}
