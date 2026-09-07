import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_invite.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/entities/parent_access_record.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/cubit/parent_detail_cubit.dart';
import 'package:school_pulse/features/admin/parent_access_workspace/presentation/screens/parent_detail_screen.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockRepo extends Mock implements ParentAccessRepository {}

ParentAccessRecord _record({
  ParentInviteStatus status = ParentInviteStatus.active,
  DateTime? canResendAt,
  List<ParentLinkedLearner> learners = const [],
}) {
  return ParentAccessRecord(
    inviteId: 'inv-1',
    parentName: 'Naluwagga Sarah',
    phoneNumber: '+256712345678',
    email: 'sarah@example.com',
    status: status,
    invitationStatus: ParentInvitationDelivery.sent,
    canResendAt: canResendAt,
    maxGuardians: 2,
    learners: learners,
  );
}

ParentLinkedLearner _learner(String linkId, {String name = 'Akol Kevin'}) =>
    ParentLinkedLearner(
      linkId: linkId,
      studentId: 's-$linkId',
      studentName: name,
      className: 'S3',
      relationship: 'Mother',
      isPrimaryContact: true,
      linkStatus: 'active',
      linkType: 'initial',
    );

void main() {
  late MockAuthBloc authBloc;
  late MockRepo repo;

  const user = UserEntity(
    id: 'admin-1',
    name: 'Admin',
    email: 'a@b.com',
    schoolId: 'school-1',
    roles: [UserRole.schoolAdmin],
  );

  setUpAll(() => registerFallbackValue(AuthCheckRequested()));

  setUp(() {
    authBloc = MockAuthBloc();
    whenListen(authBloc, const Stream<AuthState>.empty(),
        initialState: const AuthAuthenticated(user));

    repo = MockRepo();
    when(() => repo.listParentLinkAudit(inviteId: any(named: 'inviteId')))
        .thenAnswer((_) async => const Right([]));

    if (di.sl.isRegistered<ParentAccessRepository>()) {
      di.sl.unregister<ParentAccessRepository>();
    }
    di.sl.registerLazySingleton<ParentAccessRepository>(() => repo);
    if (!di.sl.isRegistered<ParentDetailCubit>()) {
      di.sl.registerFactoryParam<ParentDetailCubit, String, void>(
        (id, _) => ParentDetailCubit(repository: di.sl(), inviteId: id),
      );
    }
  });

  Widget host() => BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(
          home: ParentDetailScreen(inviteId: 'inv-1'),
        ),
      );

  testWidgets('renders guardian identity, masked phone, and learners',
      (tester) async {
    when(() => repo.getParentAccessRecord(inviteId: 'inv-1')).thenAnswer(
      (_) async => Right(_record(learners: [_learner('l1')])),
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('Naluwagga Sarah'), findsOneWidget);
    expect(find.text('***5678'), findsOneWidget);
    expect(find.text('Akol Kevin'), findsOneWidget);
    // email is masked, never shown in full
    expect(find.text('sarah@example.com'), findsNothing);
  });

  testWidgets('resend is disabled while the cooldown is active', (tester) async {
    when(() => repo.getParentAccessRecord(inviteId: 'inv-1')).thenAnswer(
      (_) async => Right(
        _record(canResendAt: DateTime.now().add(const Duration(minutes: 1))),
      ),
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    final resend = find.widgetWithText(OutlinedButton, 'Resend soon');
    expect(resend, findsOneWidget);
    expect(tester.widget<OutlinedButton>(resend).onPressed, isNull);
  });

  testWidgets('unlink dialog requires a reason before it enables Unlink',
      (tester) async {
    when(() => repo.getParentAccessRecord(inviteId: 'inv-1')).thenAnswer(
      (_) async => Right(_record(learners: [_learner('l1')])),
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.link_off));
    await tester.pumpAndSettle();

    expect(find.text('Unlink Akol Kevin?'), findsOneWidget);
    final unlinkBtn = find.widgetWithText(FilledButton, 'Unlink');
    expect(tester.widget<FilledButton>(unlinkBtn).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, 'custody transfer');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(unlinkBtn).onPressed, isNotNull);
  });

  testWidgets('a permission-denied load shows its own message', (tester) async {
    when(() => repo.getParentAccessRecord(inviteId: 'inv-1')).thenAnswer(
      (_) async => const Left(PermissionDeniedFailure('nope')),
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('You do not have permission'), findsOneWidget);
  });
}
