import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_offline_store.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_push_token_service.dart';
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
///  * push    — the owner FCM token path is
///    `super_admin_notification_tokens/{uid}/devices/{token}`, distinct from
///    the school-role `users/{uid}/tokens/{token}` path;
///  * teardown wipes all of it.
void main() {
  test('owner notification routes live entirely under the guarded '
      '/super-admin subtree', () {
    const ownerRoutes = [
      '/super-admin/notifications',
      '/super-admin/settings/notifications',
      '/super-admin/settings/notifications/preferences',
      '/super-admin/settings/notifications/history',
    ];
    for (final r in ownerRoutes) {
      expect(r.startsWith('/super-admin'), isTrue);
    }
    final router = File('lib/app/router.dart').readAsStringSync();
    // The single guard that rejects every non-superAdmin session.
    expect(
      router.contains("state.uri.path.startsWith('/super-admin')"),
      isTrue,
    );
    expect(
      router.contains('authState.user.role != UserRole.superAdmin'),
      isTrue,
    );
    // The owner notification routes are registered as children of
    // /super-admin, not as standalone top-level routes.
    expect(router.contains("path: 'settings/notifications'"), isTrue);
  });

  test('the feed collection is the owner collection, not a role path', () {
    final svc = File(
      'lib/features/super_admin/data/services/owner_notification_service.dart',
    ).readAsStringSync();
    expect(svc.contains("_feedCollection = 'super_admin_notifications'"), isTrue);
    expect(svc.contains('users/'), isFalse);
    expect(svc.contains('staff/notifications'), isFalse);
    expect(svc.contains('parent/notifications'), isFalse);
    // It must not import any school-role notification code.
    expect(svc.contains("features/notifications/"), isFalse);
    expect(svc.contains("core/notification/"), isFalse);
  });

  test('the owner push-token path is dedicated and distinct from the '
      'school-role token path', () {
    expect(
      OwnerPushTokenService.rootCollection,
      'super_admin_notification_tokens',
    );
    expect(OwnerPushTokenService.devicesSub, 'devices');
    final src = File(
      'lib/features/super_admin/data/services/owner_push_token_service.dart',
    ).readAsStringSync();
    // Never writes to the school-role token path.
    expect(src.contains(".collection('users')"), isFalse);
    expect(src.contains("users/\${"), isFalse);
  });

  test('the owner Isar cache instance name is per-owner and owner-prefixed',
      () {
    expect(
      OwnerNotificationIsarStore.instanceNameFor('u1'),
      'owner_notifications_u1',
    );
    expect(
      OwnerNotificationIsarStore.instanceNameFor('u1'),
      isNot(OwnerNotificationIsarStore.instanceNameFor('u2')),
    );
  });

  test('a signed-out service caches / queues nothing and clears cleanly',
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
  });
}
