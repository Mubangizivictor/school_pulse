import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_resource.dart';
import '../../../domain/repositories/class_resource_repository.dart';

abstract class ClassResourceEvent extends Equatable {
  const ClassResourceEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the resource list for a folder (null folderId is the root) and the
/// storage usage together - both drive the same screen tree.
class ClassResourcesRequested extends ClassResourceEvent {
  final ActiveResponsibilityContext context;
  final String? folderId;

  const ClassResourcesRequested(this.context, {this.folderId});

  @override
  List<Object?> get props => [context, folderId];
}

class ClassResourceUploaded extends ClassResourceEvent {
  final String fileName;
  final Uint8List bytes;
  final String? folderId;
  final String? description;
  final ClassResourceAudience audience;

  const ClassResourceUploaded({
    required this.fileName,
    required this.bytes,
    this.folderId,
    this.description,
    this.audience = ClassResourceAudience.teacherOnly,
  });

  @override
  List<Object?> get props => [fileName, bytes, folderId, description, audience];
}

class ClassResourceLinkAdded extends ClassResourceEvent {
  final String name;
  final String url;
  final String? folderId;
  final ClassResourceAudience audience;

  const ClassResourceLinkAdded({
    required this.name,
    required this.url,
    this.folderId,
    this.audience = ClassResourceAudience.teacherOnly,
  });

  @override
  List<Object?> get props => [name, url, folderId, audience];
}

class ClassResourceFolderCreated extends ClassResourceEvent {
  final String name;
  final String? parentFolderId;

  const ClassResourceFolderCreated({required this.name, this.parentFolderId});

  @override
  List<Object?> get props => [name, parentFolderId];
}

class ClassResourceShared extends ClassResourceEvent {
  final ClassResource resource;
  final ClassResourceAudience audience;

  const ClassResourceShared(this.resource, this.audience);

  @override
  List<Object?> get props => [resource, audience];
}

class ClassResourceRemoved extends ClassResourceEvent {
  final ClassResource resource;

  const ClassResourceRemoved(this.resource);

  @override
  List<Object?> get props => [resource];
}

class ClassResourceDownloadRequested extends ClassResourceEvent {
  final ClassResource resource;

  const ClassResourceDownloadRequested(this.resource);

  @override
  List<Object?> get props => [resource];
}

class ClassResourceDownloadRemoved extends ClassResourceEvent {
  final ClassResource resource;

  const ClassResourceDownloadRemoved(this.resource);

  @override
  List<Object?> get props => [resource];
}

class ClassResourceFeedbackCleared extends ClassResourceEvent {
  const ClassResourceFeedbackCleared();
}

class ClassResourceState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  final ActiveResponsibilityContext? context;
  final String? folderId;
  final List<ClassResource> resources;
  final StorageUsage storageUsage;

  const ClassResourceState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.folderId,
    this.resources = const [],
    this.storageUsage = const StorageUsage(),
  });

  const ClassResourceState.initial() : this(isLoading: true);

  List<ClassResource> get folders =>
      resources.where((r) => r.isFolder).toList();

  List<ClassResource> get files =>
      resources.where((r) => !r.isFolder).toList();

  List<ClassResource> get recentFirst =>
      [...resources]..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

  ClassResourceState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    String? folderId,
    List<ClassResource>? resources,
    StorageUsage? storageUsage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearFolderId = false,
  }) {
    return ClassResourceState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      resources: resources ?? this.resources,
      storageUsage: storageUsage ?? this.storageUsage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    errorMessage,
    successMessage,
    context,
    folderId,
    resources,
    storageUsage,
  ];
}

class ClassResourceBloc extends Bloc<ClassResourceEvent, ClassResourceState> {
  final ClassResourceRepository repository;

  ClassResourceBloc({required this.repository})
    : super(const ClassResourceState.initial()) {
    on<ClassResourcesRequested>(_onRequested);
    on<ClassResourceUploaded>(_onUploaded);
    on<ClassResourceLinkAdded>(_onLinkAdded);
    on<ClassResourceFolderCreated>(_onFolderCreated);
    on<ClassResourceShared>(_onShared);
    on<ClassResourceRemoved>(_onRemoved);
    on<ClassResourceDownloadRequested>(_onDownloadRequested);
    on<ClassResourceDownloadRemoved>(_onDownloadRemoved);
    on<ClassResourceFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ClassResourcesRequested event,
    Emitter<ClassResourceState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        context: event.context,
        folderId: event.folderId,
        clearFolderId: event.folderId == null,
      ),
    );

    final resources = await repository.getResources(
      context: event.context,
      folderId: event.folderId,
    );
    final usage = await repository.getStorageUsage(context: event.context);

    emit(
      state.copyWith(
        isLoading: false,
        resources: resources.getOrElse(() => const []),
        storageUsage: usage.getOrElse(() => const StorageUsage()),
        errorMessage: resources.fold(_messageFor, (_) => null),
        clearError: resources.isRight(),
      ),
    );
  }

  Future<void> _onUploaded(
    ClassResourceUploaded event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await repository.uploadFile(
      context: context,
      fileName: event.fileName,
      bytes: event.bytes,
      folderId: event.folderId,
      description: event.description,
      audience: event.audience,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Uploaded to your class.',
          clearError: true,
        ),
      ),
    );
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  Future<void> _onLinkAdded(
    ClassResourceLinkAdded event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await repository.addLink(
      context: context,
      name: event.name,
      url: event.url,
      folderId: event.folderId,
      audience: event.audience,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Link added.',
          clearError: true,
        ),
      ),
    );
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  Future<void> _onFolderCreated(
    ClassResourceFolderCreated event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await repository.createFolder(
      context: context,
      name: event.name,
      parentFolderId: event.parentFolderId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Folder created.',
          clearError: true,
        ),
      ),
    );
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  Future<void> _onShared(
    ClassResourceShared event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await repository.share(
      context: context,
      resource: event.resource,
      audience: event.audience,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Sharing updated.',
          clearError: true,
        ),
      ),
    );
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  Future<void> _onRemoved(
    ClassResourceRemoved event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await repository.remove(
      context: context,
      resource: event.resource,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Resource removed.',
          clearError: true,
        ),
      ),
    );
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  Future<void> _onDownloadRequested(
    ClassResourceDownloadRequested event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await repository.downloadForOffline(
      context: context,
      resource: event.resource,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Available offline.',
          clearError: true,
        ),
      ),
    );
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  Future<void> _onDownloadRemoved(
    ClassResourceDownloadRemoved event,
    Emitter<ClassResourceState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    await repository.removeDownload(context: context, resource: event.resource);
    add(ClassResourcesRequested(context, folderId: state.folderId));
  }

  void _onFeedbackCleared(
    ClassResourceFeedbackCleared event,
    Emitter<ClassResourceState> emit,
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
