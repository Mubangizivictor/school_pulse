import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_attempt.dart';
import '../../domain/repositories/subscription_payment_repository.dart';

enum SubscriptionPaymentStatus {
  idle,
  initiating,
  awaitingApproval,
  checking,
  succeeded,
  failed,
  timedOut,
}

class SubscriptionPaymentState extends Equatable {
  const SubscriptionPaymentState({
    this.status = SubscriptionPaymentStatus.idle,
    this.paymentAttempt,
    this.errorMessage,
  });

  final SubscriptionPaymentStatus status;
  final PaymentAttempt? paymentAttempt;
  final String? errorMessage;

  SubscriptionPaymentState copyWith({
    SubscriptionPaymentStatus? status,
    PaymentAttempt? paymentAttempt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionPaymentState(
      status: status ?? this.status,
      paymentAttempt: paymentAttempt ?? this.paymentAttempt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, paymentAttempt, errorMessage];
}

/// Drives the MTN Mobile Money "Request to Pay" flow: submits the request,
/// then polls checkMtnPaymentStatus on a bounded backoff schedule
/// (5s/10s/15s/30s/60s) while also watching the payments/{id} Firestore doc
/// directly, so a settlement that lands between polls updates the UI
/// immediately instead of waiting for the next timer tick.
class SubscriptionPaymentCubit extends Cubit<SubscriptionPaymentState> {
  SubscriptionPaymentCubit({required SubscriptionPaymentRepository repository})
    : _repository = repository,
      super(const SubscriptionPaymentState());

  final SubscriptionPaymentRepository _repository;

  static const List<Duration> _backoffSchedule = [
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  StreamSubscription<PaymentAttempt>? _watchSubscription;
  Timer? _pollTimer;
  int _pollAttempt = 0;

  Future<void> initiatePayment(String phoneNumber) async {
    if (state.status == SubscriptionPaymentStatus.initiating) return;
    emit(
      state.copyWith(
        status: SubscriptionPaymentStatus.initiating,
        clearError: true,
      ),
    );

    try {
      final paymentId = await _repository.initiatePayment(
        method: PaymentMethod.mtnMomo,
        phoneNumber: phoneNumber,
      );
      _pollAttempt = 0;
      _watchPayment(paymentId);
      emit(state.copyWith(status: SubscriptionPaymentStatus.awaitingApproval));
      _scheduleNextPoll(paymentId);
    } catch (error) {
      emit(
        state.copyWith(
          status: SubscriptionPaymentStatus.failed,
          errorMessage:
              'Could not start the MTN Mobile Money request. Please try again.',
        ),
      );
    }
  }

  void _watchPayment(String paymentId) {
    _watchSubscription?.cancel();
    _watchSubscription = _repository.watchPayment(paymentId).listen((attempt) {
      if (attempt.isTerminal) {
        _stopPolling();
      }
      emit(
        state.copyWith(status: _statusFor(attempt), paymentAttempt: attempt),
      );
    });
  }

  void _scheduleNextPoll(String paymentId) {
    if (_pollAttempt >= _backoffSchedule.length) {
      if (!isClosed && !state.status.isTerminalUi) {
        emit(state.copyWith(status: SubscriptionPaymentStatus.timedOut));
      }
      return;
    }
    final delay = _backoffSchedule[_pollAttempt];
    _pollAttempt += 1;
    _pollTimer?.cancel();
    _pollTimer = Timer(delay, () => _poll(paymentId));
  }

  Future<void> _poll(String paymentId) async {
    if (isClosed) return;
    if (state.status.isTerminalUi) return;
    emit(state.copyWith(status: SubscriptionPaymentStatus.checking));
    try {
      final attempt = await _repository.checkPaymentStatus(paymentId);
      if (isClosed) return;
      emit(
        state.copyWith(status: _statusFor(attempt), paymentAttempt: attempt),
      );
      if (attempt.isTerminal) {
        _stopPolling();
        return;
      }
      emit(state.copyWith(status: SubscriptionPaymentStatus.awaitingApproval));
      _scheduleNextPoll(paymentId);
    } catch (_) {
      if (isClosed) return;
      // Transient check failure - keep polling on the bounded schedule
      // rather than giving up on a single network blip.
      emit(state.copyWith(status: SubscriptionPaymentStatus.awaitingApproval));
      _scheduleNextPoll(paymentId);
    }
  }

  SubscriptionPaymentStatus _statusFor(PaymentAttempt attempt) {
    return switch (attempt.status) {
      PaymentAttemptStatus.successful => SubscriptionPaymentStatus.succeeded,
      PaymentAttemptStatus.failed ||
      PaymentAttemptStatus.expired ||
      PaymentAttemptStatus.cancelled => SubscriptionPaymentStatus.failed,
      PaymentAttemptStatus.created ||
      PaymentAttemptStatus.pending ||
      PaymentAttemptStatus.unknown =>
        SubscriptionPaymentStatus.awaitingApproval,
    };
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void reset() {
    _stopPolling();
    _watchSubscription?.cancel();
    _watchSubscription = null;
    _pollAttempt = 0;
    emit(const SubscriptionPaymentState());
  }

  @override
  Future<void> close() {
    _stopPolling();
    _watchSubscription?.cancel();
    return super.close();
  }
}

extension on SubscriptionPaymentStatus {
  bool get isTerminalUi =>
      this == SubscriptionPaymentStatus.succeeded ||
      this == SubscriptionPaymentStatus.failed ||
      this == SubscriptionPaymentStatus.timedOut;
}
