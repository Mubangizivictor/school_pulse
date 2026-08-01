import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/data/models/chat_message_model.dart';
import 'package:school_pulse/features/messages/data/models/conversation_model.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';

/// How many conversations / messages a single stream will hold in memory.
/// Chats in a school app are long-lived but low-volume; these ceilings keep
/// the inbox and a chat scrollback bounded without paging.
const int _kConversationLimit = 200;
const int _kMessageLimit = 200;
const int _kSearchWindow = 300;

class MessagesRepositoryImpl implements MessagesRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  MessagesRepositoryImpl({required this.firestore, required this.storage});

  CollectionReference<Map<String, dynamic>> get _conversations =>
      firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messagesOf(String conversationId) =>
      _conversations.doc(conversationId).collection('messages');

  // --- Inbox -------------------------------------------------------------

  @override
  Stream<List<ChatConversation>> watchConversations(String userId) {
    return _conversations
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(_kConversationLimit)
        .snapshots()
        .map((snapshot) {
      final conversations = snapshot.docs
          .where((doc) => !List<String>.from(doc.data()['deletedBy'] ?? const []).contains(userId))
          .map((doc) => ConversationModel.fromDoc(doc, userId))
          .toList();
      // Firestore can only order by one field; pinning is a per-viewer flag,
      // so it has to be applied here rather than in the query.
      conversations.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp);
      });
      return conversations;
    });
  }

  @override
  Stream<ChatConversation?> watchConversation(String conversationId, String userId) {
    return _conversations.doc(conversationId).snapshots().map(
          (doc) => doc.exists ? ConversationModel.fromDoc(doc, userId) : null,
        );
  }

  @override
  Future<String> startDirectConversation({
    required UserEntity me,
    required MessageContact contact,
  }) async {
    final id = ConversationModel.directId(me.id, contact.id);
    final ref = _conversations.doc(id);
    final existing = await ref.get();

    if (existing.exists) {
      // Re-opening a thread the user had hidden brings it back rather than
      // starting an empty duplicate.
      await ref.update({
        'deletedBy': FieldValue.arrayRemove([me.id]),
      });
      return id;
    }

    // A chat only lands in Message Requests when two non-staff accounts
    // (parent/student) start talking. Anything involving staff is school
    // business and goes straight to the inbox.
    final bothNonStaff = !_isStaff(me.role.name) && !_isStaff(contact.role);
    final acceptedBy = bothNonStaff ? [me.id] : [me.id, contact.id];

    await ref.set(ConversationModel.toCreateJson(
      schoolId: me.schoolId,
      type: ChatType.direct,
      title: '',
      participants: [_selfContact(me), contact],
      createdBy: me.id,
      adminIds: [me.id, contact.id],
      acceptedBy: acceptedBy,
    ));
    return id;
  }

  @override
  Future<String> createConversation({
    required UserEntity me,
    required ChatType type,
    required String title,
    required List<MessageContact> members,
    String? description,
    String? avatarUrl,
    MessagePolicy messagePolicy = MessagePolicy.everyone,
  }) async {
    final participants = [
      _selfContact(me),
      ...members.where((m) => m.id != me.id),
    ];
    final ref = _conversations.doc();
    await ref.set(ConversationModel.toCreateJson(
      schoolId: me.schoolId,
      type: type,
      title: title,
      description: description,
      avatarUrl: avatarUrl,
      participants: participants,
      createdBy: me.id,
      adminIds: [me.id],
      // Groups, broadcasts and channels are never gated behind a request.
      acceptedBy: participants.map((p) => p.id).toList(),
      messagePolicy: messagePolicy,
    ));
    return ref.id;
  }

  @override
  Future<void> setPinned(String conversationId, String userId, bool value) {
    return _toggleMembership(conversationId, 'pinnedBy', userId, value);
  }

  @override
  Future<void> setMuted(String conversationId, String userId, bool value) {
    return _toggleMembership(conversationId, 'mutedBy', userId, value);
  }

  @override
  Future<void> setArchived(String conversationId, String userId, bool value) {
    return _toggleMembership(conversationId, 'archivedBy', userId, value);
  }

  @override
  Future<void> acceptRequest(String conversationId, String userId) {
    return _conversations.doc(conversationId).update({
      'acceptedBy': FieldValue.arrayUnion([userId]),
      'spamBy': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> markSpam(String conversationId, String userId) {
    return _conversations.doc(conversationId).update({
      'spamBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> leaveConversation(String conversationId, String userId) async {
    final doc = await _conversations.doc(conversationId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final type = data['type'] as String?;

    if (type == ChatType.direct.name) {
      // A 1:1 thread stays alive for the other person; it just disappears
      // from this user's inbox until either side writes again.
      await doc.reference.update({
        'deletedBy': FieldValue.arrayUnion([userId]),
      });
      return;
    }

    final participants = (data['participants'] as List? ?? const [])
        .where((p) => p['id'] != userId)
        .toList();
    await doc.reference.update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'participants': participants,
      'adminIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> updateGroupInfo(
    String conversationId, {
    String? title,
    String? description,
    String? avatarUrl,
    MessagePolicy? messagePolicy,
  }) {
    return _conversations.doc(conversationId).update({
      'title': ?title,
      'description': ?description,
      'avatarUrl': ?avatarUrl,
      'messagePolicy': ?messagePolicy?.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addMembers(String conversationId, List<MessageContact> members) async {
    final ref = _conversations.doc(conversationId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final existing = (doc.data()!['participants'] as List? ?? const [])
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final existingIds = existing.map((p) => p['id']).toSet();
    final added = members.where((m) => !existingIds.contains(m.id)).toList();
    if (added.isEmpty) return;

    await ref.update({
      'participantIds': FieldValue.arrayUnion(added.map((m) => m.id).toList()),
      'participants': [
        ...existing,
        ...added.map((m) => {'id': m.id, 'name': m.name, 'role': m.role, 'avatarUrl': m.avatarUrl}),
      ],
      'acceptedBy': FieldValue.arrayUnion(added.map((m) => m.id).toList()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeMember(String conversationId, String userId) =>
      leaveConversation(conversationId, userId);

  @override
  Future<void> archiveAllChats(String userId) async {
    await _forEachConversation(userId, (ref) async {
      await ref.update({
        'archivedBy': FieldValue.arrayUnion([userId]),
      });
    });
  }

  @override
  Future<void> deleteAllChats(String userId) async {
    await _forEachConversation(userId, (ref) async {
      await ref.update({
        'deletedBy': FieldValue.arrayUnion([userId]),
      });
    });
  }

  @override
  Future<void> reportConversation({
    required String conversationId,
    required UserEntity reporter,
    required String reason,
    String? reportedUserId,
  }) {
    return firestore.collection('message_reports').add({
      'conversationId': conversationId,
      'schoolId': reporter.schoolId,
      'reportedBy': reporter.id,
      'reportedByName': reporter.name,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- One conversation --------------------------------------------------

  @override
  Stream<List<ChatMessage>> watchMessages(
    String conversationId,
    String userId, {
    int limit = _kMessageLimit,
  }) {
    return _messagesOf(conversationId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromDoc(doc, userId))
            .toList()
            .reversed
            .toList());
  }

  @override
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
  }) async {
    final conversationRef = _conversations.doc(conversationId);
    final conversation = await conversationRef.get();
    if (!conversation.exists) return;

    final participantIds = List<String>.from(conversation.data()!['participantIds'] ?? const []);
    final messageRef = _messagesOf(conversationId).doc();

    final batch = firestore.batch();
    batch.set(
      messageRef,
      ChatMessageModel.toCreateJson(
        senderId: sender.id,
        senderName: sender.name,
        content: content,
        type: type,
        participantIds: participantIds,
        fileName: fileName,
        fileSize: fileSize,
        mediaUrl: mediaUrl,
        replyToId: replyTo?.id,
        replyToSender: replyTo?.senderName,
        replyToContent: replyTo?.content,
        pollOptions: pollOptions,
        audioDuration: audioDuration,
        latitude: latitude,
        longitude: longitude,
        sharedContactId: sharedContactId,
        sharedContactRole: sharedContactRole,
        eventStart: eventStart,
        eventLocation: eventLocation,
      ),
    );

    batch.update(conversationRef, {
      'lastMessage': {
        'id': messageRef.id,
        'senderId': sender.id,
        'senderName': sender.name,
        'content': ChatMessageModel.preview(type, content, fileName),
        'type': type.name,
        'timestamp': Timestamp.now(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
      // Everyone but the sender gains an unread; a thread the sender had
      // hidden comes back for them the moment they write in it.
      for (final id in participantIds)
        if (id != sender.id) 'unreadCounts.$id': FieldValue.increment(1),
      'deletedBy': FieldValue.arrayRemove([sender.id]),
    });

    await batch.commit();
  }

  @override
  Future<String> uploadAttachment({
    required String schoolId,
    required String conversationId,
    required File file,
    required String fileName,
  }) async {
    final ref = storage.ref(
      'chat_attachments/$schoolId/$conversationId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  Future<void> markConversationRead(String conversationId, String userId) async {
    await _conversations.doc(conversationId).update({'unreadCounts.$userId': 0});

    // Firestore has no "array does not contain" filter, so stamp readBy on
    // the recent window and skip the ones already marked.
    final recent = await _messagesOf(conversationId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    final unread = recent.docs.where(
      (doc) => !List<String>.from(doc.data()['readBy'] ?? const []).contains(userId),
    );
    if (unread.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in unread) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> setStarred(String conversationId, String messageId, String userId, bool value) {
    return _messagesOf(conversationId).doc(messageId).update({
      'starredBy': value ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> setMessagePinned(String conversationId, ChatMessage message, bool value) async {
    final batch = firestore.batch();
    batch.update(_messagesOf(conversationId).doc(message.id), {'isPinned': value});
    // The banner at the top of the chat reads from the conversation doc, so
    // it has to be kept in step with the message flag.
    batch.update(_conversations.doc(conversationId), {
      'pinnedMessage': value
          ? {
              'id': message.id,
              'content': message.content,
              'senderName': message.senderName,
              'pinnedAt': Timestamp.now(),
            }
          : null,
    });
    await batch.commit();
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    final conversationRef = _conversations.doc(conversationId);
    final batch = firestore.batch();

    batch.update(_messagesOf(conversationId).doc(messageId), {
      'isDeleted': true,
      'content': '',
      'mediaUrl': null,
      'isPinned': false,
    });

    final conversation = await conversationRef.get();
    final lastMessage = conversation.data()?['lastMessage'] as Map<String, dynamic>?;
    if (lastMessage != null && lastMessage['id'] == messageId) {
      batch.update(conversationRef, {'lastMessage.content': 'This message was deleted'});
    }
    final pinned = conversation.data()?['pinnedMessage'] as Map<String, dynamic>?;
    if (pinned != null && pinned['id'] == messageId) {
      batch.update(conversationRef, {'pinnedMessage': null});
    }

    await batch.commit();
  }

  @override
  Future<void> editMessage(String conversationId, String messageId, String content) async {
    final conversationRef = _conversations.doc(conversationId);
    final batch = firestore.batch();

    batch.update(_messagesOf(conversationId).doc(messageId), {
      'content': content,
      'editedAt': FieldValue.serverTimestamp(),
    });

    final conversation = await conversationRef.get();
    final lastMessage = conversation.data()?['lastMessage'] as Map<String, dynamic>?;
    if (lastMessage != null && lastMessage['id'] == messageId) {
      batch.update(conversationRef, {'lastMessage.content': content});
    }

    await batch.commit();
  }

  @override
  Future<void> react(
    String conversationId,
    String messageId,
    String userId,
    String? emoji,
  ) async {
    final ref = _messagesOf(conversationId).doc(messageId);
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) return;

      final reactions = Map<String, dynamic>.from(doc.data()!['reactions'] ?? const {});
      // One reaction per person, so the transaction first has to find which
      // emoji they are currently on.
      String? previous;
      for (final entry in reactions.entries) {
        if (List<String>.from(entry.value ?? const []).contains(userId)) {
          previous = entry.key;
          break;
        }
      }

      // Written as per-emoji array edits rather than one whole-map write:
      // rewriting `reactions` wholesale is a read-modify-write that would
      // clobber a reaction somebody else added in the same instant.
      final updates = <String, dynamic>{};
      if (previous != null) {
        updates['reactions.$previous'] = FieldValue.arrayRemove([userId]);
      }
      // Tapping the emoji you already reacted with just clears it.
      if (emoji != null && emoji != previous) {
        updates['reactions.$emoji'] = FieldValue.arrayUnion([userId]);
      }
      if (updates.isEmpty) return;

      transaction.update(ref, updates);
    });
  }

  @override
  Future<void> voteInPoll(
    String conversationId,
    String messageId,
    String userId,
    int optionIndex,
  ) async {
    final ref = _messagesOf(conversationId).doc(messageId);
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) return;

      final votes = Map<String, dynamic>.from(doc.data()!['pollVotes'] ?? const {});
      String? previous;
      for (final entry in votes.entries) {
        if (List<String>.from(entry.value ?? const []).contains(userId)) {
          previous = entry.key;
          break;
        }
      }

      // Per-option array edits rather than one whole-map write, so two people
      // voting at the same instant can't overwrite each other.
      final updates = <String, dynamic>{};
      if (previous != null) {
        updates['pollVotes.$previous'] = FieldValue.arrayRemove([userId]);
      }
      if (previous != '$optionIndex') {
        updates['pollVotes.$optionIndex'] = FieldValue.arrayUnion([userId]);
      }
      if (updates.isEmpty) return;

      transaction.update(ref, updates);
    });
  }

  @override
  Future<void> forwardMessage({
    required ChatMessage message,
    required List<String> conversationIds,
    required UserEntity sender,
  }) async {
    for (final conversationId in conversationIds) {
      await sendMessage(
        conversationId: conversationId,
        sender: sender,
        content: message.content,
        type: message.type,
        fileName: message.fileName,
        fileSize: message.fileSize,
        mediaUrl: message.mediaUrl,
        // A forwarded poll starts a fresh vote rather than carrying the
        // original chat's tallies across.
        pollOptions: message.pollOptions,
        audioDuration: message.audioDuration,
        latitude: message.latitude,
        longitude: message.longitude,
        sharedContactId: message.sharedContactId,
        sharedContactRole: message.sharedContactRole,
        eventStart: message.eventStart,
        eventLocation: message.eventLocation,
      );
    }
  }

  @override
  Stream<List<ChatMessage>> watchAttachments(String conversationId, String userId) {
    return _messagesOf(conversationId)
        .orderBy('timestamp', descending: true)
        .limit(_kMessageLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromDoc(doc, userId))
            .where((m) => !m.isDeleted && (m.mediaUrl != null || _hasLink(m)))
            .toList());
  }

  // --- Across conversations ----------------------------------------------

  @override
  Stream<List<ChatMessageRef>> watchStarredMessages(String userId) {
    final starred = firestore
        .collectionGroup('messages')
        .where('starredBy', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
    return _withConversationTitles(starred, userId);
  }

  @override
  Stream<List<ChatMessageRef>> watchPinnedMessages(String userId) {
    final pinned = firestore
        .collectionGroup('messages')
        .where('participantIds', arrayContains: userId)
        .where('isPinned', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
    return _withConversationTitles(pinned, userId);
  }

  @override
  Future<List<ChatMessageRef>> searchMessages(String userId, String query) async {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return const [];

    final results = await firestore
        .collectionGroup('messages')
        .where('participantIds', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .limit(_kSearchWindow)
        .get();

    final matches = results.docs
        .where((doc) => (doc.data()['content'] as String? ?? '').toLowerCase().contains(term))
        .where((doc) => doc.data()['isDeleted'] != true)
        .toList();
    if (matches.isEmpty) return const [];

    final titles = await _conversationTitles(
      matches.map((doc) => doc.reference.parent.parent!.id).toSet(),
      userId,
    );

    return matches.map((doc) {
      final conversationId = doc.reference.parent.parent!.id;
      return ChatMessageRef(
        message: ChatMessageModel.fromDoc(doc, userId),
        conversationId: conversationId,
        conversationTitle: titles[conversationId] ?? 'Conversation',
      );
    }).toList();
  }

  // --- Directory ---------------------------------------------------------

  @override
  Future<List<MessageContact>> getContacts(String schoolId, {String? excludeId}) async {
    final snapshot = await firestore
        .collection('school_contacts')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .get();

    final contacts = snapshot.docs
        .where((doc) => doc.id != excludeId)
        .map((doc) => MessageContact(
              id: doc.id,
              name: doc.data()['name'] as String? ?? 'Unknown',
              role: doc.data()['role'] as String? ?? '',
            ))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return contacts;
  }

  @override
  Future<MessageContact?> getContact(String userId) async {
    final doc = await firestore.collection('school_contacts').doc(userId).get();
    if (!doc.exists) return null;
    return MessageContact(
      id: doc.id,
      name: doc.data()!['name'] as String? ?? 'Unknown',
      role: doc.data()!['role'] as String? ?? '',
    );
  }

  @override
  Future<List<MessageContact>> getRecentContacts(String userId, {int limit = 4}) async {
    final snapshot = await _conversations
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(30)
        .get();

    final seen = <String>{};
    final recent = <MessageContact>[];
    for (final doc in snapshot.docs) {
      if (doc.data()['type'] != ChatType.direct.name) continue;
      for (final participant in (doc.data()['participants'] as List? ?? const [])) {
        final id = participant['id'] as String? ?? '';
        if (id == userId || id.isEmpty || !seen.add(id)) continue;
        recent.add(MessageContact(
          id: id,
          name: participant['name'] as String? ?? 'Unknown',
          role: participant['role'] as String? ?? '',
        ));
      }
      if (recent.length >= limit) break;
    }
    return recent.take(limit).toList();
  }

  // --- Internals ---------------------------------------------------------

  Future<void> _toggleMembership(
    String conversationId,
    String field,
    String userId,
    bool value,
  ) {
    return _conversations.doc(conversationId).update({
      field: value ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> _forEachConversation(
    String userId,
    Future<void> Function(DocumentReference<Map<String, dynamic>>) action,
  ) async {
    final snapshot = await _conversations
        .where('participantIds', arrayContains: userId)
        .limit(_kConversationLimit)
        .get();
    for (final doc in snapshot.docs) {
      await action(doc.reference);
    }
  }

  /// Joins a collection-group message stream to the titles of the
  /// conversations they belong to - the standalone Starred/Pinned screens
  /// show `in <chat name>`, which the message document alone can't answer
  /// (a 1:1 title depends on who is looking).
  Stream<List<ChatMessageRef>> _withConversationTitles(
    Stream<QuerySnapshot<Map<String, dynamic>>> messages,
    String userId,
  ) {
    return Rx.combineLatest2<QuerySnapshot<Map<String, dynamic>>, List<ChatConversation>,
        List<ChatMessageRef>>(
      messages,
      watchConversations(userId),
      (snapshot, conversations) {
        final titles = {for (final c in conversations) c.id: c.title};
        return snapshot.docs.where((doc) => doc.data()['isDeleted'] != true).map((doc) {
          final conversationId = doc.reference.parent.parent!.id;
          return ChatMessageRef(
            message: ChatMessageModel.fromDoc(doc, userId),
            conversationId: conversationId,
            conversationTitle: titles[conversationId] ?? 'Conversation',
          );
        }).toList();
      },
    );
  }

  Future<Map<String, String>> _conversationTitles(Set<String> ids, String userId) async {
    final titles = <String, String>{};
    for (final id in ids) {
      final doc = await _conversations.doc(id).get();
      if (doc.exists) titles[id] = ConversationModel.fromDoc(doc, userId).title;
    }
    return titles;
  }

  MessageContact _selfContact(UserEntity me) => MessageContact(
        id: me.id,
        name: me.name,
        role: me.role.name,
        avatarUrl: me.photoUrl,
      );

  /// Mirrors the `isStaff()` helper in firestore.rules: anyone who isn't a
  /// parent or a student.
  bool _isStaff(String roleName) =>
      roleName != UserRole.parent.name && roleName != UserRole.student.name;

  bool _hasLink(ChatMessage message) =>
      message.type == MessageType.text && message.content.contains('http');
}
