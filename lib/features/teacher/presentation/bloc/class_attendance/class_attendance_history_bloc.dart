import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_attendance.dart';
import '../../../domain/repositories/class_attendance_repository.dart';

abstract class ClassAttendanceHistoryEvent extends Equatable {
  const ClassAttendanceHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load submitted registers over a window. Defaults to the last 30 days,
/// which is the span the approved history list shows.
class ClassAttendanceHistoryRequested extends ClassAttendanceHistoryEvent {
  final ActiveResponsibilityContext context;
  final HistoryRange range;

  const ClassAttendanceHistoryRequested(
    this.context, {
    this.range = HistoryRange.month,
  });

  @override
  List<Object?> get props => [context, range];
}

/// The windows the history view offers. Term is bounded by the assignment's
/// own term rather than a fixed number of days, so a school with an unusual
/// term length still gets the right span.
enum HistoryRange { week, month, term }

class ClassAttendanceHistoryState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<ClassAttendanceSession> sessions;
  final List<ClassAttendanceOption> options;
  final HistoryRange range;

  const ClassAttendanceHistoryState({
    this.isLoading = false,
    this.errorMessage,
    this.sessions = const [],
    this.options = const [],
    this.range = HistoryRange.month,
  });

  const ClassAttendanceHistoryState.initial() : this(isLoading: true);

  bool get isEmpty => sessions.isEmpty;

  int get daysRecorded => sessions.length;

  int _sum(AttendanceClassification classification) => sessions.fold(
    0,
    (total, session) =>
        total + (session.countsBy(options)[classification] ?? 0),
  );

  int get totalPresent => _sum(AttendanceClassification.present);
  int get totalAuthorisedAbsent =>
      _sum(AttendanceClassification.authorisedAbsence);
  int get totalUnauthorisedAbsent =>
      _sum(AttendanceClassification.unauthorisedAbsence);

  int get totalMarks =>
      totalPresent + totalAuthorisedAbsent + totalUnauthorisedAbsent;

  /// Attendance rate across the window, or null when nothing has been marked -
  /// a rate of 0% and "no registers yet" are different facts.
  double? get attendanceRate {
    if (totalMarks == 0) return null;
    return (totalPresent / totalMarks) * 100;
  }

  ClassAttendanceHistoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ClassAttendanceSession>? sessions,
    List<ClassAttendanceOption>? options,
    HistoryRange? range,
    bool clearError = false,
  }) {
    return ClassAttendanceHistoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sessions: sessions ?? this.sessions,
      options: options ?? this.options,
      range: range ?? this.range,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    sessions,
    options,
    range,
  ];
}

class ClassAttendanceHistoryBloc
    extends Bloc<ClassAttendanceHistoryEvent, ClassAttendanceHistoryState> {
  final ClassAttendanceRepository attendanceRepository;

  ClassAttendanceHistoryBloc({required this.attendanceRepository})
    : super(const ClassAttendanceHistoryState.initial()) {
    on<ClassAttendanceHistoryRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ClassAttendanceHistoryRequested event,
    Emitter<ClassAttendanceHistoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, range: event.range));

    final now = DateTime.now();
    final from = switch (event.range) {
      HistoryRange.week => now.subtract(const Duration(days: 7)),
      HistoryRange.month => now.subtract(const Duration(days: 30)),
      HistoryRange.term => now.subtract(const Duration(days: 120)),
    };

    final options = await attendanceRepository.getStatusOptions(
      context: event.context,
    );
    final result = await attendanceRepository.getHistory(
      context: event.context,
      from: DateTime(from.year, from.month, from.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: _messageFor(failure)),
      ),
      (sessions) => emit(
        state.copyWith(
          isLoading: false,
          sessions: sessions,
          options: options.getOrElse(() => AttendanceStatusResolver.defaults),
          clearError: true,
        ),
      ),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    NetworkFailure() => failure.message,
    ValidationFailure() => failure.message,
    _ => 'Could not load attendance history. Pull down to retry.',
  };
}
