part of 'messaging_bloc.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object?> get props => [];
}

/// Starts watching the inbox for [user] and the active role changes that
/// re-evaluate permission decisions. Call once when the messaging feature is
/// entered; the bloc stays alive for the session (registered as a
/// lazySingleton) so re-dispatching just re-subscribes idempotently.
class MessagingStarted extends MessagingEvent {
  final UserEntity user;
  const MessagingStarted(this.user);

  @override
  List<Object?> get props => [user];
}

/// Internal: the conversations stream produced a new snapshot.
class _ConversationsUpdated extends MessagingEvent {
  final List<ChatConversation> conversations;
  const _ConversationsUpdated(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class _ConversationsErrored extends MessagingEvent {
  final Object error;
  const _ConversationsErrored(this.error);

  @override
  List<Object?> get props => [error];
}

/// Internal: the active role session changed (multi-role staff switching
/// context, or resolved for the first time after sign-in).
class _ActiveRoleChanged extends MessagingEvent {
  final UserRole? role;
  const _ActiveRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

/// Permission-gated: opens (or reuses) a 1:1 thread with [contact].
class DirectConversationRequested extends MessagingEvent {
  final MessageContact contact;
  const DirectConversationRequested(this.contact);

  @override
  List<Object?> get props => [contact];
}

/// Permission-gated: creates a group/broadcast/channel conversation.
class ConversationCreateRequested extends MessagingEvent {
  final ChatType type;
  final String title;
  final List<MessageContact> members;
  final String? description;
  final String? avatarUrl;
  final MessagePolicy messagePolicy;

  const ConversationCreateRequested({
    required this.type,
    required this.title,
    required this.members,
    this.description,
    this.avatarUrl,
    this.messagePolicy = MessagePolicy.everyone,
  });

  @override
  List<Object?> get props => [
    type,
    title,
    members,
    description,
    avatarUrl,
    messagePolicy,
  ];
}

/// Permission-gated: sends a message into an existing conversation. The
/// conversation's own MessagePolicy (everyone/adminsOnly) is checked against
/// the conversation snapshot already held in state.
class MessageSendRequested extends MessagingEvent {
  final String conversationId;
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

  const MessageSendRequested({
    required this.conversationId,
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
    conversationId,
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

/// Permission-gated (school-wide broadcast requires an authorized role).
class BroadcastRequested extends MessagingEvent {
  final String title;
  final List<MessageContact> recipients;
  final String? description;

  const BroadcastRequested({
    required this.title,
    required this.recipients,
    this.description,
  });

  @override
  List<Object?> get props => [title, recipients, description];
}

/// Permission-gated: group-info mutation (rename, member add/remove, policy
/// change), only admins may perform it.
class GroupInfoUpdateRequested extends MessagingEvent {
  final String conversationId;
  final List<String> adminIds;
  final String? title;
  final String? description;
  final String? avatarUrl;
  final MessagePolicy? messagePolicy;

  const GroupInfoUpdateRequested({
    required this.conversationId,
    required this.adminIds,
    this.title,
    this.description,
    this.avatarUrl,
    this.messagePolicy,
  });

  @override
  List<Object?> get props => [
    conversationId,
    adminIds,
    title,
    description,
    avatarUrl,
    messagePolicy,
  ];
}

class ConversationReadMarked extends MessagingEvent {
  final String conversationId;
  const ConversationReadMarked(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ConversationPinnedSet extends MessagingEvent {
  final String conversationId;
  final bool value;
  const ConversationPinnedSet(this.conversationId, this.value);

  @override
  List<Object?> get props => [conversationId, value];
}

class ConversationMutedSet extends MessagingEvent {
  final String conversationId;
  final bool value;
  const ConversationMutedSet(this.conversationId, this.value);

  @override
  List<Object?> get props => [conversationId, value];
}

class ConversationArchivedSet extends MessagingEvent {
  final String conversationId;
  final bool value;
  const ConversationArchivedSet(this.conversationId, this.value);

  @override
  List<Object?> get props => [conversationId, value];
}

class ConversationLeaveRequested extends MessagingEvent {
  final String conversationId;
  const ConversationLeaveRequested(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Moves a Message Request out of "You May Know" and into the inbox.
class ConversationRequestAccepted extends MessagingEvent {
  final String conversationId;
  const ConversationRequestAccepted(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Cancels the inbox subscription and wipes bloc state so a shared device
/// signing out doesn't leave the previous user's conversation list, unread
/// counts, or last action result readable by the next person who signs in.
class MessagingSessionCleared extends MessagingEvent {
  const MessagingSessionCleared();
}

class ConversationMarkedSpam extends MessagingEvent {
  final String conversationId;
  const ConversationMarkedSpam(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
