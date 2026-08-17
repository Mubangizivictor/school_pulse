import 'dart:io';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

/// Offline-first send queue for one message. A message is written here
/// before any network call, shown immediately via [watchPending], and only
/// removed once [MessagesRepository.sendMessage] confirms it landed.
///
/// No-op on web: `isar` is null there (see injection_container.dart's
/// `if (!kIsWeb)` guard, mirrored by every other Isar-backed service in this
/// project), so [MessageOutboxService] on web degrades to "queue nothing,
/// let ConversationBloc send directly and surface a normal failure" rather
/// than silently pretending to queue.
abstract class MessageOutboxService {
  /// Queues a text message for [conversationId] and returns its
  /// [clientMessageId] immediately, before any network attempt.
  Future<String> enqueueText({
    required String conversationId,
    required UserEntity sender,
    required String content,
    ChatMessage? replyTo,
  });

  /// Queues an attachment (image/document/voice note) referenced by
  /// [localFilePath]. The file is uploaded, then the message sent, on the
  /// next successful [drain] pass - not before this call returns.
  Future<String> enqueueAttachment({
    required String conversationId,
    required UserEntity sender,
    required MessageType type,
    required File file,
    required String fileName,
    Duration? audioDuration,
  });

  /// Every still-queued message for [conversationId], oldest first - the
  /// optimistic bubbles a chat screen renders on top of the confirmed
  /// history from Firestore.
  Stream<List<ChatMessage>> watchPending(String conversationId);

  /// Attempts every queued message across all conversations once. Safe to
  /// call repeatedly (from a lifecycle gate, a manual retry tap, or after
  /// [enqueueText]/[enqueueAttachment]) - a message already sent or still
  /// mid-attempt is skipped.
  Future<void> drain();

  /// Re-queues a message stuck in the failed state for another [drain]
  /// attempt - the explicit "Tap to retry" action on a failed bubble.
  Future<void> retry(String clientMessageId);

  /// Discards a queued message without sending it - "cancel" on a bubble
  /// still in flight, or the sender giving up on a failed send.
  Future<void> discard(String clientMessageId);
}
