import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:school_pulse/features/registration/presentation/pages/step4_students_pricing_page.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430 * 3, 932 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => RegistrationBloc(),
        child: const Step4StudentsPricingPage(),
      ),
    ),
  );
}

void main() {
  testWidgets('shows a flat Growth price, yearly price, includes and trial', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.textContaining('30-day trial'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '450');
    await tester.pump();

    expect(find.text('Growth plan · 450 students'), findsOneWidget);
    expect(find.text('UGX 550,000'), findsOneWidget);
    expect(find.textContaining('UGX 1,485,000 per year'), findsOneWidget);
    expect(find.text('Fees and Bursar'), findsOneWidget);
    // The old screen multiplied the plan price by the student count.
    expect(find.textContaining('247,500,000'), findsNothing);
  });

  testWidgets('blocks Enterprise-sized schools with a quote message', (
    tester,
  ) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), '2000');
    await tester.pump();
    expect(find.text('Custom quote'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.textContaining('Enterprise quote'), findsOneWidget);
  });
}
