import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_record.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/cubit/parent_detail_cubit.dart';

class _MockRepo extends Mock implements ParentAccessRepository {}

ParentAccessRecord _record({
  ParentInviteStatus status = ParentInviteStatus.active,
  List<ParentLinkedLearner> learners = const [],
}) {
  return ParentAccessRecord(
    inviteId: 'inv-1',
    parentName: 'Naluwagga Sarah',
    phoneNumber: '+256712345678',
    email: 'sarah@example.com',
    status: status,
    invitationStatus: ParentInvitationDelivery.sent,
    maxGuardians: 2,
    learners: learners,
  );
}

ParentLinkedLearner _learner(String linkId, {String name = 'Akol Kevin'}) {
  return ParentLinkedLearner(
    linkId: linkId,
    studentId: 's-$linkId',
    studentName: name,
    className: 'S3',
    relationship: 'Mother',
    isPrimaryContact: true,
    linkStatus: 'active',
    linkType: 'initial',
  );
}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(
      () => repo.listParentLinkAudit(inviteId: any(named: 'inviteId')),
    ).thenAnswer((_) async => const Right([]));
  });

  ParentDetailCubit build() =>
      ParentDetailCubit(repository: repo, inviteId: 'inv-1');

  test('load populates the record and then the audit list', () async {
    when(
      () => repo.getParentAccessRecord(inviteId: 'inv-1'),
    ).thenAnswer((_) async => Right(_record()));
    when(() => repo.listParentLinkAudit(inviteId: 'inv-1')).thenAnswer(
      (_) async => Right([
        const ParentLinkAuditEntry(
          id: 'a1',
          action: 'reallocated',
          actorRole: 'schoolAdmin',
          studentId: 's1',
          reason: 'custody change',
        ),
      ]),
    );

    final cubit = build();
    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.record!.parentName, 'Naluwagga Sarah');
    // audit loads on a follow-up microtask
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.audit, hasLength(1));
  });

  test('a permission-denied load surfaces isPermissionDenied', () async {
    when(
      () => repo.getParentAccessRecord(inviteId: 'inv-1'),
    ).thenAnswer((_) async => const Left(PermissionDeniedFailure('nope')));
    final cubit = build();
    await cubit.load();
    expect(cubit.state.isPermissionDenied, isTrue);
    expect(cubit.state.record, isNull);
  });

  test('an offline load surfaces isOffline + retry re-fetches', () async {
    var calls = 0;
    when(() => repo.getParentAccessRecord(inviteId: 'inv-1')).thenAnswer((
      _,
    ) async {
      calls++;
      return calls == 1
          ? const Left(NetworkFailure('offline'))
          : Right(_record());
    });
    final cubit = build();
    await cubit.load();
    expect(cubit.state.isOffline, isTrue);
    await cubit.retry();
    expect(cubit.state.record, isNotNull);
    expect(calls, 2);
  });

  test('resendInvitation surfaces success + reloads', () async {
    when(
      () => repo.getParentAccessRecord(inviteId: 'inv-1'),
    ).thenAnswer((_) async => Right(_record()));
    when(
      () => repo.resendParentInvitation(inviteId: 'inv-1'),
    ).thenAnswer((_) async => const Right(null));

    final cubit = build();
    await cubit.load();
    final ok = await cubit.resendInvitation();
    expect(ok, isTrue);
    expect(cubit.state.actionSuccess, 'Invitation sent.');
    verify(() => repo.getParentAccessRecord(inviteId: 'inv-1')).called(2);
  });

  test('resendInvitation failure surfaces actionError, no reload', () async {
    when(
      () => repo.getParentAccessRecord(inviteId: 'inv-1'),
    ).thenAnswer((_) async => Right(_record()));
    when(() => repo.resendParentInvitation(inviteId: 'inv-1')).thenAnswer(
      (_) async => const Left(ServerFailure('Please wait before resending.')),
    );

    final cubit = build();
    await cubit.load();
    final ok = await cubit.resendInvitation();
    expect(ok, isFalse);
    expect(cubit.state.actionError, contains('wait'));
  });

  test('unlinkLearner calls reallocateParentLink in removal mode', () async {
    when(
      () => repo.getParentAccessRecord(inviteId: 'inv-1'),
    ).thenAnswer((_) async => Right(_record(learners: [_learner('l1')])));
    when(
      () => repo.reallocateParentLink(
        linkId: any(named: 'linkId'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final cubit = build();
    await cubit.load();
    final ok = await cubit.unlinkLearner(
      linkId: 'l1',
      reason: 'custody transfer',
    );
    expect(ok, isTrue);
    verify(
      () => repo.reallocateParentLink(linkId: 'l1', reason: 'custody transfer'),
    ).called(1);
  });

  test('updateDetails passes only the changed fields', () async {
    when(
      () => repo.getParentAccessRecord(inviteId: 'inv-1'),
    ).thenAnswer((_) async => Right(_record()));
    when(
      () => repo.updateParentDetails(
        inviteId: any(named: 'inviteId'),
        parentName: any(named: 'parentName'),
        phoneNumber: any(named: 'phoneNumber'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final cubit = build();
    await cubit.load();
    await cubit.updateDetails(parentName: 'New Name');
    verify(
      () => repo.updateParentDetails(
        inviteId: 'inv-1',
        parentName: 'New Name',
        phoneNumber: null,
        email: null,
      ),
    ).called(1);
  });
}
