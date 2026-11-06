import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/brand/animated_pulse_mark.dart';

Widget _host(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  test('splash size matches the 4x native splash artwork', () {
    expect(AnimatedPulseMark.splashSize, 313.5);
  });

  test('traced geometry stays inside the 1254 px splash canvas', () {
    for (final point in PulseMarkPainter.linePoints) {
      expect(point.dx, inInclusiveRange(0, PulseMarkPainter.canvasSize));
      expect(point.dy, inInclusiveRange(0, PulseMarkPainter.canvasSize));
    }
  });

  testWidgets('loops the pulse animation while mounted', (tester) async {
    await tester.pumpWidget(
      _host(const AnimatedPulseMark(semanticsLabel: 'Loading School Pulse')),
    );
    expect(find.bySemanticsLabel('Loading School Pulse'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.hasRunningAnimations, isTrue);
    }

    // Unmounting must dispose the repeating controllers cleanly.
    await tester.pumpWidget(_host(const SizedBox()));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('shows the static mark when reduced motion is requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AnimatedPulseMark(), disableAnimations: true),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('skipIntro starts directly in the animated state', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const AnimatedPulseMark(skipIntro: true)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
  });
}
