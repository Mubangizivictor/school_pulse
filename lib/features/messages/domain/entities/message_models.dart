import 'package:flutter/material.dart';

enum MessageType {
  text,
  image,
  video,
  file,
  audio,
  location,
  contact,
  poll,
  event,
}

enum ChatType { direct, group, broadcast, channel, event }

/// Who is allowed to post in a group/channel.
enum MessagePolicy { everyone, adminsOnly }

class MessageParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role;
  final Color? roleColor;

  const MessageParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.roleColor,
  });
}

/// A person in the school directory who can be messaged. Sourced from
/// `school_contacts` (the sanitized mirror of `users`), so it deliberately
/// carries no email/phone/token fields.
class MessageContact {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;

  const MessageContact({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  /// "Mr. Kofi Mensah" -> "KM", "Finance Office" -> "FO"
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final single = parts.first;
      return (single.length >= 2 ? single.substring(0, 2) : single)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isMe;
  final bool isRead;
  final bool isStarred;
  final bool isPinned;
  final String? fileName;
  final String? fileSize;
  final String? mediaUrl;
  final List<String>? pollOptions;

  /// Option index (as a string, because Firestore map keys are strings) ->
  /// number of votes.
  final Map<String, int>? pollVotes;

  /// The option the signed-in user voted for, if any.
  final int? myPollVote;

  /// Length of a voice note. Shown on the bubble before it is played.
  final Duration? audioDuration;

  /// Shared location.
  final double? latitude;
  final double? longitude;

  /// A school directory entry shared into the chat, so the recipient can
  /// open a conversation with them in one tap.
  final String? sharedContactId;
  final String? sharedContactRole;

  /// Event card. [content] carries the title.
  final DateTime? eventStart;
  final String? eventLocation;

  /// Set once the sender tombstones the message - the bubble still renders,
  /// but with "This message was deleted" instead of the original body.
  final bool isDeleted;
  final DateTime? editedAt;

  /// Quoted message, denormalized so the bubble never needs a second read.
  final String? replyToId;
  final String? replyToSender;
  final String? replyToContent;

  /// emoji -> number of people who reacted with it.
  final Map<String, int> reactions;

  /// The emoji the signed-in user reacted with, if any.
  final String? myReaction;

  /// True while the write is still in flight (optimistic bubble).
  final bool isSending;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isMe = false,
    this.isRead = false,
    this.isStarred = false,
    this.isPinned = false,
    this.fileName,
    this.fileSize,
    this.mediaUrl,
    this.pollOptions,
    this.pollVotes,
    this.myPollVote,
    this.audioDuration,
    this.latitude,
    this.longitude,
    this.sharedContactId,
    this.sharedContactRole,
    this.eventStart,
    this.eventLocation,
    this.isDeleted = false,
    this.editedAt,
    this.replyToId,
    this.replyToSender,
    this.replyToContent,
    this.reactions = const {},
    this.myReaction,
    this.isSending = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isStarred,
    bool? isPinned,
    bool? isDeleted,
    bool? isSending,
    DateTime? editedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content ?? this.content,
      timestamp: timestamp,
      type: type,
      isMe: isMe,
      isRead: isRead,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      fileName: fileName,
      fileSize: fileSize,
      mediaUrl: mediaUrl,
      pollOptions: pollOptions,
      pollVotes: pollVotes,
      myPollVote: myPollVote,
      audioDuration: audioDuration,
      latitude: latitude,
      longitude: longitude,
      sharedContactId: sharedContactId,
      sharedContactRole: sharedContactRole,
      eventStart: eventStart,
      eventLocation: eventLocation,
      isDeleted: isDeleted ?? this.isDeleted,
      editedAt: editedAt ?? this.editedAt,
      replyToId: replyToId,
      replyToSender: replyToSender,
      replyToContent: replyToContent,
      reactions: reactions,
      myReaction: myReaction,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// A starred or pinned message together with the chat it lives in - the
/// standalone Starred/Pinned screens need that context, the in-chat bubble
/// does not.
class ChatMessageRef {
  final ChatMessage message;
  final String conversationId;
  final String conversationTitle;

  const ChatMessageRef({
    required this.message,
    required this.conversationId,
    required this.conversationTitle,
  });
}

class ChatConversation {
  final String id;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final ChatType type;
  final ChatMessage lastMessage;
  final int unreadCount;
  final List<MessageParticipant> participants;
  final bool isPinned;
  final bool isMuted;

  final String schoolId;
  final String? description;
  final List<String> adminIds;
  final String createdBy;
  final DateTime? createdAt;
  final bool isArchived;
  final MessagePolicy messagePolicy;

  /// Pinned-banner payload, denormalized onto the conversation so the chat
  /// header can render it without a second query.
  final String? pinnedMessageId;
  final String? pinnedMessageContent;
  final String? pinnedMessageSender;

  /// False while a 1:1 chat is still sitting in the recipient's Message
  /// Requests inbox. Always true for chats the signed-in user started, for
  /// groups, and for anything a staff member opened.
  final bool isAccepted;

  /// Filed under the Spam tab of Message Requests by this user.
  final bool isSpam;

  const ChatConversation({
    required this.id,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    required this.type,
    required this.lastMessage,
    this.unreadCount = 0,
    required this.participants,
    this.isPinned = false,
    this.isMuted = false,
    this.schoolId = '',
    this.description,
    this.adminIds = const [],
    this.createdBy = '',
    this.createdAt,
    this.isArchived = false,
    this.messagePolicy = MessagePolicy.everyone,
    this.pinnedMessageId,
    this.pinnedMessageContent,
    this.pinnedMessageSender,
    this.isAccepted = true,
    this.isSpam = false,
  });

  bool get hasMessages => lastMessage.id.isNotEmpty;

  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Whether [userId] may post here. Direct chats are always open; groups and
  /// channels honour [messagePolicy].
  bool canPost(String userId) {
    if (type == ChatType.direct) return true;
    if (messagePolicy == MessagePolicy.everyone) return true;
    return adminIds.contains(userId);
  }
}
