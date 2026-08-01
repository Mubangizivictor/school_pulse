import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/failures/notification_failure.dart';

enum NotificationCenterStatus { initial, loading, ready, failure }

class NotificationCenterState extends Equatable {
  final NotificationCenterStatus status;

  /// Everything loaded so far, newest first, after filters.
  final List<NotificationItem> items;

  final Set<NotificationCategory> categoryFilter;
  final Set<NotificationPriority> priorityFilter;
  final bool? readFilter;
  final bool pinnedOnly;
  final bool includeArchived;
  final String? studentFilter;
  final String searchTerm;

  final int unreadCount;
  final int pinnedCount;
  final int totalCount;
  final int acknowledgementCount;

  /// True while an additional page is being appended, so the list can show a
  /// footer spinner without blanking the rows already on screen.
  final bool isLoadingMore;
  final bool hasMore;

  /// True when the rows on screen came from the offline cache. The UI surfaces
  /// this so a parent knows they are looking at saved data.
  final bool isOffline;

  final NotificationFailure? failure;

  const NotificationCenterState({
    this.status = NotificationCenterStatus.initial,
    this.items = const [],
    this.categoryFilter = const {},
    this.priorityFilter = const {},
    this.readFilter,
    this.pinnedOnly = false,
    this.includeArchived = false,
    this.studentFilter,
    this.searchTerm = '',
    this.unreadCount = 0,
    this.pinnedCount = 0,
    this.totalCount = 0,
    this.acknowledgementCount = 0,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.isOffline = false,
    this.failure,
  });

  /// Unread subset, for the "Unread" tab. Derived rather than stored so it can
  /// never drift out of sync with [items].
  List<NotificationItem> get unread =>
      items.where((n) => n.status == NotificationStatus.unread).toList();

  List<NotificationItem> get pinned =>
      items.where((n) => n.status == NotificationStatus.pinned).toList();

  /// Notifications naming this user's student(s) - what the "Mentions" tab in
  /// the existing list screen shows.
  List<NotificationItem> get mentions =>
      items.where((n) => n.relatedStudentId != null).toList();

  bool get isEmpty =>
      status == NotificationCenterStatus.ready && items.isEmpty;

  /// Groups by calendar day for the date-grouped view, preserving order.
  Map<DateTime, List<NotificationItem>> get groupedByDay {
    final grouped = <DateTime, List<NotificationItem>>{};
    for (final item in items) {
      final day = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return grouped;
  }

  Map<NotificationCategory, List<NotificationItem>> get groupedByCategory {
    final grouped = <NotificationCategory, List<NotificationItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  NotificationCenterState copyWith({
    NotificationCenterStatus? status,
    List<NotificationItem>? items,
    Set<NotificationCategory>? categoryFilter,
    Set<NotificationPriority>? priorityFilter,
    bool? readFilter,
    bool clearReadFilter = false,
    bool? pinnedOnly,
    bool? includeArchived,
    String? studentFilter,
    bool clearStudentFilter = false,
    String? searchTerm,
    int? unreadCount,
    int? pinnedCount,
    int? totalCount,
    int? acknowledgementCount,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isOffline,
    NotificationFailure? failure,
    bool clearFailure = false,
  }) {
    return NotificationCenterState(
      status: status ?? this.status,
      items: items ?? this.items,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      readFilter: clearReadFilter ? null : (readFilter ?? this.readFilter),
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      includeArchived: includeArchived ?? this.includeArchived,
      studentFilter:
          clearStudentFilter ? null : (studentFilter ?? this.studentFilter),
      searchTerm: searchTerm ?? this.searchTerm,
      unreadCount: unreadCount ?? this.unreadCount,
      pinnedCount: pinnedCount ?? this.pinnedCount,
      totalCount: totalCount ?? this.totalCount,
      acknowledgementCount: acknowledgementCount ?? this.acknowledgementCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        categoryFilter,
        priorityFilter,
        readFilter,
        pinnedOnly,
        includeArchived,
        studentFilter,
        searchTerm,
        unreadCount,
        pinnedCount,
        totalCount,
        acknowledgementCount,
        isLoadingMore,
        hasMore,
        isOffline,
        failure,
      ];
}
