import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';

void main() {
  testWidgets('uses the neutral placeholder when a badge is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SchoolBadge(badgeUrl: null))),
    );

    expect(find.byIcon(Icons.school_outlined), findsOneWidget);
  });

  testWidgets('uses the neutral placeholder while a remote badge loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SchoolBadge(badgeUrl: 'https://invalid.example/badge.png'),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.school_outlined), findsOneWidget);
  });

  testWidgets(
    'falls back to the placeholder if a badge URL never resolves '
    '(e.g. silently blocked by CORS on web, with no error callback)',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SchoolBadge(badgeUrl: 'https://stalled.example/badge.png'),
          ),
        ),
      );

      // Before the timeout: still showing the placeholder (never a blank
      // box), since the image hasn't produced a frame yet.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);

      // After the timeout: still the placeholder, not stuck blank forever.
      await tester.pump(const Duration(seconds: 4));
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    },
  );
}
