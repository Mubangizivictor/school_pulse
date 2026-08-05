import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_model.dart';

abstract class NotificationCenterEvent extends Equatable {
  const NotificationCenterEvent();

  @override
  List<Object?> get props => [];
}

/// Starts watching this user's notifications. Safe to dispatch more than once;
/// the bloc replaces any existing subscription.
class NotificationCenterStarted extends NotificationCenterEvent {
  final String schoolId;
  final String userId;

  const NotificationCenterStarted({
    required this.schoolId,
    required this.userId,
  });

  @override
  List<Object?> get props => [schoolId, userId];
}

/// Pull-to-refresh. Re-fetches the first page and drains any queued offline
/// state changes.
class NotificationCenterRefreshed extends NotificationCenterEvent {
  const NotificationCenterRefreshed();
}

/// Infinite scroll - appends the next page.
class NotificationCenterLoadedMore extends NotificationCenterEvent {
  const NotificationCenterLoadedMore();
}

class NotificationCenterFilterChanged extends NotificationCenterEvent {
  final Set<NotificationCategory>? categories;
  final Set<NotificationPriority>? priorities;
  final bool? isRead;
  final bool? pinnedOnly;
  final bool? includeArchived;
  final String? relatedStudentId;

  /// Clears every filter back to the default view.
  final bool reset;

  const NotificationCenterFilterChanged({
    this.categories,
    this.priorities,
    this.isRead,
    this.pinnedOnly,
    this.includeArchived,
    this.relatedStudentId,
    this.reset = false,
  });

  @override
  List<Object?> get props => [
    categories,
    priorities,
    isRead,
    pinnedOnly,
    includeArchived,
    relatedStudentId,
    reset,
  ];
}

class NotificationCenterSearched extends NotificationCenterEvent {
  final String term;

  const NotificationCenterSearched(this.term);

  @override
  List<Object?> get props => [term];
}

class NotificationMarkedRead extends NotificationCenterEvent {
  final String notificationId;

  const NotificationMarkedRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkedUnread extends NotificationCenterEvent {
  final String notificationId;

  const NotificationMarkedUnread(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Records that the user opened the notification or its destination. Distinct
/// from read - opening a deep link marks opened without necessarily displaying
/// the body.
class NotificationOpened extends NotificationCenterEvent {
  final String notificationId;

  const NotificationOpened(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationAcknowledged extends NotificationCenterEvent {
  final String notificationId;

  const NotificationAcknowledged(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationPinToggled extends NotificationCenterEvent {
  final String notificationId;
  final bool pinned;

  const NotificationPinToggled(this.notificationId, {required this.pinned});

  @override
  List<Object?> get props => [notificationId, pinned];
}

class NotificationArchiveToggled extends NotificationCenterEvent {
  final String notificationId;
  final bool archived;

  const NotificationArchiveToggled(
    this.notificationId, {
    required this.archived,
  });

  @override
  List<Object?> get props => [notificationId, archived];
}

class NotificationDeleted extends NotificationCenterEvent {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationAllMarkedRead extends NotificationCenterEvent {
  final Set<NotificationCategory> categories;

  const NotificationAllMarkedRead({this.categories = const {}});

  @override
  List<Object?> get props => [categories];
}

class NotificationAllArchived extends NotificationCenterEvent {
  final Set<NotificationCategory> categories;

  const NotificationAllArchived({this.categories = const {}});

  @override
  List<Object?> get props => [categories];
}

/// Emitted by the messaging module when a conversation is opened, so its
/// transient chat pings stop cluttering the notification centre.
class NotificationTransientCleared extends NotificationCenterEvent {
  final String sourceModule;
  final String sourceEntityId;

  const NotificationTransientCleared({
    required this.sourceModule,
    required this.sourceEntityId,
  });

  @override
  List<Object?> get props => [sourceModule, sourceEntityId];
}

/// Internal: a new page arrived from the repository stream.
class NotificationCenterDataReceived extends NotificationCenterEvent {
  final List<NotificationItem> items;
  final bool fromCache;
  final bool hasMore;

  const NotificationCenterDataReceived({
    required this.items,
    required this.fromCache,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, fromCache, hasMore];
}

/// Internal: unread/pinned counts changed.
class NotificationCountsReceived extends NotificationCenterEvent {
  final int unread;
  final int pinned;
  final int total;
  final int requiringAcknowledgement;

  const NotificationCountsReceived({
    required this.unread,
    required this.pinned,
    required this.total,
    required this.requiringAcknowledgement,
  });

  @override
  List<Object?> get props => [unread, pinned, total, requiringAcknowledgement];
}
