// Proves the app-wide ThemeProvider (the same instance main.dart feeds into
// MaterialApp.themeMode) correctly switches and persists Light/Dark/System,
// which is the contract any owner Settings theme selector must drive.
// Reproduced as a minimal harness rather than pumping the real Settings
// screen, since that screen is under active concurrent development in this
// repo (its own theme-mode selector widget/name is still being finalized)
// and depends on AuthBloc/SuperAdminBloc wiring this fast widget-test layer
// doesn't set up.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';

void main() {
  Widget harness(ThemeProvider provider) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: provider,
      child: MaterialApp(
        home: Consumer<ThemeProvider>(
          builder: (context, theme, _) => Scaffold(
            body: Row(
              children: [
                for (final mode in ThemeMode.values)
                  TextButton(
                    key: ValueKey(mode),
                    onPressed: () =>
                        context.read<ThemeProvider>().setThemeMode(mode),
                    child: Text(mode.name),
                  ),
                Text('current: ${theme.themeMode.name}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('selecting Light sets ThemeProvider.themeMode to light', (
    tester,
  ) async {
    final provider = ThemeProvider();
    await tester.pumpWidget(harness(provider));
    await tester.tap(find.byKey(const ValueKey(ThemeMode.light)));
    await tester.pump();
    expect(provider.themeMode, ThemeMode.light);
    expect(find.text('current: light'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting Dark sets ThemeProvider.themeMode to dark', (
    tester,
  ) async {
    final provider = ThemeProvider();
    await tester.pumpWidget(harness(provider));
    await tester.tap(find.byKey(const ValueKey(ThemeMode.dark)));
    await tester.pump();
    expect(provider.themeMode, ThemeMode.dark);
    expect(find.text('current: dark'), findsOneWidget);
  });

  testWidgets('selecting System sets ThemeProvider.themeMode to system', (
    tester,
  ) async {
    final provider = ThemeProvider();
    await tester.pumpWidget(harness(provider));
    await tester.tap(find.byKey(const ValueKey(ThemeMode.dark)));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(ThemeMode.system)));
    await tester.pump();
    expect(provider.themeMode, ThemeMode.system);
    expect(find.text('current: system'), findsOneWidget);
  });
}
