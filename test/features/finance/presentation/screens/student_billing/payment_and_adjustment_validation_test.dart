// Phase 2 coverage: the client-side draft validators for adjustments and
// payments must reject decimal amounts outright (money is integer UGX
// everywhere, mirroring the backend's own asMoney validator) and must
// enforce the balance/percentage constraints before ever calling the
// applyBillAdjustment/recordStudentPayment callables.
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/finance/presentation/screens/student_billing/apply_adjustment_dialog.dart';
import 'package:school_pulse/features/finance/presentation/screens/student_billing/record_payment_dialog.dart';

void main() {
  group('validateAdjustmentDraft', () {
    test('accepts a valid whole-number-UGX amount', () {
      final error = validateAdjustmentDraft(
        type: 'discount',
        amountText: '50000',
        percentageText: '',
        reason: 'sibling discount',
      );
      expect(error, isNull);
    });

    test('accepts a valid percentage', () {
      final error = validateAdjustmentDraft(
        type: 'scholarship',
        amountText: '',
        percentageText: '25',
        reason: 'merit scholarship',
      );
      expect(error, isNull);
    });

    test('rejects providing both an amount and a percentage', () {
      final error = validateAdjustmentDraft(
        type: 'discount',
        amountText: '10000',
        percentageText: '10',
        reason: 'ambiguous',
      );
      expect(error, contains('not both'));
    });

    test('rejects providing neither an amount nor a percentage', () {
      final error = validateAdjustmentDraft(
        type: 'discount',
        amountText: '',
        percentageText: '',
        reason: 'nothing entered',
      );
      expect(error, isNotNull);
    });

    test('rejects a decimal amount rather than rounding it', () {
      final error = validateAdjustmentDraft(
        type: 'discount',
        amountText: '5000.50',
        percentageText: '',
        reason: 'decimal',
      );
      expect(error, contains('whole number'));
    });

    test('rejects a percentage over 100', () {
      final error = validateAdjustmentDraft(
        type: 'discount',
        amountText: '',
        percentageText: '150',
        reason: 'too much',
      );
      expect(error, isNotNull);
    });

    test('requires a reason', () {
      final error = validateAdjustmentDraft(
        type: 'discount',
        amountText: '10000',
        percentageText: '',
        reason: '',
      );
      expect(error, 'Enter a reason.');
    });
  });

  group('validatePaymentDraft', () {
    test('accepts a valid whole-number-UGX amount within the balance', () {
      final error = validatePaymentDraft(amountText: '200000', balanceUgx: 500000);
      expect(error, isNull);
    });

    test('rejects a decimal amount rather than rounding it', () {
      final error = validatePaymentDraft(amountText: '1000.75', balanceUgx: 500000);
      expect(error, contains('whole number'));
    });

    test('rejects zero and negative amounts', () {
      expect(validatePaymentDraft(amountText: '0', balanceUgx: 500000), isNotNull);
      expect(validatePaymentDraft(amountText: '-1000', balanceUgx: 500000), isNotNull);
    });

    test('rejects an amount exceeding the remaining balance', () {
      final error = validatePaymentDraft(amountText: '600000', balanceUgx: 500000);
      expect(error, contains('exceeds'));
    });

    test('requires an amount', () {
      final error = validatePaymentDraft(amountText: '', balanceUgx: 500000);
      expect(error, 'Enter an amount.');
    });
  });
}
