// StudentBill/StudentPayment must render exactly what the immutable
// backend snapshot stored - this covers the fromJson mapping that the
// display layer relies on, including the reversal-linkage fields
// (reversalOfPaymentId / reversalPaymentId -> reversedByPaymentId).
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';

void main() {
  group('StudentBill.fromJson', () {
    test('maps every money field as an int and preserves lines exactly', () {
      final bill = StudentBill.fromJson('bill1', {
        'schoolId': 'schoolA',
        'studentId': 'studentA',
        'status': 'open',
        'planId': 'planA',
        'planVersionId': 'v1',
        'academicYearId': 'year1',
        'termId': 'term1',
        'classId': 'classA',
        'issuedTotalUgx': 500000,
        'paidTotalUgx': 200000,
        'adjustmentTotalUgx': 50000,
        'balanceUgx': 250000,
        'lines': [
          {'chargeId': 'tuition', 'name': 'Tuition', 'amountUgx': 500000, 'required': true},
        ],
      });
      expect(bill.issuedTotalUgx, 500000);
      expect(bill.paidTotalUgx, 200000);
      expect(bill.adjustmentTotalUgx, 50000);
      expect(bill.balanceUgx, 250000);
      expect(bill.lines, hasLength(1));
      expect(bill.lines.first.amountUgx, 500000);
    });

    test('defaults missing money fields to zero rather than throwing', () {
      final bill = StudentBill.fromJson('bill1', {'schoolId': 'schoolA'});
      expect(bill.issuedTotalUgx, 0);
      expect(bill.balanceUgx, 0);
      expect(bill.lines, isEmpty);
    });
  });

  group('StudentPayment.fromJson', () {
    test('a normal payment is not a reversal and is not itself reversed', () {
      final payment = StudentPayment.fromJson('pay1', {
        'billId': 'bill1',
        'status': 'recorded',
        'method': 'cash',
        'amountUgx': 200000,
        'receiptNumber': 'RCT-000001',
        'recordedBy': 'bursarUid',
      });
      expect(payment.isReversal, isFalse);
      expect(payment.isReversed, isFalse);
      expect(payment.amountUgx, 200000);
    });

    test('a payment marked with reversalPaymentId (server field name) is '
        'surfaced as reversedByPaymentId / isReversed', () {
      final payment = StudentPayment.fromJson('pay1', {
        'billId': 'bill1',
        'status': 'recorded',
        'method': 'cash',
        'amountUgx': 200000,
        'receiptNumber': 'RCT-000001',
        'recordedBy': 'bursarUid',
        'reversalPaymentId': 'pay2',
      });
      expect(payment.isReversed, isTrue);
      expect(payment.reversedByPaymentId, 'pay2');
    });

    test('a compensating reversal record has a negative amount and '
        'references the original via reversalOfPaymentId', () {
      final reversal = StudentPayment.fromJson('pay2', {
        'billId': 'bill1',
        'status': 'reversal',
        'method': 'cash',
        'amountUgx': -200000,
        'receiptNumber': 'RCT-000002',
        'recordedBy': 'bursarUid',
        'reversalOfPaymentId': 'pay1',
      });
      expect(reversal.isReversal, isTrue);
      expect(reversal.amountUgx, -200000);
      expect(reversal.reversalOfPaymentId, 'pay1');
    });
  });

  group('BillAdjustment.fromJson', () {
    test('maps type/amount/reason/approver exactly as stored', () {
      final adjustment = BillAdjustment.fromJson('adj1', {
        'billId': 'bill1',
        'type': 'discount',
        'amountUgx': 50000,
        'reason': 'sibling discount',
        'approverId': 'bursarUid',
      });
      expect(adjustment.type, 'discount');
      expect(adjustment.amountUgx, 50000);
      expect(adjustment.approverId, 'bursarUid');
    });
  });
}
