import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/role_assignment_cubit.dart';
import 'package:school_pulse/features/structure/presentation/bloc/role_assignment_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';

class _MockRepository extends Mock implements StaffAssignmentRepository {}

class _MockAuditRepository extends Mock implements AuditRepository {}

class _MockNotificationSendService extends Mock
    implements NotificationSendService {}

void main() {
  late _MockRepository repository;
  late _MockAuditRepository auditRepository;
  late _MockNotificationSendService notificationSender;
  late RoleAssignmentCubit cubit;

  const actor = UserEntity(
    id: 'admin-1',
    name: 'Admin',
    email: 'admin@school.test',
    schoolId: 'school-1',
    roles: [UserRole.schoolAdmin],
  );

  const role = StaffDesignation(
    id: 'role-1',
    schoolId: 'school-1',
    name: 'Class Teacher',
    iconName: 'badge_outlined',
    colorHex: '#6366F1',
  );

  StaffRoleAssignment assignment({
    String id = 'assignment-1',
    AssignmentStatus status = AssignmentStatus.active,
  }) {
    return StaffRoleAssignment(
      id: id,
      schoolId: 'school-1',
      staffId: 'staff-1',
      userId: 'user-1',
      roleDefinitionId: 'role-1',
      roleType: StaffResponsibilityType.classTeacher,
      academicYearId: '2026',
      className: 'S2',
      streamName: 'Blue',
      startDate: DateTime(2026),
      status: status,
      assignedAt: DateTime(2026),
    );
  }

  setUpAll(() {
    registerFallbackValue(
      StaffRoleAssignment(
        id: '',
        schoolId: 'school-1',
        staffId: 'staff-1',
        userId: 'user-1',
        roleType: StaffResponsibilityType.other,
        academicYearId: '2026',
        startDate: DateTime(2026),
        assignedAt: DateTime(2026),
      ),
    );
    registerFallbackValue(actor);
    registerFallbackValue(
      const NotificationAudience(kind: NotificationAudienceKind.users),
    );
    registerFallbackValue(NotificationCategory.others);
    registerFallbackValue(NotificationType.custom);
  });

  setUp(() {
    repository = _MockRepository();
    auditRepository = _MockAuditRepository();
    notificationSender = _MockNotificationSendService();
    cubit = RoleAssignmentCubit(
      repository: repository,
      auditRepository: auditRepository,
      notificationSender: notificationSender,
    );

    when(
      () => auditRepository.logAction(
        schoolId: any(named: 'schoolId'),
        title: any(named: 'title'),
        description: any(named: 'description'),
        iconName: any(named: 'iconName'),
        colorHex: any(named: 'colorHex'),
        userId: any(named: 'userId'),
        relatedEntityId: any(named: 'relatedEntityId'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => notificationSender.send(
        sender: any(named: 'sender'),
        audience: any(named: 'audience'),
        category: any(named: 'category'),
        type: any(named: 'type'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        sourceModule: any(named: 'sourceModule'),
        sourceEntityId: any(named: 'sourceEntityId'),
      ),
    ).thenAnswer((_) async => const Right('request-1'));
  });

  group('assign', () {
    test(
      'creates the assignment, logs a non-empty schoolId, and notifies the staff member',
      () async {
        cubit.emit(const RoleAssignmentLoaded([]));
        final created = assignment();
        when(
          () => repository.createAssignment(any()),
        ).thenAnswer((_) async => Right(created));

        final ok = await cubit.assign(draft: created, role: role, actor: actor);

        expect(ok, isTrue);
        expect(cubit.state, isA<RoleAssignmentLoaded>());
        final loaded = cubit.state as RoleAssignmentLoaded;
        expect(loaded.assignments, [created]);
        expect(loaded.isMutating, isFalse);

        final captured = verify(
          () => auditRepository.logAction(
            schoolId: captureAny(named: 'schoolId'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            iconName: any(named: 'iconName'),
            colorHex: any(named: 'colorHex'),
            userId: any(named: 'userId'),
            relatedEntityId: any(named: 'relatedEntityId'),
          ),
        ).captured;
        expect(captured.single, isNotEmpty);

        verify(
          () => notificationSender.send(
            sender: actor,
            audience: any(named: 'audience'),
            category: any(named: 'category'),
            type: any(named: 'type'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            sourceModule: 'structure',
            sourceEntityId: created.id,
          ),
        ).called(1);
      },
    );

    test('surfaces a failure without logging or notifying', () async {
      when(
        () => repository.createAssignment(any()),
      ).thenAnswer((_) async => const Left(NetworkFailure('offline')));

      final ok = await cubit.assign(
        draft: assignment(),
        role: role,
        actor: actor,
      );

      expect(ok, isFalse);
      expect(cubit.state, isA<RoleAssignmentError>());
      verifyNever(
        () => auditRepository.logAction(
          schoolId: any(named: 'schoolId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          iconName: any(named: 'iconName'),
          colorHex: any(named: 'colorHex'),
        ),
      );
    });
  });

  group('endAssignment', () {
    test('marks the assignment removed and logs it', () async {
      final active = assignment();
      cubit.emit(RoleAssignmentLoaded([active]));

      when(
        () => repository.endAssignment(
          schoolId: any(named: 'schoolId'),
          assignmentId: any(named: 'assignmentId'),
          endedBy: any(named: 'endedBy'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final ok = await cubit.endAssignment(
        assignment: active,
        role: role,
        actor: actor,
      );

      expect(ok, isTrue);
      final loaded = cubit.state as RoleAssignmentLoaded;
      expect(loaded.assignments.single.status, AssignmentStatus.removed);
      expect(loaded.assignments.single.endDate, isNotNull);
    });
  });
}
