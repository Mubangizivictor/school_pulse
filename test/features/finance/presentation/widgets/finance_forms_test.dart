import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_forms.dart';

/// Audit area 8 — the shared finance write-form primitives used by the
/// Suppliers / Petty Cash / Cash & Bank action sheets.
void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  group('FinanceField', () {
    testWidgets('required money field rejects empty and non-positive', (
      tester,
    ) async {
      final ctl = TextEditingController();
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        wrap(
          Form(
            key: formKey,
            child: FinanceField(
              controller: ctl,
              label: 'Amount',
              moneyUgx: true,
              required: true,
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      ctl.text = '0';
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a positive amount'), findsOneWidget);

      ctl.text = '2500';
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('money field strips non-digits as you type', (tester) async {
      final ctl = TextEditingController();
      await tester.pumpWidget(
        wrap(FinanceField(controller: ctl, label: 'Amount', moneyUgx: true)),
      );
      await tester.enterText(find.byType(TextField), 'ab12c3');
      expect(ctl.text, '123');
    });

    testWidgets('a plain required field flags empty', (tester) async {
      final ctl = TextEditingController();
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        wrap(
          Form(
            key: formKey,
            child: FinanceField(
              controller: ctl,
              label: 'Payee',
              required: true,
            ),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      ctl.text = 'Acme';
      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('FinanceSubmitButton', () {
    testWidgets('shows a spinner while running and cannot be double-tapped', (
      tester,
    ) async {
      var calls = 0;
      final completer = Completer<void>();
      await tester.pumpWidget(
        wrap(
          FinanceSubmitButton(
            label: 'Save',
            onPressed: () async {
              calls++;
              await completer.future;
            },
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // second tap while busy is ignored
      await tester.tap(find.byType(FinanceSubmitButton));
      await tester.pump();
      expect(calls, 1);

      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('runFinanceAction', () {
    testWidgets(
      'shows the server message from a FirebaseFunctionsException-style error',
      (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          wrap(
            Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        );

        final ok = await runFinanceAction(
          ctx,
          successMessage: 'Done',
          action: () async => throw Exception('boom'),
        );
        await tester.pump();
        expect(ok, isFalse);
        // Generic fallback for a non-functions error.
        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('surfaces the message of a [firebase_functions/...] error', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      );
      await runFinanceAction(
        ctx,
        successMessage: 'Done',
        action: () async => throw _FakeFunctionsError(),
      );
      await tester.pump();
      expect(
        find.text('You cannot decide a requisition you raised.'),
        findsOneWidget,
      );
    });
  });
}

class _FakeFunctionsError implements Exception {
  @override
  String toString() =>
      '[firebase_functions/permission-denied] You cannot decide a requisition you raised.';
}
