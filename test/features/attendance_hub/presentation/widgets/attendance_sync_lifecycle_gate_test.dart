import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/attendance_repository.dart';
import 'package:school_pulse/features/attendance_hub/presentation/widgets/attendance_sync_lifecycle_gate.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class _MockAttendanceRepository extends Mock implements AttendanceRepository {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

class _MockAuthBloc extends Mock implements AuthBloc {}

const _user = UserEntity(
  id: 'staff-a',
  name: 'Teacher A',
  email: 't@school.test',
  roles: [UserRole.classTeacher],
  studentIds: [],
  schoolId: 'school-a',
  isActive: true,
  mustChangePassword: false,
  mfaEnabled: false,
);

void main() {
  late _MockAttendanceRepository repository;
  late _MockNetworkInfo networkInfo;
  late _MockAuthBloc authBloc;

  setUp(() {
    repository = _MockAttendanceRepository();
    networkInfo = _MockNetworkInfo();
    authBloc = _MockAuthBloc();
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(
      () => repository.syncPendingAttendance(any()),
    ).thenAnswer((_) async {});

    if (di.sl.isRegistered<AttendanceRepository>()) {
      di.sl.unregister<AttendanceRepository>();
    }
    if (di.sl.isRegistered<NetworkInfo>()) {
      di.sl.unregister<NetworkInfo>();
    }
    di.sl.registerSingleton<AttendanceRepository>(repository);
    di.sl.registerSingleton<NetworkInfo>(networkInfo);

    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => authBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    di.sl.unregister<AttendanceRepository>();
    di.sl.unregister<NetworkInfo>();
  });

  Widget buildSubject() => MaterialApp(
    home: BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const AttendanceSyncLifecycleGate(child: SizedBox.shrink()),
    ),
  );

  testWidgets('syncs pending attendance for the current tenant on app resume', (
    tester,
  ) async {
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));

    await tester.pumpWidget(buildSubject());
    final state = tester.state(find.byType(AttendanceSyncLifecycleGate));
    (state as WidgetsBindingObserver).didChangeAppLifecycleState(
      AppLifecycleState.resumed,
    );
    await tester.pump();

    verify(() => repository.syncPendingAttendance('school-a')).called(1);
  });

  testWidgets('does not sync when there is no authenticated user', (
    tester,
  ) async {
    when(() => authBloc.state).thenReturn(AuthUnauthenticated());

    await tester.pumpWidget(buildSubject());
    final state = tester.state(find.byType(AttendanceSyncLifecycleGate));
    (state as WidgetsBindingObserver).didChangeAppLifecycleState(
      AppLifecycleState.resumed,
    );
    await tester.pump();

    verifyNever(() => repository.syncPendingAttendance(any()));
  });

  testWidgets('a background/inactive transition does not trigger a sync', (
    tester,
  ) async {
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));

    await tester.pumpWidget(buildSubject());
    final state = tester.state(find.byType(AttendanceSyncLifecycleGate));
    (state as WidgetsBindingObserver).didChangeAppLifecycleState(
      AppLifecycleState.paused,
    );
    await tester.pump();

    verifyNever(() => repository.syncPendingAttendance(any()));
  });
}
