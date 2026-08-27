import 'package:equatable/equatable.dart';
import '../../../domain/entities/fee_plan.dart';

class FeePlanBuilderState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final List<FeePlan> plans;
  final String? error;
  final String? successMessage;

  const FeePlanBuilderState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.plans = const [],
    this.error,
    this.successMessage,
  });

  FeePlanBuilderState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<FeePlan>? plans,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return FeePlanBuilderState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      plans: plans ?? this.plans,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    plans,
    error,
    successMessage,
  ];
}
