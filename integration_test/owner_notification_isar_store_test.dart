import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_notification_isar_store.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_store.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

OwnerNotification _n(String id, {String owner = 'owner-a', String status = 'unread'}) =>
    OwnerNotification.fromJson({
      'id': id,
      'ownerId': owner,
      'category': 'billing',
      'severity': 'requires_review',
      'type': 'manual_payment_pending',
      'paymentId': 'p_$id',
      'status': status,
      'title': 'Payment awaiting review',
      'body': 'A school submitted a proof',
      'schoolName': 'Demo School',
      'reference': 'MOMO •••• 4821',
      'createdAt': DateTime.utc(2026, 9, 1).toIso8601String(),
    });

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late OwnerNotificationIsarStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('owner_notif_isar_');
    store = OwnerNotificationIsarStore(directoryOverride: dir);
  });

  tearDown(() async {
    for (final name in ['owner_notifications_owner-a', 'owner_notifications_owner-b']) {
      final i = Isar.getInstance(name);
      if (i != null && i.isOpen) await i.close(deleteFromDisk: true);
    }
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  testWidgets('caches and reads back a per-owner feed', (_) async {
    await store.writeCache('owner-a', [_n('n1'), _n('n2')]);
    final cached = await store.readCache('owner-a');
    expect(cached.length, 2);
    expect(cached.map((n) => n.id).toSet(), {'n1', 'n2'});
    expect(cached.first.reference, 'MOMO •••• 4821');
  });

  testWidgets('a different owner sees nothing — separate Isar instance', (_) async {
    await store.writeCache('owner-a', [_n('n1')]);
    expect(await store.readCache('owner-b'), isEmpty);
    expect(
      Isar.getInstance('owner_notifications_owner-a'),
      isNotNull,
    );
  });

  testWidgets('queue is idempotent across a reconnect sync', (_) async {
    await store.enqueue(
      ownerId: 'owner-a',
      type: OwnerQueuedActionType.markRead,
      notificationId: 'n1',
    );
    var calls = 0;
    await store.sync(ownerId: 'owner-a', send: (_) async => calls++);
    await store.sync(ownerId: 'owner-a', send: (_) async => calls++);
    expect(calls, 1);
    expect(await store.readQueue('owner-a'), isEmpty);
  });

  testWidgets('a delete supersedes a queued mark-read for the same id', (_) async {
    await store.enqueue(
      ownerId: 'owner-a',
      type: OwnerQueuedActionType.markRead,
      notificationId: 'n1',
    );
    await store.enqueue(
      ownerId: 'owner-a',
      type: OwnerQueuedActionType.delete,
      notificationId: 'n1',
    );
    final q = await store.readQueue('owner-a');
    expect(q.length, 1);
    expect(q.single.type, OwnerQueuedActionType.delete);
  });

  testWidgets('clearForOwner deletes the owner Isar instance from disk', (_) async {
    await store.writeCache('owner-a', [_n('n1')]);
    await store.enqueue(
      ownerId: 'owner-a',
      type: OwnerQueuedActionType.clearAll,
    );
    await store.clearForOwner('owner-a');

    expect(Isar.getInstance('owner_notifications_owner-a')?.isOpen ?? false, isFalse);
    // Re-opening starts empty.
    expect(await store.readCache('owner-a'), isEmpty);
    expect(await store.readQueue('owner-a'), isEmpty);
  });

  testWidgets('reconcile evicts rows no longer present server-side', (_) async {
    await store.writeCache('owner-a', [_n('n1'), _n('n2'), _n('n3')]);
    await store.reconcile('owner-a', {'n1', 'n2'});
    expect((await store.readCache('owner-a')).map((n) => n.id).toSet(), {'n1', 'n2'});
  });
}
