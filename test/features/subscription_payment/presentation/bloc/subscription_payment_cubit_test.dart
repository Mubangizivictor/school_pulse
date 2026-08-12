import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/subscription_payment/domain/entities/payment_attempt.dart';
import 'package:school_pulse/features/subscription_payment/domain/repositories/subscription_payment_repository.dart';
import 'package:school_pulse/features/subscription_payment/presentation/bloc/subscription_payment_cubit.dart';

class _MockRepository extends Mock implements SubscriptionPaymentRepository {}

PaymentAttempt _attempt({
  String id = 'pay-1',
  PaymentAttemptStatus status = PaymentAttemptStatus.pending,
}) {
  return PaymentAttempt(
    id: id,
    status: status,
    realPlanPriceUgx: 550000,
    planName: 'Growth',
    currency: 'EUR',
    amount: 100,
    targetEnvironment: 'sandbox',
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
  });

  group('SubscriptionPaymentCubit', () {
    blocTest<SubscriptionPaymentCubit, SubscriptionPaymentState>(
      'emits initiating then awaitingApproval on successful initiation',
      build: () {
        when(
          () => repository.initiatePayment(
            method: PaymentMethod.mtnMomo,
            phoneNumber: any(named: 'phoneNumber'),
          ),
        ).thenAnswer((_) async => 'pay-1');
        when(
          () => repository.watchPayment('pay-1'),
        ).thenAnswer((_) => const Stream.empty());
        return SubscriptionPaymentCubit(repository: repository);
      },
      act: (cubit) => cubit.initiatePayment('0793128137'),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        predicate<SubscriptionPaymentState>(
          (s) => s.status == SubscriptionPaymentStatus.initiating,
        ),
        predicate<SubscriptionPaymentState>(
          (s) => s.status == SubscriptionPaymentStatus.awaitingApproval,
        ),
      ],
      tearDown: () {},
    );

    blocTest<SubscriptionPaymentCubit, SubscriptionPaymentState>(
      'emits failed when initiation throws',
      build: () {
        when(
          () => repository.initiatePayment(
            method: PaymentMethod.mtnMomo,
            phoneNumber: any(named: 'phoneNumber'),
          ),
        ).thenThrow(Exception('network error'));
        return SubscriptionPaymentCubit(repository: repository);
      },
      act: (cubit) => cubit.initiatePayment('0793128137'),
      expect: () => [
        predicate<SubscriptionPaymentState>(
          (s) => s.status == SubscriptionPaymentStatus.initiating,
        ),
        predicate<SubscriptionPaymentState>(
          (s) =>
              s.status == SubscriptionPaymentStatus.failed &&
              s.errorMessage != null,
        ),
      ],
    );

    blocTest<SubscriptionPaymentCubit, SubscriptionPaymentState>(
      'a successful settlement delivered via watchPayment stops polling and emits succeeded',
      build: () {
        when(
          () => repository.initiatePayment(
            method: PaymentMethod.mtnMomo,
            phoneNumber: any(named: 'phoneNumber'),
          ),
        ).thenAnswer((_) async => 'pay-1');
        when(() => repository.watchPayment('pay-1')).thenAnswer(
          (_) =>
              Stream.value(_attempt(status: PaymentAttemptStatus.successful)),
        );
        return SubscriptionPaymentCubit(repository: repository);
      },
      act: (cubit) => cubit.initiatePayment('0793128137'),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        predicate<SubscriptionPaymentState>(
          (s) => s.status == SubscriptionPaymentStatus.initiating,
        ),
        predicate<SubscriptionPaymentState>(
          (s) => s.status == SubscriptionPaymentStatus.awaitingApproval,
        ),
        predicate<SubscriptionPaymentState>(
          (s) =>
              s.status == SubscriptionPaymentStatus.succeeded &&
              s.paymentAttempt?.status == PaymentAttemptStatus.successful,
        ),
      ],
    );

    blocTest<SubscriptionPaymentCubit, SubscriptionPaymentState>(
      'reset() clears state back to idle',
      build: () {
        when(
          () => repository.initiatePayment(
            method: PaymentMethod.mtnMomo,
            phoneNumber: any(named: 'phoneNumber'),
          ),
        ).thenAnswer((_) async => 'pay-1');
        when(
          () => repository.watchPayment('pay-1'),
        ).thenAnswer((_) => const Stream.empty());
        return SubscriptionPaymentCubit(repository: repository);
      },
      act: (cubit) async {
        await cubit.initiatePayment('0793128137');
        cubit.reset();
      },
      wait: const Duration(milliseconds: 10),
      skip: 2,
      expect: () => [const SubscriptionPaymentState()],
    );
  });
}
