import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/profile/presentation/screens/about_school_pulse_screen.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'School Pulse',
      packageName: 'com.victorbee.schoolPulse',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Future<void> pumpAboutScreen(
    WidgetTester tester,
    Size size,
    ThemeData theme,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: theme, home: const AboutSchoolPulseScreen()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses dynamic package metadata and has no bottom navigation', (
    tester,
  ) async {
    await pumpAboutScreen(tester, const Size(390, 844), AppTheme.light());

    expect(find.text('1.0.0 (1)'), findsOneWidget);
    expect(find.text('Build 1'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reflows without overflow in dark mode on compact widths', (
    tester,
  ) async {
    await pumpAboutScreen(tester, const Size(320, 568), AppTheme.dark());

    await tester.drag(find.byType(Scrollable), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Check for Updates'), findsOneWidget);
    await tester.drag(find.byType(Scrollable), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('About Us'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the detail view constrained on a wide screen', (
    tester,
  ) async {
    await pumpAboutScreen(tester, const Size(1024, 900), AppTheme.light());

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Licences'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow below the usual phone width', (tester) async {
    await pumpAboutScreen(tester, const Size(240, 568), AppTheme.dark());

    await tester.drag(find.byType(Scrollable), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
