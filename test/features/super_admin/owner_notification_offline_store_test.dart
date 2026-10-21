import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_notification_offline_store.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

OwnerNotification _n(
  String id, {
  String owner = 'owner-a',
  String status = 'unread',
}) {
  return OwnerNotification.fromJson({
    'id': id,
    'ownerId': owner,
    'type': 'manual_payment_submitted',
    'status': status,
    'title': 'Payment verification required',
    'body': 'A school submitted a proof',
    'schoolName': 'Demo School',
    'createdAt': DateTime.utc(2026, 9, 1).toIso8601String(),
  });
}

void main() {
  late OwnerNotificationOfflineStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = OwnerNotificationOfflineStore(
      prefs: await SharedPreferences.getInstance(),
    );
  });

  group('cache', () {
    test('reads back what was written, scoped to the owner', () async {
      await store.writeCache('owner-a', [_n('n1'), _n('n2')]);
      final cached = await store.readCache('owner-a');
      expect(cached.map((n) => n.id), ['n1', 'n2']);

      // A different owner sees nothing.
      expect(await store.readCache('owner-b'), isEmpty);
    });

    test(
      'reconcile evicts rows and queued actions no longer on the server',
      () async {
        await store.writeCache('owner-a', [_n('n1'), _n('n2'), _n('n3')]);
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.markRead,
          notificationId: 'n3',
        );

        await store.reconcile('owner-a', {'n1', 'n2'});

        expect((await store.readCache('owner-a')).map((n) => n.id), [
          'n1',
          'n2',
        ]);
        expect(await store.readQueue('owner-a'), isEmpty);
      },
    );
  });

  group('queue', () {
    test('enqueue carries the full envelope', () async {
      final action = await store.enqueue(
        ownerId: 'owner-a',
        type: OwnerQueuedActionType.delete,
        notificationId: 'n7',
      );
      expect(action.ownerId, 'owner-a');
      expect(action.type, OwnerQueuedActionType.delete);
      expect(action.notificationId, 'n7');
      expect(action.idempotencyKey, isNotEmpty);
      expect(action.attempts, 0);
      expect(action.createdAt, isNotNull);
    });

    test(
      'markAllRead / clearAll / updatePreferences collapse duplicates',
      () async {
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.markAllRead,
        );
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.markAllRead,
        );
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.clearAll,
        );

        final queue = await store.readQueue('owner-a');
        expect(
          queue
              .where((a) => a.type == OwnerQueuedActionType.markAllRead)
              .length,
          1,
        );
      },
    );

    test('sync sends each action once and drains the queue', () async {
      await store.enqueue(
        ownerId: 'owner-a',
        type: OwnerQueuedActionType.markRead,
        notificationId: 'n1',
      );
      await store.enqueue(
        ownerId: 'owner-a',
        type: OwnerQueuedActionType.markRead,
        notificationId: 'n2',
      );

      final sent = <String?>[];
      final result = await store.sync(
        ownerId: 'owner-a',
        send: (action) async => sent.add(action.notificationId),
      );

      expect(sent, ['n1', 'n2']);
      expect(result.synced, 2);
      expect(result.remaining, 0);
      expect(await store.readQueue('owner-a'), isEmpty);
    });

    test(
      'a permanent failure drops the action; a transient one is retried',
      () async {
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.delete,
          notificationId: 'gone',
        );
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.markRead,
          notificationId: 'later',
        );

        final result = await store.sync(
          ownerId: 'owner-a',
          send: (action) async {
            if (action.notificationId == 'gone') {
              throw const OwnerPermanentSyncError('not-found');
            }
            throw Exception('unavailable');
          },
        );

        expect(result.synced, 0);
        expect(result.dropped, 1); // 'gone'
        expect(result.remaining, 1); // 'later', bumped

        final queue = await store.readQueue('owner-a');
        expect(queue.single.notificationId, 'later');
        expect(queue.single.attempts, 1);
      },
    );

    test(
      'retry is idempotent: replaying a synced queue does nothing',
      () async {
        await store.enqueue(
          ownerId: 'owner-a',
          type: OwnerQueuedActionType.markRead,
          notificationId: 'n1',
        );
        var calls = 0;
        await store.sync(ownerId: 'owner-a', send: (_) async => calls++);
        await store.sync(ownerId: 'owner-a', send: (_) async => calls++);
        expect(calls, 1);
      },
    );

    test('an action retried up to maxAttempts is finally dropped', () async {
      await store.enqueue(
        ownerId: 'owner-a',
        type: OwnerQueuedActionType.markRead,
        notificationId: 'n1',
      );
      for (var i = 0; i < 6; i++) {
        await store.sync(
          ownerId: 'owner-a',
          send: (_) async => throw Exception('unavailable'),
          maxAttempts: 3,
        );
      }
      expect(await store.readQueue('owner-a'), isEmpty);
    });
  });

  group('teardown', () {
    test('clearForOwner wipes only that owner', () async {
      await store.writeCache('owner-a', [_n('n1')]);
      await store.writeCache('owner-b', [_n('x1', owner: 'owner-b')]);
      await store.enqueue(
        ownerId: 'owner-a',
        type: OwnerQueuedActionType.clearAll,
      );

      await store.clearForOwner('owner-a');

      expect(await store.readCache('owner-a'), isEmpty);
      expect(await store.readQueue('owner-a'), isEmpty);
      expect(await store.readCache('owner-b'), isNotEmpty);
    });

    test('clearEverything wipes all owners (full sign-out)', () async {
      await store.writeCache('owner-a', [_n('n1')]);
      await store.writeCache('owner-b', [_n('x1', owner: 'owner-b')]);

      await store.clearEverything();

      expect(await store.readCache('owner-a'), isEmpty);
      expect(await store.readCache('owner-b'), isEmpty);
    });
  });
}
