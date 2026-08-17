import 'package:isar/isar.dart';

import '../../domain/entities/message_models.dart';

part 'pending_message_isar.g.dart';

enum PendingMessageStatus { queued, sending, sent, failed }

/// Offline outbox row for one queued message send.
///
/// [clientMessageId] is what makes retry safe end to end: it is generated
/// once, held here, and passed through to
/// `MessagesRepository.sendMessage(clientMessageId: ...)`, which uses it as
/// the Firestore document id - so a retry after a dropped connection writes
/// to the same document rather than creating a duplicate message. This row
/// itself is deleted once the send is confirmed; a message that stays
/// [PendingMessageStatus.failed] is the only kind of row a restart should
/// find still queued.
@collection
class PendingMessageIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String clientMessageId;

  @Index(composite: [CompositeIndex('createdAt')])
  late String conversationId;

  late String senderId;
  late String senderName;
  String? senderAvatar;
  late String senderSchoolId;
  late String senderEmail;

  /// Roles held by the sender at enqueue time, stored as their enum names
  /// (Isar has no direct `List<UserRole>` support) - reconstructed into a
  /// `UserEntity` for the repository call in [MessageOutboxServiceImpl].
  /// Not itself trusted for authorization; the repository/rules re-derive
  /// permission from the real signed-in session, this is only enough
  /// identity to satisfy `sendMessage`'s `UserEntity sender` parameter.
  List<String> senderRoleNames = const [];

  late String content;

  @enumerated
  late MessageType type;

  String? fileName;
  String? fileSize;

  /// Local filesystem path to the attachment, used for a fresh upload
  /// attempt on retry. Not the same as [mediaUrl], which is only populated
  /// once the file has actually finished uploading to Storage.
  String? localFilePath;
  String? mediaUrl;

  List<String>? pollOptions;
  int? audioDurationMs;
  double? latitude;
  double? longitude;
  String? sharedContactId;
  String? sharedContactRole;
  DateTime? eventStart;
  String? eventLocation;

  String? replyToId;
  String? replyToSender;
  String? replyToContent;

  @enumerated
  @Index()
  late PendingMessageStatus status;

  /// Bumped on every failed attempt; the sync worker backs off based on
  /// this rather than retrying in a tight loop against a still-down
  /// connection.
  int attemptCount = 0;
  DateTime? lastAttemptAt;
  String? lastError;

  @Index()
  late DateTime createdAt;

  PendingMessageIsar();

  /// The optimistic [ChatMessage] shown in the thread while this row is
  /// still queued/sending/failed - see [MessageOutboxService.watchPending].
  ChatMessage toOptimisticMessage() {
    return ChatMessage(
      id: clientMessageId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      timestamp: createdAt,
      type: type,
      isMe: true,
      fileName: fileName,
      fileSize: fileSize,
      mediaUrl: mediaUrl,
      pollOptions: pollOptions,
      audioDuration: audioDurationMs == null
          ? null
          : Duration(milliseconds: audioDurationMs!),
      latitude: latitude,
      longitude: longitude,
      sharedContactId: sharedContactId,
      sharedContactRole: sharedContactRole,
      eventStart: eventStart,
      eventLocation: eventLocation,
      replyToId: replyToId,
      replyToSender: replyToSender,
      replyToContent: replyToContent,
      isSending: status != PendingMessageStatus.failed,
    );
  }
}
