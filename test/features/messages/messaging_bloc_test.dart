import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/app_role_session_service.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/domain/policies/messaging_permission_policy.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';

class MockMessagesRepository extends Mock implements MessagesRepository {}

class MockAppRoleSessionService extends Mock implements AppRoleSessionService {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const MessageContact(id: 'x', name: 'x', role: 'Parent'),
    );
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(ChatType.direct);
    registerFallbackValue(MessagePolicy.everyone);
  });

  late MockMessagesRepository repository;
  late MockAppRoleSessionService roleService;
  late AppRoleSessionCubit roleSession;

  final staffUser = UserEntity(
    id: 'staff1',
    name: 'Staff One',
    email: 'staff1@example.com',
    schoolId: 's1',
    roles: const [UserRole.subjectTeacher],
  );

  final adminUser = UserEntity(
    id: 'admin1',
    name: 'Admin',
    email: 'admin@example.com',
    schoolId: 's1',
    roles: const [UserRole.schoolAdmin],
  );

  final studentUser = UserEntity(
    id: 'stu1',
    name: 'Student One',
    email: 'stu1@example.com',
    schoolId: 's1',
    roles: const [UserRole.student],
    studentId: 'stu1',
  );

  setUp(() {
    repository = MockMessagesRepository();
    roleService = MockAppRoleSessionService();
    when(() => roleService.current).thenReturn(null);
    when(() => roleService.changes).thenAnswer((_) => const Stream.empty());
    roleSession = AppRoleSessionCubit(service: roleService);

    when(
      () => repository.watchConversations(any()),
    ).thenAnswer((_) => Stream.value(const []));
  });

  tearDown(() => roleSession.close());

  MessagingBloc buildBloc() =>
      MessagingBloc(repository: repository, roleSession: roleSession);

  group('MessagingStarted', () {
    blocTest<MessagingBloc, MessagingState>(
      'subscribes to watchConversations and aggregates unread count',
      setUp: () {
        when(() => repository.watchConversations('staff1')).thenAnswer(
          (_) => Stream.value([
            _conversation(id: 'c1', unreadCount: 2),
            _conversation(id: 'c2', unreadCount: 3),
            _conversation(id: 'c3', unreadCount: 5, isArchived: true),
          ]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(MessagingStarted(staffUser)),
      expect: () => [
        isA<MessagingState>().having((s) => s.user, 'user', staffUser),
        isA<MessagingState>()
            .having((s) => s.conversations?.length, 'conversations', 3)
            .having((s) => s.totalUnreadCount, 'totalUnreadCount', 5),
      ],
    );

    blocTest<MessagingBloc, MessagingState>(
      'does not resubscribe for the same user id',
      build: buildBloc,
      act: (bloc) {
        bloc.add(MessagingStarted(staffUser));
        bloc.add(MessagingStarted(staffUser));
      },
      verify: (_) {
        verify(() => repository.watchConversations('staff1')).called(1);
      },
    );
  });

  group('DirectConversationRequested', () {
    blocTest<MessagingBloc, MessagingState>(
      'refuses a student contacting a student when the school disallows it',
      build: buildBloc,
      act: (bloc) {
        bloc.add(MessagingStarted(studentUser));
        bloc.add(
          const DirectConversationRequested(
            MessageContact(id: 'stu2', name: 'Student Two', role: 'Student'),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.user, studentUser);
        expect(bloc.state.conversations, isEmpty);
        expect(bloc.state.actionStatus, MessagingActionStatus.failure);
        expect(
          bloc.state.lastDecision?.refusal,
          MessagingRefusal.studentToStudentDisallowed,
        );
        verifyNever(
          () => repository.startDirectConversation(
            me: any(named: 'me'),
            contact: any(named: 'contact'),
          ),
        );
      },
    );

    blocTest<MessagingBloc, MessagingState>(
      'starts a direct conversation when allowed',
      setUp: () {
        when(
          () => repository.startDirectConversation(
            me: any(named: 'me'),
            contact: any(named: 'contact'),
          ),
        ).thenAnswer((_) async => 'dm_conv_1');
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(MessagingStarted(staffUser));
        bloc.add(
          const DirectConversationRequested(
            MessageContact(
              id: 'admin1',
              name: 'Admin One',
              role: 'School Admin',
            ),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.actionStatus, MessagingActionStatus.success);
        expect(bloc.state.createdConversationId, 'dm_conv_1');
        verify(
          () => repository.startDirectConversation(
            me: any(named: 'me'),
            contact: any(named: 'contact'),
          ),
        ).called(1);
      },
    );
  });

  group('BroadcastRequested', () {
    blocTest<MessagingBloc, MessagingState>(
      'refuses a role not authorized for school-wide broadcast',
      build: buildBloc,
      act: (bloc) {
        bloc.add(MessagingStarted(staffUser));
        bloc.add(
          const BroadcastRequested(
            title: 'All Parents',
            recipients: [
              MessageContact(id: 'p1', name: 'Parent One', role: 'Parent'),
            ],
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.actionStatus, MessagingActionStatus.failure);
        expect(
          bloc.state.lastDecision?.refusal,
          MessagingRefusal.broadcastNotAuthorized,
        );
        verifyNever(
          () => repository.createConversation(
            me: any(named: 'me'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            members: any(named: 'members'),
          ),
        );
      },
    );

    blocTest<MessagingBloc, MessagingState>(
      'allows a school admin to broadcast',
      setUp: () {
        when(() => roleService.current).thenReturn(UserRole.schoolAdmin);
        when(
          () => repository.createConversation(
            me: any(named: 'me'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            members: any(named: 'members'),
            description: any(named: 'description'),
            avatarUrl: any(named: 'avatarUrl'),
            messagePolicy: any(named: 'messagePolicy'),
          ),
        ).thenAnswer((_) async => 'broadcast_1');
      },
      build: () {
        roleSession = AppRoleSessionCubit(service: roleService);
        return MessagingBloc(repository: repository, roleSession: roleSession);
      },
      act: (bloc) {
        bloc.add(MessagingStarted(adminUser));
        bloc.add(
          const BroadcastRequested(
            title: 'All Parents',
            recipients: [
              MessageContact(id: 'p1', name: 'Parent One', role: 'Parent'),
            ],
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.actionStatus, MessagingActionStatus.success);
        expect(bloc.state.createdConversationId, 'broadcast_1');
      },
    );
  });

  group('active role switching', () {
    blocTest<MessagingBloc, MessagingState>(
      'reflects a role change from the role session stream',
      build: () {
        when(
          () => roleService.changes,
        ).thenAnswer((_) => Stream.value(UserRole.boardingPatron));
        final freshSession = AppRoleSessionCubit(service: roleService);
        addTearDown(freshSession.close);
        return MessagingBloc(repository: repository, roleSession: freshSession);
      },
      expect: () => [
        isA<MessagingState>().having(
          (s) => s.activeRole,
          'activeRole',
          UserRole.boardingPatron,
        ),
      ],
    );
  });

  group('MessagingSessionCleared', () {
    blocTest<MessagingBloc, MessagingState>(
      'wipes the inbox and stops the subscription, so a new sign-in never '
      'sees a stale user\'s conversations',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(MessagingStarted(staffUser));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const MessagingSessionCleared());
      },
      verify: (bloc) {
        expect(bloc.state.user, isNull);
        expect(bloc.state.conversations, isNull);
      },
    );

    blocTest<MessagingBloc, MessagingState>(
      'allows a fresh MessagingStarted for a different user afterward',
      setUp: () {
        when(
          () => repository.watchConversations('staff1'),
        ).thenAnswer((_) => Stream.value(const []));
        when(() => repository.watchConversations('stu1')).thenAnswer(
          (_) => Stream.value([_conversation(id: 'c1', unreadCount: 1)]),
        );
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(MessagingStarted(staffUser));
        bloc.add(const MessagingSessionCleared());
        bloc.add(
          MessagingStarted(
            UserEntity(
              id: 'stu1',
              name: 'Student',
              email: 'stu1@example.com',
              schoolId: 's1',
              roles: const [UserRole.student],
            ),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.user?.id, 'stu1');
        expect(bloc.state.conversations?.length, 1);
      },
    );
  });
}

ChatConversation _conversation({
  required String id,
  int unreadCount = 0,
  bool isArchived = false,
}) {
  return ChatConversation(
    id: id,
    title: 'Chat $id',
    type: ChatType.direct,
    lastMessage: ChatMessage(
      id: 'm_$id',
      senderId: 'u1',
      senderName: 'User',
      content: 'hi',
      timestamp: DateTime(2026, 1, 1),
    ),
    unreadCount: unreadCount,
    participants: const [],
    schoolId: 's1',
    adminIds: const [],
    createdBy: 'u1',
    isArchived: isArchived,
  );
}
