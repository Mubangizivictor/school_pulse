import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

UserEntity _user(String id, String name, UserRole role) => UserEntity(
  id: id,
  name: name,
  email: '$id@school.test',
  schoolId: 'school-1',
  roles: [role],
);

void main() {
  late FakeFirebaseFirestore firestore;
  late MessagesRepositoryImpl repository;

  final teacher = _user('teacher-1', 'Mrs. Amina', UserRole.classTeacher);
  final parent = _user('parent-1', 'Mr. Boateng', UserRole.parent);
  final otherParent = _user('parent-2', 'Abena Owusu', UserRole.parent);

  const teacherContact = MessageContact(
    id: 'teacher-1',
    name: 'Mrs. Amina',
    role: 'classTeacher',
  );
  const parentContact = MessageContact(
    id: 'parent-1',
    name: 'Mr. Boateng',
    role: 'parent',
  );
  const otherParentContact = MessageContact(
    id: 'parent-2',
    name: 'Abena Owusu',
    role: 'parent',
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = MessagesRepositoryImpl(
      firestore: firestore,
      storage: MockFirebaseStorage(),
    );
  });

  group('startDirectConversation', () {
    test('reuses the same thread no matter who opens it first', () async {
      final fromParent = await repository.startDirectConversation(
        me: parent,
        contact: teacherContact,
      );
      final fromTeacher = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );

      expect(fromParent, fromTeacher);
      final all = await firestore.collection('conversations').get();
      expect(all.docs, hasLength(1));
    });

    test('auto-accepts when a staff member is involved', () async {
      final id = await repository.startDirectConversation(
        me: parent,
        contact: teacherContact,
      );

      final doc = await firestore.collection('conversations').doc(id).get();
      expect(doc.data()!['acceptedBy'], containsAll(['parent-1', 'teacher-1']));
    });

    test('leaves a parent-to-parent chat pending for the recipient', () async {
      final id = await repository.startDirectConversation(
        me: parent,
        contact: otherParentContact,
      );

      final doc = await firestore.collection('conversations').doc(id).get();
      expect(doc.data()!['acceptedBy'], ['parent-1']);

      final forRecipient = await repository
          .watchConversation(id, otherParent.id)
          .first;
      expect(forRecipient!.isAccepted, isFalse);
    });

    test('un-hides a thread the user had previously deleted', () async {
      final id = await repository.startDirectConversation(
        me: parent,
        contact: teacherContact,
      );
      await repository.leaveConversation(id, parent.id);
      expect(await repository.watchConversations(parent.id).first, isEmpty);

      await repository.startDirectConversation(
        me: parent,
        contact: teacherContact,
      );
      expect(
        await repository.watchConversations(parent.id).first,
        hasLength(1),
      );
    });
  });

  group('sendMessage', () {
    test('raises the unread count for everyone but the sender', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'PTA on Friday',
      );

      final doc = await firestore.collection('conversations').doc(id).get();
      final unread = doc.data()!['unreadCounts'] as Map<String, dynamic>;
      expect(unread['parent-1'], 1);
      expect(unread['teacher-1'], 0);
    });

    test(
      'denormalizes the preview and participants onto the conversation',
      () async {
        final id = await repository.startDirectConversation(
          me: teacher,
          contact: parentContact,
        );
        await repository.sendMessage(
          conversationId: id,
          sender: teacher,
          content: 'PTA on Friday',
        );

        final conversation = await repository
            .watchConversation(id, parent.id)
            .first;
        expect(conversation!.lastMessage.content, 'PTA on Friday');
        expect(conversation.hasMessages, isTrue);
        // A 1:1 title is resolved per viewer, never stored.
        expect(conversation.title, 'Mrs. Amina');
      },
    );

    test('shows a photo as a preview rather than empty text', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: '',
        type: MessageType.image,
        mediaUrl: 'https://example.test/a.jpg',
        fileName: 'a.jpg',
      );

      final conversation = await repository
          .watchConversation(id, parent.id)
          .first;
      expect(conversation!.lastMessage.content, '📷 Photo');
    });

    test('carries the quoted message when replying', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'PTA on Friday',
      );
      final original =
          (await repository.watchMessages(id, parent.id).first).single;

      await repository.sendMessage(
        conversationId: id,
        sender: parent,
        content: 'Thank you!',
        replyTo: original,
      );

      final messages = await repository.watchMessages(id, parent.id).first;
      expect(messages.last.replyToContent, 'PTA on Friday');
      expect(messages.last.replyToSender, 'Mrs. Amina');
    });
  });

  group('read state', () {
    test(
      'markConversationRead clears the badge and flips the sender ticks',
      () async {
        final id = await repository.startDirectConversation(
          me: teacher,
          contact: parentContact,
        );
        await repository.sendMessage(
          conversationId: id,
          sender: teacher,
          content: 'Hello',
        );

        expect(
          (await repository.watchMessages(id, teacher.id).first).single.isRead,
          isFalse,
        );

        await repository.markConversationRead(id, parent.id);

        final forParent = await repository
            .watchConversation(id, parent.id)
            .first;
        expect(forParent!.unreadCount, 0);
        expect(
          (await repository.watchMessages(id, teacher.id).first).single.isRead,
          isTrue,
        );
      },
    );

    test('isMe is resolved per viewer', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Hello',
      );

      expect(
        (await repository.watchMessages(id, teacher.id).first).single.isMe,
        isTrue,
      );
      expect(
        (await repository.watchMessages(id, parent.id).first).single.isMe,
        isFalse,
      );
    });
  });

  group('message actions', () {
    late String conversationId;
    late ChatMessage message;

    setUp(() async {
      conversationId = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: conversationId,
        sender: teacher,
        content: 'Original',
      );
      message =
          (await repository.watchMessages(conversationId, teacher.id).first)
              .single;
    });

    test('starring is per-user', () async {
      await repository.setStarred(conversationId, message.id, parent.id, true);

      expect(
        (await repository.watchMessages(conversationId, parent.id).first)
            .single
            .isStarred,
        isTrue,
      );
      expect(
        (await repository.watchMessages(conversationId, teacher.id).first)
            .single
            .isStarred,
        isFalse,
      );
    });

    test('pinning updates both the message and the chat banner', () async {
      await repository.setMessagePinned(conversationId, message, true);

      final conversation = await repository
          .watchConversation(conversationId, teacher.id)
          .first;
      expect(conversation!.pinnedMessageContent, 'Original');
      expect(
        (await repository.watchMessages(conversationId, teacher.id).first)
            .single
            .isPinned,
        isTrue,
      );

      await repository.setMessagePinned(conversationId, message, false);
      final cleared = await repository
          .watchConversation(conversationId, teacher.id)
          .first;
      expect(cleared!.pinnedMessageContent, isNull);
    });

    test('editing rewrites the inbox preview too', () async {
      await repository.editMessage(conversationId, message.id, 'Corrected');

      final conversation = await repository
          .watchConversation(conversationId, teacher.id)
          .first;
      expect(conversation!.lastMessage.content, 'Corrected');
      expect(
        (await repository.watchMessages(conversationId, teacher.id).first)
            .single
            .editedAt,
        isNotNull,
      );
    });

    test('deleting tombstones the message and the preview', () async {
      await repository.deleteMessage(conversationId, message.id);

      final deleted =
          (await repository.watchMessages(conversationId, teacher.id).first)
              .single;
      expect(deleted.isDeleted, isTrue);
      expect(deleted.content, isEmpty);

      final conversation = await repository
          .watchConversation(conversationId, teacher.id)
          .first;
      expect(conversation!.lastMessage.content, 'This message was deleted');
    });

    test('a person only ever holds one reaction', () async {
      await repository.react(conversationId, message.id, parent.id, '👍');
      var reacted =
          (await repository.watchMessages(conversationId, parent.id).first)
              .single;
      expect(reacted.myReaction, '👍');
      expect(reacted.reactions, {'👍': 1});

      await repository.react(conversationId, message.id, parent.id, '❤️');
      reacted =
          (await repository.watchMessages(conversationId, parent.id).first)
              .single;
      expect(reacted.myReaction, '❤️');
      expect(reacted.reactions, {'❤️': 1});

      // Tapping the same emoji again clears it.
      await repository.react(conversationId, message.id, parent.id, '❤️');
      reacted =
          (await repository.watchMessages(conversationId, parent.id).first)
              .single;
      expect(reacted.myReaction, isNull);
      expect(reacted.reactions, isEmpty);
    });

    test('forwarding copies the body into another chat', () async {
      final other = await repository.startDirectConversation(
        me: teacher,
        contact: otherParentContact,
      );

      await repository.forwardMessage(
        message: message,
        conversationIds: [other],
        sender: teacher,
      );

      final forwarded = await repository.watchMessages(other, teacher.id).first;
      expect(forwarded.single.content, 'Original');
    });
  });

  group('rich attachments', () {
    test(
      'a poll starts with every option on zero and no vote of my own',
      () async {
        final id = await repository.startDirectConversation(
          me: teacher,
          contact: parentContact,
        );
        await repository.sendMessage(
          conversationId: id,
          sender: teacher,
          content: 'Which day suits the trip?',
          type: MessageType.poll,
          pollOptions: ['Friday', 'Saturday'],
        );

        final poll =
            (await repository.watchMessages(id, parent.id).first).single;
        expect(poll.pollOptions, ['Friday', 'Saturday']);
        expect(poll.pollVotes, {'0': 0, '1': 0});
        expect(poll.myPollVote, isNull);
        // The inbox preview names the type rather than showing a blank line.
        final conversation = await repository
            .watchConversation(id, parent.id)
            .first;
        expect(conversation!.lastMessage.content, '📊 Poll');
      },
    );

    test('a person holds one poll vote and can move or withdraw it', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Which day suits the trip?',
        type: MessageType.poll,
        pollOptions: ['Friday', 'Saturday'],
      );
      final poll = (await repository.watchMessages(id, parent.id).first).single;

      await repository.voteInPoll(id, poll.id, parent.id, 0);
      var voted = (await repository.watchMessages(id, parent.id).first).single;
      expect(voted.myPollVote, 0);
      expect(voted.pollVotes, {'0': 1, '1': 0});

      await repository.voteInPoll(id, poll.id, parent.id, 1);
      voted = (await repository.watchMessages(id, parent.id).first).single;
      expect(voted.myPollVote, 1);
      expect(voted.pollVotes, {'0': 0, '1': 1});

      // Voting for the same option again withdraws it.
      await repository.voteInPoll(id, poll.id, parent.id, 1);
      voted = (await repository.watchMessages(id, parent.id).first).single;
      expect(voted.myPollVote, isNull);
      expect(voted.pollVotes, {'0': 0, '1': 0});
    });

    test('two people voting are counted separately', () async {
      final id = await repository.createConversation(
        me: teacher,
        type: ChatType.group,
        title: 'P7 - Parents Group',
        members: [parentContact, otherParentContact],
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Which day suits the trip?',
        type: MessageType.poll,
        pollOptions: ['Friday', 'Saturday'],
      );
      final poll =
          (await repository.watchMessages(id, teacher.id).first).single;

      await repository.voteInPoll(id, poll.id, parent.id, 0);
      await repository.voteInPoll(id, poll.id, otherParent.id, 0);

      final voted =
          (await repository.watchMessages(id, teacher.id).first).single;
      expect(voted.pollVotes, {'0': 2, '1': 0});
      expect(voted.myPollVote, isNull, reason: 'the teacher has not voted');
    });

    test('a voice note keeps its duration', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: '',
        type: MessageType.audio,
        mediaUrl: 'https://example.test/voice.m4a',
        fileName: 'Voice note.m4a',
        audioDuration: const Duration(seconds: 12),
      );

      final message =
          (await repository.watchMessages(id, parent.id).first).single;
      expect(message.audioDuration, const Duration(seconds: 12));

      final conversation = await repository
          .watchConversation(id, parent.id)
          .first;
      expect(conversation!.lastMessage.content, '🎤 Voice message');
    });

    test('a shared location round-trips its coordinates', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: '',
        type: MessageType.location,
        latitude: 0.3476,
        longitude: 32.5825,
      );

      final message =
          (await repository.watchMessages(id, parent.id).first).single;
      expect(message.latitude, closeTo(0.3476, 0.00001));
      expect(message.longitude, closeTo(32.5825, 0.00001));
    });

    test('a shared contact carries the id needed to open a chat', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Abena Owusu',
        type: MessageType.contact,
        sharedContactId: 'parent-2',
        sharedContactRole: 'parent',
      );

      final message =
          (await repository.watchMessages(id, parent.id).first).single;
      expect(message.sharedContactId, 'parent-2');
      expect(message.sharedContactRole, 'parent');
      expect(message.content, 'Abena Owusu');
    });

    test('an event keeps its start time and place', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      final start = DateTime(2026, 9, 4, 16, 30);
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'PTA meeting',
        type: MessageType.event,
        eventStart: start,
        eventLocation: 'Assembly hall',
      );

      final message =
          (await repository.watchMessages(id, parent.id).first).single;
      expect(message.eventStart, start);
      expect(message.eventLocation, 'Assembly hall');
    });

    test('a document shows its filename in the inbox preview', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: '',
        type: MessageType.file,
        mediaUrl: 'https://example.test/newsletter.pdf',
        fileName: 'Newsletter.pdf',
        fileSize: '2.4 MB',
      );

      final conversation = await repository
          .watchConversation(id, parent.id)
          .first;
      expect(conversation!.lastMessage.content, '📄 Newsletter.pdf');
    });

    test('forwarding a poll resets the votes', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Which day suits the trip?',
        type: MessageType.poll,
        pollOptions: ['Friday', 'Saturday'],
      );
      final poll =
          (await repository.watchMessages(id, teacher.id).first).single;
      await repository.voteInPoll(id, poll.id, parent.id, 0);
      final voted =
          (await repository.watchMessages(id, teacher.id).first).single;

      final other = await repository.startDirectConversation(
        me: teacher,
        contact: otherParentContact,
      );
      await repository.forwardMessage(
        message: voted,
        conversationIds: [other],
        sender: teacher,
      );

      final forwarded =
          (await repository.watchMessages(other, teacher.id).first).single;
      expect(forwarded.pollOptions, ['Friday', 'Saturday']);
      expect(forwarded.pollVotes, {'0': 0, '1': 0});
    });
  });

  group('message requests', () {
    test('marking spam is per-user and does not accept the chat', () async {
      final id = await repository.startDirectConversation(
        me: parent,
        contact: otherParentContact,
      );

      await repository.markSpam(id, otherParent.id);

      final forRecipient = await repository
          .watchConversation(id, otherParent.id)
          .first;
      expect(forRecipient!.isSpam, isTrue);
      expect(forRecipient.isAccepted, isFalse);

      final forSender = await repository.watchConversation(id, parent.id).first;
      expect(forSender!.isSpam, isFalse);
    });

    test(
      'accepting clears the spam flag and moves it into the inbox',
      () async {
        final id = await repository.startDirectConversation(
          me: parent,
          contact: otherParentContact,
        );
        await repository.markSpam(id, otherParent.id);

        await repository.acceptRequest(id, otherParent.id);

        final accepted = await repository
            .watchConversation(id, otherParent.id)
            .first;
        expect(accepted!.isAccepted, isTrue);
        expect(accepted.isSpam, isFalse);
      },
    );
  });

  group('groups', () {
    test('creates a group with the creator as its only admin', () async {
      final id = await repository.createConversation(
        me: teacher,
        type: ChatType.group,
        title: 'P7 - Parents Group',
        members: [parentContact, otherParentContact],
      );

      final conversation = await repository
          .watchConversation(id, parent.id)
          .first;
      expect(conversation!.title, 'P7 - Parents Group');
      expect(conversation.participants, hasLength(3));
      expect(conversation.isAdmin(teacher.id), isTrue);
      expect(conversation.isAdmin(parent.id), isFalse);
      expect(conversation.subtitle, '3 members');
    });

    test('an admins-only channel blocks members from posting', () async {
      final id = await repository.createConversation(
        me: teacher,
        type: ChatType.channel,
        title: 'School Announcements',
        members: [parentContact],
        messagePolicy: MessagePolicy.adminsOnly,
      );

      final conversation = await repository
          .watchConversation(id, parent.id)
          .first;
      expect(conversation!.canPost(teacher.id), isTrue);
      expect(conversation.canPost(parent.id), isFalse);
    });

    test('leaving a group removes the member for everyone', () async {
      final id = await repository.createConversation(
        me: teacher,
        type: ChatType.group,
        title: 'P7 - Parents Group',
        members: [parentContact, otherParentContact],
      );

      await repository.leaveConversation(id, parent.id);

      final conversation = await repository
          .watchConversation(id, teacher.id)
          .first;
      expect(
        conversation!.participants.map((p) => p.id),
        isNot(contains(parent.id)),
      );
      expect(await repository.watchConversations(parent.id).first, isEmpty);
    });

    test('addMembers is idempotent', () async {
      final id = await repository.createConversation(
        me: teacher,
        type: ChatType.group,
        title: 'P7 - Parents Group',
        members: [parentContact],
      );

      await repository.addMembers(id, [parentContact, otherParentContact]);
      await repository.addMembers(id, [otherParentContact]);

      final conversation = await repository
          .watchConversation(id, teacher.id)
          .first;
      expect(conversation!.participants, hasLength(3));
    });
  });

  group('reporting', () {
    test(
      'files a report staff can pick up, tied to the conversation',
      () async {
        final id = await repository.startDirectConversation(
          me: parent,
          contact: teacherContact,
        );

        await repository.reportConversation(
          conversationId: id,
          reporter: parent,
          reason: 'Inappropriate language',
          reportedUserId: teacher.id,
        );

        final reports = await firestore.collection('message_reports').get();
        final report = reports.docs.single.data();
        expect(report['conversationId'], id);
        expect(report['reportedBy'], parent.id);
        expect(report['reportedUserId'], teacher.id);
        expect(report['reason'], 'Inappropriate language');
        expect(report['schoolId'], 'school-1');
        // Staff triage on this field, so it has to start open.
        expect(report['status'], 'open');
      },
    );
  });

  group('pagination', () {
    test('the limit caps how far back a chat loads', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      for (var i = 0; i < 5; i++) {
        await repository.sendMessage(
          conversationId: id,
          sender: teacher,
          content: 'Message $i',
        );
      }

      final firstPage = await repository
          .watchMessages(id, teacher.id, limit: 3)
          .first;
      expect(firstPage, hasLength(3));
      // Oldest first within the window, and the window holds the newest.
      expect(firstPage.last.content, 'Message 4');

      final wholeChat = await repository
          .watchMessages(id, teacher.id, limit: 50)
          .first;
      expect(wholeChat, hasLength(5));
      expect(wholeChat.first.content, 'Message 0');
    });
  });

  group('inbox', () {
    test('pinned chats sort above newer ones', () async {
      final older = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: older,
        sender: teacher,
        content: 'First',
      );
      final newer = await repository.startDirectConversation(
        me: teacher,
        contact: otherParentContact,
      );
      await repository.sendMessage(
        conversationId: newer,
        sender: teacher,
        content: 'Second',
      );

      await repository.setPinned(older, teacher.id, true);

      final inbox = await repository.watchConversations(teacher.id).first;
      expect(inbox.first.id, older);
      expect(inbox.first.isPinned, isTrue);
    });

    test('archiving is per-user', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.setArchived(id, teacher.id, true);

      expect(
        (await repository.watchConversations(teacher.id).first)
            .single
            .isArchived,
        isTrue,
      );
      expect(
        (await repository.watchConversations(parent.id).first)
            .single
            .isArchived,
        isFalse,
      );
    });

    test(
      'deleting a 1:1 chat only hides it from the person who deleted it',
      () async {
        final id = await repository.startDirectConversation(
          me: teacher,
          contact: parentContact,
        );
        await repository.sendMessage(
          conversationId: id,
          sender: teacher,
          content: 'Hello',
        );

        await repository.leaveConversation(id, parent.id);

        expect(await repository.watchConversations(parent.id).first, isEmpty);
        expect(
          await repository.watchConversations(teacher.id).first,
          hasLength(1),
        );
      },
    );
  });

  group('directory', () {
    setUp(() async {
      await firestore.collection('school_contacts').doc('teacher-1').set({
        'name': 'Mrs. Amina',
        'role': 'classTeacher',
        'schoolId': 'school-1',
        'isActive': true,
      });
      await firestore.collection('school_contacts').doc('parent-1').set({
        'name': 'Mr. Boateng',
        'role': 'parent',
        'schoolId': 'school-1',
        'isActive': true,
      });
      await firestore.collection('school_contacts').doc('left-1').set({
        'name': 'Former Staff',
        'role': 'bursar',
        'schoolId': 'school-1',
        'isActive': false,
      });
      await firestore.collection('school_contacts').doc('other-school').set({
        'name': 'Someone Else',
        'role': 'parent',
        'schoolId': 'school-2',
        'isActive': true,
      });
    });

    test(
      'lists only active contacts from the same school, minus yourself',
      () async {
        final contacts = await repository.getContacts(
          'school-1',
          excludeId: 'teacher-1',
        );

        expect(contacts.map((c) => c.id), ['parent-1']);
      },
    );

    test('recent contacts come from direct chats, most recent first', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Hello',
      );

      final recent = await repository.getRecentContacts(teacher.id);
      expect(recent.map((c) => c.id), ['parent-1']);
    });
  });

  group('search and starred', () {
    test('finds messages by substring, case-insensitively', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'PTA meeting this Friday',
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Homework due',
      );

      final results = await repository.searchMessages(parent.id, 'friday');

      expect(results, hasLength(1));
      expect(results.single.message.content, 'PTA meeting this Friday');
      expect(results.single.conversationTitle, 'Mrs. Amina');
    });

    test('search skips deleted messages', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'PTA meeting this Friday',
      );
      final message =
          (await repository.watchMessages(id, teacher.id).first).single;
      await repository.deleteMessage(id, message.id);

      expect(await repository.searchMessages(parent.id, 'friday'), isEmpty);
    });

    test('starred messages carry the chat they came from', () async {
      final id = await repository.startDirectConversation(
        me: teacher,
        contact: parentContact,
      );
      await repository.sendMessage(
        conversationId: id,
        sender: teacher,
        content: 'Keep this',
      );
      final message =
          (await repository.watchMessages(id, parent.id).first).single;
      await repository.setStarred(id, message.id, parent.id, true);

      final starred = await repository.watchStarredMessages(parent.id).first;
      expect(starred.single.message.content, 'Keep this');
      expect(starred.single.conversationTitle, 'Mrs. Amina');
    });
  });
}
