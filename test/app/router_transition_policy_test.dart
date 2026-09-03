// Guards the single shared route-transition policy: `fadeThroughPage` is a
// fast, subtle fade with no slide/scale/bounce, and `GoRouterRefreshStream`
// collapses a synchronous burst of stream events into one refresh so a slow
// (async) redirect can't resolve against a route the user already left.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/app/router.dart';

void main() {
  group('fadeThroughPage', () {
    testWidgets('is a fade only - no SlideTransition or ScaleTransition', (
      tester,
    ) async {
      final page = fadeThroughPage(child: const Text('x'));
      expect(page.transitionDuration, const Duration(milliseconds: 180));
      expect(page.reverseTransitionDuration, const Duration(milliseconds: 180));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => KeyedSubtree(
              key: const Key('policy-under-test'),
              child: page.transitionsBuilder(
                context,
                const AlwaysStoppedAnimation(0.5),
                const AlwaysStoppedAnimation(0),
                const Text('x'),
              ),
            ),
          ),
        ),
      );

      final scope = find.byKey(const Key('policy-under-test'));
      expect(
        find.descendant(of: scope, matching: find.byType(FadeTransition)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: scope, matching: find.byType(SlideTransition)),
        findsNothing,
      );
      expect(
        find.descendant(of: scope, matching: find.byType(ScaleTransition)),
        findsNothing,
      );
    });
  });

  group('GoRouterRefreshStream', () {
    test('coalesces a synchronous burst into a single notification', () async {
      final controller = StreamController<int>.broadcast();
      final refresh = GoRouterRefreshStream(controller.stream);
      addTearDown(() {
        refresh.dispose();
        controller.close();
      });

      var notifications = 0;
      refresh.addListener(() => notifications++);

      // No eager notification on construction.
      expect(notifications, 0);

      controller
        ..add(1)
        ..add(2)
        ..add(3);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifications, 1, reason: 'a same-turn burst => one refresh');

      controller.add(4);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(notifications, 2);
    });
  });
}
