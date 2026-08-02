import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_behaviour.dart';
import '../../../domain/entities/class_homework.dart';
import '../../../domain/entities/class_student_summary.dart';
import '../../../domain/repositories/class_student_repository.dart';
import '../../../domain/repositories/class_work_repository.dart';

abstract class ClassWorkEvent extends Equatable {
  const ClassWorkEvent();

  @override
  List<Object?> get props => [];
}

/// Load homework, behaviour records, categories and the roster together - the
/// behaviour form needs the roster to name a student, and the homework list
/// needs nothing else.
class ClassWorkRequested extends ClassWorkEvent {
  final ActiveResponsibilityContext context;

  const ClassWorkRequested(this.context);

  @override
  List<Object?> get props => [context];
}

class ClassHomeworkSaved extends ClassWorkEvent {
  final ClassHomework homework;

  /// Publish immediately after saving, rather than leaving it a draft.
  final bool publish;

  const ClassHomeworkSaved(this.homework, {this.publish = false});

  @override
  List<Object?> get props => [homework, publish];
}

class ClassHomeworkPublished extends ClassWorkEvent {
  final ClassHomework homework;

  const ClassHomeworkPublished(this.homework);

  @override
  List<Object?> get props => [homework];
}

class ClassHomeworkCancelled extends ClassWorkEvent {
  final ClassHomework homework;
  final String reason;

  const ClassHomeworkCancelled(this.homework, this.reason);

  @override
  List<Object?> get props => [homework, reason];
}

class ClassBehaviourRecorded extends ClassWorkEvent {
  final ClassBehaviourRecord record;

  const ClassBehaviourRecorded(this.record);

  @override
  List<Object?> get props => [record];
}

class ClassBehaviourFollowUpClosed extends ClassWorkEvent {
  final ClassBehaviourRecord record;
  final String note;

  const ClassBehaviourFollowUpClosed(this.record, this.note);

  @override
  List<Object?> get props => [record, note];
}

class ClassWorkFeedbackCleared extends ClassWorkEvent {
  const ClassWorkFeedbackCleared();
}

class ClassWorkState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final ActiveResponsibilityContext? context;
  final List<ClassHomework> homework;
  final List<ClassBehaviourRecord> behaviourRecords;
  final List<BehaviourCategory> categories;
  final List<ClassStudentSummary> students;

  const ClassWorkState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.homework = const [],
    this.behaviourRecords = const [],
    this.categories = const [],
    this.students = const [],
  });

  const ClassWorkState.initial() : this(isLoading: true);

  bool get canPublish =>
      context?.can(Permission.classHomeworkPublish) ?? false;

  /// Work still open, with the due date applied - what the list leads with.
  List<ClassHomework> get openHomework => homework
      .where((h) => h.effectiveStatus().isOpen)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<ClassHomework> get draftHomework =>
      homework.where((h) => h.isDraft).toList();

  int get overdueCount => homework
      .where((h) => h.effectiveStatus() == ClassHomeworkStatus.overdue)
      .length;

  BehaviourCategory? categoryFor(String code) =>
      categories.where((c) => c.code == code).firstOrNull;

  int get positiveCount => behaviourRecords
      .where((r) => categoryFor(r.categoryCode)?.isPositive ?? false)
      .length;

  int get concernCount => behaviourRecords
      .where((r) => categoryFor(r.categoryCode)?.valence == BehaviourValence.concern)
      .length;

  int get openFollowUps =>
      behaviourRecords.where((r) => r.isOpenFollowUp).length;

  ClassWorkState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    List<ClassHomework>? homework,
    List<ClassBehaviourRecord>? behaviourRecords,
    List<BehaviourCategory>? categories,
    List<ClassStudentSummary>? students,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClassWorkState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      homework: homework ?? this.homework,
      behaviourRecords: behaviourRecords ?? this.behaviourRecords,
      categories: categories ?? this.categories,
      students: students ?? this.students,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        context,
        homework,
        behaviourRecords,
        categories,
        students,
      ];
}

class ClassWorkBloc extends Bloc<ClassWorkEvent, ClassWorkState> {
  final ClassWorkRepository workRepository;
  final ClassStudentRepository studentRepository;

  ClassWorkBloc({
    required this.workRepository,
    required this.studentRepository,
  }) : super(const ClassWorkState.initial()) {
    on<ClassWorkRequested>(_onRequested);
    on<ClassHomeworkSaved>(_onHomeworkSaved);
    on<ClassHomeworkPublished>(_onHomeworkPublished);
    on<ClassHomeworkCancelled>(_onHomeworkCancelled);
    on<ClassBehaviourRecorded>(_onBehaviourRecorded);
    on<ClassBehaviourFollowUpClosed>(_onFollowUpClosed);
    on<ClassWorkFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ClassWorkRequested event,
    Emitter<ClassWorkState> emit,
  ) async {
    emit(ClassWorkState(isLoading: true, context: event.context));

    final homework = await workRepository.getHomework(context: event.context);
    final categories =
        await workRepository.getBehaviourCategories(context: event.context);
    final records =
        await workRepository.getBehaviourRecords(context: event.context);
    final roster =
        await studentRepository.getClassStudents(context: event.context);

    // A failure in one list must not blank the others that loaded.
    final error = [homework, records]
        .map((r) => r.fold<String?>(_messageFor, (_) => null))
        .whereType<String>()
        .firstOrNull;

    emit(state.copyWith(
      isLoading: false,
      homework: homework.getOrElse(() => const []),
      behaviourRecords: records.getOrElse(() => const []),
      categories: categories.getOrElse(() => BehaviourCategoryResolver.defaults),
      students: roster.getOrElse(() => const []),
      errorMessage: error,
      clearError: error == null,
    ));
  }

  Future<void> _onHomeworkSaved(
    ClassHomeworkSaved event,
    Emitter<ClassWorkState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final saved = await workRepository.saveHomework(
      context: context,
      homework: event.homework,
    );

    await saved.fold(
      (failure) async => emit(state.copyWith(
        isSaving: false,
        errorMessage: _messageFor(failure),
      )),
      (homework) async {
        if (!event.publish) {
          emit(state.copyWith(
            isSaving: false,
            successMessage: 'Draft saved.',
            clearError: true,
          ));
          add(ClassWorkRequested(context));
          return;
        }

        final published = await workRepository.publishHomework(
          context: context,
          homework: homework,
        );
        published.fold(
          (failure) => emit(state.copyWith(
            isSaving: false,
            // The draft did save - say so, so the teacher does not retype it.
            errorMessage: 'Saved as a draft, but not published: '
                '${_messageFor(failure)}',
          )),
          (_) => emit(state.copyWith(
            isSaving: false,
            successMessage: 'Assignment published to your class.',
            clearError: true,
          )),
        );
        add(ClassWorkRequested(context));
      },
    );
  }

  Future<void> _onHomeworkPublished(
    ClassHomeworkPublished event,
    Emitter<ClassWorkState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await workRepository.publishHomework(
      context: context,
      homework: event.homework,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: _messageFor(failure),
      )),
      (_) => emit(state.copyWith(
        isSaving: false,
        successMessage: 'Assignment published to your class.',
        clearError: true,
      )),
    );
    add(ClassWorkRequested(context));
  }

  Future<void> _onHomeworkCancelled(
    ClassHomeworkCancelled event,
    Emitter<ClassWorkState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await workRepository.cancelHomework(
      context: context,
      homework: event.homework,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: _messageFor(failure),
      )),
      (_) => emit(state.copyWith(
        isSaving: false,
        successMessage: 'Assignment cancelled.',
        clearError: true,
      )),
    );
    add(ClassWorkRequested(context));
  }

  Future<void> _onBehaviourRecorded(
    ClassBehaviourRecorded event,
    Emitter<ClassWorkState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await workRepository.recordBehaviour(
      context: context,
      record: event.record,
      rosterStudentIds: state.students.map((s) => s.studentId).toList(),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: _messageFor(failure),
      )),
      (_) => emit(state.copyWith(
        isSaving: false,
        successMessage: 'Record saved.',
        clearError: true,
      )),
    );
    add(ClassWorkRequested(context));
  }

  Future<void> _onFollowUpClosed(
    ClassBehaviourFollowUpClosed event,
    Emitter<ClassWorkState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await workRepository.updateBehaviour(
      context: context,
      record: event.record.copyWith(
        followUpClosed: true,
        followUpNote: event.note,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        errorMessage: _messageFor(failure),
      )),
      (_) => emit(state.copyWith(
        isSaving: false,
        successMessage: 'Follow-up closed.',
        clearError: true,
      )),
    );
    add(ClassWorkRequested(context));
  }

  void _onFeedbackCleared(
    ClassWorkFeedbackCleared event,
    Emitter<ClassWorkState> emit,
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
