import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

/// Firestore <-> [ChatMessage] mapping for `conversations/{id}/messages/{id}`.
///
/// Per-viewer fields on the entity (`isMe`, `isRead`, `isStarred`,
/// `myReaction`) are derived at read time from the arrays stored on the
/// document, so the same document renders correctly for every participant.
class ChatMessageModel {
  const ChatMessageModel._();

  static ChatMessage fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    final data = doc.data() ?? const {};
    final senderId = data['senderId'] as String? ?? '';
    final readBy = List<String>.from(data['readBy'] ?? const []);
    final starredBy = List<String>.from(data['starredBy'] ?? const []);
    final rawReactions = Map<String, dynamic>.from(data['reactions'] ?? const {});

    final reactions = <String, int>{};
    String? myReaction;
    for (final entry in rawReactions.entries) {
      final uids = List<String>.from(entry.value ?? const []);
      if (uids.isEmpty) continue;
      reactions[entry.key] = uids.length;
      if (uids.contains(currentUserId)) myReaction = entry.key;
    }

    return ChatMessage(
      id: doc.id,
      senderId: senderId,
      senderName: data['senderName'] as String? ?? '',
      senderAvatar: data['senderAvatar'] as String?,
      content: data['content'] as String? ?? '',
      // A message written with a server timestamp reads back null on the
      // local echo of the write; fall back to now so it sorts last instead
      // of jumping to 1970.
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: _typeFromName(data['type'] as String?),
      isMe: senderId == currentUserId,
      // "Read" for the sender means somebody else has seen it.
      isRead: readBy.any((uid) => uid != senderId),
      isStarred: starredBy.contains(currentUserId),
      isPinned: data['isPinned'] as bool? ?? false,
      fileName: data['fileName'] as String?,
      fileSize: data['fileSize'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      pollOptions: data['pollOptions'] != null ? List<String>.from(data['pollOptions']) : null,
      pollVotes: data['pollVotes'] != null ? Map<String, int>.from(data['pollVotes']) : null,
      isDeleted: data['isDeleted'] as bool? ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      replyToId: data['replyToId'] as String?,
      replyToSender: data['replyToSender'] as String?,
      replyToContent: data['replyToContent'] as String?,
      reactions: reactions,
      myReaction: myReaction,
    );
  }

  /// The payload written when someone posts. `participantIds` is denormalized
  /// onto every message so search, starred and pinned can run as one
  /// collection-group query instead of fanning out per conversation.
  static Map<String, dynamic> toCreateJson({
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
    required List<String> participantIds,
    String? fileName,
    String? fileSize,
    String? mediaUrl,
    String? replyToId,
    String? replyToSender,
    String? replyToContent,
  }) {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.name,
      'participantIds': participantIds,
      'timestamp': FieldValue.serverTimestamp(),
      // The sender has trivially read their own message - this keeps
      // unread math consistent without a second write.
      'readBy': [senderId],
      'starredBy': <String>[],
      'reactions': <String, dynamic>{},
      'isPinned': false,
      'isDeleted': false,
      'fileName': ?fileName,
      'fileSize': ?fileSize,
      'mediaUrl': ?mediaUrl,
      'replyToId': ?replyToId,
      'replyToSender': ?replyToSender,
      'replyToContent': ?replyToContent,
    };
  }

  static MessageType _typeFromName(String? name) {
    return MessageType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => MessageType.text,
    );
  }

  /// One-line preview used for the conversation list and the pinned banner.
  static String preview(MessageType type, String content, String? fileName) {
    switch (type) {
      case MessageType.text:
        return content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎬 Video';
      case MessageType.audio:
        return '🎤 Voice message';
      case MessageType.file:
        return '📄 ${fileName ?? 'Document'}';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.poll:
        return '📊 Poll';
      case MessageType.event:
        return '📅 Event';
    }
  }
}
