import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/subject_enrollment.dart';
import '../../../domain/repositories/subject_student_repository.dart';

abstract class SubjectStudentsEvent extends Equatable {
  const SubjectStudentsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the roster of students enrolled in the active subject+class - never
/// the whole class, since not every student in a class necessarily takes
/// every subject.
class SubjectStudentsRequested extends SubjectStudentsEvent {
  final ActiveResponsibilityContext context;
  final bool forceRefresh;

  const SubjectStudentsRequested(this.context, {this.forceRefresh = false});

  @override
  List<Object?> get props => [context, forceRefresh];
}

/// Free-text search across name and admission number.
class SubjectStudentsSearched extends SubjectStudentsEvent {
  final String query;

  const SubjectStudentsSearched(this.query);

  @override
  List<Object?> get props => [query];
}

enum SubjectRosterFilter { all, noMarks, belowAverage }

/// Switch between All / No marks yet / Below subject average.
class SubjectStudentsFiltered extends SubjectStudentsEvent {
  final SubjectRosterFilter filter;

  const SubjectStudentsFiltered(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SubjectStudentsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// The assignment this roster belongs to, so a late response from a
  /// previous subject/class can be discarded rather than painting over the
  /// new one.
  final String? roleAssignmentId;

  final List<SubjectStudentSummary> students;
  final String query;
  final SubjectRosterFilter filter;

  const SubjectStudentsState({
    this.isLoading = false,
    this.errorMessage,
    this.roleAssignmentId,
    this.students = const [],
    this.query = '',
    this.filter = SubjectRosterFilter.all,
  });

  const SubjectStudentsState.initial() : this(isLoading: true);

  bool get isEmpty => students.isEmpty;

  double? get subjectAverage {
    final marked = students.where((s) => s.subjectAverage != null).toList();
    if (marked.isEmpty) return null;
    final total = marked.fold<double>(0, (sum, s) => sum + s.subjectAverage!);
    return total / marked.length;
  }

  /// The roster after search and filter. Applied here rather than by
  /// re-querying - a subject's cohort within one class is small enough to
  /// already be in memory.
  List<SubjectStudentSummary> get visibleStudents {
    return students.where((student) {
      final q = query.trim().toLowerCase();
      if (q.isNotEmpty &&
          !student.name.toLowerCase().contains(q) &&
          !student.admissionNumber.toLowerCase().contains(q)) {
        return false;
      }

      final average = subjectAverage;
      return switch (filter) {
        SubjectRosterFilter.all => true,
        SubjectRosterFilter.noMarks => student.assessmentsMarked == 0,
        SubjectRosterFilter.belowAverage =>
          student.subjectAverage != null &&
              average != null &&
              student.subjectAverage! < average,
      };
    }).toList();
  }

  SubjectStudentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? roleAssignmentId,
    List<SubjectStudentSummary>? students,
    String? query,
    SubjectRosterFilter? filter,
    bool clearError = false,
  }) {
    return SubjectStudentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      students: students ?? this.students,
      query: query ?? this.query,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    roleAssignmentId,
    students,
    query,
    filter,
  ];
}

class SubjectStudentsBloc
    extends Bloc<SubjectStudentsEvent, SubjectStudentsState> {
  final SubjectStudentRepository studentRepository;

  SubjectStudentsBloc({required this.studentRepository})
    : super(const SubjectStudentsState.initial()) {
    on<SubjectStudentsRequested>(_onRequested);
    on<SubjectStudentsSearched>(_onSearched);
    on<SubjectStudentsFiltered>(_onFiltered);
  }

  Future<void> _onRequested(
    SubjectStudentsRequested event,
    Emitter<SubjectStudentsState> emit,
  ) async {
    // A fresh state rather than copyWith: carrying one subject's roster
    // across a switch would briefly list Mathematics/P1's students under
    // ICT/P6.
    emit(
      SubjectStudentsState(
        isLoading: true,
        roleAssignmentId: event.context.roleAssignmentId,
        query: state.query,
        filter: state.filter,
      ),
    );

    final result = await studentRepository.getSubjectStudents(
      context: event.context,
      forceRefresh: event.forceRefresh,
    );

    // The teacher may have switched again while this was in flight.
    if (state.roleAssignmentId != event.context.roleAssignmentId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: _messageFor(failure)),
      ),
      (students) => emit(
        state.copyWith(isLoading: false, students: students, clearError: true),
      ),
    );
  }

  void _onSearched(
    SubjectStudentsSearched event,
    Emitter<SubjectStudentsState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  void _onFiltered(
    SubjectStudentsFiltered event,
    Emitter<SubjectStudentsState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    NetworkFailure() => failure.message,
    ValidationFailure() => failure.message,
    _ => 'Could not load your student list. Pull down to retry.',
  };
}
