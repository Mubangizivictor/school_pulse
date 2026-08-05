import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_performance.dart';
import '../../../domain/repositories/class_performance_repository.dart';

abstract class ClassPerformanceEvent extends Equatable {
  const ClassPerformanceEvent();

  @override
  List<Object?> get props => [];
}

class ClassPerformanceRequested extends ClassPerformanceEvent {
  final ActiveResponsibilityContext context;

  const ClassPerformanceRequested(this.context);

  @override
  List<Object?> get props => [context];
}

class ClassPerformanceState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? roleAssignmentId;
  final ClassPerformanceSummary? summary;

  const ClassPerformanceState({
    this.isLoading = false,
    this.errorMessage,
    this.roleAssignmentId,
    this.summary,
  });

  const ClassPerformanceState.initial() : this(isLoading: true);

  bool get hasSummary => summary != null;

  /// True when the class has students but no approved marks yet - a real and
  /// common state early in a term, distinct from an error.
  bool get awaitingMarks {
    final s = summary;
    if (s == null) return false;
    return s.students.isNotEmpty && s.studentsWithMarks == 0;
  }

  ClassPerformanceState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? roleAssignmentId,
    ClassPerformanceSummary? summary,
    bool clearError = false,
  }) {
    return ClassPerformanceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    roleAssignmentId,
    summary,
  ];
}

class ClassPerformanceBloc
    extends Bloc<ClassPerformanceEvent, ClassPerformanceState> {
  final ClassPerformanceRepository performanceRepository;

  ClassPerformanceBloc({required this.performanceRepository})
    : super(const ClassPerformanceState.initial()) {
    on<ClassPerformanceRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ClassPerformanceRequested event,
    Emitter<ClassPerformanceState> emit,
  ) async {
    emit(
      ClassPerformanceState(
        isLoading: true,
        roleAssignmentId: event.context.roleAssignmentId,
      ),
    );

    final result = await performanceRepository.getPerformance(
      context: event.context,
    );

    // The teacher may have switched class while this was in flight.
    if (state.roleAssignmentId != event.context.roleAssignmentId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: _messageFor(failure)),
      ),
      (summary) => emit(
        state.copyWith(isLoading: false, summary: summary, clearError: true),
      ),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    ValidationFailure() => failure.message,
    NetworkFailure() => failure.message,
    _ => 'Could not load class performance. Pull down to retry.',
  };
}
