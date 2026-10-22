import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_performance.dart';
import '../../../domain/repositories/class_performance_repository.dart';

abstract class StudentAssessmentResultsEvent extends Equatable {
  const StudentAssessmentResultsEvent();

  @override
  List<Object?> get props => [];
}

class StudentAssessmentResultsRequested extends StudentAssessmentResultsEvent {
  final ActiveResponsibilityContext context;
  final String studentId;
  final String subjectId;

  const StudentAssessmentResultsRequested({
    required this.context,
    required this.studentId,
    required this.subjectId,
  });

  @override
  List<Object?> get props => [context, studentId, subjectId];
}

class StudentAssessmentResultsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<StudentAssessmentResult>? results;

  const StudentAssessmentResultsState({
    this.isLoading = false,
    this.errorMessage,
    this.results,
  });

  const StudentAssessmentResultsState.initial() : this(isLoading: true);

  @override
  List<Object?> get props => [isLoading, errorMessage, results];
}

class StudentAssessmentResultsBloc
    extends Bloc<StudentAssessmentResultsEvent, StudentAssessmentResultsState> {
  final ClassPerformanceRepository performanceRepository;

  StudentAssessmentResultsBloc({required this.performanceRepository})
    : super(const StudentAssessmentResultsState.initial()) {
    on<StudentAssessmentResultsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    StudentAssessmentResultsRequested event,
    Emitter<StudentAssessmentResultsState> emit,
  ) async {
    emit(const StudentAssessmentResultsState(isLoading: true));

    final result = await performanceRepository.getStudentAssessmentResults(
      context: event.context,
      studentId: event.studentId,
      subjectId: event.subjectId,
    );

    result.fold(
      (failure) => emit(
        StudentAssessmentResultsState(
          isLoading: false,
          errorMessage: _messageFor(failure),
        ),
      ),
      (results) => emit(
        StudentAssessmentResultsState(isLoading: false, results: results),
      ),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    ValidationFailure() => failure.message,
    NetworkFailure() => failure.message,
    _ => 'Could not load assessment detail. Pull down to retry.',
  };
}
