import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/data/models/parent_access_invite_model.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/cubit/parents_access_cubit.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/cubit/parents_access_state.dart';

class MockParentAccessRepository extends Mock implements ParentAccessRepository {}

void main() {
  late MockParentAccessRepository repository;
  late ParentsAccessCubit cubit;

  final invites = [
    // Active code, parent has completed sign-up -> a linked parent.
    const ParentAccessInvite(
      inviteId: 'inv-1',
      parentName: 'Amanda Carter',
      maskedPhone: '***1234',
      learnerCount: 2,
      status: ParentInviteStatus.active,
      invitationStatus: ParentInvitationDelivery.accepted,
    ),
    // Active code, parent has NOT signed up yet -> pending acceptance.
    const ParentAccessInvite(
      inviteId: 'inv-4',
      parentName: 'Priya Nair',
      maskedPhone: '***5555',
      learnerCount: 1,
      status: ParentInviteStatus.active,
      invitationStatus: ParentInvitationDelivery.sent,
    ),
    const ParentAccessInvite(
      inviteId: 'inv-2',
      parentName: 'Sarah Lee',
      maskedPhone: '***9012',
      learnerCount: 2,
      status: ParentInviteStatus.active,
      expiringSoon: true,
    ),
    const ParentAccessInvite(
      inviteId: 'inv-3',
      parentName: 'Brian Roberts',
      maskedPhone: '***2468',
      learnerCount: 1,
      status: ParentInviteStatus.revoked,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(
      const ParentAccessInvitesPage(
        rows: [],
        nextCursor: null,
        pendingCount: 0,
        expiringSoonCount: 0,
      ),
    );
  });

  setUp(() {
    repository = MockParentAccessRepository();
    cubit = ParentsAccessCubit(repository: repository);
  });

  ParentAccessInvitesPage page({
    List<ParentAccessInvite> rows = const [],
    String? nextCursor,
    int pendingCount = 0,
    int expiringSoonCount = 0,
  }) {
    return ParentAccessInvitesPage(
      rows: rows,
      nextCursor: nextCursor,
      pendingCount: pendingCount,
      expiringSoonCount: expiringSoonCount,
    );
  }

  group('loadFirstPage', () {
    test('emits loaded rows and counts on success', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer(
        (_) async => Right(page(rows: invites, pendingCount: 2, expiringSoonCount: 1)),
      );

      await cubit.loadFirstPage();

      expect(cubit.state.invites, invites);
      expect(cubit.state.pendingCount, 2);
      expect(cubit.state.expiringSoonCount, 1);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.errorMessage, isNull);
    });

    test('surfaces failure as errorMessage, not a raw exception', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => const Left(ServerFailure('Could not load parent access codes.')));

      await cubit.loadFirstPage();

      expect(cubit.state.errorMessage, 'Could not load parent access codes.');
      expect(cubit.state.invites, isEmpty);
    });

    test('marks isOffline true for NetworkFailure', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => const Left(NetworkFailure('No internet connection.')));

      await cubit.loadFirstPage();

      expect(cubit.state.isOffline, true);
    });

    test('marks isPermissionDenied true for PermissionDeniedFailure', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => const Left(PermissionDeniedFailure('nope')));

      await cubit.loadFirstPage();

      expect(cubit.state.isPermissionDenied, true);
    });
  });

  group('pagination', () {
    test('loadNextPage appends rows and advances cursor', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => Right(page(rows: [invites[0]], nextCursor: 'inv-1')));
      await cubit.loadFirstPage();

      when(
        () => repository.listParentAccessInvites(
          pageSize: any(named: 'pageSize'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => Right(page(rows: [invites[1]], nextCursor: null)));
      await cubit.loadNextPage();

      expect(cubit.state.invites, [invites[0], invites[1]]);
      expect(cubit.state.nextCursor, isNull);
    });

    test('loadNextPage is a no-op when there is no cursor', () async {
      await cubit.loadNextPage();
      verifyNever(
        () => repository.listParentAccessInvites(
          pageSize: any(named: 'pageSize'),
          cursor: any(named: 'cursor'),
        ),
      );
    });
  });

  group('search + filter', () {
    setUp(() async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => Right(page(rows: invites)));
      await cubit.loadFirstPage();
    });

    test('search filters by parent name', () {
      cubit.setSearchQuery('amanda');
      expect(cubit.state.filteredRows.map((r) => r.inviteId), ['inv-1']);
    });

    test('search filters by masked phone', () {
      cubit.setSearchQuery('9012');
      expect(cubit.state.filteredRows.map((r) => r.inviteId), ['inv-2']);
    });

    test('filter=linked returns only accepted, non-expiring, active parents', () {
      cubit.setFilter(ParentsAccessFilter.linked);
      expect(cubit.state.filteredRows.map((r) => r.inviteId), ['inv-1']);
    });

    test('filter=pending returns active codes the parent has not accepted', () {
      cubit.setFilter(ParentsAccessFilter.pending);
      expect(
        cubit.state.filteredRows.map((r) => r.inviteId).toSet(),
        {'inv-4', 'inv-2'},
      );
    });

    test('filter=expiring only returns expiringSoon rows', () {
      cubit.setFilter(ParentsAccessFilter.expiring);
      expect(cubit.state.filteredRows.map((r) => r.inviteId), ['inv-2']);
    });

    test('filter=all returns every row', () {
      cubit.setFilter(ParentsAccessFilter.all);
      expect(cubit.state.filteredRows.length, 4);
    });
  });

  group('revoke', () {
    test('failed-precondition (two-parent max) surfaces as clean actionError', () async {
      when(
        () => repository.revokeParentAccessCode(inviteId: any(named: 'inviteId')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('A learner can have a maximum of two parents.')),
      );
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => Right(page()));

      final success = await cubit.revokeAccessCode('inv-1');

      expect(success, false);
      expect(cubit.state.actionError, 'A learner can have a maximum of two parents.');
    });

    test('success clears actionInFlight and reloads', () async {
      when(
        () => repository.revokeParentAccessCode(inviteId: any(named: 'inviteId')),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => Right(page(rows: invites)));

      final success = await cubit.revokeAccessCode('inv-1');

      expect(success, true);
      expect(cubit.state.actionInFlight, false);
      expect(cubit.state.actionSuccessMessage, isNotNull);
    });
  });

  group('reallocate permission denial', () {
    test('permission-denied failure is handled gracefully, not thrown', () async {
      when(
        () => repository.reallocateParentLink(
          linkId: any(named: 'linkId'),
          parentName: any(named: 'parentName'),
          phoneNumber: any(named: 'phoneNumber'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          PermissionDeniedFailure('Only a school admin may reallocate an existing parent link.'),
        ),
      );

      final success = await cubit.reallocateLink(linkId: 'inv-1', reason: 'test');

      expect(success, false);
      expect(cubit.state.actionError, contains('school admin'));
    });
  });

  group('masking / tenant isolation', () {
    test('state never carries anything but the pre-masked phone from the repository', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => Right(page(rows: invites)));
      await cubit.loadFirstPage();

      for (final invite in cubit.state.invites) {
        expect(invite.maskedPhone, startsWith('***'));
        expect(invite.maskedPhone.replaceAll('*', '').length, lessThanOrEqualTo(4));
      }
    });

    test('listParentAccessInvites is always called with no client-supplied schoolId', () async {
      when(
        () => repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
      ).thenAnswer((_) async => Right(page()));

      await cubit.loadFirstPage();

      final captured = verify(
        () => repository.listParentAccessInvites(pageSize: captureAny(named: 'pageSize')),
      ).captured;
      expect(captured.single, ParentsAccessCubit.pageSize);
      // The repository interface has no schoolId parameter at all - tenant
      // scoping happens server-side from the authenticated user, never from
      // client state (see functions/index.js listParentAccessInvites).
    });
  });
}
