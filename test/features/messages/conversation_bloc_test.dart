import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/presentation/bloc/conversation_bloc.dart';

class MockMessagesRepository extends Mock implements MessagesRepository {}

class FakeUserEntity extends Fake implements UserEntity {}

class FakeChatMessage extends Fake implements ChatMessage {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(FakeChatMessage());
    registerFallbackValue(File('fallback.txt'));
    registerFallbackValue(MessageType.text);
  });

  late MockMessagesRepository repository;

  final user = UserEntity(
    id: 'u1',
    name: 'User One',
    email: 'u1@example.com',
    schoolId: 's1',
    roles: const [UserRole.subjectTeacher],
  );

  setUp(() {
    repository = MockMessagesRepository();
  });

  ConversationBloc buildBloc() => ConversationBloc(repository: repository);

  ChatConversation openConversation({
    List<String> adminIds = const [],
    MessagePolicy messagePolicy = MessagePolicy.everyone,
  }) {
    return ChatConversation(
      id: 'c1',
      title: 'Chat',
      type: ChatType.group,
      lastMessage: ChatMessage(
        id: 'm0',
        senderId: 'u1',
        senderName: 'User',
        content: 'hi',
        timestamp: DateTime(2026, 1, 1),
      ),
      participants: const [],
      schoolId: 's1',
      adminIds: adminIds,
      createdBy: 'u1',
      messagePolicy: messagePolicy,
    );
  }

  group('ConversationOpened', () {
    blocTest<ConversationBloc, ConversationState>(
      'subscribes to the conversation and its messages',
      setUp: () {
        when(
          () => repository.watchConversation('c1', 'u1'),
        ).thenAnswer((_) => Stream.value(openConversation()));
        when(
          () => repository.watchMessages('c1', 'u1', limit: 60),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.markConversationRead(any(), any()),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(ConversationOpened('c1', user)),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.conversationId,
          'conversationId',
          'c1',
        ),
        isA<ConversationState>().having(
          (s) => s.conversation?.id,
          'conversation',
          'c1',
        ),
        isA<ConversationState>().having((s) => s.messages, 'messages', isEmpty),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'does not resubscribe for the same conversation id',
      setUp: () {
        when(
          () => repository.watchConversation('c1', 'u1'),
        ).thenAnswer((_) => Stream.value(openConversation()));
        when(
          () => repository.watchMessages('c1', 'u1', limit: 60),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.markConversationRead(any(), any()),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(ConversationOpened('c1', user));
        bloc.add(ConversationOpened('c1', user));
      },
      verify: (_) {
        verify(() => repository.watchConversation('c1', 'u1')).called(1);
      },
    );
  });

  group('ConversationMessageSendRequested', () {
    blocTest<ConversationBloc, ConversationState>(
      'refuses to send when the conversation is admins-only and the user is not an admin',
      setUp: () {
        when(() => repository.watchConversation('c1', 'u1')).thenAnswer(
          (_) => Stream.value(
            openConversation(
              adminIds: ['someone-else'],
              messagePolicy: MessagePolicy.adminsOnly,
            ),
          ),
        );
        when(
          () => repository.watchMessages('c1', 'u1', limit: 60),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.markConversationRead(any(), any()),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(ConversationOpened('c1', user));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ConversationMessageSendRequested(content: 'hello'));
      },
      verify: (bloc) {
        expect(bloc.state.sendStatus, ConversationSendStatus.failed);
        expect(bloc.state.lastDecision?.isAllowed, isFalse);
        verifyNever(
          () => repository.sendMessage(
            conversationId: any(named: 'conversationId'),
            sender: any(named: 'sender'),
            content: any(named: 'content'),
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'sends when the conversation policy allows it',
      setUp: () {
        when(
          () => repository.watchConversation('c1', 'u1'),
        ).thenAnswer((_) => Stream.value(openConversation()));
        when(
          () => repository.watchMessages('c1', 'u1', limit: 60),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.markConversationRead(any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => repository.sendMessage(
            conversationId: any(named: 'conversationId'),
            sender: any(named: 'sender'),
            content: any(named: 'content'),
            type: any(named: 'type'),
            fileName: any(named: 'fileName'),
            fileSize: any(named: 'fileSize'),
            mediaUrl: any(named: 'mediaUrl'),
            replyTo: any(named: 'replyTo'),
            pollOptions: any(named: 'pollOptions'),
            audioDuration: any(named: 'audioDuration'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            sharedContactId: any(named: 'sharedContactId'),
            sharedContactRole: any(named: 'sharedContactRole'),
            eventStart: any(named: 'eventStart'),
            eventLocation: any(named: 'eventLocation'),
          ),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(ConversationOpened('c1', user));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ConversationMessageSendRequested(content: 'hello'));
      },
      verify: (bloc) {
        expect(bloc.state.sendStatus, ConversationSendStatus.idle);
        verify(
          () => repository.sendMessage(
            conversationId: 'c1',
            sender: user,
            content: 'hello',
            type: any(named: 'type'),
            fileName: any(named: 'fileName'),
            fileSize: any(named: 'fileSize'),
            mediaUrl: any(named: 'mediaUrl'),
            replyTo: any(named: 'replyTo'),
            pollOptions: any(named: 'pollOptions'),
            audioDuration: any(named: 'audioDuration'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            sharedContactId: any(named: 'sharedContactId'),
            sharedContactRole: any(named: 'sharedContactRole'),
            eventStart: any(named: 'eventStart'),
            eventLocation: any(named: 'eventLocation'),
          ),
        ).called(1);
      },
    );
  });

  group('MoreHistoryRequested', () {
    blocTest<ConversationBloc, ConversationState>(
      'widens the message limit and resubscribes only when the page is full',
      setUp: () {
        when(
          () => repository.watchConversation('c1', 'u1'),
        ).thenAnswer((_) => Stream.value(openConversation()));
        when(() => repository.markConversationRead(any(), any())).thenAnswer(
          (_) async {},
        );
        when(() => repository.watchMessages('c1', 'u1', limit: 60)).thenAnswer(
          (_) => Stream.value(
            List.generate(
              60,
              (i) => ChatMessage(
                id: 'm$i',
                senderId: 'u1',
                senderName: 'User',
                content: 'msg $i',
                timestamp: DateTime(2026, 1, 1),
              ),
            ),
          ),
        );
        when(
          () => repository.watchMessages('c1', 'u1', limit: 120),
        ).thenAnswer((_) => Stream.value(const []));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(ConversationOpened('c1', user));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const MoreHistoryRequested());
      },
      verify: (bloc) {
        expect(bloc.state.messageLimit, 120);
        verify(() => repository.watchMessages('c1', 'u1', limit: 120)).called(1);
      },
    );
  });

  group('attachment upload', () {
    late File tempFile;

    setUp(() {
      tempFile = File(
        '${Directory.systemTemp.path}/conversation_bloc_test_${DateTime.now().microsecondsSinceEpoch}.jpg',
      )..writeAsBytesSync([1, 2, 3]);
    });

    tearDown(() {
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    blocTest<ConversationBloc, ConversationState>(
      'uploads then sends, tracking the uploading flag',
      setUp: () {
        when(
          () => repository.watchConversation('c1', 'u1'),
        ).thenAnswer((_) => Stream.value(openConversation()));
        when(
          () => repository.watchMessages('c1', 'u1', limit: 60),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.markConversationRead(any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => repository.uploadAttachment(
            schoolId: any(named: 'schoolId'),
            conversationId: any(named: 'conversationId'),
            file: any(named: 'file'),
            fileName: any(named: 'fileName'),
          ),
        ).thenAnswer((_) async => 'https://example.com/file.jpg');
        when(
          () => repository.sendMessage(
            conversationId: any(named: 'conversationId'),
            sender: any(named: 'sender'),
            content: any(named: 'content'),
            type: any(named: 'type'),
            fileName: any(named: 'fileName'),
            fileSize: any(named: 'fileSize'),
            mediaUrl: any(named: 'mediaUrl'),
            replyTo: any(named: 'replyTo'),
            pollOptions: any(named: 'pollOptions'),
            audioDuration: any(named: 'audioDuration'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            sharedContactId: any(named: 'sharedContactId'),
            sharedContactRole: any(named: 'sharedContactRole'),
            eventStart: any(named: 'eventStart'),
            eventLocation: any(named: 'eventLocation'),
          ),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(ConversationOpened('c1', user));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          ConversationAttachmentSendRequested(
            file: tempFile,
            fileName: 'test.jpg',
            type: MessageType.image,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
      },
      verify: (bloc) {
        expect(bloc.state.uploading, isFalse);
        verify(
          () => repository.uploadAttachment(
            schoolId: 's1',
            conversationId: 'c1',
            file: any(named: 'file'),
            fileName: 'test.jpg',
          ),
        ).called(1);
        verify(
          () => repository.sendMessage(
            conversationId: 'c1',
            sender: user,
            content: '',
            type: MessageType.image,
            fileName: 'test.jpg',
            fileSize: any(named: 'fileSize'),
            mediaUrl: 'https://example.com/file.jpg',
            replyTo: any(named: 'replyTo'),
            pollOptions: any(named: 'pollOptions'),
            audioDuration: any(named: 'audioDuration'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            sharedContactId: any(named: 'sharedContactId'),
            sharedContactRole: any(named: 'sharedContactRole'),
            eventStart: any(named: 'eventStart'),
            eventLocation: any(named: 'eventLocation'),
          ),
        ).called(1);
      },
    );
  });
}
