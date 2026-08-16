import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  testWidgets('opens the notification centre when tapped', (tester) async {
    final authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthUnauthenticated());
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            appBar: AppBar(
              actions: const [
                NotificationBellButton(
                  key: Key('admin-dashboard-notifications-button'),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/staff/notifications',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Notification centre'))),
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('admin-dashboard-notifications-button')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('admin-dashboard-notifications-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notification centre'), findsOneWidget);
  });
}
