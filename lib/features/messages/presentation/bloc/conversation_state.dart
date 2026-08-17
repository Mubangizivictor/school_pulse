part of 'conversation_bloc.dart';

enum ConversationSendStatus { idle, sending, failed }

class ConversationState extends Equatable {
  final String? conversationId;
  final ChatConversation? conversation;

  /// Null until the first snapshot arrives; true when the stream produced a
  /// null document (conversation deleted or the user removed from it).
  final bool conversationMissing;

  final List<ChatMessage>? messages;
  final int messageLimit;

  final ConversationSendStatus sendStatus;
  final String? sendError;

  /// Set when a send/edit/etc. was refused by MessagingPermissionPolicy
  /// before reaching the repository, so the screen can show why rather than
  /// a generic failure.
  final MessagingDecision? lastDecision;

  final bool uploading;

  const ConversationState({
    this.conversationId,
    this.conversation,
    this.conversationMissing = false,
    this.messages,
    this.messageLimit = 60,
    this.sendStatus = ConversationSendStatus.idle,
    this.sendError,
    this.lastDecision,
    this.uploading = false,
  });

  ConversationState copyWith({
    String? conversationId,
    ChatConversation? conversation,
    bool clearConversation = false,
    bool? conversationMissing,
    List<ChatMessage>? messages,
    int? messageLimit,
    ConversationSendStatus? sendStatus,
    String? sendError,
    bool clearSendError = false,
    MessagingDecision? lastDecision,
    bool clearLastDecision = false,
    bool? uploading,
  }) {
    return ConversationState(
      conversationId: conversationId ?? this.conversationId,
      conversation: clearConversation
          ? null
          : (conversation ?? this.conversation),
      conversationMissing: conversationMissing ?? this.conversationMissing,
      messages: messages ?? this.messages,
      messageLimit: messageLimit ?? this.messageLimit,
      sendStatus: sendStatus ?? this.sendStatus,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      lastDecision: clearLastDecision
          ? null
          : (lastDecision ?? this.lastDecision),
      uploading: uploading ?? this.uploading,
    );
  }

  @override
  List<Object?> get props => [
    conversationId,
    conversation,
    conversationMissing,
    messages,
    messageLimit,
    sendStatus,
    sendError,
    lastDecision,
    uploading,
  ];
}
