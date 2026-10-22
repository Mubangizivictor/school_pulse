import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_subject.dart';
import '../../../domain/entities/subject_assessment.dart';
import '../../../domain/entities/subject_enrollment.dart';
import '../../../domain/policies/marks_entry_policy.dart';
import '../../../domain/repositories/class_student_repository.dart';
import '../../../domain/repositories/marks_repository.dart';
import '../../../domain/repositories/subject_student_repository.dart';

abstract class MarksEvent extends Equatable {
  const MarksEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the assessments and the subject roster together - the roster names
/// every mark-entry row, whichever assessment is picked afterwards.
class MarksRequested extends MarksEvent {
  final ActiveResponsibilityContext context;

  const MarksRequested(this.context);

  @override
  List<Object?> get props => [context];
}

/// Only relevant when the active context has no ambient subject (a Class
/// Teacher marking a subject that is not their own) - picks which of the
/// class's subjects every following action is scoped to.
class MarksSubjectSelected extends MarksEvent {
  final ClassSubject subject;

  const MarksSubjectSelected(this.subject);

  @override
  List<Object?> get props => [subject];
}

class MarksAssessmentCreated extends MarksEvent {
  final String title;
  final String assessmentType;
  final double maximumMark;

  const MarksAssessmentCreated({
    required this.title,
    required this.assessmentType,
    required this.maximumMark,
  });

  @override
  List<Object?> get props => [title, assessmentType, maximumMark];
}

class MarksAssessmentSelected extends MarksEvent {
  final SubjectAssessment assessment;

  const MarksAssessmentSelected(this.assessment);

  @override
  List<Object?> get props => [assessment];
}

class MarksComponentSelected extends MarksEvent {
  final AssessmentComponent component;

  const MarksComponentSelected(this.component);

  @override
  List<Object?> get props => [component];
}

class MarksEntryChanged extends MarksEvent {
  final String studentId;
  final double? score;
  final MarkEntryStatus status;

  const MarksEntryChanged({
    required this.studentId,
    this.score,
    this.status = MarkEntryStatus.scored,
  });

  @override
  List<Object?> get props => [studentId, score, status];
}

class MarksDraftSaved extends MarksEvent {
  const MarksDraftSaved();
}

class MarksReviewRequested extends MarksEvent {
  const MarksReviewRequested();
}

class MarksSubmitted extends MarksEvent {
  const MarksSubmitted();
}

class MarksEntryEdited extends MarksEvent {
  final StudentMarkEntry entry;
  final String reason;

  const MarksEntryEdited(this.entry, this.reason);

  @override
  List<Object?> get props => [entry, reason];
}

class MarksFeedbackCleared extends MarksEvent {
  const MarksFeedbackCleared();
}

class MarksState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final ActiveResponsibilityContext? context;
  final List<SubjectAssessment> assessments;
  final List<SubjectStudentSummary> students;

  /// Every subject taught in the class, offered only when [context] has no
  /// ambient subject of its own (a Class Teacher). Empty for a Subject
  /// Teacher, whose one subject already comes from the context.
  final List<ClassSubject> classSubjects;
  final ClassSubject? selectedSubject;

  final SubjectAssessment? selectedAssessment;
  final AssessmentComponent? selectedComponent;

  /// In-progress entries for the selected component, keyed by student id.
  final Map<String, StudentMarkEntry> entries;
  final MarksSubmissionReport? review;

  const MarksState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.assessments = const [],
    this.students = const [],
    this.classSubjects = const [],
    this.selectedSubject,
    this.selectedAssessment,
    this.selectedComponent,
    this.entries = const {},
    this.review,
  });

  const MarksState.initial() : this(isLoading: true);

  /// Whether the screen still needs the teacher to say which subject they
  /// mean before anything subject-scoped (assessments, roster, entry) can
  /// load. Never true for a Subject Teacher, whose context already names one.
  bool get needsSubjectSelection =>
      context?.subjectId == null && selectedSubject == null;

  int get enteredCount =>
      entries.values.where((e) => e.status.isResolved).length;

  MarksState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    List<SubjectAssessment>? assessments,
    List<SubjectStudentSummary>? students,
    List<ClassSubject>? classSubjects,
    ClassSubject? selectedSubject,
    SubjectAssessment? selectedAssessment,
    AssessmentComponent? selectedComponent,
    Map<String, StudentMarkEntry>? entries,
    MarksSubmissionReport? review,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearReview = false,
  }) {
    return MarksState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      assessments: assessments ?? this.assessments,
      students: students ?? this.students,
      classSubjects: classSubjects ?? this.classSubjects,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedAssessment: selectedAssessment ?? this.selectedAssessment,
      selectedComponent: selectedComponent ?? this.selectedComponent,
      entries: entries ?? this.entries,
      review: clearReview ? null : (review ?? this.review),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    errorMessage,
    successMessage,
    context,
    assessments,
    students,
    classSubjects,
    selectedSubject,
    selectedAssessment,
    selectedComponent,
    entries,
    review,
  ];
}

class MarksBloc extends Bloc<MarksEvent, MarksState> {
  final MarksRepository marksRepository;
  final SubjectStudentRepository studentRepository;
  final ClassStudentRepository classStudentRepository;

  MarksBloc({
    required this.marksRepository,
    required this.studentRepository,
    required this.classStudentRepository,
  }) : super(const MarksState.initial()) {
    on<MarksRequested>(_onRequested);
    on<MarksSubjectSelected>(_onSubjectSelected);
    on<MarksAssessmentCreated>(_onAssessmentCreated);
    on<MarksAssessmentSelected>(_onAssessmentSelected);
    on<MarksComponentSelected>(_onComponentSelected);
    on<MarksEntryChanged>(_onEntryChanged);
    on<MarksDraftSaved>(_onDraftSaved);
    on<MarksReviewRequested>(_onReviewRequested);
    on<MarksSubmitted>(_onSubmitted);
    on<MarksEntryEdited>(_onEntryEdited);
    on<MarksFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    MarksRequested event,
    Emitter<MarksState> emit,
  ) async {
    emit(MarksState(isLoading: true, context: event.context));

    // A Class Teacher's context names no subject of its own - the screen
    // must ask which of the class's subjects this session is for before
    // anything subject-scoped can be fetched.
    if (event.context.subjectId == null) {
      final subjects = await marksRepository.getClassSubjects(
        context: event.context,
      );
      emit(
        state.copyWith(
          isLoading: false,
          classSubjects: subjects.getOrElse(() => const []),
          errorMessage: subjects.fold(_messageFor, (_) => null),
          clearError: subjects.isRight(),
        ),
      );
      return;
    }

    await _loadSubjectScoped(event.context, null, emit);
  }

  Future<void> _onSubjectSelected(
    MarksSubjectSelected event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isLoading: true, selectedSubject: event.subject));
    await _loadSubjectScoped(context, event.subject.id, emit);
  }

  /// Loads assessments and the roster for one subject. [subjectId] is the
  /// explicit override for a Class Teacher's picked subject; null lets the
  /// repository fall back to `context.subjectId` for a Subject Teacher.
  Future<void> _loadSubjectScoped(
    ActiveResponsibilityContext context,
    String? subjectId,
    Emitter<MarksState> emit,
  ) async {
    final assessments = await marksRepository.getAssessments(
      context: context,
      subjectId: subjectId,
    );
    // A Class Teacher's roster is the whole class regardless of subject; a
    // Subject Teacher's is scoped to who is actually enrolled in theirs.
    final roster = subjectId == null
        ? await studentRepository.getSubjectStudents(context: context)
        : await classStudentRepository
              .getClassStudents(context: context)
              .then(
                (either) => either.map(
                  (rows) => rows
                      .map(
                        (r) => SubjectStudentSummary(
                          studentId: r.studentId,
                          name: r.name,
                          admissionNumber: r.admissionNumber,
                          photoUrl: r.photoUrl,
                          classId: r.classId,
                          className: r.className,
                          streamId: r.streamId,
                          streamName: r.streamName,
                        ),
                      )
                      .toList(),
                ),
              );

    emit(
      state.copyWith(
        isLoading: false,
        assessments: assessments.getOrElse(() => const []),
        students: roster.getOrElse(() => const []),
        errorMessage: assessments.fold(_messageFor, (_) => null),
        clearError: assessments.isRight(),
      ),
    );
  }

  Future<void> _onAssessmentCreated(
    MarksAssessmentCreated event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await marksRepository.createAssessment(
      context: context,
      subjectId: state.selectedSubject?.id,
      title: event.title,
      assessmentType: event.assessmentType,
      maximumMark: event.maximumMark,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (assessment) => emit(
        state.copyWith(
          isSaving: false,
          assessments: [...state.assessments, assessment],
          successMessage: 'Assessment created.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onAssessmentSelected(
    MarksAssessmentSelected event,
    Emitter<MarksState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedAssessment: event.assessment,
        entries: const {},
        clearReview: true,
      ),
    );

    // Single-component assessments skip straight to entry with existing
    // marks preloaded, so the screen that owns navigation can decide whether
    // to show the component picker at all.
    final only = event.assessment.markableComponents;
    if (only.length == 1) {
      add(MarksComponentSelected(only.first));
    }
  }

  Future<void> _onComponentSelected(
    MarksComponentSelected event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    final assessment = state.selectedAssessment;
    if (context == null || assessment == null) return;

    emit(state.copyWith(selectedComponent: event.component, isLoading: true));

    final existing = await marksRepository.getMarks(
      context: context,
      assessment: assessment,
      component: event.component,
    );

    emit(
      state.copyWith(
        isLoading: false,
        entries: {
          for (final entry in existing.getOrElse(() => const []))
            entry.studentId: entry,
        },
        errorMessage: existing.fold(_messageFor, (_) => null),
        clearError: existing.isRight(),
      ),
    );
  }

  void _onEntryChanged(MarksEntryChanged event, Emitter<MarksState> emit) {
    final updated = Map<String, StudentMarkEntry>.from(state.entries);
    final current = updated[event.studentId];
    updated[event.studentId] =
        (current ??
                StudentMarkEntry(
                  studentId: event.studentId,
                  componentId: state.selectedComponent?.id ?? '',
                ))
            .copyWith(
              score: event.score,
              status: event.status,
              clearScore: event.score == null,
              enteredAt: DateTime.now(),
            );

    emit(state.copyWith(entries: updated));
  }

  Future<void> _onDraftSaved(
    MarksDraftSaved event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    final assessment = state.selectedAssessment;
    final component = state.selectedComponent;
    if (context == null || assessment == null || component == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await marksRepository.saveDraft(
      context: context,
      assessment: assessment,
      component: component,
      entries: state.entries.values.toList(),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Draft saved.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onReviewRequested(
    MarksReviewRequested event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    final assessment = state.selectedAssessment;
    final component = state.selectedComponent;
    if (context == null || assessment == null || component == null) return;

    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await marksRepository.review(
      context: context,
      assessment: assessment,
      component: component,
      entries: state.entries.values.toList(),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (report) => emit(
        state.copyWith(isSaving: false, review: report, clearError: true),
      ),
    );
  }

  Future<void> _onSubmitted(
    MarksSubmitted event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    final assessment = state.selectedAssessment;
    final component = state.selectedComponent;
    if (context == null || assessment == null || component == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await marksRepository.submit(
      context: context,
      assessment: assessment,
      component: component,
      entries: state.entries.values.toList(),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Marks submitted for review.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onEntryEdited(
    MarksEntryEdited event,
    Emitter<MarksState> emit,
  ) async {
    final context = state.context;
    final assessment = state.selectedAssessment;
    final component = state.selectedComponent;
    if (context == null || assessment == null || component == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await marksRepository.editMark(
      context: context,
      assessment: assessment,
      component: component,
      entry: event.entry,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (updated) {
        final entries = Map<String, StudentMarkEntry>.from(state.entries);
        entries[updated.studentId] = updated;
        emit(
          state.copyWith(
            isSaving: false,
            entries: entries,
            successMessage: 'Mark updated.',
            clearError: true,
          ),
        );
      },
    );
  }

  void _onFeedbackCleared(
    MarksFeedbackCleared event,
    Emitter<MarksState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  static String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    ValidationFailure() => failure.message,
    OfflineNotAllowedFailure() => failure.message,
    NetworkFailure() => failure.message,
    _ => 'Something went wrong. Try again.',
  };
}
