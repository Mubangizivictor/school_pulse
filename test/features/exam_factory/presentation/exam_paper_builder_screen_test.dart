import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/exam_factory/domain/entities/exam_factory_entities.dart';
import 'package:school_pulse/features/exam_factory/domain/repositories/exam_factory_repository.dart';
import 'package:school_pulse/features/exam_factory/presentation/bloc/exam_factory_cubit.dart';
import 'package:school_pulse/features/exam_factory/presentation/screens/papers/exam_paper_builder_screen.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockRepository extends Mock implements ExamFactoryRepository {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

const _classes = [SchoolClass(id: 'p6', schoolId: 'school-1', name: 'P6')];
const _subjects = [
  Subject(id: 'maths', schoolId: 'school-1', name: 'Mathematics'),
];

ExamQuestion _approvedQuestion(String id, {int marks = 5, String text = 'Q'}) =>
    ExamQuestion(
      id: id,
      seriesId: 'series-1',
      institutionId: 'school-1',
      classId: 'p6',
      subjectId: 'maths',
      topic: 'Fractions',
      creatorId: 'teacher-1',
      text: text,
      marks: marks,
      version: 1,
      type: ExamQuestionType.shortAnswer,
      status: ExamQuestionStatus.approved,
    );

Widget _wrap({
  required ExamFactoryRepository repository,
  required StructureBloc structureBloc,
  String? paperId,
  List<String> initialQuestionIds = const [],
}) {
  final router = GoRouter(
    initialLocation: '/paper-builder',
    routes: [
      GoRoute(
        path: '/paper-builder',
        builder: (context, state) => ExamPaperBuilderScreen(
          paperId: paperId,
          initialQuestionIds: initialQuestionIds,
        ),
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

void main() {
  late _MockRepository repository;
  late _MockStructureBloc structureBloc;

  setUpAll(() {
    registerFallbackValue(const LoadStructureData('school-1'));
    registerFallbackValue(
      ExamPaper(
        id: 'fallback',
        seriesId: 'fallback',
        institutionId: 'school-1',
        classId: 'fallback',
        subjectId: 'fallback',
        title: 'fallback',
        targetMarks: 1,
        totalMarks: 1,
        version: 1,
        status: ExamPaperStatus.draft,
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
      () => repository.watchSeries('school-1'),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      () => repository.watchQuestions(
        'school-1',
        status: ExamQuestionStatus.approved,
      ),
    ).thenAnswer(
      (_) => Stream.value([_approvedQuestion('q1'), _approvedQuestion('q2')]),
    );
  });

  testWidgets('shows the marks-mismatch warning when totals do not match', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        repository: repository,
        structureBloc: structureBloc,
        initialQuestionIds: const ['q1'],
      ),
    );
    await tester.pumpAndSettle();

    // Default target marks is 100; one 5-mark question selected -> mismatch.
    expect(find.text('Questions (5 / 100 marks)'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('the warning clears once totals match', (tester) async {
    await tester.pumpWidget(
      _wrap(
        repository: repository,
        structureBloc: structureBloc,
        initialQuestionIds: const ['q1', 'q2'],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target marks'),
      '10',
    );
    await tester.pumpAndSettle();

    expect(find.text('Questions (10 / 10 marks)'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('removing a question updates the running total', (tester) async {
    await tester.pumpWidget(
      _wrap(
        repository: repository,
        structureBloc: structureBloc,
        initialQuestionIds: const ['q1', 'q2'],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Questions (10 / 100 marks)'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(find.text('Questions (5 / 100 marks)'), findsOneWidget);
  });

  testWidgets('refuses to save without title, series, class or subject', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(repository: repository, structureBloc: structureBloc),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save paper'));
    await tester.tap(find.text('Save paper'));
    await tester.pump();

    expect(
      find.text('Fill in title, series, class and subject.'),
      findsOneWidget,
    );
    verifyNever(
      () => repository.savePaper(any(), operationId: any(named: 'operationId')),
    );
  });

  testWidgets('a locked paper cannot be re-saved into a draft', (tester) async {
    final lockedPaper = ExamPaper(
      id: 'paper-1',
      seriesId: 'series-1',
      institutionId: 'school-1',
      classId: 'p6',
      subjectId: 'maths',
      title: 'P6 Mathematics',
      targetMarks: 100,
      totalMarks: 100,
      version: 1,
      status: ExamPaperStatus.locked,
      questionIds: const ['q1', 'q2'],
    );
    when(
      () => repository.watchPaper('school-1', 'paper-1'),
    ).thenAnswer((_) => Stream.value(lockedPaper));
    when(
      () => repository.watchQuestions(
        'school-1',
        status: ExamQuestionStatus.usedInPaper,
      ),
    ).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(
      _wrap(
        repository: repository,
        structureBloc: structureBloc,
        paperId: 'paper-1',
      ),
    );
    await tester.pumpAndSettle();

    // No "Send for approval" action is offered once locked - the paper is
    // already past that stage.
    expect(find.text('Send for approval'), findsNothing);
  });
}
