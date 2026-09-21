import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/add_staff_wizard_controller.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/steps/stage_05_review.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Constructing the real AuthBloc needs its full usecase/repository
/// dependency graph, unrelated to what Stage05Review actually reads from it
/// (just `state.user.roles`) - mirrors the MockAuthBloc pattern already used
/// in test/admin_quick_add_sheet_test.dart.
class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

UserEntity _adminUser(List<UserRole> roles) => UserEntity(
  id: 'admin-1',
  name: 'Admin',
  email: 'admin@example.com',
  schoolId: 'school-1',
  roles: roles,
);

/// Never actually invoked in these tests (the checkbox/RBAC gate is
/// exercised without tapping submit), but AddStaffWizardController.submit()
/// resolves `di.sl<CreateStaffAccount>` eagerly if reached.
class _StubAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, String>> createStaffAccount({
    required String name,
    required String email,
    required String schoolId,
    required List<UserRole> roles,
    String? signInMethod,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
    String? idempotencyKey,
    bool sendLoginDetailsViaEmail = false,
    Map<String, dynamic>? staffData,
    Map<String, dynamic>? roleConfigs,
  }) async {
    return const Right('SMAC000001');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

Future<void> _pump(
  WidgetTester tester, {
  required AddStaffWizardController controller,
  required List<UserRole> adminRoles,
}) async {
  final authBloc = _MockAuthBloc();
  when(
    () => authBloc.state,
  ).thenReturn(AuthAuthenticated(_adminUser(adminRoles)));
  when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

  await tester.pumpWidget(
    MaterialApp(
      home: MultiProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          ChangeNotifierProvider<AddStaffWizardController>.value(
            value: controller,
          ),
        ],
        child: Scaffold(body: Stage05Review(onSaveDraft: () {})),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AddStaffWizardController controller;

  setUp(() {
    controller = AddStaffWizardController(
      schoolId: 'school-1',
      adminUid: 'admin-1',
    );
    controller.draft
      ..firstName = 'Jane'
      ..lastName = 'Doe'
      ..email = 'jane.doe@example.com'
      ..phoneNumber = '0700000000'
      ..employmentType = 'Permanent'
      ..campusId = 'campus-1'
      ..departmentId = 'dept-1'
      ..designationId = 'desig-1'
      ..selectedRoles.add(UserRole.bursar);
  });

  tearDown(() {
    if (di.sl.isRegistered<AuthRepository>()) {
      di.sl.unregister<AuthRepository>();
    }
  });

  testWidgets('renders all five review rows with their summaries', (
    tester,
  ) async {
    await _pump(
      tester,
      controller: controller,
      adminRoles: [UserRole.schoolAdmin],
    );

    // "Profile" also appears in the wizard's stage stepper header, so this
    // row title is expected twice.
    expect(find.text('Profile'), findsNWidgets(2));
    expect(find.text('Work details'), findsOneWidget);
    expect(find.text('Roles & responsibilities'), findsOneWidget);
    expect(find.text('Account access'), findsOneWidget);
    expect(find.text('Compensation'), findsOneWidget);
    expect(
      find.text('Secure invitation will be sent to jane.doe@example.com'),
      findsOneWidget,
    );
    expect(
      find.textContaining('completed later by HR & Finance'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Edit on a row routes back to the matching stage', (
    tester,
  ) async {
    await _pump(
      tester,
      controller: controller,
      adminRoles: [UserRole.schoolAdmin],
    );

    final workRow = find.ancestor(
      of: find.text('Work details'),
      matching: find.byType(InkWell),
    );
    await tester.tap(workRow.first);
    await tester.pumpAndSettle();

    expect(controller.stage, WizardStage.work);
  });

  testWidgets(
    'submit stays disabled until the confirmation checkbox is checked',
    (tester) async {
      di.sl.registerLazySingleton<AuthRepository>(() => _StubAuthRepository());

      await _pump(
        tester,
        controller: controller,
        adminRoles: [UserRole.schoolAdmin],
      );

      Finder submitButton() =>
          find.widgetWithText(FilledButton, 'Create staff & send invitation');

      expect(tester.widget<FilledButton>(submitButton()).onPressed, isNull);

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(tester.widget<FilledButton>(submitButton()).onPressed, isNotNull);
    },
  );

  testWidgets('shows the RBAC-blocked banner when the admin cannot submit', (
    tester,
  ) async {
    await _pump(
      tester,
      controller: controller,
      adminRoles: [UserRole.deputyHead],
    );

    expect(find.text('You cannot finalize this yourself'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(
      FilledButton,
      'Create staff & send invitation',
    );
    expect(tester.widget<FilledButton>(submitButton).onPressed, isNull);
  });
}
