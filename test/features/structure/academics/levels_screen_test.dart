import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/levels_screen.dart';

// GetIt.instance directly (not injection_container.dart's `di.sl`) - that
// file also imports the app router, which transitively pulls in every
// screen in the app, including ones mid-edit elsewhere in the repo.
final _sl = GetIt.instance;

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

class _MockStructureDependencyService extends Mock
    implements StructureDependencyService {}

class _FakeStructureEvent extends Fake implements StructureEvent {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [UserRole.schoolAdmin],
);

Widget _wrap(Widget child, {required StructureState structureState}) {
  final authBloc = _MockAuthBloc();
  final structureBloc = _MockStructureBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  when(() => structureBloc.state).thenReturn(structureState);
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StructureBloc>.value(value: structureBloc),
      ],
      child: child,
    ),
  );
}

void main() {
  late _MockStructureDependencyService dependencyService;

  setUpAll(() => registerFallbackValue(_FakeStructureEvent()));

  setUp(() {
    dependencyService = _MockStructureDependencyService();
    when(
      () => dependencyService.countAllStudents(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => dependencyService.countStudentsInLevel(any(), any()),
    ).thenAnswer((_) async => 0);
    when(
      () => dependencyService.countClassesInLevel(any(), any()),
    ).thenAnswer((_) async => 0);
    if (_sl.isRegistered<StructureDependencyService>()) {
      _sl.unregister<StructureDependencyService>();
    }
    _sl.registerSingleton<StructureDependencyService>(dependencyService);
  });

  tearDown(() {
    if (_sl.isRegistered<StructureDependencyService>()) {
      _sl.unregister<StructureDependencyService>();
    }
  });

  testWidgets('renders empty-state hint when no levels exist', (tester) async {
    await tester.pumpWidget(
      _wrap(const LevelsScreen(), structureState: const StructureState()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No educational levels yet'), findsOneWidget);
    expect(find.text('Add Level'), findsOneWidget);
  });

  testWidgets('renders a card for each level with its code', (tester) async {
    final state = StructureState(
      levels: const [
        EducationalLevel(
          id: 'l1',
          schoolId: 'school-1',
          name: 'Primary',
          code: 'PRI',
        ),
      ],
    );
    await tester.pumpWidget(_wrap(const LevelsScreen(), structureState: state));
    await tester.pumpAndSettle();

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('PRI'), findsOneWidget);
  });

  testWidgets('tapping Add Level opens the full-screen add form', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const LevelsScreen(), structureState: const StructureState()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Level'));
    await tester.pumpAndSettle();

    expect(find.text('Add Educational Level'), findsOneWidget);
    expect(find.text('Level Name *'), findsOneWidget);
    expect(find.text('Save Level'), findsOneWidget);
  });

  testWidgets(
    'saving a valid level dispatches SaveLevelRequested to the bloc',
    (tester) async {
      final structureBloc = _MockStructureBloc();
      final authBloc = _MockAuthBloc();
      when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
      when(() => structureBloc.state).thenReturn(const StructureState());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<StructureBloc>.value(value: structureBloc),
            ],
            child: const LevelsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Level'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Primary');
      await tester.enterText(fields.at(1), 'PRI');
      await tester.tap(find.text('Save Level'));
      await tester.pumpAndSettle();

      verify(
        () => structureBloc.add(any(that: isA<SaveLevelRequested>())),
      ).called(1);
    },
  );
}
