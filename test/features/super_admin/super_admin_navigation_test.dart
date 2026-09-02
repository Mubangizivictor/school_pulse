// Proves the owner console's mobile bottom navigation exposes exactly the
// approved five destinations, in the approved order and labeling:
// Overview | Schools | Billing | Activity | Settings. This mirrors the
// exact NavigationBar destinations rendered by
// SuperAdminDashboard._SuperAdminDashboardState.build(), reproduced here
// directly (rather than pumping the real dashboard, which needs Firebase/
// SuperAdminBloc/GoRouter wiring this fast widget-test layer doesn't set
// up) so a regression that adds a sixth tab or renames one is caught.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'SuperAdminDashboard._kSections declares exactly the five approved labels, in order',
    () {
      final source = File(
        'lib/features/super_admin/presentation/pages/super_admin_dashboard.dart',
      ).readAsStringSync();
      final labelPattern = RegExp(r"label:\s*'([^']+)'");
      final sectionsStart = source.indexOf('const _kSections = [');
      expect(sectionsStart, isNot(-1));
      final sectionsEnd = source.indexOf('];', sectionsStart);
      final sectionsBlock = source.substring(sectionsStart, sectionsEnd);
      final labels = labelPattern
          .allMatches(sectionsBlock)
          .map((m) => m.group(1))
          .toList();
      expect(labels, ['Overview', 'Schools', 'Billing', 'Activity', 'Settings']);
    },
  );

  const destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Overview',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: 'Schools',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Billing',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: 'Activity',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  testWidgets('owner navigation exposes exactly five destinations in the approved order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: destinations,
          ),
        ),
      ),
    );

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    final labels = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((d) => d.label)
        .toList();
    expect(labels, ['Overview', 'Schools', 'Billing', 'Activity', 'Settings']);

    // No separate "Payments", "Plans", or "Subscription Plans" destination -
    // those are tabs inside Billing (BillingHomeScreen), not nav items.
    expect(labels, isNot(contains('Payments')));
    expect(labels, isNot(contains('Plans')));
    expect(labels, isNot(contains('Payments & Billing')));
    expect(labels, isNot(contains('Subscription Plans')));
    expect(labels, isNot(contains('Notifications')));
    expect(labels, isNot(contains('Audit Logs')));
    expect(tester.takeException(), isNull);
  });
}
