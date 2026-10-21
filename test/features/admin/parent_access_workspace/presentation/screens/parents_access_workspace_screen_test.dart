import 'dart:ui' as ui;

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/data/models/parent_access_invite_model.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/cubit/parents_access_cubit.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/screens/parents_access_workspace_screen.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/widgets/filter_bottom_sheet.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockParentAccessRepository extends Mock
    implements ParentAccessRepository {}

/// ParentsAccessWorkspaceScreen resolves its Cubit from the real DI
/// container internally (matching how the app wires it in production via
/// injection_container.dart), so these tests register a mock repository
/// directly into `di.sl` rather than trying to inject a Cubit through a
/// BlocProvider the screen never reads from.
void main() {
  late MockAuthBloc authBloc;
  late MockParentAccessRepository repository;

  final invites = List.generate(
    5,
    (i) => ParentAccessInvite(
      inviteId: 'inv-$i',
      parentName: 'Parent $i',
      maskedPhone: '***${1000 + i}',
      learnerCount: 1,
      status: ParentInviteStatus.active,
    ),
  );

  final user = const UserEntity(
    id: 'admin-1',
    name: 'Test Admin',
    email: 'admin@example.com',
    schoolId: 'school-1',
    roles: [UserRole.schoolAdmin],
  );

  setUpAll(() {
    registerFallbackValue(AuthCheckRequested());
  });

  setUp(() async {
    authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      Stream<AuthState>.empty(),
      initialState: AuthAuthenticated(user),
    );

    repository = MockParentAccessRepository();
    when(
      () =>
          repository.listParentAccessInvites(pageSize: any(named: 'pageSize')),
    ).thenAnswer(
      (_) async => Right(
        ParentAccessInvitesPage(
          rows: invites,
          nextCursor: null,
          pendingCount: 3,
          expiringSoonCount: 1,
        ),
      ),
    );

    if (di.sl.isRegistered<ParentAccessRepository>()) {
      di.sl.unregister<ParentAccessRepository>();
    }
    if (di.sl.isRegistered<ParentsAccessCubit>()) {
      di.sl.unregister<ParentsAccessCubit>();
    }
    di.sl.registerLazySingleton<ParentAccessRepository>(() => repository);
    di.sl.registerFactory(() => ParentsAccessCubit(repository: di.sl()));
  });

  Widget buildAt() {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const MaterialApp(home: ParentsAccessWorkspaceScreen()),
    );
  }

  group('responsive tiers render without overflow', () {
    testWidgets(
      '390x844 (phone reference) shows TabBar + inline filter chips, no '
      'redundant app-bar leading/search/filter icons',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildAt());
        await tester.pumpAndSettle();

        expect(find.text('Parents & access'), findsOneWidget);
        expect(find.byType(ParentAccessFilterChips), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(
          find.byIcon(Icons.search),
          findsOneWidget,
          reason:
              'only the body search field icon should remain, not a '
              'second redundant app-bar search action',
        );
        expect(find.byIcon(Icons.filter_list), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('768x1024 (tablet reference) shows two-column grid', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildAt());
      await tester.pumpAndSettle();

      expect(find.text('Parents & access'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '1440x900 (desktop reference) shows side rail + table + attention panel',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildAt());
        await tester.pumpAndSettle();

        expect(find.text('Parents & access'), findsOneWidget);
        expect(find.text('Codes needing attention'), findsOneWidget);
        expect(find.byType(DataTable), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('states render distinctly', () {
    testWidgets(
      'permission-denied state shows its own message, not a generic error',
      (tester) async {
        when(
          () => repository.listParentAccessInvites(
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => const Left(PermissionDeniedFailure('nope')));

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildAt());
        await tester.pumpAndSettle();

        expect(find.text('You do not have permission'), findsOneWidget);
      },
    );

    testWidgets(
      'error state shows a message distinct from the permission-denied one',
      (tester) async {
        when(
          () => repository.listParentAccessInvites(
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Could not load parent access codes.')),
        );

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildAt());
        await tester.pumpAndSettle();

        expect(find.text('Could not load parents'), findsOneWidget);
        expect(find.text('You do not have permission'), findsNothing);
      },
    );
  });

  group('keyboard accessibility', () {
    testWidgets(
      'search field and add-parent button are reachable and labeled',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildAt());
        await tester.pumpAndSettle();

        expect(find.text('Add / link parent'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);

        final addButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Add / link parent',
        );
        final data = tester.getSemantics(addButtonFinder).getSemanticsData();
        expect(data.flagsCollection.isButton, true);
        expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), true);
      },
    );
  });
}
