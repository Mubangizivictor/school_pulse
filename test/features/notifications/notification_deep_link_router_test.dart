import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/routing/deep_link_router/notification_deep_link_router.dart';
import 'package:school_pulse/features/notifications/routing/deep_link_router/notification_destination.dart';

UserEntity _user({
  String id = 'user-1',
  String schoolId = 'school-1',
  List<UserRole> roles = const [UserRole.classTeacher],
  List<String> studentIds = const [],
  String? studentId,
}) {
  return UserEntity(
    id: id,
    name: 'Test User',
    email: 'test@example.com',
    schoolId: schoolId,
    roles: roles,
    studentIds: studentIds,
    studentId: studentId,
  );
}

NotificationItem _notification({
  String id = 'notif-1',
  String? schoolId = 'school-1',
  String? recipientUserId,
  NotificationType type = NotificationType.announcement,
  String? relatedStudentId,
  String? relatedConversationId,
  String? sourceEntityId,
  DateTime? expiresAt,
}) {
  return NotificationItem(
    id: id,
    title: 'Title',
    description: 'Body',
    senderName: 'Office',
    senderRole: 'Admin',
    timestamp: DateTime(2026, 8, 1),
    category: NotificationCategory.announcements,
    priority: NotificationPriority.medium,
    schoolId: schoolId,
    recipientUserId: recipientUserId,
    type: type,
    relatedStudentId: relatedStudentId,
    relatedConversationId: relatedConversationId,
    sourceEntityId: sourceEntityId,
    expiresAt: expiresAt,
  );
}

void main() {
  const router = NotificationDeepLinkRouter();

  group('authentication', () {
    test('refuses when no user is signed in', () async {
      final result = await router.resolve(
        notification: _notification(),
        user: null,
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.notAuthenticated);
    });
  });

  group('tenant isolation', () {
    test('refuses a notification from another school', () async {
      final result = await router.resolve(
        notification: _notification(schoolId: 'school-2'),
        user: _user(schoolId: 'school-1'),
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.wrongTenant);
    });

    test('refuses a notification addressed to a different user', () async {
      final result = await router.resolve(
        notification: _notification(recipientUserId: 'someone-else'),
        user: _user(id: 'user-1'),
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.wrongTenant);
    });

    test('allows a broadcast with no explicit recipient', () async {
      final result = await router.resolve(
        notification: _notification(recipientUserId: null),
        user: _user(),
      );

      expect(result.isAllowed, isTrue);
    });
  });

  group('parent student scoping', () {
    test('parent may open a report card for their own child', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.reportCardPublished,
          relatedStudentId: 'student-1',
        ),
        user: _user(roles: [UserRole.parent], studentIds: ['student-1']),
      );

      expect(result.isAllowed, isTrue);
      expect(result.destination!.route, '/parent/academics/report-card');
    });

    test('parent may not open a report card for another family', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.reportCardPublished,
          relatedStudentId: 'student-99',
        ),
        user: _user(roles: [UserRole.parent], studentIds: ['student-1']),
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.notPermitted);
    });

    test('parent may not open a fee statement for another family', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.feeReminder,
          relatedStudentId: 'student-99',
        ),
        user: _user(roles: [UserRole.parent], studentIds: ['student-1']),
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.notPermitted);
    });
  });

  group('sensitive destinations', () {
    test('a class teacher may not open a medical alert', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.medicalAlert,
          relatedStudentId: 'student-1',
        ),
        user: _user(roles: [UserRole.classTeacher]),
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.notPermitted);
    });

    test('the nurse may open a medical alert', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.medicalAlert,
          relatedStudentId: 'student-1',
        ),
        user: _user(roles: [UserRole.nurse]),
      );

      expect(result.isAllowed, isTrue);
      expect(result.destination!.route, '/staff/nurse');
    });

    test('a parent may open their own child medical alert', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.medicalAlert,
          relatedStudentId: 'student-1',
        ),
        user: _user(roles: [UserRole.parent], studentIds: ['student-1']),
      );

      expect(result.isAllowed, isTrue);
      expect(result.destination!.route, '/parent/health');
    });

    test('a gatekeeper may not open a visitor record as a teacher', () async {
      final result = await router.resolve(
        notification: _notification(type: NotificationType.visitorArrived),
        user: _user(roles: [UserRole.subjectTeacher]),
      );

      expect(result.isAllowed, isFalse);
    });
  });

  group('messaging', () {
    test(
      'routes to the conversation using the related conversation id',
      () async {
        final result = await router.resolve(
          notification: _notification(
            type: NotificationType.newMessage,
            relatedConversationId: 'chat-42',
            recipientUserId: 'user-1',
          ),
          user: _user(id: 'user-1'),
        );

        expect(result.isAllowed, isTrue);
        expect(result.destination!.route, '/messages/chat/chat-42');
      },
    );

    test(
      'falls back to the details screen when no conversation id exists',
      () async {
        final result = await router.resolve(
          notification: _notification(
            type: NotificationType.newMessage,
            recipientUserId: 'user-1',
          ),
          user: _user(id: 'user-1'),
        );

        expect(result.isAllowed, isTrue);
        expect(
          result.destination!.kind,
          NotificationDestinationKind.notificationDetails,
        );
      },
    );
  });

  group('expiry and missing targets', () {
    test(
      'an expired notification still opens its own details screen',
      () async {
        final result = await router.resolve(
          notification: _notification(
            type: NotificationType.reportCardPublished,
            relatedStudentId: 'student-1',
            expiresAt: DateTime(2020, 1, 1),
          ),
          user: _user(roles: [UserRole.parent], studentIds: ['student-1']),
        );

        expect(result.isAllowed, isTrue);
        expect(
          result.destination!.kind,
          NotificationDestinationKind.notificationDetails,
        );
      },
    );

    test('refuses when the target record no longer exists', () async {
      final result = await router.resolve(
        notification: _notification(
          type: NotificationType.reportCardPublished,
          relatedStudentId: 'student-1',
          sourceEntityId: 'report-1',
        ),
        user: _user(roles: [UserRole.parent], studentIds: ['student-1']),
        targetExists: (kind, id) async => false,
      );

      expect(result.isAllowed, isFalse);
      expect(result.refusal, DeepLinkRefusal.targetMissing);
    });
  });

  group('side selection', () {
    test('staff land on the staff side of the app', () async {
      final result = await router.resolve(
        notification: _notification(type: NotificationType.feeReminder),
        user: _user(roles: [UserRole.bursar]),
      );

      expect(result.destination!.route, startsWith('/staff'));
    });

    test('students land on the parent-side shell', () async {
      final result = await router.resolve(
        notification: _notification(type: NotificationType.announcement),
        user: _user(roles: [UserRole.student], studentId: 'student-1'),
      );

      expect(result.destination!.route, startsWith('/parent'));
    });
  });

  group('PendingDeepLink', () {
    setUp(PendingDeepLink.clear);

    test('stashes and replays a link exactly once', () {
      final notification = _notification(id: 'pending-1');
      PendingDeepLink.stash(notification);

      expect(PendingDeepLink.hasPending, isTrue);
      expect(PendingDeepLink.consume()?.id, 'pending-1');
      expect(PendingDeepLink.hasPending, isFalse);
      expect(PendingDeepLink.consume(), isNull);
    });

    test('does not re-stash a link that was already consumed', () {
      final notification = _notification(id: 'pending-1');
      PendingDeepLink.stash(notification);
      PendingDeepLink.consume();

      PendingDeepLink.stash(notification);

      expect(PendingDeepLink.hasPending, isFalse);
    });
  });
}
