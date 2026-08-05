import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_attendance.dart';
import '../../../domain/entities/class_student_summary.dart';
import '../../../domain/repositories/class_attendance_repository.dart';
import '../../../domain/repositories/class_student_repository.dart';

abstract class ClassAttendanceEvent extends Equatable {
  const ClassAttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Open the register for a date - the roster, the school's status options and
/// any existing session, resolved together.
class ClassAttendanceOpened extends ClassAttendanceEvent {
  final ActiveResponsibilityContext context;
  final DateTime date;

  const ClassAttendanceOpened(this.context, {required this.date});

  @override
  List<Object?> get props => [context, date];
}

class ClassAttendanceStudentMarked extends ClassAttendanceEvent {
  final String studentId;
  final String statusCode;

  const ClassAttendanceStudentMarked(this.studentId, this.statusCode);

  @override
  List<Object?> get props => [studentId, statusCode];
}

/// Mark everyone currently visible with one status - the "Mark all present"
/// control. Scoped to the filtered list so a search does not silently mark
/// students the teacher cannot see.
class ClassAttendanceAllMarked extends ClassAttendanceEvent {
  final String statusCode;

  const ClassAttendanceAllMarked(this.statusCode);

  @override
  List<Object?> get props => [statusCode];
}

class ClassAttendanceSearched extends ClassAttendanceEvent {
  final String query;

  const ClassAttendanceSearched(this.query);

  @override
  List<Object?> get props => [query];
}

class ClassAttendanceDraftSaved extends ClassAttendanceEvent {
  const ClassAttendanceDraftSaved();
}

class ClassAttendanceSubmitted extends ClassAttendanceEvent {
  const ClassAttendanceSubmitted();
}

/// Change one student's mark on an already-submitted register.
class ClassAttendanceCorrected extends ClassAttendanceEvent {
  final String studentId;
  final String statusCode;
  final String reason;

  const ClassAttendanceCorrected({
    required this.studentId,
    required this.statusCode,
    required this.reason,
  });

  @override
  List<Object?> get props => [studentId, statusCode, reason];
}

/// Ask the academic office to change a register the teacher may no longer
/// edit themselves.
class ClassAttendanceCorrectionRequested extends ClassAttendanceEvent {
  final String studentId;
  final String statusCode;
  final String reason;

  const ClassAttendanceCorrectionRequested({
    required this.studentId,
    required this.statusCode,
    required this.reason,
  });

  @override
  List<Object?> get props => [studentId, statusCode, reason];
}

class ClassAttendanceFeedbackCleared extends ClassAttendanceEvent {
  const ClassAttendanceFeedbackCleared();
}

class ClassAttendanceState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final ActiveResponsibilityContext? context;
  final ClassAttendanceSession? session;
  final List<ClassStudentSummary> students;
  final List<ClassAttendanceOption> options;
  final String query;

  /// True when the last refusal is one the academic office could still
  /// approve, so the UI can offer that instead of a dead end.
  final bool canRequestCorrection;

  const ClassAttendanceState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.session,
    this.students = const [],
    this.options = const [],
    this.query = '',
    this.canRequestCorrection = false,
  });

  const ClassAttendanceState.initial() : this(isLoading: true);

  List<String> get rosterStudentIds =>
      students.map((s) => s.studentId).toList();

  List<ClassStudentSummary> get visibleStudents =>
      students.where((s) => s.matches(query)).toList();

  String statusOf(String studentId) => session?.statusCodeFor(studentId) ?? '';

  ClassAttendanceOption? optionFor(String code) =>
      options.where((o) => o.code == code).firstOrNull;

  /// Students with no mark at all. Named rather than counted as absent - the
  /// submit guard reports them so nobody is recorded absent by omission.
  int get unmarkedCount =>
      session?.unmarkedFrom(rosterStudentIds).length ?? students.length;

  bool get isSubmitted => session?.isSubmitted ?? false;
  bool get isLocked => session?.isLocked ?? false;

  /// Whether the teacher may still change marks directly, as opposed to
  /// needing a correction reason or the academic office.
  bool get isEditable {
    final s = session;
    if (s == null) return false;
    if (s.isLocked) return false;
    if (!s.isSubmitted) return true;
    return context?.can(Permission.classAttendanceEdit) ?? false;
  }

  Map<AttendanceClassification, int> get counts =>
      session?.countsBy(options) ??
      {for (final c in AttendanceClassification.values) c: 0};

  int get presentCount => counts[AttendanceClassification.present] ?? 0;

  int get absentCount =>
      (counts[AttendanceClassification.unauthorisedAbsence] ?? 0) +
      (counts[AttendanceClassification.authorisedAbsence] ?? 0);

  ClassAttendanceState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    ClassAttendanceSession? session,
    List<ClassStudentSummary>? students,
    List<ClassAttendanceOption>? options,
    String? query,
    bool? canRequestCorrection,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClassAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      session: session ?? this.session,
      students: students ?? this.students,
      options: options ?? this.options,
      query: query ?? this.query,
      canRequestCorrection: canRequestCorrection ?? this.canRequestCorrection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    errorMessage,
    successMessage,
    context,
    session,
    students,
    options,
    query,
    canRequestCorrection,
  ];
}

class ClassAttendanceBloc
    extends Bloc<ClassAttendanceEvent, ClassAttendanceState> {
  final ClassAttendanceRepository attendanceRepository;
  final ClassStudentRepository studentRepository;

  ClassAttendanceBloc({
    required this.attendanceRepository,
    required this.studentRepository,
  }) : super(const ClassAttendanceState.initial()) {
    on<ClassAttendanceOpened>(_onOpened);
    on<ClassAttendanceStudentMarked>(_onMarked);
    on<ClassAttendanceAllMarked>(_onAllMarked);
    on<ClassAttendanceSearched>(_onSearched);
    on<ClassAttendanceDraftSaved>(_onDraftSaved);
    on<ClassAttendanceSubmitted>(_onSubmitted);
    on<ClassAttendanceCorrected>(_onCorrected);
    on<ClassAttendanceCorrectionRequested>(_onCorrectionRequested);
    on<ClassAttendanceFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onOpened(
    ClassAttendanceOpened event,
    Emitter<ClassAttendanceState> emit,
  ) async {
    emit(ClassAttendanceState(isLoading: true, context: event.context));

    final roster = await studentRepository.getClassStudents(
      context: event.context,
    );
    final options = await attendanceRepository.getStatusOptions(
      context: event.context,
    );
    final session = await attendanceRepository.resolveSession(
      context: event.context,
      date: event.date,
    );

    final students = roster.getOrElse(() => const []);
    final resolvedOptions = options.getOrElse(
      () => AttendanceStatusResolver.defaults,
    );

    session.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          students: students,
          options: resolvedOptions,
          errorMessage: _messageFor(failure),
        ),
      ),
      (resolved) => emit(
        state.copyWith(
          isLoading: false,
          students: students,
          options: resolvedOptions,
          session: resolved,
          clearError: true,
        ),
      ),
    );
  }

  void _onMarked(
    ClassAttendanceStudentMarked event,
    Emitter<ClassAttendanceState> emit,
  ) {
    final session = state.session;
    if (session == null) return;

    if (!state.isEditable) {
      emit(
        state.copyWith(
          errorMessage: session.isLocked
              ? 'This register has been closed by the academic office.'
              : 'This register has been submitted. Use Correct to change a mark.',
          canRequestCorrection: true,
        ),
      );
      return;
    }

    final decision = ClassAttendancePolicyBridge.canMark(
      statusCode: event.statusCode,
      options: state.options,
      studentId: event.studentId,
      rosterStudentIds: state.rosterStudentIds,
    );
    if (decision != null) {
      emit(state.copyWith(errorMessage: decision));
      return;
    }

    emit(
      state.copyWith(
        session: session.withMark(event.studentId, event.statusCode),
        clearError: true,
      ),
    );
  }

  void _onAllMarked(
    ClassAttendanceAllMarked event,
    Emitter<ClassAttendanceState> emit,
  ) {
    final session = state.session;
    if (session == null || !state.isEditable) return;

    var updated = session;
    // Only what the teacher can currently see: marking students hidden behind
    // a search would be marking students they did not look at.
    for (final student in state.visibleStudents) {
      updated = updated.withMark(student.studentId, event.statusCode);
    }

    emit(state.copyWith(session: updated, clearError: true));
  }

  void _onSearched(
    ClassAttendanceSearched event,
    Emitter<ClassAttendanceState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onDraftSaved(
    ClassAttendanceDraftSaved event,
    Emitter<ClassAttendanceState> emit,
  ) async {
    final context = state.context;
    final session = state.session;
    if (context == null || session == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await attendanceRepository.saveDraft(
      context: context,
      session: session,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (saved) => emit(
        state.copyWith(
          isSaving: false,
          session: saved,
          successMessage: 'Draft saved.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    ClassAttendanceSubmitted event,
    Emitter<ClassAttendanceState> emit,
  ) async {
    final context = state.context;
    final session = state.session;
    if (context == null || session == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await attendanceRepository.submit(
      context: context,
      session: session,
      rosterStudentIds: state.rosterStudentIds,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSaving: false,
          errorMessage: _messageFor(failure),
          canRequestCorrection: failure is PermissionDeniedFailure,
        ),
      ),
      (submitted) => emit(
        state.copyWith(
          isSaving: false,
          session: submitted,
          successMessage: 'Attendance submitted.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCorrected(
    ClassAttendanceCorrected event,
    Emitter<ClassAttendanceState> emit,
  ) async {
    final context = state.context;
    final session = state.session;
    if (context == null || session == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await attendanceRepository.correct(
      context: context,
      session: session,
      studentId: event.studentId,
      newStatusCode: event.statusCode,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSaving: false,
          errorMessage: _messageFor(failure),
          canRequestCorrection: failure is PermissionDeniedFailure,
        ),
      ),
      (corrected) => emit(
        state.copyWith(
          isSaving: false,
          session: corrected,
          successMessage: 'Register corrected.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCorrectionRequested(
    ClassAttendanceCorrectionRequested event,
    Emitter<ClassAttendanceState> emit,
  ) async {
    final context = state.context;
    final session = state.session;
    if (context == null || session == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await attendanceRepository.requestCorrection(
      context: context,
      session: session,
      studentId: event.studentId,
      requestedStatusCode: event.statusCode,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage:
              'Correction requested. The academic office will review it.',
          canRequestCorrection: false,
          clearError: true,
        ),
      ),
    );
  }

  void _onFeedbackCleared(
    ClassAttendanceFeedbackCleared event,
    Emitter<ClassAttendanceState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    ValidationFailure() => failure.message,
    OfflineNotAllowedFailure() => failure.message,
    NetworkFailure() => failure.message,
    _ => 'Could not save the register. Try again.',
  };
}

/// Thin adapter so the BLoC can run the marking guard without importing the
/// policy's whole decision type into its own vocabulary.
class ClassAttendancePolicyBridge {
  const ClassAttendancePolicyBridge._();

  /// Returns the refusal message, or null when the mark is allowed.
  static String? canMark({
    required String statusCode,
    required List<ClassAttendanceOption> options,
    required String studentId,
    required List<String> rosterStudentIds,
  }) {
    if (!rosterStudentIds.contains(studentId)) {
      return 'That student is not on this class register.';
    }
    if (!options.any((o) => o.code == statusCode)) {
      return 'That attendance status is not one your school uses.';
    }
    return null;
  }
}
