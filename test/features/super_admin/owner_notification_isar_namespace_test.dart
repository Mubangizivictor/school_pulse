import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_notification_isar_store.dart';

/// The full Isar cache/queue behaviour is exercised on-device in
/// `integration_test/owner_notification_isar_store_test.dart` (Isar needs
/// its native libs). This unit test locks down the one property that keeps
/// owner data isolated from every school role: the dedicated instance name.
void main() {
  test('the owner Isar instance name is per-owner and owner-prefixed', () {
    final a = OwnerNotificationIsarStore.instanceNameFor('owner-a');
    final b = OwnerNotificationIsarStore.instanceNameFor('owner-b');

    expect(a, 'owner_notifications_owner-a');
    expect(b, 'owner_notifications_owner-b');
    expect(a, isNot(b));
    expect(a.startsWith('owner_notifications_'), isTrue);
  });

  test('the owner instance name never collides with the app-wide default '
      'Isar instance or a school-role cache name', () {
    final name = OwnerNotificationIsarStore.instanceNameFor('any-uid');
    // Default Flutter Isar instance is 'default'; school-role notification
    // rows live in the default instance's NotificationIsar / NotificationToken
    // collections — never in a named instance.
    expect(name, isNot('default'));
    expect(name.contains('NotificationIsar'), isFalse);
    expect(name.contains('notification_token'), isFalse);
  });
}
