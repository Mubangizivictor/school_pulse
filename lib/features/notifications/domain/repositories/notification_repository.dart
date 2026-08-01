import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../entities/notification_model.dart';
import '../entities/notification_preferences.dart';
import '../failures/notification_failure.dart';

/// Filter/sort criteria for a notification-centre query.
///
/// Mirrors what the existing filter, search and grouped-centre screens already
/// offer, so those screens can hand their state straight to the repository.
@immutable
class NotificationQuery {
  final String schoolId;
  final String recipientUserId;

  final Set<NotificationCategory> categories;
  final Set<NotificationPriority> priorities;

  /// null = both read and unread.
  final bool? isRead;
  final bool includeArchived;
  final bool pinnedOnly;

  /// Free-text match over title, body and sender name.
  final String? searchTerm;

  /// Restricts to notifications about one student - the "group by student"
  /// view a parent with several children needs.
  final String? relatedStudentId;

  final DateTime? from;
  final DateTime? to;

  final int limit;

  /// Opaque cursor: the `timestamp` of the last row of the previous page.
  final DateTime? startAfter;

  const NotificationQuery({
    required this.schoolId,
    required this.recipientUserId,
    this.categories = const {},
    this.priorities = const {},
    this.isRead,
    this.includeArchived = false,
    this.pinnedOnly = false,
    this.searchTerm,
    this.relatedStudentId,
    this.from,
    this.to,
    this.limit = 30,
    this.startAfter,
  });

  NotificationQuery copyWith({
    Set<NotificationCategory>? categories,
    Set<NotificationPriority>? priorities,
    bool? isRead,
    bool? includeArchived,
    bool? pinnedOnly,
    String? searchTerm,
    String? relatedStudentId,
    DateTime? from,
    DateTime? to,
    int? limit,
    DateTime? startAfter,
    bool clearCursor = false,
  }) {
    return NotificationQuery(
      schoolId: schoolId,
      recipientUserId: recipientUserId,
      categories: categories ?? this.categories,
      priorities: priorities ?? this.priorities,
      isRead: isRead ?? this.isRead,
      includeArchived: includeArchived ?? this.includeArchived,
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      searchTerm: searchTerm ?? this.searchTerm,
      relatedStudentId: relatedStudentId ?? this.relatedStudentId,
      from: from ?? this.from,
      to: to ?? this.to,
      limit: limit ?? this.limit,
      startAfter: clearCursor ? null : (startAfter ?? this.startAfter),
    );
  }
}

/// One page of notifications plus the cursor needed to fetch the next.
@immutable
class NotificationPage {
  final List<NotificationItem> items;
  final DateTime? nextCursor;
  final bool hasMore;

  /// True when these rows came from the offline cache rather than the server.
  final bool fromCache;

  const NotificationPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.fromCache = false,
  });

  static const empty = NotificationPage(items: []);
}

/// Unread counts backing the tab badges on the notification list.
@immutable
class NotificationCounts {
  final int total;
  final int unread;
  final int pinned;
  final int requiringAcknowledgement;
  final Map<NotificationCategory, int> unreadByCategory;

  const NotificationCounts({
    this.total = 0,
    this.unread = 0,
    this.pinned = 0,
    this.requiringAcknowledgement = 0,
    this.unreadByCategory = const {},
  });

  static const empty = NotificationCounts();
}

/// Read/write access to a user's notifications.
///
/// Every method takes the tenant and recipient explicitly rather than reading
/// ambient state, so a caller cannot accidentally query across schools and the
/// implementation has the values it needs to enforce isolation.
abstract class NotificationRepository {
  /// One page, newest first. Falls back to the offline cache on network
  /// failure rather than erroring, with [NotificationPage.fromCache] set.
  Future<Either<NotificationFailure, NotificationPage>> getNotifications(
    NotificationQuery query,
  );

  /// Live stream for the notification centre. Emits the cached page first so
  /// the list paints immediately, then server updates as they arrive.
  Stream<NotificationPage> watchNotifications(NotificationQuery query);

  Future<Either<NotificationFailure, NotificationItem>> getById({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  });

  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  });

  /// Records that the user viewed the content. Queues locally when offline.
  Future<Either<NotificationFailure, Unit>> markAsRead({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  });

  Future<Either<NotificationFailure, Unit>> markAsUnread({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  });

  /// Records that the user opened the notification or its destination.
  /// Distinct from read: opening a deep link marks opened without necessarily
  /// having displayed the notification body.
  Future<Either<NotificationFailure, Unit>> markAsOpened({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  });

  /// Explicit confirmation for alerts that require it. Queues offline.
  Future<Either<NotificationFailure, Unit>> acknowledge({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  });

  Future<Either<NotificationFailure, Unit>> setPinned({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
    required bool pinned,
  });

  Future<Either<NotificationFailure, Unit>> setArchived({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
    required bool archived,
  });

  Future<Either<NotificationFailure, Unit>> delete({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  });

  Future<Either<NotificationFailure, Unit>> markAllAsRead({
    required String schoolId,
    required String recipientUserId,
    Set<NotificationCategory> categories = const {},
  });

  Future<Either<NotificationFailure, Unit>> archiveAll({
    required String schoolId,
    required String recipientUserId,
    Set<NotificationCategory> categories = const {},
  });

  /// Clears transient notifications whose source has been opened - the hook
  /// the messaging module calls when a conversation is opened, so chat pings
  /// do not linger in the centre.
  Future<Either<NotificationFailure, Unit>> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  });

  /// Pushes any locally queued read/acknowledge/archive operations. Called on
  /// reconnect and at app start.
  Future<Either<NotificationFailure, int>> syncPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  });

  Future<Either<NotificationFailure, NotificationPreferences>> getPreferences({
    required String schoolId,
    required String userId,
  });

  Future<Either<NotificationFailure, Unit>> savePreferences(
    NotificationPreferences preferences,
  );

  Future<Either<NotificationFailure, SchoolNotificationPolicy>> getSchoolPolicy(
    String schoolId,
  );

  /// Deletes cached rows past their retention cutoff.
  Future<Either<NotificationFailure, int>> purgeExpired({
    required String schoolId,
    required String recipientUserId,
  });
}
