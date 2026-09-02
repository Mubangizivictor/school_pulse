import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_store.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/owner_notification_detail_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_notifications_screen.dart';

class _Svc extends OwnerNotificationService {
  _Svc(this._items) : super.forTest();
  final List<OwnerNotification> _items;
  @override
  String? get currentOwnerId => 'owner-x';
  @override
  Stream<List<OwnerNotification>> watchNotifications() =>
      Stream.value(_items);
  @override
  Future<List<OwnerNotification>> cachedNotifications() async => const [];
  @override
  Future<int> pendingActionCount() async => 0;
  @override
  Future<OwnerQueueSyncResult> syncPending() async =>
      const OwnerQueueSyncResult(synced: 0, dropped: 0, remaining: 0);
  @override
  Future<void> markRead(String id) async {}
}

OwnerNotification _n(String id, OwnerNotificationCategory c, {String? sev}) =>
    OwnerNotification.fromJson({
      'id': id,
      'category': c.wire,
      if (sev != null) 'severity': sev,
      'type': 'evt',
      'status': id.hashCode.isEven ? 'unread' : 'read',
      'title': 'A rather long owner notification title that should wrap onto '
          'two lines and then ellipsize $id',
      'body': 'A safe one-line summary that is also quite long and must '
          'ellipsize cleanly on every width $id',
      'schoolName': 'Lakeside High School of Science and Technology',
      'reference': 'MOMO •••• 4821',
      'amountUgx': 350000,
      'createdAt': DateTime.utc(2026, 9, 2, 13, 18).toIso8601String(),
    });

final _items = [
  _n('a', OwnerNotificationCategory.billing, sev: 'requires_review'),
  _n('b', OwnerNotificationCategory.platform, sev: 'critical'),
  _n('c', OwnerNotificationCategory.schools),
  _n('d', OwnerNotificationCategory.security),
  _n('e', OwnerNotificationCategory.digest),
];

Widget _app(Widget child, ThemeData theme, Size size) => MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(theme: theme, home: child),
    );

Future<void> _expectNoOverflow(
  WidgetTester tester,
  Widget screen,
) async {
  final themes = {'light': AppTheme.light(), 'dark': AppTheme.dark()};
  final sizes = {
    'mobile': const Size(390, 844),
    'tablet': const Size(834, 1112),
    'desktop': const Size(1280, 900),
  };
  for (final t in themes.entries) {
    for (final s in sizes.entries) {
      tester.view.physicalSize = s.value;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(screen, t.value, s.value));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester.takeException(),
        isNull,
        reason: '${t.key} / ${s.key} overflowed or threw',
      );
    }
  }
}

void main() {
  testWidgets('Owner Notifications screen — no overflow, all themes/sizes',
      (tester) async {
    await _expectNoOverflow(
      tester,
      SuperAdminNotificationsScreen(service: _Svc(_items)),
    );
  });

  testWidgets('Owner Notification Detail — no overflow, all themes/sizes',
      (tester) async {
    await _expectNoOverflow(
      tester,
      OwnerNotificationDetailScreen(
        notification: _n('a', OwnerNotificationCategory.billing,
            sev: 'requires_review'),
        service: _Svc(const []),
      ),
    );
  });
}
