import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_ui.dart';

void main() {
  Widget subjectUnderTest(ThemeData theme) => MaterialApp(
    theme: theme,
    home: TeacherScaffold(
      body: const Center(child: Text('Students')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
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

  testWidgets('TeacherScaffold resolves light theme tokens', (tester) async {
    await tester.pumpWidget(subjectUnderTest(AppTheme.light()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
    expect(find.text('Students'), findsWidgets);
  });

  testWidgets('TeacherScaffold rebuilds cleanly in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(subjectUnderTest(AppTheme.dark()));

    final theme = Theme.of(tester.element(find.byType(TeacherScaffold)));
    expect(
      theme.scaffoldBackgroundColor,
      equals(AppTheme.dark().scaffoldBackgroundColor),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
