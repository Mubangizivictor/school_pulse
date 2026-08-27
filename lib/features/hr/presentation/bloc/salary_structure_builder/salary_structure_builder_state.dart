import 'package:equatable/equatable.dart';
import '../../../domain/entities/salary_structure.dart';

class SalaryStructureBuilderState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final List<SalaryStructure> structures;
  final String? error;
  final String? successMessage;

  const SalaryStructureBuilderState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.structures = const [],
    this.error,
    this.successMessage,
  });

  SalaryStructureBuilderState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<SalaryStructure>? structures,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return SalaryStructureBuilderState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      structures: structures ?? this.structures,
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
    structures,
    error,
    successMessage,
  ];
}
