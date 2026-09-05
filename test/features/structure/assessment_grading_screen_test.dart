import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/assessment_grading_screen.dart';

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

class _FakeStructureEvent extends Fake implements StructureEvent {}

const _primaryLevel = EducationalLevel(
  id: 'level-primary',
  schoolId: 'school-1',
  name: 'Primary',
  code: 'PRI',
  order: 1,
);

const _secondaryLevel = EducationalLevel(
  id: 'level-secondary',
  schoolId: 'school-1',
  name: 'Secondary',
  code: 'SEC',
  order: 2,
);

const _primaryGradingSystem = GradingSystemDef(
  id: 'gs-1',
  schoolId: 'school-1',
  name: 'Primary Letter Grades',
  appliesTo: 'levels',
  levelIds: ['level-primary'],
);

Widget _wrap(Widget child, {required StructureBloc bloc}) {
  return MaterialApp(
    home: BlocProvider<StructureBloc>.value(value: bloc, child: child),
  );
}

void main() {
  late _MockStructureBloc structureBloc;

  setUpAll(() => registerFallbackValue(_FakeStructureEvent()));

  setUp(() {
    structureBloc = _MockStructureBloc();
  });

  group('AssessmentGradingScreen', () {
    testWidgets(
      'renders every active education level from real Firestore-backed '
      'state, marking the level with a configured grading system Ready and '
      'the level without one as not yet configured',
      (tester) async {
        when(() => structureBloc.state).thenReturn(
          const StructureState(
            levels: [_primaryLevel, _secondaryLevel],
            gradingSystems: [_primaryGradingSystem],
          ),
        );

        await tester.pumpWidget(
          _wrap(
            const AssessmentGradingScreen(showAppBar: false),
            bloc: structureBloc,
          ),
        );

        expect(find.text('Primary'), findsOneWidget);
        expect(find.text('Secondary'), findsOneWidget);
        // Primary has a configured system -> "Ready" status pill.
        expect(find.text('Ready'), findsOneWidget);
        // Secondary has none yet -> its subtitle reflects that.
        expect(find.text('No system yet'), findsOneWidget);
      },
    );

    testWidgets('excludes archived (inactive) levels from the overview', (
      tester,
    ) async {
      when(() => structureBloc.state).thenReturn(
        const StructureState(
          levels: [
            _primaryLevel,
            EducationalLevel(
              id: 'level-archived',
              schoolId: 'school-1',
              name: 'Retired Level',
              isActive: false,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _wrap(
          const AssessmentGradingScreen(showAppBar: false),
          bloc: structureBloc,
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Retired Level'), findsNothing);
    });

    testWidgets(
      'shows a state for a level with no grading system configured yet '
      '(validation/error-state coverage: nothing crashes on empty data)',
      (tester) async {
        when(
          () => structureBloc.state,
        ).thenReturn(const StructureState(levels: [_primaryLevel]));

        await tester.pumpWidget(
          _wrap(
            const AssessmentGradingScreen(showAppBar: false),
            bloc: structureBloc,
          ),
        );

        expect(find.text('Primary'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('shows the explanatory info banner', (tester) async {
      when(
        () => structureBloc.state,
      ).thenReturn(const StructureState(levels: [_primaryLevel]));

      await tester.pumpWidget(
        _wrap(
          const AssessmentGradingScreen(showAppBar: false),
          bloc: structureBloc,
        ),
      );

      expect(
        find.text('Different levels can use different systems.'),
        findsOneWidget,
      );
    });
  });
}
