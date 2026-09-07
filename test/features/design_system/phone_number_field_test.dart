import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/components/phone_number_field.dart';

void main() {
  group('phoneToE164', () {
    test('combines dial code and national number', () {
      expect(phoneToE164('+256', '772123456'), '+256772123456');
    });

    test('strips spaces and non-digits from the national number', () {
      expect(phoneToE164('+256', '772 123 456'), '+256772123456');
      expect(phoneToE164('+44', '(7700) 900-123'), '+447700900123');
    });

    test('returns null for an empty number', () {
      expect(phoneToE164('+256', ''), isNull);
      expect(phoneToE164('+256', '   '), isNull);
    });

    test('returns null when the result is too short or too long', () {
      expect(phoneToE164('+1', '123'), isNull); // 4 digits total
      expect(phoneToE164('+256', '1234567890123456'), isNull); // > 15
    });

    test('accepts an 8-15 digit E.164 result', () {
      expect(phoneToE164('+250', '78123456'), '+25078123456');
    });
  });

  group('PhoneNumberField widget', () {
    Widget host({
      String dialCode = kDefaultDialCode,
      String number = '',
      String? error,
      ValueChanged<String>? onDial,
      ValueChanged<String>? onNumber,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PhoneNumberField(
            dialCode: dialCode,
            nationalNumber: number,
            errorText: error,
            onDialCodeChanged: onDial ?? (_) {},
            onNationalNumberChanged: onNumber ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('defaults to the +256 dial code', (tester) async {
      await tester.pumpWidget(host());
      expect(find.text('+256'), findsOneWidget);
    });

    testWidgets('emits digit-only national number changes', (tester) async {
      String? captured;
      await tester.pumpWidget(host(onNumber: (v) => captured = v));
      await tester.enterText(find.byType(TextField), '772abc123');
      expect(captured, '772123');
    });

    testWidgets('renders the error text when provided', (tester) async {
      await tester.pumpWidget(host(error: 'Enter a valid phone number'));
      expect(find.text('Enter a valid phone number'), findsOneWidget);
    });

    testWidgets('opens the searchable country picker and reports selection',
        (tester) async {
      String? picked;
      await tester.pumpWidget(host(onDial: (v) => picked = v));
      await tester.tap(find.text('+256'));
      await tester.pumpAndSettle();

      expect(find.text('Search country or code'), findsOneWidget);
      // The picker sheet lists every country initially; tap Kenya directly.
      await tester.tap(find.text('Kenya'));
      await tester.pumpAndSettle();

      expect(picked, '+254');
    });
  });
}
