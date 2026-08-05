import 'package:flutter/foundation.dart';

import '../entities/notification_category_config.dart';
import '../entities/notification_model.dart';

/// One category's contribution to a digest.
@immutable
class DigestSection {
  final NotificationCategory category;
  final String heading;

  /// One line per notification, already worded for reading in a summary.
  final List<String> lines;

  /// How many notifications this section represents, which can exceed
  /// [lines] when the section was truncated.
  final int totalCount;

  const DigestSection({
    required this.category,
    required this.heading,
    required this.lines,
    required this.totalCount,
  });

  bool get isTruncated => totalCount > lines.length;
}

/// A composed digest, ready to be shown or sent.
@immutable
class NotificationDigest {
  final String title;
  final String summary;
  final List<DigestSection> sections;
  final DateTime from;
  final DateTime to;

  /// Notifications the digest deliberately excluded because they were urgent
  /// and already delivered individually. Surfaced so a caller can assert that
  /// nothing important was swallowed.
  final int excludedUrgentCount;

  const NotificationDigest({
    required this.title,
    required this.summary,
    required this.sections,
    required this.from,
    required this.to,
    this.excludedUrgentCount = 0,
  });

  bool get isEmpty => sections.isEmpty;

  int get totalCount =>
      sections.fold(0, (sum, section) => sum + section.totalCount);

  /// Plain-text rendering, used for the email/SMS copy and as the notification
  /// body when the digest is delivered in-app.
  String toPlainText() {
    final buffer = StringBuffer()
      ..writeln(title)
      ..writeln()
      ..writeln(summary)
      ..writeln();

    for (final section in sections) {
      buffer.writeln(section.heading);
      for (final line in section.lines) {
        buffer.writeln('  • $line');
      }
      if (section.isTruncated) {
        final remaining = section.totalCount - section.lines.length;
        buffer.writeln('  • …and $remaining more');
      }
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }
}

/// Composes daily and weekly digests from a set of notifications.
///
/// Digests exist to reduce notification fatigue: a parent who would otherwise
/// receive nine low-priority pings across a day gets one summary instead.
///
/// Pure and dependency-free so the same composition can run on the client for
/// an in-app summary, or on the server for an email or SMS copy.
class NotificationDigestBuilder {
  const NotificationDigestBuilder();

  /// Maximum lines shown per category before the section is truncated. Keeps a
  /// digest scannable rather than reproducing the whole notification centre.
  static const maxLinesPerSection = 5;

  /// Builds a digest covering [notifications].
  ///
  /// Urgent notifications and anything requiring acknowledgement are excluded
  /// on purpose: those were delivered individually at the time and must not be
  /// deferred into a summary, which is the spec's rule that emergency alerts
  /// never wait for a digest.
  NotificationDigest build({
    required List<NotificationItem> notifications,
    required DateTime from,
    required DateTime to,
    required bool isWeekly,
    String? recipientName,
  }) {
    final eligible = <NotificationItem>[];
    var excludedUrgent = 0;

    for (final notification in notifications) {
      if (notification.timestamp.isBefore(from) ||
          notification.timestamp.isAfter(to)) {
        continue;
      }
      if (notification.isArchived) continue;

      final isUrgent =
          notification.priority == NotificationPriority.urgent ||
          notification.requiresAcknowledgment ||
          NotificationCategoryCatalog.of(notification.category).isMandatory;

      if (isUrgent) {
        excludedUrgent++;
        continue;
      }

      // A chat ping is a pointer to a conversation, not news worth restating
      // in a summary a day later.
      if (notification.isTransient) continue;

      eligible.add(notification);
    }

    final grouped = <NotificationCategory, List<NotificationItem>>{};
    for (final notification in eligible) {
      grouped.putIfAbsent(notification.category, () => []).add(notification);
    }

    final sections = <DigestSection>[];
    // Ordered by category importance so a fee reminder is not buried beneath
    // a club notice.
    final orderedCategories = grouped.keys.toList()
      ..sort((a, b) => _categoryRank(a).compareTo(_categoryRank(b)));

    for (final category in orderedCategories) {
      final items = grouped[category]!
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final config = NotificationCategoryCatalog.of(category);

      sections.add(
        DigestSection(
          category: category,
          heading: config.displayName,
          lines: items.take(maxLinesPerSection).map(_lineFor).toList(),
          totalCount: items.length,
        ),
      );
    }

    return NotificationDigest(
      title: isWeekly ? 'Your week at school' : 'Your day at school',
      summary: _summaryFor(
        count: eligible.length,
        unread: eligible.where((n) => !n.isRead).length,
        isWeekly: isWeekly,
        recipientName: recipientName,
      ),
      sections: sections,
      from: from,
      to: to,
      excludedUrgentCount: excludedUrgent,
    );
  }

  /// One digest line for a notification.
  ///
  /// Leads with the student's name where there is one, because a parent with
  /// several children needs to know which one a line concerns before reading
  /// the rest of it.
  String _lineFor(NotificationItem notification) {
    final student = notification.relatedStudentName;
    final base = notification.description.trim().isEmpty
        ? notification.title
        : notification.description.trim();

    if (student == null || student.isEmpty) return base;
    // Avoid "Brian: Brian was marked absent".
    if (base.toLowerCase().contains(student.toLowerCase())) return base;
    return '$student: $base';
  }

  String _summaryFor({
    required int count,
    required int unread,
    required bool isWeekly,
    String? recipientName,
  }) {
    final period = isWeekly ? 'this week' : 'today';
    final greeting = recipientName == null ? '' : 'Hello $recipientName. ';

    if (count == 0) {
      return '${greeting}Nothing new $period.';
    }
    if (unread == 0) {
      return '$greeting$count update${count == 1 ? '' : 's'} $period, '
          'all of which you have already seen.';
    }
    return '$greeting$count update${count == 1 ? '' : 's'} $period, '
        '$unread still unread.';
  }

  /// Sort weight for digest sections. Lower sorts first.
  static int _categoryRank(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.finance:
        return 0;
      case NotificationCategory.results:
      case NotificationCategory.examinations:
        return 1;
      case NotificationCategory.homework:
        return 2;
      case NotificationCategory.timetable:
      case NotificationCategory.appointments:
        return 3;
      case NotificationCategory.transport:
        return 4;
      case NotificationCategory.announcements:
        return 5;
      case NotificationCategory.events:
        return 6;
      case NotificationCategory.library:
        return 7;
      default:
        return 8;
    }
  }
}
