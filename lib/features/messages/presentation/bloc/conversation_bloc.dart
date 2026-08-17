import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/policies/messaging_permission_policy.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

/// One conversation's live thread: the conversation document itself, its
/// paginated message window, and every message-level mutation (send, edit,
/// delete, react, star, pin, vote, forward, attachments).
///
/// Factory-scoped (registered with sl.registerFactory, see
/// injection_container.dart) rather than a singleton like [MessagingBloc] -
/// a fresh instance is created per [ChatConversationScreen] and closed when
/// the screen is popped, so subscriptions never outlive the chat the user
/// actually has open. This mirrors the per-entity factory-bloc shape used
/// elsewhere in the app for a single record's screen.
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessagesRepository _repository;

  StreamSubscription<ChatConversation?>? _conversationSub;
  StreamSubscription<List<ChatMessage>>? _messagesSub;
  UserEntity? _user;
  bool _markingRead = false;

  ConversationBloc({required MessagesRepository repository})
    : _repository = repository,
      super(const ConversationState()) {
    on<ConversationOpened>(_onOpened);
    on<_ConversationUpdated>(_onConversationUpdated);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<MoreHistoryRequested>(_onMoreHistoryRequested);
    on<ConversationMessageReadMarked>(_onReadMarked);
    on<ConversationMessageSendRequested>(_onSendRequested);
    on<ConversationMessageEditRequested>(_onEditRequested);
    on<ConversationMessageDeleteRequested>(_onDeleteRequested);
    on<ConversationMessageStarredSet>(_onStarredSet);
    on<ConversationMessagePinnedSet>(_onPinnedSet);
    on<ConversationMessageReacted>(_onReacted);
    on<ConversationPollVoted>(_onPollVoted);
    on<ConversationMessageForwardRequested>(_onForwardRequested);
    on<ConversationAttachmentSendRequested>(_onAttachmentSendRequested);
    on<ConversationMemberRemoved>(_onMemberRemoved);
    on<ConversationMembersAdded>(_onMembersAdded);
    on<ConversationInfoUpdated>(_onInfoUpdated);
    on<ConversationLeft>(_onLeft);
  }

  void _onOpened(ConversationOpened event, Emitter<ConversationState> emit) {
    if (state.conversationId == event.conversationId) return;
    _user = event.user;
    emit(state.copyWith(conversationId: event.conversationId));

    _conversationSub?.cancel();
    _conversationSub = _repository
        .watchConversation(event.conversationId, event.user.id)
        .listen((conversation) => add(_ConversationUpdated(conversation)));

    _resubscribeMessages();
  }

  void _resubscribeMessages() {
    final user = _user;
    final conversationId = state.conversationId;
    if (user == null || conversationId == null) return;
    _messagesSub?.cancel();
    _messagesSub = _repository
        .watchMessages(conversationId, user.id, limit: state.messageLimit)
        .listen((messages) => add(_MessagesUpdated(messages)));
  }

  void _onConversationUpdated(
    _ConversationUpdated event,
    Emitter<ConversationState> emit,
  ) {
    emit(
      state.copyWith(
        conversation: event.conversation,
        clearConversation: event.conversation == null,
        conversationMissing: event.conversation == null,
      ),
    );
    if (event.conversation != null) add(const ConversationMessageReadMarked());
  }

  void _onMessagesUpdated(
    _MessagesUpdated event,
    Emitter<ConversationState> emit,
  ) {
    emit(state.copyWith(messages: event.messages));
  }

  void _onMoreHistoryRequested(
    MoreHistoryRequested event,
    Emitter<ConversationState> emit,
  ) {
    final messages = state.messages;
    // Only widen the window while the current page is actually full - the
    // repository has already returned everything otherwise.
    if (messages == null || messages.length < state.messageLimit) return;
    emit(state.copyWith(messageLimit: state.messageLimit + 60));
    _resubscribeMessages();
  }

  /// Not permission-gated - a participant may always mark their own inbox
  /// read. Guards against re-issuing the write on every stream tick the
  /// same way the screen used to.
  Future<void> _onReadMarked(
    ConversationMessageReadMarked event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    final conversation = state.conversation;
    if (user == null || conversation == null) return;
    if (conversation.unreadCount == 0 || _markingRead) return;
    _markingRead = true;
    try {
      await _repository.markConversationRead(conversation.id, user.id);
    } finally {
      _markingRead = false;
    }
  }

  Future<void> _onSendRequested(
    ConversationMessageSendRequested event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    final conversation = state.conversation;
    if (user == null || conversation == null) return;

    if (!conversation.canPost(user.id)) {
      emit(
        state.copyWith(
          sendStatus: ConversationSendStatus.failed,
          lastDecision: const MessagingDecision.refused(
            MessagingRefusal.groupNotAdmin,
            'Only admins can send messages here.',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sendStatus: ConversationSendStatus.sending,
        clearLastDecision: true,
      ),
    );
    try {
      await _repository.sendMessage(
        conversationId: conversation.id,
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
      emit(
        state.copyWith(
          sendStatus: ConversationSendStatus.idle,
          clearSendError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          sendStatus: ConversationSendStatus.failed,
          sendError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onEditRequested(
    ConversationMessageEditRequested event,
    Emitter<ConversationState> emit,
  ) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    await _repository.editMessage(conversationId, event.messageId, event.content);
  }

  Future<void> _onDeleteRequested(
    ConversationMessageDeleteRequested event,
    Emitter<ConversationState> emit,
  ) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    await _repository.deleteMessage(conversationId, event.messageId);
  }

  Future<void> _onStarredSet(
    ConversationMessageStarredSet event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    final conversationId = state.conversationId;
    if (user == null || conversationId == null) return;
    await _repository.setStarred(
      conversationId,
      event.messageId,
      user.id,
      event.value,
    );
  }

  Future<void> _onPinnedSet(
    ConversationMessagePinnedSet event,
    Emitter<ConversationState> emit,
  ) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    await _repository.setMessagePinned(conversationId, event.message, event.value);
  }

  Future<void> _onReacted(
    ConversationMessageReacted event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    final conversationId = state.conversationId;
    if (user == null || conversationId == null) return;
    await _repository.react(conversationId, event.messageId, user.id, event.emoji);
  }

  Future<void> _onPollVoted(
    ConversationPollVoted event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    final conversationId = state.conversationId;
    if (user == null || conversationId == null) return;
    await _repository.voteInPoll(
      conversationId,
      event.messageId,
      user.id,
      event.optionIndex,
    );
  }

  Future<void> _onForwardRequested(
    ConversationMessageForwardRequested event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    if (user == null) return;
    await _repository.forwardMessage(
      message: event.message,
      conversationIds: event.conversationIds,
      sender: user,
    );
  }

  Future<void> _onAttachmentSendRequested(
    ConversationAttachmentSendRequested event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    final conversation = state.conversation;
    if (user == null || conversation == null) return;

    emit(state.copyWith(uploading: true));
    try {
      final url = await _repository.uploadAttachment(
        schoolId: user.schoolId,
        conversationId: conversation.id,
        file: event.file,
        fileName: event.fileName,
      );
      await _repository.sendMessage(
        conversationId: conversation.id,
        sender: user,
        content: '',
        type: event.type,
        mediaUrl: url,
        fileName: event.fileName,
        fileSize: _readableSize(await event.file.length()),
        audioDuration: event.audioDuration,
      );
      emit(state.copyWith(uploading: false, clearSendError: true));
    } catch (e) {
      emit(
        state.copyWith(
          uploading: false,
          sendStatus: ConversationSendStatus.failed,
          sendError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMemberRemoved(
    ConversationMemberRemoved event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    if (user == null) return;
    final decision = MessagingPermissionPolicy.canManageGroup(
      actorId: user.id,
      adminIds: event.adminIds,
    );
    if (!decision.isAllowed) {
      emit(state.copyWith(lastDecision: decision));
      return;
    }
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    await _repository.removeMember(conversationId, event.memberId);
  }

  Future<void> _onMembersAdded(
    ConversationMembersAdded event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    if (user == null) return;
    final decision = MessagingPermissionPolicy.canManageGroup(
      actorId: user.id,
      adminIds: event.adminIds,
    );
    if (!decision.isAllowed) {
      emit(state.copyWith(lastDecision: decision));
      return;
    }
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    await _repository.addMembers(conversationId, event.members);
  }

  Future<void> _onInfoUpdated(
    ConversationInfoUpdated event,
    Emitter<ConversationState> emit,
  ) async {
    final user = _user;
    if (user == null) return;
    final decision = MessagingPermissionPolicy.canManageGroup(
      actorId: user.id,
      adminIds: event.adminIds,
    );
    if (!decision.isAllowed) {
      emit(state.copyWith(lastDecision: decision));
      return;
    }
    final conversationId = state.conversationId;
    if (conversationId == null) return;
    await _repository.updateGroupInfo(
      conversationId,
      title: event.title,
      description: event.description,
      avatarUrl: event.avatarUrl,
      messagePolicy: event.messagePolicy,
    );
  }

  Future<void> _onLeft(ConversationLeft event, Emitter<ConversationState> emit) async {
    final user = _user;
    final conversationId = state.conversationId;
    if (user == null || conversationId == null) return;
    await _repository.leaveConversation(conversationId, user.id);
  }

  String _readableSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Future<void> close() {
    _conversationSub?.cancel();
    _messagesSub?.cancel();
    return super.close();
  }
}
