import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/subscription_payment/domain/entities/payment_attempt.dart';

void main() {
  group('PaymentAttempt.fromMap', () {
    test('parses a PENDING sandbox payment', () {
      final attempt = PaymentAttempt.fromMap('pay-1', {
        'status': 'PENDING',
        'realPlanPriceUgx': 550000,
        'planName': 'Growth',
        'currency': 'EUR',
        'amount': '100',
        'targetEnvironment': 'sandbox',
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(1700000000000),
      });

      expect(attempt.status, PaymentAttemptStatus.pending);
      expect(attempt.realPlanPriceUgx, 550000);
      expect(attempt.planName, 'Growth');
      expect(attempt.isSandbox, isTrue);
      expect(attempt.isTerminal, isFalse);
    });

    test('parses a SUCCESSFUL payment with settlement fields', () {
      final attempt = PaymentAttempt.fromMap('pay-2', {
        'status': 'SUCCESSFUL',
        'realPlanPriceUgx': 350000,
        'planName': 'Starter',
        'currency': 'UGX',
        'amount': 350000,
        'targetEnvironment': 'mtnuganda',
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(1700000000000),
        'settledAt': Timestamp.fromMillisecondsSinceEpoch(1700000100000),
        'subscriptionExpiry': 1710000000000,
      });

      expect(attempt.status, PaymentAttemptStatus.successful);
      expect(attempt.isTerminal, isTrue);
      expect(attempt.isSandbox, isFalse);
      expect(attempt.settledAt, isNotNull);
      expect(attempt.subscriptionExpiry, isNotNull);
    });

    test('maps FAILED/EXPIRED/CANCELLED to terminal states', () {
      for (final status in ['FAILED', 'EXPIRED', 'CANCELLED']) {
        final attempt = PaymentAttempt.fromMap('pay-x', {
          'status': status,
          'realPlanPriceUgx': 100000,
          'planName': 'Plan',
          'currency': 'UGX',
          'amount': 100000,
          'targetEnvironment': 'sandbox',
          'createdAt': Timestamp.now(),
          'failureReason': 'mtn_status_${status.toLowerCase()}',
        });
        expect(attempt.isTerminal, isTrue, reason: status);
      }
    });

    test('unrecognized status falls back to unknown, never throws', () {
      final attempt = PaymentAttempt.fromMap('pay-3', {
        'status': 'SOMETHING_ELSE',
        'realPlanPriceUgx': 0,
        'planName': '',
        'currency': 'UGX',
        'amount': 0,
        'targetEnvironment': 'sandbox',
        'createdAt': Timestamp.now(),
      });
      expect(attempt.status, PaymentAttemptStatus.unknown);
      expect(attempt.isTerminal, isFalse);
    });

    test('missing createdAt does not throw, falls back to now', () {
      final attempt = PaymentAttempt.fromMap('pay-4', {
        'status': 'CREATED',
        'realPlanPriceUgx': 0,
        'planName': '',
        'currency': 'UGX',
        'amount': 0,
        'targetEnvironment': 'sandbox',
      });
      expect(attempt.createdAt, isNotNull);
    });
  });
}
