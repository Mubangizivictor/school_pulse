import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_offline_store.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_isar_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proves the owner notification stack is owner-only and shares nothing with
/// any school-role notification stack:
///  * routes  — the router guard denies every non-superAdmin session on the
///    whole `/super-admin*` tree, which contains the owner notification
///    routes (asserted here by path membership + guard presence);
///  * data    — the feed collection is `super_admin_notifications`, never a
///    `users/{uid}/...` or role notification path;
///  * cache   — the owner cache is namespaced by owner uid and the Isar
///    instance name is `owner_notifications_<uid>`;
///  * push    — device registration goes through the canonical, already
///    server-verified `registerOwnerNotificationDevice` /
///    `unregisterOwnerNotificationDevice` callables (never a client write
///    to `platform_owner_device_tokens` directly);
///  * teardown wipes all of it.
void main() {
  test('owner notification routes live entirely under the guarded '
      '/super-admin subtree', () {
    const ownerRoutes = [
      '/super-admin/notifications',
      '/super-admin/notifications/history',
    ];
    for (final r in ownerRoutes) {
      expect(r.startsWith('/super-admin'), isTrue);
    }
    final router = File('lib/app/router.dart').readAsStringSync();
    // The single synchronous guard that rejects every non-superAdmin
    // session before it ever reaches the owner-console subtree.
    expect(
      router.contains("state.uri.path.startsWith('/super-admin')"),
      isTrue,
    );
    expect(
      router.contains('authState.user.role != UserRole.superAdmin'),
      isTrue,
    );
    // The owner notification route is a guarded /super-admin sibling, defined
    // in the extracted subtree (commit d2d15ef1).
    final routes = File(
      'lib/features/super_admin/presentation/super_admin_routes.dart',
    ).readAsStringSync();
    expect(routes.contains("path: '/super-admin/notifications',"), isTrue);
    // ...and the whole subtree carries its own async owner-session redirect.
    expect(
      routes.contains('redirect: (context, state) => _superAdminRedirect'),
      isTrue,
    );
  });

  test('the feed collection is the owner collection, not a role path', () {
    final svc = File(
      'lib/features/super_admin/data/services/owner_notification_service.dart',
    ).readAsStringSync();
    expect(
      svc.contains("_feedCollection = 'super_admin_notifications'"),
      isTrue,
    );
    expect(svc.contains('users/'), isFalse);
    expect(svc.contains('staff/notifications'), isFalse);
    expect(svc.contains('parent/notifications'), isFalse);
    // It must not import any school-role notification code.
    expect(svc.contains("features/notifications/"), isFalse);
    expect(svc.contains("core/notification/"), isFalse);
  });

  test('owner push registration goes through the canonical server-verified '
      'callables, not a direct client Firestore write', () {
    final src = File(
      'lib/features/super_admin/data/services/owner_push_token_service.dart',
    ).readAsStringSync();
    expect(
      src.contains("httpsCallable('registerOwnerNotificationDevice')"),
      isTrue,
    );
    expect(
      src.contains("httpsCallable('unregisterOwnerNotificationDevice')"),
      isTrue,
    );
    // No direct client write to any token collection - registration is
    // callable-only so the server's send path and the client can never
    // drift onto different token stores.
    expect(src.contains('.collection('), isFalse);
  });

  test(
    'the owner Isar cache instance name is per-owner and owner-prefixed',
    () {
      expect(
        OwnerNotificationIsarStore.instanceNameFor('u1'),
        'owner_notifications_u1',
      );
      expect(
        OwnerNotificationIsarStore.instanceNameFor('u1'),
        isNot(OwnerNotificationIsarStore.instanceNameFor('u2')),
      );
    },
  );

  test(
    'a signed-out service caches / queues nothing and clears cleanly',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = OwnerNotificationOfflineStore(
        prefs: await SharedPreferences.getInstance(),
      );
      final svc = OwnerNotificationService.forTest(offlineStore: store);
      // forTest() has no auth -> currentOwnerId is null.
      expect(svc.currentOwnerId, isNull);
      expect(await svc.cachedNotifications(), isEmpty);
      expect(await svc.pendingActionCount(), 0);
      // clearOfflineState with no owner wipes everything.
      await store.writeCache('someone', const []);
      await svc.clearOfflineState();
      expect(await store.readCache('someone'), isEmpty);
    },
  );
}
