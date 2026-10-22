import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/exam_factory/domain/entities/exam_factory_entities.dart';
import 'package:school_pulse/features/exam_factory/domain/repositories/exam_factory_repository.dart';
import 'package:school_pulse/features/exam_factory/presentation/bloc/exam_factory_cubit.dart';
import 'package:school_pulse/features/exam_factory/presentation/screens/series/exam_series_screens.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockRepository extends Mock implements ExamFactoryRepository {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

const _classes = [
  SchoolClass(id: 'p6', schoolId: 'school-1', name: 'P6'),
  SchoolClass(id: 'p7', schoolId: 'school-1', name: 'P7'),
];

const _subjects = [
  Subject(id: 'maths', schoolId: 'school-1', name: 'Mathematics'),
  Subject(id: 'eng', schoolId: 'school-1', name: 'English'),
];

const _levels = [
  EducationalLevel(
    id: 'lower',
    schoolId: 'school-1',
    name: 'Lower Primary',
    order: 0,
  ),
  EducationalLevel(
    id: 'upper',
    schoolId: 'school-1',
    name: 'Upper Primary',
    order: 1,
  ),
];

const _leveledClasses = [
  SchoolClass(id: 'p1', schoolId: 'school-1', name: 'P1', levelId: 'lower'),
  SchoolClass(id: 'p6', schoolId: 'school-1', name: 'P6', levelId: 'upper'),
  SchoolClass(id: 'x1', schoolId: 'school-1', name: 'Unassigned Class'),
];

final _academicYear = AcademicYear(
  id: 'year-2026',
  schoolId: 'school-1',
  name: '2026',
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 12, 1),
  isCurrent: true,
);

final _academicTerms = [
  AcademicTerm(
    id: 'term-1',
    schoolId: 'school-1',
    academicYearId: 'year-2026',
    name: 'Semester 1',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 6, 1),
    periodType: AcademicPeriodType.semester,
  ),
  AcademicTerm(
    id: 'term-2',
    schoolId: 'school-1',
    academicYearId: 'year-2026',
    name: 'Semester 2',
    startDate: DateTime(2026, 6, 2),
    endDate: DateTime(2026, 12, 1),
    periodType: AcademicPeriodType.semester,
    isCurrent: true,
  ),
];

const _assessmentTypes = [
  AssessmentTypeDef(id: 'cat', schoolId: 'school-1', name: 'CAT'),
  AssessmentTypeDef(id: 'prelim', schoolId: 'school-1', name: 'Prelim'),
];

Widget _wrap({
  required ExamFactoryRepository repository,
  required StructureBloc structureBloc,
  String? seriesId,
}) {
  final router = GoRouter(
    initialLocation: '/series-editor',
    routes: [
      GoRoute(
        path: '/series-editor',
        builder: (context, state) => ExamSeriesEditorScreen(seriesId: seriesId),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<ExamFactoryCubit>(
        create: (_) => ExamFactoryCubit(
          repository: repository,
          institutionId: 'school-1',
          currentUserId: 'dos-1',
        ),
      ),
      BlocProvider<StructureBloc>.value(value: structureBloc),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// The default 800x600 test surface clips this long form's bottom action
/// button - use a taller viewport matching a typical phone so taps on it
/// hit-test correctly, restoring the default afterwards.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late _MockRepository repository;
  late _MockStructureBloc structureBloc;

  setUpAll(() {
    registerFallbackValue(const LoadStructureData('school-1'));
    registerFallbackValue(
      ExamSeries(
        id: 'fallback',
        institutionId: 'school-1',
        name: 'fallback',
        academicYear: '2026',
        term: 'Term 1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 2),
        status: ExamSeriesStatus.draft,
      ),
    );
  });

  setUp(() {
    repository = _MockRepository();
    structureBloc = _MockStructureBloc();
    when(
      () => structureBloc.state,
    ).thenReturn(const StructureState(classes: _classes, subjects: _subjects));
    when(
      () => repository.watchSeriesById(any(), any()),
    ).thenAnswer((_) => Stream.value(null));
  });

  testWidgets('shows a loading indicator until Structure data arrives', (
    tester,
  ) async {
    when(() => structureBloc.state).thenReturn(const StructureState());

    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Series name'), findsNothing);
  });

  testWidgets('renders the create form with every class and subject chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create examination series'), findsOneWidget);
    expect(find.text('Series name'), findsOneWidget);
    for (final schoolClass in _classes) {
      expect(find.text(schoolClass.name), findsOneWidget);
    }
    for (final subject in _subjects) {
      expect(find.text(subject.name), findsOneWidget);
    }
  });

  testWidgets('refuses to save without a name', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save series'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save series'));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
    verifyNever(
      () => repository.saveExamSeries(
        any(),
        operationId: any(named: 'operationId'),
      ),
    );
  });

  testWidgets('refuses to save without start/end dates even with a name', (
    tester,
  ) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Term 2 Midterm');
    await tester.ensureVisible(find.text('Save series'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save series'));
    await tester.pump();

    expect(find.text('Select a start and end date.'), findsOneWidget);
    verifyNever(
      () => repository.saveExamSeries(
        any(),
        operationId: any(named: 'operationId'),
      ),
    );
  });

  testWidgets('selecting a class chip toggles it, not the others', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    final p6Chip = find.widgetWithText(FilterChip, 'P6');
    final p7Chip = find.widgetWithText(FilterChip, 'P7');
    expect(tester.widget<FilterChip>(p6Chip).selected, isFalse);

    await tester.tap(p6Chip);
    await tester.pump();

    expect(tester.widget<FilterChip>(p6Chip).selected, isTrue);
    expect(tester.widget<FilterChip>(p7Chip).selected, isFalse);
  });

  testWidgets('editing an existing series preloads its saved fields', (
    tester,
  ) async {
    final existing = ExamSeries(
      id: 'series-1',
      institutionId: 'school-1',
      name: 'Term 2 Midterm',
      academicYear: '2026',
      term: 'Term 2',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 6),
      status: ExamSeriesStatus.collectingQuestions,
      classIds: const ['p6'],
      subjectIds: const ['maths'],
    );
    when(
      () => repository.watchSeriesById('school-1', 'series-1'),
    ).thenAnswer((_) => Stream.value(existing));

    await tester.pumpWidget(
      _wrap(
        repository: repository,
        structureBloc: structureBloc,
        seriesId: 'series-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit examination series'), findsOneWidget);
    expect(find.text('Term 2 Midterm'), findsOneWidget);
    expect(
      tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'P6')).selected,
      isTrue,
    );
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Mathematics'))
          .selected,
      isTrue,
    );
  });

  testWidgets('a series that no longer exists shows a not-found message', (
    tester,
  ) async {
    when(
      () => repository.watchSeriesById('school-1', 'missing'),
    ).thenAnswer((_) => Stream.value(null));

    await tester.pumpWidget(
      _wrap(
        repository: repository,
        structureBloc: structureBloc,
        seriesId: 'missing',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Series not found'), findsOneWidget);
  });

  testWidgets('a successful save shows a confirmation snackbar', (
    tester,
  ) async {
    _useTallViewport(tester);
    when(
      () => repository.saveExamSeries(
        any(),
        operationId: any(named: 'operationId'),
      ),
    ).thenAnswer((_) async => 'new-series-id');

    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Term 2 Midterm');
    await tester.tap(find.widgetWithText(FilterChip, 'P6'));
    await tester.tap(find.widgetWithText(FilterChip, 'Mathematics'));
    await tester.pump();

    // Drive the real Material date picker for both Start date and End date
    // so this exercises the same path a user takes, rather than reaching
    // into the widget's private state.
    await tester.tap(find.text('Select date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save series'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save series'));
    await tester.pump();
    await tester.pump();

    verify(
      () => repository.saveExamSeries(
        any(),
        operationId: any(named: 'operationId'),
      ),
    ).called(1);
    expect(find.text('Examination series saved.'), findsOneWidget);
  });

  testWidgets('groups classes under their configured level, with a fallback '
      'section for classes that have none', (tester) async {
    _useTallViewport(tester);
    when(() => structureBloc.state).thenReturn(
      const StructureState(
        classes: _leveledClasses,
        subjects: _subjects,
        levels: _levels,
      ),
    );

    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lower Primary'), findsOneWidget);
    expect(find.text('Upper Primary'), findsOneWidget);
    expect(find.text('Other classes'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'P1'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'P6'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Unassigned Class'), findsOneWidget);
  });

  testWidgets(
    'sources academic year, term and exam type from Structure config when '
    'the school has set them up',
    (tester) async {
      when(() => structureBloc.state).thenReturn(
        StructureState(
          classes: _classes,
          subjects: _subjects,
          academicYears: [_academicYear],
          academicTerms: _academicTerms,
          assessmentTypes: _assessmentTypes,
        ),
      );

      await tester.pumpWidget(
        _wrap(repository: repository, structureBloc: structureBloc),
      );
      await tester.pumpAndSettle();

      // No free-text fallback fields - the school's own catalog drives these.
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Semester 2'), findsOneWidget); // the current term
      expect(find.text('CAT'), findsOneWidget); // first defined type
      expect(find.text('Term 1'), findsNothing);
      expect(find.text('Midterm'), findsNothing);
    },
  );
}
