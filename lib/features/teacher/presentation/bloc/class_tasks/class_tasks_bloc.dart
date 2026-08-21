import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_task.dart';
import '../../../domain/repositories/class_task_repository.dart';

abstract class ClassTasksEvent extends Equatable {
  const ClassTasksEvent();

  @override
  List<Object?> get props => [];
}

class ClassTasksRequested extends ClassTasksEvent {
  final ActiveResponsibilityContext context;

  const ClassTasksRequested(this.context);

  @override
  List<Object?> get props => [context];
}

class ClassTaskSaved extends ClassTasksEvent {
  final ClassTask task;

  const ClassTaskSaved(this.task);

  @override
  List<Object?> get props => [task];
}

class ClassTaskCompleted extends ClassTasksEvent {
  final ClassTask task;

  const ClassTaskCompleted(this.task);

  @override
  List<Object?> get props => [task];
}

class ClassTaskDeleted extends ClassTasksEvent {
  final ClassTask task;

  const ClassTaskDeleted(this.task);

  @override
  List<Object?> get props => [task];
}

class ClassTasksFeedbackCleared extends ClassTasksEvent {
  const ClassTasksFeedbackCleared();
}

class ClassTasksState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final ActiveResponsibilityContext? context;
  final List<ClassTask> tasks;

  const ClassTasksState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.tasks = const [],
  });

  const ClassTasksState.initial() : this(isLoading: true);

  List<ClassTask> get open =>
      tasks.where((t) => t.status.isOpen).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  List<ClassTask> get highPriority =>
      open.where((t) => t.priority == ClassTaskPriority.high).toList();

  List<ClassTask> get overdue => tasks.where((t) => t.isOverdue()).toList();

  List<ClassTask> get completed => tasks.where((t) => t.isComplete).toList();

  List<ClassTask> get dueToday {
    final now = DateTime.now();
    return open
        .where(
          (t) =>
              t.dueAt.year == now.year &&
              t.dueAt.month == now.month &&
              t.dueAt.day == now.day,
        )
        .toList();
  }

  ClassTasksState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    List<ClassTask>? tasks,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClassTasksState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    errorMessage,
    successMessage,
    context,
    tasks,
  ];
}

class ClassTasksBloc extends Bloc<ClassTasksEvent, ClassTasksState> {
  final ClassTaskRepository taskRepository;

  ClassTasksBloc({required this.taskRepository})
    : super(const ClassTasksState.initial()) {
    on<ClassTasksRequested>(_onRequested);
    on<ClassTaskSaved>(_onSaved);
    on<ClassTaskCompleted>(_onCompleted);
    on<ClassTaskDeleted>(_onDeleted);
    on<ClassTasksFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ClassTasksRequested event,
    Emitter<ClassTasksState> emit,
  ) async {
    emit(ClassTasksState(isLoading: true, context: event.context));

    final result = await taskRepository.getTasks(context: event.context);

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: _messageFor(failure)),
      ),
      (tasks) => emit(
        state.copyWith(isLoading: false, tasks: tasks, clearError: true),
      ),
    );
  }

  Future<void> _onSaved(
    ClassTaskSaved event,
    Emitter<ClassTasksState> emit,
  ) async {
    await _mutate(
      emit,
      (context) => taskRepository.saveTask(context: context, task: event.task),
      success: 'Task saved.',
    );
  }

  Future<void> _onCompleted(
    ClassTaskCompleted event,
    Emitter<ClassTasksState> emit,
  ) async {
    await _mutate(
      emit,
      (context) =>
          taskRepository.completeTask(context: context, task: event.task),
      success: 'Task completed.',
    );
  }

  Future<void> _onDeleted(
    ClassTaskDeleted event,
    Emitter<ClassTasksState> emit,
  ) async {
    await _mutate(
      emit,
      (context) =>
          taskRepository.deleteTask(context: context, task: event.task),
      success: 'Task deleted.',
    );
  }

  /// The shared shape of every write: save, report, reload. Reloading rather
  /// than patching the list in place keeps the derived counts honest.
  Future<void> _mutate(
    Emitter<ClassTasksState> emit,
    Future<Either<Failure, Object?>> Function(ActiveResponsibilityContext)
    action, {
    required String success,
  }) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await action(context);

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: success,
          clearError: true,
        ),
      ),
    );
    add(ClassTasksRequested(context));
  }

  void _onFeedbackCleared(
    ClassTasksFeedbackCleared event,
    Emitter<ClassTasksState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  static String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    ValidationFailure() => failure.message,
    OfflineNotAllowedFailure() => failure.message,
    NetworkFailure() => failure.message,
    ServerFailure() => failure.message,
    _ => 'Something went wrong. Try again.',
  };
}
