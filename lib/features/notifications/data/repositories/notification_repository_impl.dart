import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/failures/notification_failure.dart';
import '../../domain/policies/notification_delivery_policy.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/pending_notification_change.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';

/// Offline-first notification repository.
///
/// Reads serve the cache first and refresh from the server behind it; writes
/// apply locally, then attempt the server and leave a pending flag behind on
/// failure. The user therefore never waits on the network to mark something
/// read, and never loses that action if they were offline when they did it.
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;

  /// Whether the device currently has a usable connection. Injected rather
  /// than queried directly so tests can drive both paths.
  final Future<bool> Function() isConnected;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.isConnected,
  });

  @override
  Future<Either<NotificationFailure, NotificationPage>> getNotifications(
    NotificationQuery query,
  ) async {
    // Offline: serve whatever is cached. This is a success, not a failure -
    // the notification centre is expected to work on a bad connection.
    if (!await isConnected()) {
      return Right(await _cachedPage(query, fromCache: true));
    }

    try {
      final items = await remoteDataSource.fetch(query);
      await localDataSource.upsertAll(
        items,
        schoolId: query.schoolId,
        recipientUserId: query.recipientUserId,
      );
      return Right(_pageFrom(items, query, fromCache: false));
    } catch (e, stack) {
      _log('getNotifications failed, falling back to cache', e, stack);
      // A server error must not empty a list the user could otherwise read.
      final cached = await _cachedPage(query, fromCache: true);
      if (cached.items.isNotEmpty) return Right(cached);
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  @override
  Stream<NotificationPage> watchNotifications(NotificationQuery query) async* {
    // Paint from cache immediately so the list never opens blank, then follow
    // the server stream.
    final cached = await _cachedPage(query, fromCache: true);
    if (cached.items.isNotEmpty) yield cached;

    if (!await isConnected()) return;

    yield* remoteDataSource
        .watch(query)
        .asyncMap((items) async {
          await localDataSource.upsertAll(
            items,
            schoolId: query.schoolId,
            recipientUserId: query.recipientUserId,
          );
          return _pageFrom(items, query, fromCache: false);
        })
        .handleError((Object e, StackTrace stack) {
          // Swallowing here would leave the list silently frozen on stale data;
          // logging keeps the failure visible without tearing down the screen.
          _log('watchNotifications stream error', e, stack);
        });
  }

  Future<NotificationPage> _cachedPage(
    NotificationQuery query, {
    required bool fromCache,
  }) async {
    try {
      final items = await localDataSource.query(query);
      return _pageFrom(items, query, fromCache: fromCache);
    } catch (e, stack) {
      _log('cache read failed', e, stack);
      return NotificationPage.empty;
    }
  }

  NotificationPage _pageFrom(
    List<NotificationItem> items,
    NotificationQuery query, {
    required bool fromCache,
  }) {
    return NotificationPage(
      items: items,
      nextCursor: items.isEmpty ? null : items.last.timestamp,
      hasMore: items.length >= query.limit,
      fromCache: fromCache,
    );
  }

  @override
  Future<Either<NotificationFailure, NotificationItem>> getById({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  }) async {
    try {
      if (await isConnected()) {
        final remote = await remoteDataSource.getById(notificationId);
        if (remote != null) {
          // Tenant check runs client-side as well as in the security rules:
          // defence in depth, and it produces a clean failure rather than a
          // permission-denied exception surfacing in the UI.
          if (remote.schoolId != null && remote.schoolId != schoolId) {
            return const Left(NotificationTenantMismatchFailure());
          }
          if (remote.recipientUserId != null &&
              remote.recipientUserId != recipientUserId) {
            return const Left(NotificationTenantMismatchFailure());
          }
          await localDataSource.upsertAll(
            [remote],
            schoolId: schoolId,
            recipientUserId: recipientUserId,
          );
          return Right(remote);
        }
      }

      final cached = await localDataSource.getById(notificationId);
      if (cached == null) return const Left(NotificationNotFoundFailure());
      if (cached.schoolId != schoolId ||
          cached.recipientUserId != recipientUserId) {
        return const Left(NotificationTenantMismatchFailure());
      }
      return Right(cached);
    } catch (e, stack) {
      _log('getById failed', e, stack);
      final cached = await localDataSource.getById(notificationId);
      if (cached != null &&
          cached.schoolId == schoolId &&
          cached.recipientUserId == recipientUserId) {
        return Right(cached);
      }
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  @override
  Stream<NotificationCounts> watchCounts({
    required String schoolId,
    required String recipientUserId,
  }) {
    // Counts come from the local cache rather than a server aggregation query.
    // The cache is kept current by the watch stream, and this avoids billing a
    // count query every time a badge needs refreshing.
    return localDataSource.watchCounts(
      schoolId: schoolId,
      recipientUserId: recipientUserId,
    );
  }

  /// Applies a state change locally first, then to the server.
  ///
  /// The local write is what the UI reflects, so the change is instant and
  /// survives being made offline. If the server write fails the pending flag
  /// stays set and [syncPendingStateChanges] retries later.
  Future<Either<NotificationFailure, Unit>> _changeState({
    required String notificationId,
    required String field,
    bool value = true,
  }) async {
    try {
      await localDataSource.applyLocalStateChange(
        notificationId: notificationId,
        field: field,
        value: value,
      );
    } catch (e, stack) {
      _log('local state change failed', e, stack);
      return Left(NotificationCacheFailure(debugDetail: '$e'));
    }

    if (!await isConnected()) return const Right(unit);

    try {
      await remoteDataSource.applyStateChange(
        notificationId: notificationId,
        field: field,
        value: value,
      );
      await localDataSource.clearPendingFlags([notificationId]);
      return const Right(unit);
    } catch (e, stack) {
      // Deliberately still a success: the change is applied locally and queued.
      _log('remote state change queued for retry', e, stack);
      return const Right(unit);
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAsRead({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  }) => _changeState(notificationId: notificationId, field: PendingField.read);

  @override
  Future<Either<NotificationFailure, Unit>> markAsUnread({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  }) =>
      _changeState(notificationId: notificationId, field: PendingField.unread);

  @override
  Future<Either<NotificationFailure, Unit>> markAsOpened({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  }) =>
      _changeState(notificationId: notificationId, field: PendingField.opened);

  @override
  Future<Either<NotificationFailure, Unit>> acknowledge({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  }) => _changeState(
    notificationId: notificationId,
    field: PendingField.acknowledged,
  );

  @override
  Future<Either<NotificationFailure, Unit>> setPinned({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
    required bool pinned,
  }) => _changeState(
    notificationId: notificationId,
    field: PendingField.pinned,
    value: pinned,
  );

  @override
  Future<Either<NotificationFailure, Unit>> setArchived({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
    required bool archived,
  }) => _changeState(
    notificationId: notificationId,
    field: PendingField.archived,
    value: archived,
  );

  @override
  Future<Either<NotificationFailure, Unit>> delete({
    required String schoolId,
    required String notificationId,
    required String recipientUserId,
  }) async {
    try {
      await localDataSource.deleteById(notificationId);
      if (await isConnected()) {
        await remoteDataSource.delete(notificationId);
      }
      return const Right(unit);
    } catch (e, stack) {
      _log('delete failed', e, stack);
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> markAllAsRead({
    required String schoolId,
    required String recipientUserId,
    Set<NotificationCategory> categories = const {},
  }) async {
    try {
      await localDataSource.applyBulkLocalStateChange(
        schoolId: schoolId,
        recipientUserId: recipientUserId,
        field: PendingField.read,
        categories: categories,
      );
      if (await isConnected()) {
        await remoteDataSource.applyBulkStateChange(
          schoolId: schoolId,
          recipientUserId: recipientUserId,
          field: PendingField.read,
          categories: categories,
        );
        final pending = await localDataSource.getPendingStateChanges(
          schoolId: schoolId,
          recipientUserId: recipientUserId,
        );
        await localDataSource.clearPendingFlags(
          pending.map((r) => r.notificationId).toList(),
        );
      }
      return const Right(unit);
    } catch (e, stack) {
      _log('markAllAsRead partially applied', e, stack);
      // Local state is already updated and flagged, so the retry path covers
      // the server side.
      return const Right(unit);
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> archiveAll({
    required String schoolId,
    required String recipientUserId,
    Set<NotificationCategory> categories = const {},
  }) async {
    try {
      await localDataSource.applyBulkLocalStateChange(
        schoolId: schoolId,
        recipientUserId: recipientUserId,
        field: PendingField.archived,
        categories: categories,
      );
      if (await isConnected()) {
        await remoteDataSource.applyBulkStateChange(
          schoolId: schoolId,
          recipientUserId: recipientUserId,
          field: PendingField.archived,
          categories: categories,
        );
      }
      return const Right(unit);
    } catch (e, stack) {
      _log('archiveAll partially applied', e, stack);
      return const Right(unit);
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  }) async {
    try {
      await localDataSource.clearTransientForSource(
        schoolId: schoolId,
        recipientUserId: recipientUserId,
        sourceModule: sourceModule,
        sourceEntityId: sourceEntityId,
      );
      if (await isConnected()) {
        await remoteDataSource.clearTransientForSource(
          schoolId: schoolId,
          recipientUserId: recipientUserId,
          sourceModule: sourceModule,
          sourceEntityId: sourceEntityId,
        );
      }
      return const Right(unit);
    } catch (e, stack) {
      _log('clearTransientForSource failed', e, stack);
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> syncPendingStateChanges({
    required String schoolId,
    required String recipientUserId,
  }) async {
    if (!await isConnected()) return const Right(0);

    try {
      final pending = await localDataSource.getPendingStateChanges(
        schoolId: schoolId,
        recipientUserId: recipientUserId,
      );
      if (pending.isEmpty) return const Right(0);

      final synced = <String>[];
      for (final row in pending) {
        try {
          // Each queued field is pushed separately so one rejected field does
          // not discard the others recorded on the same notification.
          for (final field in row.pendingFields) {
            await remoteDataSource.applyStateChange(
              notificationId: row.notificationId,
              field: field,
              value: _valueForField(row, field),
            );
          }
          synced.add(row.notificationId);
        } catch (e, stack) {
          _log('sync failed for ${row.notificationId}', e, stack);
          // Leave the flag set; the next sync will retry this row.
        }
      }

      await localDataSource.clearPendingFlags(synced);
      return Right(synced.length);
    } catch (e, stack) {
      _log('syncPendingStateChanges failed', e, stack);
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  /// Recovers the boolean a pending pin/archive change was set to, so a queued
  /// un-pin is not replayed as a pin.
  static bool _valueForField(PendingNotificationChange row, String field) {
    switch (field) {
      case PendingField.pinned:
        return row.status == NotificationStatus.pinned;
      case PendingField.archived:
        return row.isArchived;
      default:
        return true;
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationPreferences>> getPreferences({
    required String schoolId,
    required String userId,
  }) async {
    try {
      if (await isConnected()) {
        final remote = await remoteDataSource.getPreferences(
          schoolId: schoolId,
          userId: userId,
        );
        if (remote != null) return Right(remote);
      }
      // No stored preferences yet is normal for a new user, not an error.
      return Right(
        NotificationPreferences.defaults(userId: userId, schoolId: schoolId),
      );
    } catch (e, stack) {
      _log('getPreferences failed, using defaults', e, stack);
      return Right(
        NotificationPreferences.defaults(userId: userId, schoolId: schoolId),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, Unit>> savePreferences(
    NotificationPreferences preferences,
  ) async {
    if (!await isConnected()) {
      return const Left(NotificationNetworkFailure());
    }
    try {
      await remoteDataSource.savePreferences(preferences);
      return const Right(unit);
    } catch (e, stack) {
      _log('savePreferences failed', e, stack);
      return Left(NotificationServerFailure(debugDetail: '$e'));
    }
  }

  @override
  Future<Either<NotificationFailure, SchoolNotificationPolicy>> getSchoolPolicy(
    String schoolId,
  ) async {
    if (schoolId.isEmpty) {
      return Right(SchoolNotificationPolicy.defaults(schoolId));
    }
    try {
      if (await isConnected()) {
        final policy = await remoteDataSource.getSchoolPolicy(schoolId);
        if (policy != null) return Right(policy);
      }
      return Right(SchoolNotificationPolicy.defaults(schoolId));
    } catch (e, stack) {
      _log('getSchoolPolicy failed, using defaults', e, stack);
      return Right(SchoolNotificationPolicy.defaults(schoolId));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> purgeExpired({
    required String schoolId,
    required String recipientUserId,
  }) async {
    try {
      final policyResult = await getSchoolPolicy(schoolId);
      final policy = policyResult.getOrElse(
        () => SchoolNotificationPolicy.defaults(schoolId),
      );

      final cutoffs = <NotificationCategory, DateTime>{};
      for (final category in NotificationCategory.values) {
        final cutoff = NotificationDeliveryPolicy.retentionCutoff(
          category: category,
          schoolPolicy: policy,
        );
        if (cutoff != null) cutoffs[category] = cutoff;
      }

      final removed = await localDataSource.purgeOlderThan(
        schoolId: schoolId,
        recipientUserId: recipientUserId,
        cutoffsByCategory: cutoffs,
      );
      return Right(removed);
    } catch (e, stack) {
      _log('purgeExpired failed', e, stack);
      return Left(NotificationCacheFailure(debugDetail: '$e'));
    }
  }

  static void _log(String message, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('[notifications] $message: $error');
    }
  }
}
