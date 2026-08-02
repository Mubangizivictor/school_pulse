import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_student_summary.dart';
import '../../../domain/entities/lesson_attendance.dart';
import '../../../domain/repositories/class_attendance_repository.dart';
import '../../../domain/repositories/class_student_repository.dart';

abstract class ClassStudentsEvent extends Equatable {
  const ClassStudentsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the roster for a class, with today's register applied to it.
class ClassStudentsRequested extends ClassStudentsEvent {
  final ActiveResponsibilityContext context;
  final bool forceRefresh;

  const ClassStudentsRequested(this.context, {this.forceRefresh = false});

  @override
  List<Object?> get props => [context, forceRefresh];
}

/// Free-text search across name, admission number and student id - a teacher
/// chasing an absentee has whichever one the parent quoted.
class ClassStudentsSearched extends ClassStudentsEvent {
  final String query;

  const ClassStudentsSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Switch between the All / Present / Absent views.
class ClassStudentsFiltered extends ClassStudentsEvent {
  final ClassRosterFilter filter;

  const ClassStudentsFiltered(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Narrow the roster by an attribute the school records. Passing null for a
/// dimension clears it.
class ClassStudentsRefined extends ClassStudentsEvent {
  final String? gender;
  final ResidencyType? residency;
  final bool clearGender;
  final bool clearResidency;

  const ClassStudentsRefined({
    this.gender,
    this.residency,
    this.clearGender = false,
    this.clearResidency = false,
  });

  @override
  List<Object?> get props => [gender, residency, clearGender, clearResidency];
}

enum ClassRosterFilter { all, present, absent }

class ClassStudentsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// The assignment this roster belongs to, so a late response from a
  /// previous class can be discarded rather than painting over the new one.
  final String? roleAssignmentId;

  final List<ClassStudentSummary> students;

  /// Today's register. A student absent from this map was never marked, which
  /// the roster shows as "Not marked" rather than as an absence.
  final Map<String, LessonAttendanceStatus> attendance;

  final String query;
  final ClassRosterFilter filter;
  final String? genderFilter;
  final ResidencyType? residencyFilter;

  const ClassStudentsState({
    this.isLoading = false,
    this.errorMessage,
    this.roleAssignmentId,
    this.students = const [],
    this.attendance = const {},
    this.query = '',
    this.filter = ClassRosterFilter.all,
    this.genderFilter,
    this.residencyFilter,
  });

  const ClassStudentsState.initial() : this(isLoading: true);

  LessonAttendanceStatus statusOf(String studentId) =>
      attendance[studentId] ?? LessonAttendanceStatus.notMarked;

  /// True once any student has been marked - what separates "nobody is
  /// absent" from "the register has not been taken".
  bool get hasRegister => attendance.isNotEmpty;

  int get presentCount => students
      .where((s) => statusOf(s.studentId).countsAsPresent)
      .length;

  int get absentCount => students.where((s) {
        final status = statusOf(s.studentId);
        return status != LessonAttendanceStatus.notMarked &&
            !status.countsAsPresent;
      }).length;

  /// The roster after search, tab and attribute filters. Applied in the BLoC's
  /// state rather than by re-querying, because the whole class is already in
  /// memory and a school class is tens of students, not thousands.
  List<ClassStudentSummary> get visibleStudents {
    return students.where((student) {
      if (!student.matches(query)) return false;

      final gender = genderFilter;
      if (gender != null && student.gender != gender) return false;

      final residency = residencyFilter;
      if (residency != null && student.residency != residency) return false;

      return switch (filter) {
        ClassRosterFilter.all => true,
        ClassRosterFilter.present => statusOf(student.studentId).countsAsPresent,
        ClassRosterFilter.absent => statusOf(student.studentId) !=
                LessonAttendanceStatus.notMarked &&
            !statusOf(student.studentId).countsAsPresent,
      };
    }).toList();
  }

  bool get isEmpty => students.isEmpty;

  ClassStudentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? roleAssignmentId,
    List<ClassStudentSummary>? students,
    Map<String, LessonAttendanceStatus>? attendance,
    String? query,
    ClassRosterFilter? filter,
    String? genderFilter,
    ResidencyType? residencyFilter,
    bool clearError = false,
    bool clearGender = false,
    bool clearResidency = false,
  }) {
    return ClassStudentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      students: students ?? this.students,
      attendance: attendance ?? this.attendance,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      genderFilter: clearGender ? null : (genderFilter ?? this.genderFilter),
      residencyFilter:
          clearResidency ? null : (residencyFilter ?? this.residencyFilter),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        roleAssignmentId,
        students,
        attendance,
        query,
        filter,
        genderFilter,
        residencyFilter,
      ];
}

class ClassStudentsBloc extends Bloc<ClassStudentsEvent, ClassStudentsState> {
  final ClassStudentRepository studentRepository;
  final ClassAttendanceRepository attendanceRepository;

  ClassStudentsBloc({
    required this.studentRepository,
    required this.attendanceRepository,
  }) : super(const ClassStudentsState.initial()) {
    on<ClassStudentsRequested>(_onRequested);
    on<ClassStudentsSearched>(_onSearched);
    on<ClassStudentsFiltered>(_onFiltered);
    on<ClassStudentsRefined>(_onRefined);
  }

  Future<void> _onRequested(
    ClassStudentsRequested event,
    Emitter<ClassStudentsState> emit,
  ) async {
    // A fresh state rather than copyWith: carrying one class's roster across a
    // switch would briefly list P5 East's students under P6 West.
    emit(ClassStudentsState(
      isLoading: true,
      roleAssignmentId: event.context.roleAssignmentId,
      query: state.query,
      filter: state.filter,
    ));

    final roster = await studentRepository.getClassStudents(
      context: event.context,
      forceRefresh: event.forceRefresh,
    );
    final register = await attendanceRepository.getStatusesForDate(
      context: event.context,
      date: DateTime.now(),
    );

    // The teacher may have switched again while these were in flight.
    if (state.roleAssignmentId != event.context.roleAssignmentId) return;

    roster.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _messageFor(failure),
      )),
      (students) => emit(state.copyWith(
        isLoading: false,
        students: students,
        // A register that will not load must not blank the roster that did.
        attendance: register.getOrElse(() => const {}),
        clearError: true,
      )),
    );
  }

  void _onSearched(ClassStudentsSearched event, Emitter<ClassStudentsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onFiltered(ClassStudentsFiltered event, Emitter<ClassStudentsState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onRefined(ClassStudentsRefined event, Emitter<ClassStudentsState> emit) {
    emit(state.copyWith(
      genderFilter: event.gender,
      residencyFilter: event.residency,
      clearGender: event.clearGender,
      clearResidency: event.clearResidency,
    ));
  }

  String _messageFor(Failure failure) => switch (failure) {
        PermissionDeniedFailure() => failure.message,
        AssignmentInvalidFailure() => failure.message,
        NetworkFailure() => failure.message,
        ValidationFailure() => failure.message,
        _ => 'Could not load your class list. Pull down to retry.',
      };
}
