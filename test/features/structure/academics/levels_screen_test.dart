import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/levels_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

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
  testWidgets('renders empty-state hint when no levels exist', (
    tester,
  ) async {
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

  testWidgets('saving a valid level dispatches SaveLevelRequested', (
    tester,
  ) async {
    registerFallbackValue(
      const SaveLevelRequested(
        EducationalLevel(id: 'fallback', schoolId: 'school-1', name: 'x'),
      ),
    );
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
      () => structureBloc.add(
        any(that: isA<SaveLevelRequested>()),
      ),
    ).called(1);
  });
}
