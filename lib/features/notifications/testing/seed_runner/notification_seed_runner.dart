import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../data/models/notification_isar.dart';
import '../../data/seed/notification_seed_data.dart';

/// Result of a seed or removal run, for display in the test screen.
@immutable
class SeedOutcome {
  final bool ran;
  final int written;
  final int removed;
  final String message;

  const SeedOutcome({
    required this.ran,
    this.written = 0,
    this.removed = 0,
    required this.message,
  });
}

/// Installs and removes development seed notifications.
///
/// Writes only to the local Isar cache, never to Firestore. That keeps the
/// seed genuinely development-only - it cannot leak into a real tenant, cannot
/// be pushed to anybody's device, and disappears when app data is cleared.
///
/// Guarded by [kReleaseMode]: in a release build every method refuses and
/// reports why, so seed data can never appear in a build handed to a school.
class NotificationSeedRunner {
  final Isar isar;

  NotificationSeedRunner({required this.isar});

  /// True when seeding is permitted in this build.
  static bool get isPermitted => !kReleaseMode;

  /// Writes the seed set for [recipientUserId].
  ///
  /// Idempotent: seeded ids are deterministic, and the unique index on
  /// `notificationId` replaces rather than duplicates, so running this twice
  /// leaves exactly one copy of each record.
  Future<SeedOutcome> seed({
    required String schoolId,
    required String recipientUserId,
    required String recipientRole,
  }) async {
    if (!isPermitted) {
      return const SeedOutcome(
        ran: false,
        message: 'Seed data is disabled in release builds.',
      );
    }

    final items = NotificationSeedData.build(
      schoolId: schoolId,
      recipientUserId: recipientUserId,
      recipientRole: recipientRole,
    );

    final rows = items
        .map((item) => NotificationIsar.fromEntity(
              item,
              schoolId: schoolId,
              recipientUserId: recipientUserId,
              syncedAt: DateTime.now(),
            ))
        .toList();

    await isar.writeTxn(() async {
      await isar.notificationIsars.putAll(rows);
    });

    return SeedOutcome(
      ran: true,
      written: rows.length,
      message: 'Seeded ${rows.length} development notifications.',
    );
  }

  /// Removes every seeded record for this recipient, leaving real ones intact.
  Future<SeedOutcome> remove({
    required String schoolId,
    required String recipientUserId,
  }) async {
    if (!isPermitted) {
      return const SeedOutcome(
        ran: false,
        message: 'Seed data is disabled in release builds.',
      );
    }

    var removed = 0;
    await isar.writeTxn(() async {
      // Matched by id prefix so only seeded rows are touched - a real
      // notification can never carry this prefix, since real ids are
      // Firestore document ids.
      removed = await isar.notificationIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .and()
          .recipientUserIdEqualTo(recipientUserId)
          .and()
          .notificationIdStartsWith(NotificationSeedData.seedIdPrefix)
          .deleteAll();
    });

    return SeedOutcome(
      ran: true,
      removed: removed,
      message: 'Removed $removed seeded notifications.',
    );
  }

  /// How many seeded records currently exist for this recipient.
  Future<int> count({
    required String schoolId,
    required String recipientUserId,
  }) {
    return isar.notificationIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .and()
        .recipientUserIdEqualTo(recipientUserId)
        .and()
        .notificationIdStartsWith(NotificationSeedData.seedIdPrefix)
        .count();
  }
}
