import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/components/app_confirmation_dialog.dart';
import 'package:school_pulse/design_system/components/app_error_state.dart';
import 'package:school_pulse/design_system/components/app_filter_bar.dart';
import 'package:school_pulse/design_system/components/app_list_tile.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_scaffold.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

Future<void> _setWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('AppErrorState', () {
    testWidgets('shows the message and fires retry', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        _app(
          AppErrorState(
            title: 'Could not load',
            message: 'Check your connection.',
            onRetry: () => retried++,
          ),
        ),
      );
      expect(find.text('Could not load'), findsOneWidget);
      expect(find.text('Check your connection.'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, 1);
    });

    testWidgets('hides the retry button without onRetry', (tester) async {
      await tester.pumpWidget(_app(const AppErrorState(message: 'Nope')));
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('AppListTile', () {
    testWidgets('renders title, subtitle, chevron and handles taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          AppListTile(
            title: 'Grace Nakato',
            subtitle: 'P5 East',
            showChevron: true,
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.text('Grace Nakato'), findsOneWidget);
      expect(find.text('P5 East'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      await tester.tap(find.text('Grace Nakato'));
      expect(taps, 1);
    });
  });

  group('AppFilterBar', () {
    const options = [
      AppFilterOption(value: 'all', label: 'All'),
      AppFilterOption(value: 'pending', label: 'Pending', count: 3),
      AppFilterOption(value: 'paid', label: 'Paid'),
      AppFilterOption(value: 'failed', label: 'Failed'),
    ];

    testWidgets('selects a chip and reports counts', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _app(
          AppFilterBar<String>(
            options: options,
            selected: 'all',
            onSelected: (v) => picked = v,
          ),
        ),
      );
      expect(find.text('Pending (3)'), findsOneWidget);
      await tester.tap(find.text('Paid'));
      expect(picked, 'paid');
    });

    testWidgets('does not overflow at 320px with search', (tester) async {
      await _setWidth(tester, 320);
      await tester.pumpWidget(
        _app(
          AppFilterBar<String>(
            options: options,
            selected: 'all',
            onSelected: (_) {},
            onSearchChanged: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('showAppConfirmationDialog', () {
    Future<bool?> open(WidgetTester tester, String tapLabel) async {
      bool? result;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showAppConfirmationDialog(
                context,
                title: 'Delete record?',
                message: 'This cannot be undone.',
                confirmLabel: 'Delete',
                destructive: true,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('This cannot be undone.'), findsOneWidget);
      await tester.tap(find.text(tapLabel));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('resolves true on confirm', (tester) async {
      expect(await open(tester, 'Delete'), isTrue);
    });

    testWidgets('resolves false on cancel', (tester) async {
      expect(await open(tester, 'Cancel'), isFalse);
    });
  });

  group('AppResponsiveScaffold', () {
    testWidgets('pads per layout and caps width on desktop', (tester) async {
      await _setWidth(tester, 1400);
      await tester.pumpWidget(
        const MaterialApp(
          home: AppResponsiveScaffold(
            title: 'Students',
            body: SizedBox(key: Key('body'), height: 10),
          ),
        ),
      );
      expect(find.text('Students'), findsOneWidget);
      // 840 cap minus 2 × desktop padding.
      expect(
        tester.getSize(find.byKey(const Key('body'))).width,
        840 -
            2 *
                AppResponsiveScaffold.horizontalPadding(
                  ResponsiveLayout.desktop,
                ),
      );
    });

    testWidgets('fills the width on mobile', (tester) async {
      await _setWidth(tester, 360);
      await tester.pumpWidget(
        const MaterialApp(
          home: AppResponsiveScaffold(
            body: SizedBox(key: Key('body'), height: 10),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const Key('body'))).width,
        360 -
            2 *
                AppResponsiveScaffold.horizontalPadding(
                  ResponsiveLayout.mobile,
                ),
      );
    });
  });
}
