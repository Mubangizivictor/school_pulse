import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_quick_add_sheet.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

const _schoolId = 'test-school';

UserEntity _userWith(List<UserRole> roles) => UserEntity(
  id: 'staff-1',
  name: 'Staff Member',
  email: 'staff@school.test',
  roles: roles,
  schoolId: _schoolId,
);

Future<void> _openSheet(WidgetTester tester, AuthBloc authBloc) async {
  // BlocProvider must wrap MaterialApp, not just its `home` - a modal bottom
  // sheet attaches to the root Navigator, which sits above `home` in the
  // tree, so a provider scoped only inside `home` would not be visible to
  // it (this mirrors how the real app provides AuthBloc above its router).
  await tester.pumpWidget(
    BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdminQuickAddSheet.show(context),
              child: const Text('Open quick add'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open quick add'));
  await tester.pumpAndSettle();
}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
  });

  testWidgets(
    'shows every admin quick-add action for a schoolAdmin, who is server-verified to invite staff',
    (tester) async {
      when(
        () => authBloc.state,
      ).thenReturn(AuthAuthenticated(_userWith([UserRole.schoolAdmin])));
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await _openSheet(tester, authBloc);

      for (final label in const [
        'Add Staff',
        'Add Student',
        'Add Parent',
        'Create Announcement',
        'Create Appointment',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    },
  );

  testWidgets(
    'does not show Add Staff for Deputy Head, who shares the admin console UI but is not server-verified to invite staff',
    (tester) async {
      when(
        () => authBloc.state,
      ).thenReturn(AuthAuthenticated(_userWith([UserRole.deputyHead])));
      when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());

      await _openSheet(tester, authBloc);

      expect(find.text('Add Staff'), findsNothing);
      // Every other quick-add action deputyHead IS allowed to use must still
      // render - this isn't a blanket lockout of the sheet, just the one
      // action the Cloud Function rejects.
      for (final label in const [
        'Add Student',
        'Add Parent',
        'Create Announcement',
        'Create Appointment',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    },
  );
}
