import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

/// Firestore <-> [ChatConversation] mapping for `conversations/{id}`.
///
/// Everything the list needs is denormalized onto the parent document
/// (`lastMessage`, `unreadCounts`, `pinnedMessage`), so rendering the inbox
/// costs exactly one query and never touches the messages subcollection.
class ConversationModel {
  const ConversationModel._();

  /// Deterministic id for a 1:1 chat, so opening the same person twice always
  /// lands in the same thread no matter who taps first.
  static String directId(String a, String b) {
    final ids = [a, b]..sort();
    return 'dm_${ids[0]}_${ids[1]}';
  }

  static ChatConversation fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String currentUserId,
  ) {
    final data = doc.data() ?? const {};

    final participants = (data['participants'] as List? ?? const [])
        .map((p) => MessageParticipant(
              id: p['id'] as String? ?? '',
              name: p['name'] as String? ?? '',
              role: p['role'] as String? ?? '',
              avatarUrl: p['avatarUrl'] as String?,
            ))
        .toList();

    final type = ChatType.values.firstWhere(
      (t) => t.name == data['type'],
      orElse: () => ChatType.direct,
    );

    // A 1:1 thread has no stored title - it is whoever the viewer is not.
    String title = data['title'] as String? ?? '';
    String? subtitle = data['description'] as String?;
    if (type == ChatType.direct) {
      final other = participants.where((p) => p.id != currentUserId).toList();
      if (other.isNotEmpty) {
        title = other.first.name;
        subtitle = other.first.role;
      }
    } else {
      subtitle = '${participants.length} members';
    }

    final unreadCounts = Map<String, dynamic>.from(data['unreadCounts'] ?? const {});
    final pinnedMessage = data['pinnedMessage'] as Map<String, dynamic>?;

    return ChatConversation(
      id: doc.id,
      title: title.isEmpty ? 'Conversation' : title,
      subtitle: subtitle,
      avatarUrl: data['avatarUrl'] as String?,
      type: type,
      lastMessage: _lastMessage(data['lastMessage'] as Map<String, dynamic>?, currentUserId),
      unreadCount: (unreadCounts[currentUserId] as num?)?.toInt() ?? 0,
      participants: participants,
      isPinned: List<String>.from(data['pinnedBy'] ?? const []).contains(currentUserId),
      isMuted: List<String>.from(data['mutedBy'] ?? const []).contains(currentUserId),
      isArchived: List<String>.from(data['archivedBy'] ?? const []).contains(currentUserId),
      isAccepted: List<String>.from(data['acceptedBy'] ?? const []).contains(currentUserId),
      isSpam: List<String>.from(data['spamBy'] ?? const []).contains(currentUserId),
      schoolId: data['schoolId'] as String? ?? '',
      description: data['description'] as String?,
      adminIds: List<String>.from(data['adminIds'] ?? const []),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      messagePolicy: data['messagePolicy'] == MessagePolicy.adminsOnly.name
          ? MessagePolicy.adminsOnly
          : MessagePolicy.everyone,
      pinnedMessageId: pinnedMessage?['id'] as String?,
      pinnedMessageContent: pinnedMessage?['content'] as String?,
      pinnedMessageSender: pinnedMessage?['senderName'] as String?,
    );
  }

  /// An empty placeholder (id == '') means "no messages yet" - see
  /// [ChatConversation.hasMessages].
  static ChatMessage _lastMessage(Map<String, dynamic>? data, String currentUserId) {
    if (data == null) {
      return ChatMessage(
        id: '',
        senderId: '',
        senderName: '',
        content: '',
        timestamp: DateTime.now(),
      );
    }
    final senderId = data['senderId'] as String? ?? '';
    return ChatMessage(
      id: data['id'] as String? ?? '',
      senderId: senderId,
      senderName: data['senderName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MessageType.text,
      ),
      isMe: senderId == currentUserId,
    );
  }

  static Map<String, dynamic> toCreateJson({
    required String schoolId,
    required ChatType type,
    required String title,
    String? description,
    String? avatarUrl,
    required List<MessageContact> participants,
    required String createdBy,
    required List<String> adminIds,
    required List<String> acceptedBy,
    MessagePolicy messagePolicy = MessagePolicy.everyone,
  }) {
    return {
      'schoolId': schoolId,
      'type': type.name,
      'title': type == ChatType.direct ? '' : title,
      'description': description,
      'avatarUrl': avatarUrl,
      'participantIds': participants.map((p) => p.id).toList(),
      'participants': participants
          .map((p) => {'id': p.id, 'name': p.name, 'role': p.role, 'avatarUrl': p.avatarUrl})
          .toList(),
      'adminIds': adminIds,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'messagePolicy': messagePolicy.name,
      'unreadCounts': {for (final p in participants) p.id: 0},
      'pinnedBy': <String>[],
      'mutedBy': <String>[],
      'archivedBy': <String>[],
      'spamBy': <String>[],
      'acceptedBy': acceptedBy,
    };
  }
}
