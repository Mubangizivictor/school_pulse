import 'dart:async';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/data/models/pending_message_isar.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/domain/services/message_outbox_service.dart';

const _uuid = Uuid();

MessageOutboxService create({required dynamic isar, required MessagesRepository repository}) =>
    MessageOutboxServiceMobile(isar: isar as Isar, repository: repository);

class MessageOutboxServiceMobile implements MessageOutboxService {
  final Isar isar;
  final MessagesRepository repository;

  /// Guards against two overlapping [drain] passes (e.g. a manual retry tap
  /// racing the lifecycle gate's poll) attempting the same row twice.
  bool _draining = false;

  MessageOutboxServiceMobile({required this.isar, required this.repository});

  @override
  Future<String> enqueueText({
    required String conversationId,
    required UserEntity sender,
    required String content,
    ChatMessage? replyTo,
  }) async {
    final row = PendingMessageIsar()
      ..clientMessageId = _uuid.v4()
      ..conversationId = conversationId
      ..senderId = sender.id
      ..senderName = sender.name
      ..senderSchoolId = sender.schoolId
      ..senderEmail = sender.email
      ..senderRoleNames = sender.roles.map((r) => r.name).toList()
      ..content = content
      ..type = MessageType.text
      ..replyToId = replyTo?.id
      ..replyToSender = replyTo?.senderName
      ..replyToContent = replyTo?.content
      ..status = PendingMessageStatus.queued
      ..createdAt = DateTime.now();

    await isar.writeTxn(() => isar.pendingMessageIsars.put(row));
    unawaited(drain());
    return row.clientMessageId;
  }

  @override
  Future<String> enqueueAttachment({
    required String conversationId,
    required UserEntity sender,
    required MessageType type,
    required File file,
    required String fileName,
    Duration? audioDuration,
  }) async {
    final row = PendingMessageIsar()
      ..clientMessageId = _uuid.v4()
      ..conversationId = conversationId
      ..senderId = sender.id
      ..senderName = sender.name
      ..senderSchoolId = sender.schoolId
      ..senderEmail = sender.email
      ..senderRoleNames = sender.roles.map((r) => r.name).toList()
      ..content = ''
      ..type = type
      ..fileName = fileName
      ..localFilePath = file.path
      ..audioDurationMs = audioDuration?.inMilliseconds
      ..status = PendingMessageStatus.queued
      ..createdAt = DateTime.now();

    await isar.writeTxn(() => isar.pendingMessageIsars.put(row));
    unawaited(drain());
    return row.clientMessageId;
  }

  @override
  Stream<List<ChatMessage>> watchPending(String conversationId) {
    final query = isar.pendingMessageIsars
        .filter()
        .conversationIdEqualTo(conversationId)
        .sortByCreatedAt()
        .build();
    return query
        .watch(fireImmediately: true)
        .map((rows) => rows.map((r) => r.toOptimisticMessage()).toList());
  }

  @override
  Future<void> drain() async {
    if (_draining) return;
    _draining = true;
    try {
      // Oldest first, so a burst of queued messages lands in the order the
      // sender wrote them rather than racing.
      final pending = await isar.pendingMessageIsars
          .filter()
          .statusEqualTo(PendingMessageStatus.queued)
          .or()
          .statusEqualTo(PendingMessageStatus.failed)
          .sortByCreatedAt()
          .findAll();

      for (final row in pending) {
        await _attempt(row);
      }
    } finally {
      _draining = false;
    }
  }

  @override
  Future<void> retry(String clientMessageId) async {
    final row = await isar.pendingMessageIsars
        .filter()
        .clientMessageIdEqualTo(clientMessageId)
        .findFirst();
    if (row == null) return;
    await _attempt(row);
  }

  @override
  Future<void> discard(String clientMessageId) async {
    await isar.writeTxn(() async {
      final row = await isar.pendingMessageIsars
          .filter()
          .clientMessageIdEqualTo(clientMessageId)
          .findFirst();
      if (row == null) return;
      await isar.pendingMessageIsars.delete(row.id);
    });
  }

  Future<void> _attempt(PendingMessageIsar row) async {
    await isar.writeTxn(() async {
      row.status = PendingMessageStatus.sending;
      row.attemptCount += 1;
      row.lastAttemptAt = DateTime.now();
      await isar.pendingMessageIsars.put(row);
    });

    final sender = UserEntity(
      id: row.senderId,
      name: row.senderName,
      email: row.senderEmail,
      schoolId: row.senderSchoolId,
      roles: row.senderRoleNames
          .map(
            (name) => UserRole.values.firstWhere(
              (r) => r.name == name,
              orElse: () => UserRole.parent,
            ),
          )
          .toList(),
    );

    try {
      var mediaUrl = row.mediaUrl;
      if (row.localFilePath != null && mediaUrl == null) {
        // Storage upload has no idempotency key of its own, but re-running
        // it on a retry is harmless (it just overwrites the same
        // timestamped path) and cheaper to reason about than trying to
        // resume a partial upload.
        mediaUrl = await repository.uploadAttachment(
          schoolId: row.senderSchoolId,
          conversationId: row.conversationId,
          file: File(row.localFilePath!),
          fileName: row.fileName ?? 'attachment',
        );
        await isar.writeTxn(() async {
          row.mediaUrl = mediaUrl;
          await isar.pendingMessageIsars.put(row);
        });
      }

      await repository.sendMessage(
        conversationId: row.conversationId,
        sender: sender,
        content: row.content,
        type: row.type,
        fileName: row.fileName,
        fileSize: null,
        mediaUrl: mediaUrl,
        pollOptions: row.pollOptions,
        audioDuration: row.audioDurationMs == null
            ? null
            : Duration(milliseconds: row.audioDurationMs!),
        latitude: row.latitude,
        longitude: row.longitude,
        sharedContactId: row.sharedContactId,
        sharedContactRole: row.sharedContactRole,
        eventStart: row.eventStart,
        eventLocation: row.eventLocation,
        clientMessageId: row.clientMessageId,
      );

      await isar.writeTxn(() => isar.pendingMessageIsars.delete(row.id));
    } catch (e) {
      await isar.writeTxn(() async {
        row.status = PendingMessageStatus.failed;
        row.lastError = e.toString();
        await isar.pendingMessageIsars.put(row);
      });
    }
  }
}
