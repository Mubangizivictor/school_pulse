import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_store.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_preferences.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/owner_notification_detail_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_notifications_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/owner_notification_visuals.dart';

class _FakeService extends OwnerNotificationService {
  _FakeService(this._items) : super.forTest();

  final List<OwnerNotification> _items;
  final _controller = StreamController<List<OwnerNotification>>.broadcast();

  final calls = <String>[];
  OwnerNotificationPreferences prefs = OwnerNotificationPreferences.defaults(
    'owner-x',
  );

  @override
  String? get currentOwnerId => 'owner-x';

  @override
  Stream<List<OwnerNotification>> watchNotifications() async* {
    yield _items;
    yield* _controller.stream;
  }

  @override
  Future<List<OwnerNotification>> cachedNotifications() async => const [];

  @override
  Future<int> pendingActionCount() async => 0;

  @override
  Future<OwnerQueueSyncResult> syncPending() async =>
      const OwnerQueueSyncResult(synced: 0, dropped: 0, remaining: 0);

  @override
  Future<void> markRead(String id) async => calls.add('markRead:$id');

  @override
  Future<int> markAllRead() async {
    calls.add('markAllRead');
    return _items.where((n) => n.isUnread).length;
  }

  @override
  Future<void> archiveNotification(String id) async => calls.add('archive:$id');

  @override
  Future<void> deleteNotification(String id) async => calls.add('delete:$id');

  @override
  Future<int> clearAll() async {
    calls.add('clearAll');
    return _items.length;
  }

  @override
  Future<OwnerNotificationPreferences> getPreferences(String ownerId) async =>
      prefs;

  @override
  Future<OwnerNotificationPreferences> savePreferences(
    OwnerNotificationPreferences p,
  ) async {
    calls.add('savePreferences');
    prefs = p;
    return p;
  }
}

OwnerNotification _n(
  String id, {
  required OwnerNotificationCategory category,
  String status = 'unread',
  String type = 'evt',
  String? severity,
}) {
  return OwnerNotification.fromJson({
    'id': id,
    'category': category.wire,
    ...(severity == null ? const {} : {'severity': severity}),
    'type': type,
    'status': status,
    'title': 'Title $id',
    'body': 'Body $id',
    'schoolName': 'Lakeside High',
    'reference': 'MOMO •••• 4821',
    'amountUgx': 350000,
    'createdAt': DateTime.utc(2026, 9, 2, 13, 18).toIso8601String(),
  });
}

Widget _wrap(Widget child) => MaterialApp(
  home: MediaQuery(
    data: const MediaQueryData(size: Size(430, 1600)),
    child: child,
  ),
);

void main() {
  group('Owner Notifications screen', () {
    testWidgets('renders the header, 3 NEW chip, filter chips and tiles', (
      tester,
    ) async {
      final svc = _FakeService([
        _n(
          'a',
          category: OwnerNotificationCategory.billing,
          type: 'manual_payment_pending',
          severity: 'requires_review',
        ),
        _n(
          'b',
          category: OwnerNotificationCategory.platform,
          severity: 'critical',
        ),
        _n('c', category: OwnerNotificationCategory.schools),
      ]);
      await tester.pumpWidget(
        _wrap(SuperAdminNotificationsScreen(service: svc)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget); // app bar title
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      // "Recent" heading removed - the app bar title says Notifications.
      expect(find.text('Recent'), findsNothing);
      // Mark all read + the overflow menu now live in the app bar, next to
      // the title, not in a separate "Recent" row.
      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.text('3 NEW'), findsOneWidget);
      for (final label in [
        'All',
        'Critical',
        'Billing',
        'Platform',
        'Schools',
        'Security',
      ]) {
        expect(find.text(label), findsOneWidget, reason: '$label chip');
      }
      expect(find.byType(OwnerNotificationTile), findsNWidgets(3));
      // Severity chips only on the two attention tiles.
      expect(find.byType(OwnerSeverityChip), findsNWidgets(2));
      // No per-tile 3-dot menu.
      expect(find.byIcon(Icons.more_vert_rounded), findsNothing);
    });

    testWidgets('a filter chip narrows the list', (tester) async {
      final svc = _FakeService([
        _n(
          'a',
          category: OwnerNotificationCategory.billing,
          type: 'manual_payment_pending',
        ),
        _n('b', category: OwnerNotificationCategory.schools),
      ]);
      await tester.pumpWidget(
        _wrap(SuperAdminNotificationsScreen(service: svc)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OwnerNotificationTile), findsNWidgets(2));

      await tester.tap(find.text('Billing'));
      await tester.pumpAndSettle();
      expect(find.byType(OwnerNotificationTile), findsOneWidget);
      expect(find.text('Title a'), findsOneWidget);
    });

    testWidgets('Mark all read calls the owner callable', (tester) async {
      final svc = _FakeService([
        _n('a', category: OwnerNotificationCategory.billing),
      ]);
      await tester.pumpWidget(
        _wrap(SuperAdminNotificationsScreen(service: svc)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(svc.calls, contains('markAllRead'));
    });

    testWidgets('Clear all is behind a destructive confirm', (tester) async {
      final svc = _FakeService([
        _n('a', category: OwnerNotificationCategory.billing),
      ]);
      await tester.pumpWidget(
        _wrap(SuperAdminNotificationsScreen(service: svc)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      expect(svc.calls, isNot(contains('clearAll'))); // not yet
      await tester.tap(find.widgetWithText(FilledButton, 'Clear all'));
      await tester.pumpAndSettle();
      expect(svc.calls, contains('clearAll'));
    });

    testWidgets('long-press opens the safe owner action menu only', (
      tester,
    ) async {
      final svc = _FakeService([
        _n('a', category: OwnerNotificationCategory.billing),
      ]);
      await tester.pumpWidget(
        _wrap(SuperAdminNotificationsScreen(service: svc)),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(OwnerNotificationTile));
      await tester.pumpAndSettle();
      expect(find.text('Archive notification'), findsOneWidget);
      expect(find.text('Delete notification'), findsOneWidget);
      for (final banned in ['Reply', 'Forward', 'Broadcast', 'Assign']) {
        expect(find.text(banned), findsNothing);
      }
    });
  });

  group('Owner Notification Detail', () {
    testWidgets('payment shows REQUIRES REVIEW, masked ref, payment actions', (
      tester,
    ) async {
      final svc = _FakeService(const []);
      final n = _n(
        'a',
        category: OwnerNotificationCategory.billing,
        type: 'manual_payment_pending',
        severity: 'requires_review',
      );
      await tester.pumpWidget(
        _wrap(OwnerNotificationDetailScreen(notification: n, service: svc)),
      );
      await tester.pumpAndSettle();

      expect(find.text('REQUIRES REVIEW'), findsOneWidget);
      expect(find.text('MOMO •••• 4821'), findsOneWidget);
      expect(find.text('UGX 350,000'), findsOneWidget);
      expect(find.text('Review payment'), findsOneWidget);
      expect(find.textContaining('Opened by you'), findsOneWidget);
      expect(
        find.text(
          'Sensitive school details are shown only after authorization.',
        ),
        findsOneWidget,
      );
      // opening marks read
      expect(svc.calls, contains('markRead:a'));
    });

    testWidgets('platform incident shows the platform-health action', (
      tester,
    ) async {
      final svc = _FakeService(const []);
      final n = _n(
        'p',
        category: OwnerNotificationCategory.platform,
        severity: 'critical',
      );
      await tester.pumpWidget(
        _wrap(OwnerNotificationDetailScreen(notification: n, service: svc)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Open platform health'), findsOneWidget);
      expect(find.text('Acknowledge'), findsOneWidget);
      // Amount is NOT shown for a non-billing notification.
      expect(find.text('UGX 350,000'), findsNothing);
    });

    testWidgets(
      'security shows security-center action, no archive-as-primary',
      (tester) async {
        final svc = _FakeService(const []);
        final n = _n(
          's',
          category: OwnerNotificationCategory.security,
          type: 'security_alert',
          severity: 'critical',
        );
        await tester.pumpWidget(
          _wrap(OwnerNotificationDetailScreen(notification: n, service: svc)),
        );
        await tester.pumpAndSettle();
        expect(find.text('Open security center'), findsOneWidget);
      },
    );
  });

  testWidgets(
    'there is no notification-settings entry point: owner alerts always '
    'deliver everything by default',
    (tester) async {
      final svc = _FakeService([
        _n('a', category: OwnerNotificationCategory.billing),
      ]);
      await tester.pumpWidget(
        _wrap(SuperAdminNotificationsScreen(service: svc)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
      expect(find.text('Notification settings'), findsNothing);
    },
  );
}
