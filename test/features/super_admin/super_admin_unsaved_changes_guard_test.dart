import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/super_admin_unsaved_changes_guard.dart';

void main() {
  testWidgets('blocks a platform back pop until the owner discards edits', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SuperAdminUnsavedChangesGuard(
                    hasUnsavedChanges: true,
                    child: Scaffold(body: Center(child: Text('Edit plan'))),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Edit plan'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
