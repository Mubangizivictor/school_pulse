import 'package:flutter/material.dart';

enum MessageType { text, image, video, file, audio, location, contact, poll, event }

enum ChatType { direct, group, broadcast, channel, event }

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
  final Map<String, int>? pollVotes;

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
  });
}
