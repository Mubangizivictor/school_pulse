import 'dart:io';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

/// The whole messaging surface: an inbox of conversations, the messages
/// inside one of them, and the school directory used to start new ones.
///
/// Every read is scoped to the signed-in user - either by
/// `participantIds arrayContains uid` (conversations and their messages) or
/// by `schoolId` (the contact directory) - so a user can only ever stream
/// threads they belong to.
abstract class MessagesRepository {
  // --- Inbox -------------------------------------------------------------

  /// Every conversation the user belongs to, newest activity first, including
  /// archived ones (the list screen filters those out; the Archived screen
  /// keeps them).
  Stream<List<ChatConversation>> watchConversations(String userId);

  Stream<ChatConversation?> watchConversation(
    String conversationId,
    String userId,
  );

  /// Opens (or reuses) the 1:1 thread between [me] and [contact] and returns
  /// its id. Reusing is guaranteed by the deterministic document id, so two
  /// people tapping each other at the same time still land in one thread.
  Future<String> startDirectConversation({
    required UserEntity me,
    required MessageContact contact,
  });

  Future<String> createConversation({
    required UserEntity me,
    required ChatType type,
    required String title,
    required List<MessageContact> members,
    String? description,
    String? avatarUrl,
    MessagePolicy messagePolicy = MessagePolicy.everyone,
  });

  Future<void> setPinned(String conversationId, String userId, bool value);
  Future<void> setMuted(String conversationId, String userId, bool value);
  Future<void> setArchived(String conversationId, String userId, bool value);

  /// Moves a chat out of Message Requests and into the inbox.
  Future<void> acceptRequest(String conversationId, String userId);

  /// Files a request under the Spam tab (and out of "You May Know").
  Future<void> markSpam(String conversationId, String userId);

  /// Hides the conversation from this user's inbox. Other participants keep
  /// their copy - only a group admin deleting the group removes it for all.
  Future<void> leaveConversation(String conversationId, String userId);

  Future<void> updateGroupInfo(
    String conversationId, {
    String? title,
    String? description,
    String? avatarUrl,
    MessagePolicy? messagePolicy,
  });

  Future<void> addMembers(String conversationId, List<MessageContact> members);
  Future<void> removeMember(String conversationId, String userId);

  Future<void> archiveAllChats(String userId);
  Future<void> deleteAllChats(String userId);

  /// Files a report for school staff to review. Writes a record rather than
  /// only acknowledging on screen, so "Report" means something.
  Future<void> reportConversation({
    required String conversationId,
    required UserEntity reporter,
    required String reason,
    String? reportedUserId,
  });

  // --- One conversation --------------------------------------------------

  Stream<List<ChatMessage>> watchMessages(
    String conversationId,
    String userId, {
    int limit,
  });

  Future<void> sendMessage({
    required String conversationId,
    required UserEntity sender,
    required String content,
    MessageType type = MessageType.text,
    String? fileName,
    String? fileSize,
    String? mediaUrl,
    ChatMessage? replyTo,
    List<String>? pollOptions,
    Duration? audioDuration,
    double? latitude,
    double? longitude,
    String? sharedContactId,
    String? sharedContactRole,
    DateTime? eventStart,
    String? eventLocation,
  });

  /// Casts (or moves) this user's vote. Passing the option they already
  /// picked withdraws it, the same way tapping a reaction twice clears it.
  Future<void> voteInPoll(
    String conversationId,
    String messageId,
    String userId,
    int optionIndex,
  );

  /// Uploads to `chat_attachments/{schoolId}/{conversationId}/...` and returns
  /// the download URL to hand back to [sendMessage].
  Future<String> uploadAttachment({
    required String schoolId,
    required String conversationId,
    required File file,
    required String fileName,
  });

  /// Zeroes this user's unread counter and stamps `readBy` on anything they
  /// hadn't seen - this is what turns the sender's single tick into a double.
  Future<void> markConversationRead(String conversationId, String userId);

  Future<void> setStarred(
    String conversationId,
    String messageId,
    String userId,
    bool value,
  );
  Future<void> setMessagePinned(
    String conversationId,
    ChatMessage message,
    bool value,
  );
  Future<void> deleteMessage(String conversationId, String messageId);
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String content,
  );

  /// Passing null for [emoji] removes the user's existing reaction.
  Future<void> react(
    String conversationId,
    String messageId,
    String userId,
    String? emoji,
  );

  Future<void> forwardMessage({
    required ChatMessage message,
    required List<String> conversationIds,
    required UserEntity sender,
  });

  /// Attachments in one thread, for the Media / Links / Docs screen.
  Stream<List<ChatMessage>> watchAttachments(
    String conversationId,
    String userId,
  );

  // --- Across conversations ----------------------------------------------

  Stream<List<ChatMessageRef>> watchStarredMessages(String userId);
  Stream<List<ChatMessageRef>> watchPinnedMessages(String userId);

  /// Substring match over the user's recent messages. Firestore has no
  /// full-text index, so this pulls a bounded window and filters client-side.
  Future<List<ChatMessageRef>> searchMessages(String userId, String query);

  // --- Directory ---------------------------------------------------------

  /// Everyone in the school who can be messaged, minus [excludeId] (the
  /// signed-in user). Sourced from `school_contacts`.
  Future<List<MessageContact>> getContacts(
    String schoolId, {
    String? excludeId,
  });

  Future<MessageContact?> getContact(String userId);

  /// The people this user has actually talked to, most recent first - backs
  /// the "Frequently Contacted" sections.
  Future<List<MessageContact>> getRecentContacts(String userId, {int limit});
}
