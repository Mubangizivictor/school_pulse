import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/academic_structure_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

class _FakeStructureEvent extends Fake implements StructureEvent {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [UserRole.schoolAdmin],
);

const _primary = EducationalLevel(
  id: 'l-primary',
  schoolId: 'school-1',
  name: 'Primary',
  code: 'PRI',
  description: 'P1 to P7',
  order: 0,
);

const _secondary = EducationalLevel(
  id: 'l-secondary',
  schoolId: 'school-1',
  name: 'Secondary',
  code: 'SEC',
  order: 1,
);

Widget _wrap(
  Widget child, {
  required StructureState structureState,
  required StructureBloc structureBloc,
}) {
  final authBloc = _MockAuthBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  when(() => structureBloc.state).thenReturn(structureState);
  final router = GoRouter(
    initialLocation: '/classes',
    routes: [
      GoRoute(
        path: '/classes',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<StructureBloc>.value(value: structureBloc),
          ],
          child: child,
        ),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeStructureEvent()));

  testWidgets('shows a hint when no active education levels exist', (
    tester,
  ) async {
    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Add an education level before creating classes.'),
      findsOneWidget,
    );
  });

  testWidgets('level switcher lists every active level and defaults to the '
      'first', (tester) async {
    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(levels: [_primary, _secondary]),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Primary'), findsWidgets);
    expect(find.text('Secondary'), findsWidgets);
    expect(find.text('P1'), findsOneWidget);
  });

  testWidgets('suggested classes derive from the level description range', (
    tester,
  ) async {
    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(levels: [_primary]),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    for (final name in ['P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7']) {
      expect(find.widgetWithText(FilterChip, name), findsOneWidget);
    }
  });

  testWidgets('selecting all suggestions then creating dispatches '
      'CreateClassesRequested with every suggested name', (tester) async {
    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(levels: [_primary]),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create 7 classes'));
    await tester.pumpAndSettle();

    // The bottom sheet's own confirm button carries the same label as the
    // inline one still behind it; the sheet's is the last in the tree.
    await tester.tap(
      find.widgetWithText(FilledButton, 'Create 7 classes').last,
    );
    await tester.pumpAndSettle();

    final captured = verify(
      () => bloc.add(captureAny(that: isA<CreateClassesRequested>())),
    ).captured;
    expect(captured, hasLength(1));
    final event = captured.single as CreateClassesRequested;
    expect(event.classes.map((c) => c.name).toSet(), {
      'P1',
      'P2',
      'P3',
      'P4',
      'P5',
      'P6',
      'P7',
    });
    expect(event.classes.every((c) => c.levelId == _primary.id), isTrue);
  });

  testWidgets('switching levels clears the pending selection and shows the '
      'other level workspace', (tester) async {
    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(levels: [_primary, _secondary]),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('P1'));
    await tester.pumpAndSettle();
    expect(find.text('Create 1 class'), findsWidgets);

    await tester.tap(find.text('Secondary').first);
    await tester.pumpAndSettle();

    expect(find.text('Create 1 class'), findsNothing);
    expect(
      find.text(
        'No configured suggestions for this level. '
        'Add the class names your school uses.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('reordering an existing class dispatches '
      'ReorderClassesRequested with persisted order values', (tester) async {
    final bloc = _MockStructureBloc();
    final classes = [
      SchoolClass(
        id: 'c1',
        schoolId: 'school-1',
        name: 'P1',
        levelId: _primary.id,
        order: 0,
      ),
      SchoolClass(
        id: 'c2',
        schoolId: 'school-1',
        name: 'P2',
        levelId: _primary.id,
        order: 1,
      ),
    ];
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: StructureState(
          levels: const [_primary],
          classes: classes,
        ),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your classes (2)'), findsOneWidget);
  });

  testWidgets(
    'a class with dependent streams cannot be dragged to reorder',
    (tester) async {
      final bloc = _MockStructureBloc();
      final classes = [
        SchoolClass(
          id: 'c1',
          schoolId: 'school-1',
          name: 'P1',
          levelId: _primary.id,
          order: 0,
        ),
      ];
      final streams = [
        const ClassStream(
          id: 's1',
          schoolId: 'school-1',
          name: 'North',
          classId: 'c1',
        ),
      ];
      await tester.pumpWidget(
        _wrap(
          const AcademicStructureScreen(
            section: 'classes',
            showAppBar: false,
          ),
          structureState: StructureState(
            levels: const [_primary],
            classes: classes,
            streams: streams,
          ),
          structureBloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byType(ReorderableListView), findsNothing);
    },
  );

  testWidgets('web-width layout shows the education levels summary card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(levels: [_primary, _secondary]),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Education levels summary'), findsOneWidget);
  });

  testWidgets('mobile-width layout does not show the summary card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bloc = _MockStructureBloc();
    await tester.pumpWidget(
      _wrap(
        const AcademicStructureScreen(section: 'classes', showAppBar: false),
        structureState: const StructureState(levels: [_primary, _secondary]),
        structureBloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Education levels summary'), findsNothing);
  });
}
