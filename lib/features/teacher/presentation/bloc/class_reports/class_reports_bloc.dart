import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_report_entry.dart';
import '../../../domain/policies/class_report_policy.dart';
import '../../../domain/repositories/class_report_repository.dart';

abstract class ClassReportsEvent extends Equatable {
  const ClassReportsEvent();

  @override
  List<Object?> get props => [];
}

class ClassReportsRequested extends ClassReportsEvent {
  final ActiveResponsibilityContext context;

  const ClassReportsRequested(this.context);

  @override
  List<Object?> get props => [context];
}

class ClassReportEntrySaved extends ClassReportsEvent {
  final ClassReportEntry entry;

  const ClassReportEntrySaved(this.entry);

  @override
  List<Object?> get props => [entry];
}

class ClassReportEntrySubmitted extends ClassReportsEvent {
  final ClassReportEntry entry;

  const ClassReportEntrySubmitted(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Generate for a set of students, or for the whole class when empty.
class ClassReportsGenerated extends ClassReportsEvent {
  final List<String> studentIds;

  const ClassReportsGenerated({this.studentIds = const []});

  @override
  List<Object?> get props => [studentIds];
}

class ClassReportsFeedbackCleared extends ClassReportsEvent {
  const ClassReportsFeedbackCleared();
}

/// Submits one or more generated report cards to the Dean for academic
/// review - the academic-submission step, not the financial-publication one
/// (see the module docstring in functions/report_card_engine.js).
class ClassReportCardsSubmittedToDean extends ClassReportsEvent {
  final List<String> reportCardIds;

  const ClassReportCardsSubmittedToDean(this.reportCardIds);

  @override
  List<Object?> get props => [reportCardIds];
}

class ClassReportsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final ActiveResponsibilityContext? context;
  final ReportProfile? profile;
  final List<ClassReportEntry> entries;

  /// Subjects whose marks have not been approved. The teacher cannot fix
  /// these, so they are shown by name rather than as a generic blocker.
  final List<String> unapprovedSubjects;

  const ClassReportsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.profile,
    this.entries = const [],
    this.unapprovedSubjects = const [],
  });

  const ClassReportsState.initial() : this(isLoading: true);

  bool get canGenerate => context?.can(Permission.classReportGenerate) ?? false;

  ReportProgress get progress => profile == null
      ? const ReportProgress()
      : ClassReportPolicy.progressOf(entries, profile!);

  List<ClassReportEntry> get returned =>
      entries.where((e) => e.wasReturned).toList();

  List<ClassReportEntry> get incomplete {
    final p = profile;
    if (p == null) return const [];
    return entries
        .where(
          (e) => ClassReportPolicy.missingSections(
            entry: e,
            profile: p,
          ).isNotEmpty,
        )
        .toList();
  }

  List<ReportSection> missingFor(ClassReportEntry entry) {
    final p = profile;
    if (p == null) return const [];
    return ClassReportPolicy.missingSections(entry: entry, profile: p);
  }

  /// Entries with a generated canonical report card that has not yet been
  /// submitted to the Dean - the set the "Submit to Dean" action operates
  /// on. A generated-but-not-yet-`classTeacherCompleted` entry is excluded:
  /// generation only produces the snapshot, submission is a distinct,
  /// deliberate step the teacher takes after reviewing it.
  List<ClassReportEntry> get submittableToDean => entries
      .where(
        (e) =>
            e.reportCardId != null &&
            e.status == ReportEntryStatus.classTeacherCompleted,
      )
      .toList();

  ClassReportsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    ReportProfile? profile,
    List<ClassReportEntry>? entries,
    List<String>? unapprovedSubjects,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClassReportsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      profile: profile ?? this.profile,
      entries: entries ?? this.entries,
      unapprovedSubjects: unapprovedSubjects ?? this.unapprovedSubjects,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    errorMessage,
    successMessage,
    context,
    profile,
    entries,
    unapprovedSubjects,
  ];
}

class ClassReportsBloc extends Bloc<ClassReportsEvent, ClassReportsState> {
  final ClassReportRepository reportRepository;

  ClassReportsBloc({required this.reportRepository})
    : super(const ClassReportsState.initial()) {
    on<ClassReportsRequested>(_onRequested);
    on<ClassReportEntrySaved>(_onSaved);
    on<ClassReportEntrySubmitted>(_onSubmitted);
    on<ClassReportsGenerated>(_onGenerated);
    on<ClassReportCardsSubmittedToDean>(_onSubmittedToDean);
    on<ClassReportsFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ClassReportsRequested event,
    Emitter<ClassReportsState> emit,
  ) async {
    // A refresh can be triggered while a report detail route is open. Keep
    // the loaded profile and entries until the replacement snapshot arrives;
    // otherwise the detail screen briefly sees an empty list and treats its
    // report as deleted.
    emit(
      state.copyWith(
        isLoading: true,
        context: event.context,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final profile = await reportRepository.getProfile(context: event.context);
    final entries = await reportRepository.getEntries(context: event.context);
    final unapproved = await reportRepository.unapprovedSubjects(
      context: event.context,
    );

    entries.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          profile: profile.getOrElse(() => const ReportProfile(id: 'default')),
          errorMessage: _messageFor(failure),
        ),
      ),
      (list) => emit(
        state.copyWith(
          isLoading: false,
          profile: profile.getOrElse(() => const ReportProfile(id: 'default')),
          entries: list,
          unapprovedSubjects: unapproved.getOrElse(() => const []),
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onSaved(
    ClassReportEntrySaved event,
    Emitter<ClassReportsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await reportRepository.saveEntry(
      context: context,
      entry: event.entry,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Saved.',
          clearError: true,
        ),
      ),
    );
    add(ClassReportsRequested(context));
  }

  Future<void> _onSubmitted(
    ClassReportEntrySubmitted event,
    Emitter<ClassReportsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await reportRepository.submitEntry(
      context: context,
      entry: event.entry,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Report sent to the academic office.',
          clearError: true,
        ),
      ),
    );
    add(ClassReportsRequested(context));
  }

  Future<void> _onGenerated(
    ClassReportsGenerated event,
    Emitter<ClassReportsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final selected = event.studentIds.isEmpty
        ? state.entries
        : state.entries
              .where((e) => event.studentIds.contains(e.studentId))
              .toList();

    final result = await reportRepository.generateReports(
      context: context,
      entries: selected,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (count) => emit(
        state.copyWith(
          isSaving: false,
          successMessage:
              '$count report${count == 1 ? '' : 's'} sent for '
              'generation.',
          clearError: true,
        ),
      ),
    );
    add(ClassReportsRequested(context));
  }

  Future<void> _onSubmittedToDean(
    ClassReportCardsSubmittedToDean event,
    Emitter<ClassReportsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await reportRepository.submitReportCardsToDean(
      context: context,
      reportCardIds: event.reportCardIds,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (outcome) {
        final submittedCount = outcome.submitted.length;
        final failedCount = outcome.failed.length;
        final message = failedCount == 0
            ? '$submittedCount report${submittedCount == 1 ? '' : 's'} '
                  'submitted to the Dean.'
            : '$submittedCount submitted, $failedCount could not be '
                  'submitted right now.';
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: message,
            clearError: true,
          ),
        );
      },
    );
    add(ClassReportsRequested(context));
  }

  void _onFeedbackCleared(
    ClassReportsFeedbackCleared event,
    Emitter<ClassReportsState> emit,
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
