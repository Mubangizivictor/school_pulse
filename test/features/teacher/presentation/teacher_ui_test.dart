import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_ui.dart';

void main() {
  Widget subjectUnderTest(ThemeData theme) => MaterialApp(
    theme: theme,
    home: TeacherScaffold(
      appBar: AppBar(title: const Text('Teacher')),
      body: const Center(child: Text('Students')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _ignoreDestination,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Students',
          ),
        ],
      ),
    ),
  );

  testWidgets('teacher scaffold defers to light theme tokens', (tester) async {
    await tester.pumpWidget(subjectUnderTest(AppTheme.light()));

    // The scaffold must not hardcode a background; it inherits the theme.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
    expect(find.text('Students'), findsWidgets);
  });

  testWidgets('teacher scaffold rebuilds cleanly in dark mode', (tester) async {
    await tester.pumpWidget(subjectUnderTest(AppTheme.dark()));

    final theme = Theme.of(tester.element(find.byType(TeacherScaffold)));
    expect(
      theme.scaffoldBackgroundColor,
      equals(AppTheme.dark().scaffoldBackgroundColor),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('teacher scaffold keeps the body clear of the bottom inset', (
    tester,
  ) async {
    await tester.pumpWidget(subjectUnderTest(AppTheme.light()));

    // top: false lets the app bar own the status bar area, while the bottom
    // inset still guards the body above the home indicator.
    final safeArea = tester.widget<SafeArea>(find.byType(SafeArea).first);
    expect(safeArea.top, isFalse);
    expect(safeArea.bottom, isTrue);
  });
}

void _ignoreDestination(int _) {}
