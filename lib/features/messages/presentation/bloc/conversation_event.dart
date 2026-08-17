part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class ConversationOpened extends ConversationEvent {
  final String conversationId;
  final UserEntity user;

  const ConversationOpened(this.conversationId, this.user);

  @override
  List<Object?> get props => [conversationId, user];
}

class _ConversationUpdated extends ConversationEvent {
  final ChatConversation? conversation;
  const _ConversationUpdated(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

class _MessagesUpdated extends ConversationEvent {
  final List<ChatMessage> messages;
  const _MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Widens the pagination window - the screen calls this when the user
/// scrolls back to the oldest message currently held in memory.
class MoreHistoryRequested extends ConversationEvent {
  const MoreHistoryRequested();
}

class ConversationMessageReadMarked extends ConversationEvent {
  const ConversationMessageReadMarked();
}

/// Permission-gated by the conversation's own MessagePolicy
/// (everyone/adminsOnly), checked against the live conversation snapshot
/// already held in state - see ChatConversation.canPost.
class ConversationMessageSendRequested extends ConversationEvent {
  final String content;
  final MessageType type;
  final String? fileName;
  final String? fileSize;
  final String? mediaUrl;
  final ChatMessage? replyTo;
  final List<String>? pollOptions;
  final Duration? audioDuration;
  final double? latitude;
  final double? longitude;
  final String? sharedContactId;
  final String? sharedContactRole;
  final DateTime? eventStart;
  final String? eventLocation;

  const ConversationMessageSendRequested({
    required this.content,
    this.type = MessageType.text,
    this.fileName,
    this.fileSize,
    this.mediaUrl,
    this.replyTo,
    this.pollOptions,
    this.audioDuration,
    this.latitude,
    this.longitude,
    this.sharedContactId,
    this.sharedContactRole,
    this.eventStart,
    this.eventLocation,
  });

  @override
  List<Object?> get props => [
    content,
    type,
    fileName,
    fileSize,
    mediaUrl,
    replyTo,
    pollOptions,
    audioDuration,
    latitude,
    longitude,
    sharedContactId,
    sharedContactRole,
    eventStart,
    eventLocation,
  ];
}

class ConversationMessageEditRequested extends ConversationEvent {
  final String messageId;
  final String content;
  const ConversationMessageEditRequested(this.messageId, this.content);

  @override
  List<Object?> get props => [messageId, content];
}

class ConversationMessageDeleteRequested extends ConversationEvent {
  final String messageId;
  const ConversationMessageDeleteRequested(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class ConversationMessageStarredSet extends ConversationEvent {
  final String messageId;
  final bool value;
  const ConversationMessageStarredSet(this.messageId, this.value);

  @override
  List<Object?> get props => [messageId, value];
}

class ConversationMessagePinnedSet extends ConversationEvent {
  final ChatMessage message;
  final bool value;
  const ConversationMessagePinnedSet(this.message, this.value);

  @override
  List<Object?> get props => [message, value];
}

class ConversationMessageReacted extends ConversationEvent {
  final String messageId;
  final String? emoji;
  const ConversationMessageReacted(this.messageId, this.emoji);

  @override
  List<Object?> get props => [messageId, emoji];
}

class ConversationPollVoted extends ConversationEvent {
  final String messageId;
  final int optionIndex;
  const ConversationPollVoted(this.messageId, this.optionIndex);

  @override
  List<Object?> get props => [messageId, optionIndex];
}

class ConversationMessageForwardRequested extends ConversationEvent {
  final ChatMessage message;
  final List<String> conversationIds;
  const ConversationMessageForwardRequested(this.message, this.conversationIds);

  @override
  List<Object?> get props => [message, conversationIds];
}

/// Permission-gated: only the conversation's admins may remove a member.
class ConversationMemberRemoved extends ConversationEvent {
  final List<String> adminIds;
  final String memberId;
  const ConversationMemberRemoved(this.adminIds, this.memberId);

  @override
  List<Object?> get props => [adminIds, memberId];
}

/// Permission-gated: only admins may add members to a group/broadcast/
/// channel.
class ConversationMembersAdded extends ConversationEvent {
  final List<String> adminIds;
  final List<MessageContact> members;
  const ConversationMembersAdded(this.adminIds, this.members);

  @override
  List<Object?> get props => [adminIds, members];
}

/// Permission-gated: only admins may edit group name/description/avatar/
/// posting policy.
class ConversationInfoUpdated extends ConversationEvent {
  final List<String> adminIds;
  final String? title;
  final String? description;
  final String? avatarUrl;
  final MessagePolicy? messagePolicy;

  const ConversationInfoUpdated(
    this.adminIds, {
    this.title,
    this.description,
    this.avatarUrl,
    this.messagePolicy,
  });

  @override
  List<Object?> get props => [
    adminIds,
    title,
    description,
    avatarUrl,
    messagePolicy,
  ];
}

class ConversationLeft extends ConversationEvent {
  const ConversationLeft();
}

class ConversationAttachmentSendRequested extends ConversationEvent {
  final File file;
  final String fileName;
  final MessageType type;
  final Duration? audioDuration;

  const ConversationAttachmentSendRequested({
    required this.file,
    required this.fileName,
    required this.type,
    this.audioDuration,
  });

  @override
  List<Object?> get props => [file, fileName, type, audioDuration];
}
