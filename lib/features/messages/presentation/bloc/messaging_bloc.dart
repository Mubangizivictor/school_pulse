import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/policies/messaging_permission_policy.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

/// Owns messaging's mutable state: the live inbox, the signed-in user's
/// currently active role, and the outcome of every gated action (send,
/// start conversation, create group, broadcast, group-info edits).
///
/// [MessagingPermissionPolicy] is evaluated here, in one place, before any
/// of those actions reach [MessagesRepository] - see the messaging module
/// audit for why this used to be scattered inline. It mirrors, but does not
/// replace, the equivalent checks in firestore.rules: this is the UX gate
/// ("don't even attempt it, and explain why"), the rules are the security
/// boundary.
///
/// Registered as a lazySingleton (see injection_container.dart) so it
/// survives navigation between messaging screens - re-dispatching
/// [MessagingStarted] for the same user is a cheap no-op, not a new
/// subscription.
class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagesRepository _repository;
  final AppRoleSessionCubit _roleSession;

  StreamSubscription<List<ChatConversation>>? _conversationsSub;
  StreamSubscription<UserRole?>? _roleSub;
  String? _watchingUserId;

  MessagingBloc({
    required MessagesRepository repository,
    required AppRoleSessionCubit roleSession,
  }) : _repository = repository,
       _roleSession = roleSession,
       super(MessagingState(activeRole: roleSession.state)) {
    on<MessagingStarted>(_onStarted);
    on<_ConversationsUpdated>(_onConversationsUpdated);
    on<_ConversationsErrored>(_onConversationsErrored);
    on<_ActiveRoleChanged>(_onActiveRoleChanged);
    on<DirectConversationRequested>(_onDirectConversationRequested);
    on<ConversationCreateRequested>(_onConversationCreateRequested);
    on<MessageSendRequested>(_onMessageSendRequested);
    on<BroadcastRequested>(_onBroadcastRequested);
    on<GroupInfoUpdateRequested>(_onGroupInfoUpdateRequested);
    on<ConversationReadMarked>(_onConversationReadMarked);
    on<ConversationPinnedSet>(_onConversationPinnedSet);
    on<ConversationMutedSet>(_onConversationMutedSet);
    on<ConversationArchivedSet>(_onConversationArchivedSet);
    on<ConversationLeaveRequested>(_onConversationLeaveRequested);
    on<ConversationRequestAccepted>(_onConversationRequestAccepted);
    on<ConversationMarkedSpam>(_onConversationMarkedSpam);
    on<MessagingSessionCleared>(_onSessionCleared);

    _roleSub = _roleSession.stream.listen(
      (role) => add(_ActiveRoleChanged(role)),
    );
  }

  /// The role to evaluate every permission decision against: the actively
  /// selected one if the session has resolved it, otherwise falling back to
  /// the user's first role so a decision can still be made before the role
  /// session finishes loading (e.g. immediately after sign-in).
  UserRole _effectiveRole(UserEntity user) =>
      state.activeRole ?? _roleSession.state ?? user.roles.first;

  void _onStarted(MessagingStarted event, Emitter<MessagingState> emit) {
    emit(state.copyWith(user: event.user));

    if (_watchingUserId == event.user.id) return;
    _watchingUserId = event.user.id;

    _conversationsSub?.cancel();
    _conversationsSub = _repository
        .watchConversations(event.user.id)
        .listen(
          (conversations) => add(_ConversationsUpdated(conversations)),
          onError: (Object error) => add(_ConversationsErrored(error)),
        );
  }

  void _onSessionCleared(
    MessagingSessionCleared event,
    Emitter<MessagingState> emit,
  ) {
    _conversationsSub?.cancel();
    _conversationsSub = null;
    _watchingUserId = null;
    emit(const MessagingState());
  }

  void _onConversationsUpdated(
    _ConversationsUpdated event,
    Emitter<MessagingState> emit,
  ) {
    emit(
      state.copyWith(
        conversations: event.conversations,
        clearConversationsError: true,
      ),
    );
  }

  void _onConversationsErrored(
    _ConversationsErrored event,
    Emitter<MessagingState> emit,
  ) {
    emit(state.copyWith(conversationsError: event.error));
  }

  void _onActiveRoleChanged(
    _ActiveRoleChanged event,
    Emitter<MessagingState> emit,
  ) {
    emit(state.copyWith(activeRole: event.role));
  }

  ChatConversation? _findConversation(String conversationId) =>
      state.conversations?.where((c) => c.id == conversationId).firstOrNull;

  Future<void> _onDirectConversationRequested(
    DirectConversationRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    final target = UserEntity(
      id: event.contact.id,
      name: event.contact.name,
      email: '',
      schoolId: user.schoolId,
      roles: [_roleFromLabel(event.contact.role)],
    );
    final decision = MessagingPermissionPolicy.canStartConversation(
      actor: user,
      actorRole: _effectiveRole(user),
      target: target,
    );
    if (!decision.isAllowed) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastDecision: decision,
        ),
      );
      return;
    }

    emit(state.copyWith(actionStatus: MessagingActionStatus.submitting));
    try {
      final id = await _repository.startDirectConversation(
        me: user,
        contact: event.contact,
      );
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.success,
          createdConversationId: id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastActionError: e.toString(),
        ),
      );
    }
  }

  /// [MessageContact.role] is a free-text display label from
  /// `school_contacts` (e.g. "Parent", "Bursar"), not a [UserRole] name -
  /// this is a best-effort mapping used only to evaluate the messaging
  /// policy client-side; the authoritative role check happens against the
  /// real user document in firestore.rules.
  UserRole _roleFromLabel(String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized.contains('parent')) return UserRole.parent;
    if (normalized.contains('student')) return UserRole.student;
    for (final role in UserRole.values) {
      if (role.name.toLowerCase() == normalized) return role;
    }
    return UserRole.schoolAdmin;
  }

  Future<void> _onConversationCreateRequested(
    ConversationCreateRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    if (event.type == ChatType.broadcast || event.type == ChatType.channel) {
      final decision = MessagingPermissionPolicy.canSendSchoolWideBroadcast(
        actorRole: _effectiveRole(user),
      );
      if (!decision.isAllowed) {
        emit(
          state.copyWith(
            actionStatus: MessagingActionStatus.failure,
            lastDecision: decision,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(actionStatus: MessagingActionStatus.submitting));
    try {
      final id = await _repository.createConversation(
        me: user,
        type: event.type,
        title: event.title,
        members: event.members,
        description: event.description,
        avatarUrl: event.avatarUrl,
        messagePolicy: event.messagePolicy,
      );
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.success,
          createdConversationId: id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastActionError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMessageSendRequested(
    MessageSendRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    final conversation = _findConversation(event.conversationId);
    if (conversation != null && !conversation.canPost(user.id)) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastDecision: const MessagingDecision.refused(
            MessagingRefusal.groupNotAdmin,
            'Only admins can send messages here.',
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(actionStatus: MessagingActionStatus.submitting));
    try {
      await _repository.sendMessage(
        conversationId: event.conversationId,
        sender: user,
        content: event.content,
        type: event.type,
        fileName: event.fileName,
        fileSize: event.fileSize,
        mediaUrl: event.mediaUrl,
        replyTo: event.replyTo,
        pollOptions: event.pollOptions,
        audioDuration: event.audioDuration,
        latitude: event.latitude,
        longitude: event.longitude,
        sharedContactId: event.sharedContactId,
        sharedContactRole: event.sharedContactRole,
        eventStart: event.eventStart,
        eventLocation: event.eventLocation,
      );
      emit(state.copyWith(actionStatus: MessagingActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastActionError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onBroadcastRequested(
    BroadcastRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    final decision = MessagingPermissionPolicy.canSendSchoolWideBroadcast(
      actorRole: _effectiveRole(user),
    );
    if (!decision.isAllowed) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastDecision: decision,
        ),
      );
      return;
    }

    emit(state.copyWith(actionStatus: MessagingActionStatus.submitting));
    try {
      final id = await _repository.createConversation(
        me: user,
        type: ChatType.broadcast,
        title: event.title,
        members: event.recipients,
        description: event.description,
      );
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.success,
          createdConversationId: id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastActionError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onGroupInfoUpdateRequested(
    GroupInfoUpdateRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    final decision = MessagingPermissionPolicy.canManageGroup(
      actorId: user.id,
      adminIds: event.adminIds,
    );
    if (!decision.isAllowed) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastDecision: decision,
        ),
      );
      return;
    }

    emit(state.copyWith(actionStatus: MessagingActionStatus.submitting));
    try {
      await _repository.updateGroupInfo(
        event.conversationId,
        title: event.title,
        description: event.description,
        avatarUrl: event.avatarUrl,
        messagePolicy: event.messagePolicy,
      );
      emit(state.copyWith(actionStatus: MessagingActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: MessagingActionStatus.failure,
          lastActionError: e.toString(),
        ),
      );
    }
  }

  /// Not permission-gated (a participant may always mark their own inbox
  /// read); fire-and-forget beyond reporting the failure, since the read
  /// receipt is best-effort UX rather than something a screen blocks on.
  Future<void> _onConversationReadMarked(
    ConversationReadMarked event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    try {
      await _repository.markConversationRead(event.conversationId, user.id);
    } catch (e) {
      emit(state.copyWith(lastActionError: e.toString()));
    }
  }

  Future<void> _onConversationPinnedSet(
    ConversationPinnedSet event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    await _repository.setPinned(event.conversationId, user.id, event.value);
  }

  Future<void> _onConversationMutedSet(
    ConversationMutedSet event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    await _repository.setMuted(event.conversationId, user.id, event.value);
  }

  Future<void> _onConversationArchivedSet(
    ConversationArchivedSet event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    await _repository.setArchived(event.conversationId, user.id, event.value);
  }

  Future<void> _onConversationLeaveRequested(
    ConversationLeaveRequested event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    await _repository.leaveConversation(event.conversationId, user.id);
  }

  Future<void> _onConversationRequestAccepted(
    ConversationRequestAccepted event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    await _repository.acceptRequest(event.conversationId, user.id);
  }

  Future<void> _onConversationMarkedSpam(
    ConversationMarkedSpam event,
    Emitter<MessagingState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    await _repository.markSpam(event.conversationId, user.id);
  }

  @override
  Future<void> close() {
    _conversationsSub?.cancel();
    _roleSub?.cancel();
    return super.close();
  }
}
