import 'dart:io';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/domain/services/message_outbox_service.dart';

MessageOutboxService create({dynamic isar, required MessagesRepository repository}) =>
    const MessageOutboxServiceWeb();

/// No local send queue on web - see MessageOutboxService's doc comment.
/// enqueue calls throw rather than silently pretending to queue, since no
/// caller on web is expected to call this at all (ConversationBloc sends
/// directly there instead).
class MessageOutboxServiceWeb implements MessageOutboxService {
  const MessageOutboxServiceWeb();

  @override
  Future<String> enqueueText({
    required String conversationId,
    required UserEntity sender,
    required String content,
    ChatMessage? replyTo,
  }) => throw UnsupportedError('MessageOutboxService is not available on web.');

  @override
  Future<String> enqueueAttachment({
    required String conversationId,
    required UserEntity sender,
    required MessageType type,
    required File file,
    required String fileName,
    Duration? audioDuration,
  }) => throw UnsupportedError('MessageOutboxService is not available on web.');

  @override
  Stream<List<ChatMessage>> watchPending(String conversationId) => const Stream.empty();

  @override
  Future<void> drain() async {}

  @override
  Future<void> retry(String clientMessageId) async {}

  @override
  Future<void> discard(String clientMessageId) async {}
}
