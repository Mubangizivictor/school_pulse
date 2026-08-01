import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_digest_builder.dart';

NotificationItem _item({
  String id = 'n1',
  String title = 'Title',
  String description = 'Body',
  NotificationCategory category = NotificationCategory.announcements,
  NotificationPriority priority = NotificationPriority.medium,
  NotificationPersistence persistence = NotificationPersistence.permanent,
  bool requiresAcknowledgment = false,
  bool isArchived = false,
  String? relatedStudentName,
  DateTime? at,
  NotificationStatus status = NotificationStatus.unread,
}) {
  return NotificationItem(
    id: id,
    title: title,
    description: description,
    senderName: 'Office',
    senderRole: 'Admin',
    timestamp: at ?? DateTime(2026, 8, 1, 10),
    category: category,
    priority: priority,
    persistence: persistence,
    requiresAcknowledgment: requiresAcknowledgment,
    isArchived: isArchived,
    relatedStudentName: relatedStudentName,
    status: status,
  );
}

void main() {
  const builder = NotificationDigestBuilder();
  final from = DateTime(2026, 8, 1);
  final to = DateTime(2026, 8, 1, 23, 59);

  NotificationDigest build(List<NotificationItem> items, {bool weekly = false}) {
    return builder.build(
      notifications: items,
      from: from,
      to: to,
      isWeekly: weekly,
    );
  }

  group('exclusions', () {
    test('an emergency alert is never deferred into a digest', () {
      final digest = build([
        _item(
          category: NotificationCategory.emergency,
          priority: NotificationPriority.urgent,
        ),
      ]);

      expect(digest.isEmpty, isTrue);
      expect(digest.excludedUrgentCount, 1);
    });

    test('anything requiring acknowledgement is excluded', () {
      final digest = build([_item(requiresAcknowledgment: true)]);

      expect(digest.isEmpty, isTrue);
      expect(digest.excludedUrgentCount, 1);
    });

    test('mandatory categories are excluded even at normal priority', () {
      final digest = build([
        _item(category: NotificationCategory.attendance),
        _item(id: 'n2', category: NotificationCategory.medical),
      ]);

      expect(digest.isEmpty, isTrue);
      expect(digest.excludedUrgentCount, 2);
    });

    test('transient chat pings are excluded', () {
      final digest = build([
        _item(
          category: NotificationCategory.messages,
          persistence: NotificationPersistence.transient,
        ),
      ]);

      expect(digest.isEmpty, isTrue);
      // Not counted as urgent - it was excluded for being transient.
      expect(digest.excludedUrgentCount, 0);
    });

    test('archived notifications are excluded', () {
      final digest = build([_item(isArchived: true)]);
      expect(digest.isEmpty, isTrue);
    });

    test('notifications outside the window are excluded', () {
      final digest = build([_item(at: DateTime(2026, 7, 20))]);
      expect(digest.isEmpty, isTrue);
    });
  });

  group('composition', () {
    test('groups by category and counts each section', () {
      final digest = build([
        _item(id: 'a', category: NotificationCategory.homework),
        _item(id: 'b', category: NotificationCategory.homework),
        _item(id: 'c', category: NotificationCategory.library),
      ]);

      expect(digest.sections, hasLength(2));
      expect(digest.totalCount, 3);

      final homework = digest.sections
          .firstWhere((s) => s.category == NotificationCategory.homework);
      expect(homework.totalCount, 2);
    });

    test('orders finance above club-type notices', () {
      final digest = build([
        _item(id: 'a', category: NotificationCategory.clubs),
        _item(id: 'b', category: NotificationCategory.finance),
      ]);

      expect(digest.sections.first.category, NotificationCategory.finance);
    });

    test('truncates a long section and reports the true total', () {
      final items = List.generate(
        9,
        (i) => _item(id: 'n$i', category: NotificationCategory.events),
      );

      final digest = build(items);
      final section = digest.sections.single;

      expect(section.lines, hasLength(NotificationDigestBuilder.maxLinesPerSection));
      expect(section.totalCount, 9);
      expect(section.isTruncated, isTrue);
      expect(digest.toPlainText(), contains('and 4 more'));
    });

    test('prefixes the student name so a parent knows who it concerns', () {
      final digest = build([
        _item(
          category: NotificationCategory.homework,
          description: 'New Mathematics homework assigned',
          relatedStudentName: 'Brian',
        ),
      ]);

      expect(digest.sections.single.lines.single, startsWith('Brian:'));
    });

    test('does not repeat a student name already in the text', () {
      final digest = build([
        _item(
          category: NotificationCategory.homework,
          description: 'Brian was assigned new homework',
          relatedStudentName: 'Brian',
        ),
      ]);

      expect(digest.sections.single.lines.single, 'Brian was assigned new homework');
    });
  });

  group('summary', () {
    test('says nothing new when there is nothing to report', () {
      final digest = build(const []);
      expect(digest.summary, contains('Nothing new'));
      expect(digest.isEmpty, isTrue);
    });

    test('reports the unread count', () {
      final digest = build([
        _item(id: 'a', category: NotificationCategory.events),
        _item(
          id: 'b',
          category: NotificationCategory.events,
          status: NotificationStatus.read,
        ),
      ]);

      expect(digest.summary, contains('2 updates'));
      expect(digest.summary, contains('1 still unread'));
    });

    test('titles a weekly digest differently from a daily one', () {
      expect(build(const []).title, 'Your day at school');
      expect(build(const [], weekly: true).title, 'Your week at school');
    });
  });

  group('plain text', () {
    test('renders headings and bulleted lines', () {
      final digest = build([
        _item(
          category: NotificationCategory.finance,
          description: 'Term 2 fees are due',
        ),
      ]);

      final text = digest.toPlainText();
      expect(text, contains('Your day at school'));
      expect(text, contains('Finance'));
      expect(text, contains('• Term 2 fees are due'));
    });
  });
}
