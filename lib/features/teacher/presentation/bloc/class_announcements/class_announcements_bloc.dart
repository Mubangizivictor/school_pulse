import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_announcement.dart';
import '../../../domain/repositories/class_communication_repository.dart';

abstract class ClassAnnouncementsEvent extends Equatable {
  const ClassAnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

class ClassAnnouncementsRequested extends ClassAnnouncementsEvent {
  final ActiveResponsibilityContext context;

  const ClassAnnouncementsRequested(this.context);

  @override
  List<Object?> get props => [context];
}

class ClassAnnouncementSaved extends ClassAnnouncementsEvent {
  final ClassAnnouncement announcement;
  final bool publish;

  const ClassAnnouncementSaved(this.announcement, {this.publish = false});

  @override
  List<Object?> get props => [announcement, publish];
}

class ClassAnnouncementPublished extends ClassAnnouncementsEvent {
  final ClassAnnouncement announcement;

  const ClassAnnouncementPublished(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class ClassAnnouncementArchived extends ClassAnnouncementsEvent {
  final ClassAnnouncement announcement;

  const ClassAnnouncementArchived(this.announcement);

  @override
  List<Object?> get props => [announcement];
}

class ClassAnnouncementsFeedbackCleared extends ClassAnnouncementsEvent {
  const ClassAnnouncementsFeedbackCleared();
}

class ClassAnnouncementsState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final ActiveResponsibilityContext? context;
  final List<ClassAnnouncement> announcements;

  const ClassAnnouncementsState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.context,
    this.announcements = const [],
  });

  const ClassAnnouncementsState.initial() : this(isLoading: true);

  bool get canPublish =>
      context?.can(Permission.classAnnouncementPublish) ?? false;

  List<ClassAnnouncement> get live => announcements
      .where(
        (a) =>
            a.effectiveStatus() == ClassAnnouncementStatus.published ||
            a.effectiveStatus() == ClassAnnouncementStatus.scheduled,
      )
      .toList();

  List<ClassAnnouncement> get drafts =>
      announcements.where((a) => a.isDraft).toList();

  ClassAnnouncementsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    ActiveResponsibilityContext? context,
    List<ClassAnnouncement>? announcements,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClassAnnouncementsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      context: context ?? this.context,
      announcements: announcements ?? this.announcements,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    errorMessage,
    successMessage,
    context,
    announcements,
  ];
}

class ClassAnnouncementsBloc
    extends Bloc<ClassAnnouncementsEvent, ClassAnnouncementsState> {
  final ClassCommunicationRepository communicationRepository;

  ClassAnnouncementsBloc({required this.communicationRepository})
    : super(const ClassAnnouncementsState.initial()) {
    on<ClassAnnouncementsRequested>(_onRequested);
    on<ClassAnnouncementSaved>(_onSaved);
    on<ClassAnnouncementPublished>(_onPublished);
    on<ClassAnnouncementArchived>(_onArchived);
    on<ClassAnnouncementsFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ClassAnnouncementsRequested event,
    Emitter<ClassAnnouncementsState> emit,
  ) async {
    emit(ClassAnnouncementsState(isLoading: true, context: event.context));

    final result = await communicationRepository.getAnnouncements(
      context: event.context,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: _messageFor(failure)),
      ),
      (announcements) => emit(
        state.copyWith(
          isLoading: false,
          announcements: announcements,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onSaved(
    ClassAnnouncementSaved event,
    Emitter<ClassAnnouncementsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final saved = await communicationRepository.saveAnnouncement(
      context: context,
      announcement: event.announcement,
    );

    await saved.fold(
      (failure) async => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (announcement) async {
        if (!event.publish) {
          emit(
            state.copyWith(
              isSaving: false,
              successMessage: 'Draft saved.',
              clearError: true,
            ),
          );
          add(ClassAnnouncementsRequested(context));
          return;
        }

        final published = await communicationRepository.publishAnnouncement(
          context: context,
          announcement: announcement,
        );
        published.fold(
          (failure) => emit(
            state.copyWith(
              isSaving: false,
              // The draft did save - saying so stops the teacher retyping it.
              errorMessage:
                  'Saved as a draft, but not sent: ${_messageFor(failure)}',
            ),
          ),
          (sent) => emit(
            state.copyWith(
              isSaving: false,
              successMessage: 'Sent to ${sent.recipientCount} recipients.',
              clearError: true,
            ),
          ),
        );
        add(ClassAnnouncementsRequested(context));
      },
    );
  }

  Future<void> _onPublished(
    ClassAnnouncementPublished event,
    Emitter<ClassAnnouncementsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await communicationRepository.publishAnnouncement(
      context: context,
      announcement: event.announcement,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (sent) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Sent to ${sent.recipientCount} recipients.',
          clearError: true,
        ),
      ),
    );
    add(ClassAnnouncementsRequested(context));
  }

  Future<void> _onArchived(
    ClassAnnouncementArchived event,
    Emitter<ClassAnnouncementsState> emit,
  ) async {
    final context = state.context;
    if (context == null) return;

    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await communicationRepository.archiveAnnouncement(
      context: context,
      announcement: event.announcement,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: _messageFor(failure)),
      ),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Announcement archived.',
          clearError: true,
        ),
      ),
    );
    add(ClassAnnouncementsRequested(context));
  }

  void _onFeedbackCleared(
    ClassAnnouncementsFeedbackCleared event,
    Emitter<ClassAnnouncementsState> emit,
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
