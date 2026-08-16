import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/domain/repositories/communication_repository.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_bloc.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_event.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_state.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class _Repository extends Mock implements CommunicationRepository {}

class _Permissions extends Mock implements PermissionEvaluator {}

class _CampaignFake extends Fake implements CommunicationCampaign {}

const _admin = UserEntity(
  id: 'admin-1',
  name: 'School Admin',
  email: 'admin@example.com',
  schoolId: 'school-a',
  roles: [UserRole.schoolAdmin],
);

const _teacher = UserEntity(
  id: 'teacher-1',
  name: 'Class Teacher',
  email: 'teacher@example.com',
  schoolId: 'school-a',
  roles: [UserRole.classTeacher],
);

CommunicationCampaign _campaign({
  CommunicationType type = CommunicationType.announcement,
}) {
  final now = DateTime(2026, 1, 1);
  return CommunicationCampaign(
    campaignId: 'campaign-1',
    schoolId: 'school-a',
    title: 'Closure notice',
    body: 'School is closed tomorrow.',
    communicationType: type,
    senderId: 'admin-1',
    senderNameSnapshot: 'School Admin',
    audienceDefinition: const NotificationAudience.school(),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_admin);
    registerFallbackValue(_CampaignFake());
  });

  late _Repository repository;
  late _Permissions permissions;

  setUp(() {
    repository = _Repository();
    permissions = _Permissions();
    when(
      () => repository.watchCampaigns(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchTemplates(any()),
    ).thenAnswer((_) => const Stream.empty());
  });

  CommunicationBloc buildBloc() => CommunicationBloc(
    repository: repository,
    permissionEvaluator: permissions,
  );

  group('saveDraft', () {
    blocTest<CommunicationBloc, CommunicationState>(
      'denies a create when the operator lacks communications.create',
      build: () {
        when(
          () => permissions.can(any(), any()),
        ).thenAnswer((_) async => const Right(false));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        SaveCommunicationDraftRequested(
          schoolId: 'school-a',
          campaign: _campaign(),
          operatorUser: _teacher,
        ),
      ),
      expect: () => [isA<CommunicationActionDenied>()],
      verify: (_) {
        verifyNever(
          () => repository.saveDraft(
            any(),
            any(),
            campaignId: any(named: 'campaignId'),
          ),
        );
      },
    );

    blocTest<CommunicationBloc, CommunicationState>(
      'saves a draft once communications.create is granted',
      build: () {
        when(
          () => permissions.can(any(), any()),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => repository.saveDraft(
            any(),
            any(),
            campaignId: any(named: 'campaignId'),
          ),
        ).thenAnswer((_) async => const Right('campaign-1'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        SaveCommunicationDraftRequested(
          schoolId: 'school-a',
          campaign: _campaign(),
          operatorUser: _admin,
        ),
      ),
      expect: () => [
        isA<CommunicationActionSuccess>().having(
          (s) => s.campaignId,
          'campaignId',
          'campaign-1',
        ),
      ],
    );
  });

  group('publish', () {
    blocTest<CommunicationBloc, CommunicationState>(
      'an emergency alert is gated on communications.send_emergency, not communications.publish',
      build: () {
        when(
          () => permissions.can(Permission.communicationsPublish, any()),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => permissions.can(Permission.communicationsSendEmergency, any()),
        ).thenAnswer((_) async => const Right(false));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        PublishCommunicationCampaignRequested(
          schoolId: 'school-a',
          campaignId: 'campaign-1',
          communicationType: CommunicationType.emergencyAlert,
          operatorUser: _admin,
        ),
      ),
      expect: () => [isA<CommunicationActionDenied>()],
      verify: (_) {
        verifyNever(() => repository.publish(any(), any()));
      },
    );

    blocTest<CommunicationBloc, CommunicationState>(
      'publishes once permitted',
      build: () {
        when(
          () => permissions.can(any(), any()),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => repository.publish(any(), any()),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        PublishCommunicationCampaignRequested(
          schoolId: 'school-a',
          campaignId: 'campaign-1',
          communicationType: CommunicationType.announcement,
          operatorUser: _admin,
        ),
      ),
      expect: () => [isA<CommunicationActionSuccess>()],
    );
  });

  group('cancel', () {
    blocTest<CommunicationBloc, CommunicationState>(
      'surfaces a repository failure as CommunicationError',
      build: () {
        when(
          () => permissions.can(any(), any()),
        ).thenAnswer((_) async => const Right(true));
        when(() => repository.cancel(any(), any())).thenAnswer(
          (_) async => const Left(
            ValidationFailure(
              'Only scheduled communications can be cancelled.',
            ),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        CancelCommunicationCampaignRequested(
          schoolId: 'school-a',
          campaignId: 'campaign-1',
          operatorUser: _admin,
        ),
      ),
      expect: () => [
        isA<CommunicationError>().having(
          (s) => s.message,
          'message',
          'Only scheduled communications can be cancelled.',
        ),
      ],
    );
  });
}
