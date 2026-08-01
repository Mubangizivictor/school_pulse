import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/data/mappers/notification_mapper.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';

void main() {
  group('fromFirestore', () {
    test('maps a complete document', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'schoolId': 'school-1',
        'recipientUserId': 'user-1',
        'title': 'Report published',
        'shortBody': 'Term 2 report is ready',
        'fullBody': 'The full report card is now available.',
        'category': 'results',
        'type': 'reportCardPublished',
        'priority': 'high',
        'senderId': 'staff-1',
        'senderNameSnapshot': 'Sarah Namusoke',
        'senderRoleSnapshot': 'Class Teacher',
        'senderKind': 'human',
        'relatedStudentId': 'student-1',
        'isRead': true,
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 1, 9)),
      });

      expect(item.id, 'doc-1');
      expect(item.category, NotificationCategory.results);
      expect(item.type, NotificationType.reportCardPublished);
      expect(item.priority, NotificationPriority.high);
      expect(item.longMessage, 'The full report card is now available.');
      expect(item.status, NotificationStatus.read);
      expect(item.senderIdentity.isAutomated, isFalse);
    });

    test('derives the category from the type when absent', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'type': 'busDelayed',
        'title': 'Bus late',
      });

      expect(item.category, NotificationCategory.transport);
    });

    test('treats a document with no sender id as automated', () {
      // Otherwise an automated event would be attributed to a human sender,
      // which the spec explicitly forbids.
      final item = NotificationMapper.fromFirestore('doc-1', {
        'title': 'Gate scan',
        'type': 'gateEntry',
      });

      expect(item.senderIdentity.isAutomated, isTrue);
      expect(item.senderName, 'Automated System');
    });

    test('survives a document missing every optional field', () {
      final item = NotificationMapper.fromFirestore('doc-1', {});

      expect(item.id, 'doc-1');
      expect(item.title, 'School Pulse');
      expect(item.description, '');
      expect(item.status, NotificationStatus.unread);
    });

    test('accepts timestamps as Timestamp, ISO string or epoch millis', () {
      final asTimestamp = NotificationMapper.fromFirestore('a', {
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 1)),
      });
      final asString = NotificationMapper.fromFirestore('b', {
        'createdAt': '2026-08-01T00:00:00.000',
      });
      final asMillis = NotificationMapper.fromFirestore('c', {
        'createdAt': DateTime(2026, 8, 1).millisecondsSinceEpoch,
      });

      expect(asTimestamp.timestamp, DateTime(2026, 8, 1));
      expect(asString.timestamp, DateTime(2026, 8, 1));
      expect(asMillis.timestamp, DateTime(2026, 8, 1));
    });

    test('pinned wins over read so a pin survives being read', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'isPinned': true,
        'isRead': true,
      });

      expect(item.status, NotificationStatus.pinned);
    });

    test('archived wins over pinned', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'isArchived': true,
        'isPinned': true,
      });

      expect(item.status, NotificationStatus.archived);
      expect(item.isArchived, isTrue);
    });

    test('infers read state from readAt when isRead is absent', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'readAt': Timestamp.fromDate(DateTime(2026, 8, 1)),
      });

      expect(item.status, NotificationStatus.read);
    });

    test('applies the category default for acknowledgement', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'category': 'emergency',
      });

      expect(item.requiresAcknowledgment, isTrue);
    });

    test('parses attachments and actions defensively', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'attachments': [
          {'name': 'a.pdf', 'type': 'PDF', 'size': '1 MB', 'url': 'u'},
          {'name': 'incomplete'},
          'not a map',
        ],
        'actionButtons': [
          {'id': 'view', 'label': 'View', 'deepLinkRoute': '/parent/fees'},
        ],
      });

      expect(item.attachments, hasLength(2));
      expect(item.attachments[1].type, '');
      expect(item.actions, hasLength(1));
      expect(item.actions.first.id, 'view');
    });

    test('ignores a malformed metadata map rather than throwing', () {
      final item = NotificationMapper.fromFirestore('doc-1', {
        'metadata': 'not a map',
      });

      expect(item.metadata, isEmpty);
    });
  });

  group('toFirestore', () {
    test('never writes recipient engagement state', () {
      // A full document write must not clobber another device's read receipt.
      final map = NotificationMapper.toFirestore(
        NotificationItem(
          id: 'n1',
          title: 'T',
          description: 'B',
          senderName: 'Office',
          senderRole: 'Admin',
          timestamp: DateTime(2026, 8, 1),
          category: NotificationCategory.announcements,
          priority: NotificationPriority.medium,
          schoolId: 'school-1',
          recipientUserId: 'user-1',
          readAt: DateTime(2026, 8, 1),
          acknowledgedAt: DateTime(2026, 8, 1),
        ),
      );

      expect(map['isRead'], isFalse);
      expect(map.containsKey('readAt'), isFalse);
      expect(map.containsKey('acknowledgedAt'), isFalse);
      expect(map.containsKey('openedAt'), isFalse);
    });

    test('round-trips through fromFirestore', () {
      final original = NotificationItem(
        id: 'n1',
        title: 'Fees due',
        description: 'Balance outstanding',
        senderName: 'Finance Office',
        senderRole: 'Bursar',
        timestamp: DateTime(2026, 8, 1),
        category: NotificationCategory.finance,
        priority: NotificationPriority.high,
        type: NotificationType.feeReminder,
        schoolId: 'school-1',
        recipientUserId: 'user-1',
        relatedStudentId: 'student-1',
        longMessage: 'Full detail here.',
      );

      final map = NotificationMapper.toFirestore(original);
      // serverTimestamp sentinels cannot round-trip; substitute a real value.
      map['createdAt'] = Timestamp.fromDate(original.timestamp);

      final restored = NotificationMapper.fromFirestore('n1', map);

      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.longMessage, original.longMessage);
      expect(restored.category, original.category);
      expect(restored.type, original.type);
      expect(restored.priority, original.priority);
      expect(restored.relatedStudentId, original.relatedStudentId);
      expect(restored.senderName, original.senderName);
    });
  });

  group('stateUpdate', () {
    test('marking read sets both the flag and the timestamp', () {
      final update = NotificationMapper.stateUpdate('read');
      expect(update['isRead'], isTrue);
      expect(update.containsKey('readAt'), isTrue);
    });

    test('marking unread clears the timestamp', () {
      final update = NotificationMapper.stateUpdate('unread');
      expect(update['isRead'], isFalse);
      expect(update['readAt'], isA<FieldValue>());
    });

    test('acknowledging implies read', () {
      final update = NotificationMapper.stateUpdate('acknowledged');
      expect(update['isRead'], isTrue);
      expect(update.containsKey('acknowledgedAt'), isTrue);
    });

    test('opening does not mark read', () {
      // Opened and read are separate states per spec.
      final update = NotificationMapper.stateUpdate('opened');
      expect(update.containsKey('openedAt'), isTrue);
      expect(update.containsKey('isRead'), isFalse);
    });

    test('pin and archive carry the requested value', () {
      expect(NotificationMapper.stateUpdate('pinned', value: false)['isPinned'],
          isFalse);
      expect(
        NotificationMapper.stateUpdate('archived', value: true)['isArchived'],
        isTrue,
      );
    });

    test('an unknown field produces no write', () {
      expect(NotificationMapper.stateUpdate('bogus'), isEmpty);
    });
  });
}
