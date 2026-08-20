import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SeverityBadge', () {
    // The underlying StatusBadge renders labels uppercased.
    testWidgets('renders the severity label as passed', (tester) async {
      await tester.pumpWidget(_wrap(const SeverityBadge(severity: 'High')));
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('renders Medium and Low without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const SeverityBadge(severity: 'Medium')));
      expect(find.text('MEDIUM'), findsOneWidget);

      await tester.pumpWidget(_wrap(const SeverityBadge(severity: 'Low')));
      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('falls back gracefully for an unrecognized value', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SeverityBadge(severity: 'Unknown')));
      expect(find.text('UNKNOWN'), findsOneWidget);
    });
  });

  group('AttendanceStatusToggle', () {
    testWidgets('renders all four status buttons', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AttendanceStatusToggle(
            selected: AttendanceQuickStatus.present,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('tapping a status fires onChanged with that status', (
      tester,
    ) async {
      AttendanceQuickStatus? picked;
      await tester.pumpWidget(
        _wrap(
          AttendanceStatusToggle(
            selected: AttendanceQuickStatus.present,
            onChanged: (status) => picked = status,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(picked, AttendanceQuickStatus.absent);
    });
  });

  group('StudentListRow', () {
    testWidgets('renders name, bed and class as subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StudentListRow(
            name: 'Aiden Mwangi',
            bedLabel: 'Bed 01',
            classLabel: 'Form 3A',
          ),
        ),
      );
      expect(find.text('Aiden Mwangi'), findsOneWidget);
      expect(find.text('Bed 01 · Form 3A'), findsOneWidget);
    });

    testWidgets('onTap fires when the row is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          StudentListRow(
            name: 'Brian Ochieng',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Brian Ochieng'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('RollCallGaugeCard', () {
    testWidgets('renders present/absent/late counts', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RollCallGaugeCard(
            presentPercent: 0.9,
            presentCount: 128,
            absentCount: 5,
            lateCount: 3,
            totalCount: 136,
          ),
        ),
      );
      expect(find.text('128'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('TabbedListScaffold', () {
    testWidgets('filters items by the selected tab', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TabbedListScaffold<int>(
            tabLabels: const ['Even', 'Odd'],
            items: const [1, 2, 3, 4, 5],
            filter: (tabIndex, item) =>
                tabIndex == 0 ? item.isEven : item.isOdd,
            itemBuilder: (context, item) => Text('item-$item'),
          ),
        ),
      );

      // Tab 0 (Even) is selected by default.
      expect(find.text('item-2'), findsOneWidget);
      expect(find.text('item-4'), findsOneWidget);
      expect(find.text('item-1'), findsNothing);

      await tester.tap(find.text('Odd'));
      await tester.pumpAndSettle();

      expect(find.text('item-1'), findsOneWidget);
      expect(find.text('item-3'), findsOneWidget);
      expect(find.text('item-5'), findsOneWidget);
      expect(find.text('item-2'), findsNothing);
    });

    testWidgets('shows the empty state when no items match', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TabbedListScaffold<int>(
            tabLabels: const [],
            items: const <int>[],
            filter: (_, __) => true,
            itemBuilder: (context, item) => Text('item-$item'),
            emptyTitle: 'No records',
          ),
        ),
      );
      expect(find.text('No records'), findsOneWidget);
    });
  });

  group('MoreMenuRow / MoreMenuSection', () {
    testWidgets('renders label and fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          MoreMenuSection(
            title: 'Boarding Management',
            rows: [
              MoreMenuRow(
                icon: Icons.home_outlined,
                label: 'Dormitory Management',
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );
      expect(find.text('Boarding Management'), findsOneWidget);
      expect(find.text('Dormitory Management'), findsOneWidget);

      await tester.tap(find.text('Dormitory Management'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
