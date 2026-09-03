// Proves school_detail_screen.dart re-exports the real SchoolDetailScreen
// from school_overview_screen.dart (already covered by
// school_overview_screen_test.dart) and provides the shared
// confirmSchoolStatusChange dialog reused by both the Schools list's quick
// actions and Screen D's administrative actions, so suspend/reactivate
// wording and behavior stay in one place. Verified at the source level -
// the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/school_detail_screen.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/school_detail_screen.dart',
    ).readAsStringSync();
  });

  test('re-exports the real SchoolDetailScreen rather than defining a duplicate', () {
    expect(
      source.contains("export 'school_overview_screen.dart' show SchoolDetailScreen;"),
      isTrue,
    );
  });

  testWidgets('confirmSchoolStatusChange shows a title/message dialog and only fires onConfirm on confirm', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => confirmSchoolStatusChange(
                context,
                action: 'Suspend',
                message: 'This school will lose access immediately.',
                color: Colors.red,
                onConfirm: () => confirmed = true,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Suspend School?'), findsOneWidget);
    expect(
      find.text('This school will lose access immediately.'),
      findsOneWidget,
    );
    expect(confirmed, isFalse);

    await tester.tap(find.text('Suspend'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancel dismisses without calling onConfirm', (tester) async {
    var confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => confirmSchoolStatusChange(
                context,
                action: 'Reactivate',
                message: 'This school will regain access.',
                color: Colors.green,
                onConfirm: () => confirmed = true,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
    expect(tester.takeException(), isNull);
  });
}
