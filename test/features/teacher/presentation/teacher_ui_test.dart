import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_ui.dart';

void main() {
  Widget subjectUnderTest(ThemeData theme) => MaterialApp(
    theme: theme,
    home: const TeacherScaffold(
      appBar: TeacherHeader(title: 'Teacher'),
      body: TeacherResponsiveContainer(
        child: TeacherSectionCard(
          child: TeacherStatsCard(
            label: 'Students',
            value: '24',
            icon: Icons.people_outline,
          ),
        ),
      ),
      bottomNavigationBar: TeacherBottomNavigation(
        selectedIndex: 0,
        onDestinationSelected: _ignoreDestination,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Students',
          ),
        ],
      ),
    ),
  );

  testWidgets('teacher primitives resolve light theme tokens', (tester) async {
    await tester.pumpWidget(subjectUnderTest(AppTheme.light()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final card = tester.widget<Card>(find.byType(Card).first);
    expect(scaffold.backgroundColor, isNull);
    expect(card.color, isNull);
    expect(find.text('Students'), findsWidgets);
  });

  testWidgets('teacher primitives rebuild cleanly in dark mode', (
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

void _ignoreDestination(int _) {}
