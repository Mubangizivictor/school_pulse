import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/exam_factory/data/datasources/exam_factory_queue_data_source.dart';
import 'package:school_pulse/features/exam_factory/domain/entities/exam_factory_entities.dart';
import 'package:school_pulse/features/exam_factory/domain/repositories/exam_factory_repository.dart';
import 'package:school_pulse/features/exam_factory/domain/services/exam_factory_offline_queue_service.dart';
import 'package:school_pulse/features/exam_factory/presentation/bloc/exam_factory_cubit.dart';

class _MockRepository extends Mock implements ExamFactoryRepository {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

class _MockQueueDataSource extends Mock implements ExamFactoryQueueDataSource {}

void main() {
  const institutionId = 'school-1';
  const userId = 'teacher-1';

  late _MockRepository repository;
  late ExamFactoryCubit cubit;

  ExamQuestion question({
    ExamQuestionStatus status = ExamQuestionStatus.draft,
  }) => ExamQuestion(
    id: 'q1',
    seriesId: 'series-1',
    institutionId: institutionId,
    classId: 'p6',
    subjectId: 'maths',
    topic: 'Fractions',
    creatorId: userId,
    text: 'Simplify 3/4 + 1/8',
    marks: 5,
    version: 1,
    type: ExamQuestionType.shortAnswer,
    status: status,
  );

  setUpAll(() {
    registerFallbackValue(ExamFactoryQueueActionType.saveQuestionDraft);
    registerFallbackValue(
      ExamQuestion(
        id: 'fallback',
        seriesId: 'fallback',
        institutionId: 'fallback',
        classId: 'fallback',
        subjectId: 'fallback',
        topic: 'fallback',
        creatorId: 'fallback',
        text: 'fallback',
        marks: 1,
        version: 1,
        type: ExamQuestionType.shortAnswer,
        status: ExamQuestionStatus.draft,
      ),
    );
    registerFallbackValue(
      ExamPaper(
        id: 'fallback',
        seriesId: 'fallback',
        institutionId: 'fallback',
        classId: 'fallback',
        subjectId: 'fallback',
        title: 'fallback',
        targetMarks: 1,
        totalMarks: 1,
        version: 1,
        status: ExamPaperStatus.draft,
      ),
    );
    registerFallbackValue(
      ExamSeries(
        id: 'fallback',
        institutionId: 'fallback',
        name: 'fallback',
        academicYear: '2026',
        term: 'Term 1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 2),
        status: ExamSeriesStatus.draft,
      ),
    );
    registerFallbackValue(ExamQuestionStatus.draft);
    registerFallbackValue(ExamIncidentType.other);
  });

  setUp(() {
    repository = _MockRepository();
    cubit = ExamFactoryCubit(
      repository: repository,
      institutionId: institutionId,
      currentUserId: userId,
    );
  });

  tearDown(() => cubit.close());

  group('_guarded error mapping', () {
    test('permission-denied maps to a friendly message', () async {
      when(
        () => repository.saveExamSeries(
          any(),
          operationId: any(named: 'operationId'),
        ),
      ).thenThrow(Exception('permission-denied: nope'));

      final series = ExamSeries(
        id: 's1',
        institutionId: institutionId,
        name: 'Term 2',
        academicYear: '2026',
        term: 'Term 2',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 6),
        status: ExamSeriesStatus.draft,
      );

      await expectLater(cubit.saveSeries(series), throwsException);
      expect(cubit.state.error, 'You do not have permission to do this.');
      expect(cubit.state.isBusy, isFalse);
    });

    test('failed-precondition maps to a friendly message', () async {
      when(
        () => repository.lockPaper(
          any(),
          any(),
          operationId: any(named: 'operationId'),
        ),
      ).thenThrow(Exception('failed-precondition: not approved'));

      await expectLater(cubit.lockPaper('paper-1'), throwsException);
      expect(
        cubit.state.error,
        'This action is not allowed in the current state.',
      );
    });

    test('not-found maps to a friendly message', () async {
      when(
        () => repository.moderateQuestion(
          any(),
          any(),
          any(),
          comment: any(named: 'comment'),
          operationId: any(named: 'operationId'),
        ),
      ).thenThrow(Exception('not-found: gone'));

      await expectLater(
        cubit.moderateQuestion('q1', ExamQuestionStatus.approved),
        throwsException,
      );
      expect(cubit.state.error, 'Record not found.');
    });

    test('invalid-argument maps to a friendly message', () async {
      when(
        () =>
            repository.savePaper(any(), operationId: any(named: 'operationId')),
      ).thenThrow(Exception('invalid-argument: bad marks'));

      final paper = ExamPaper(
        id: 'p1',
        seriesId: 's1',
        institutionId: institutionId,
        classId: 'p6',
        subjectId: 'maths',
        title: 'Paper',
        targetMarks: 100,
        totalMarks: 0,
        version: 1,
        status: ExamPaperStatus.draft,
      );

      await expectLater(cubit.savePaper(paper), throwsException);
      expect(cubit.state.error, 'Please check the entered values.');
    });

    test('an unrecognised error falls back to a generic message', () async {
      when(
        () => repository.submitQuestion(
          any(),
          any(),
          academicYearId: any(named: 'academicYearId'),
          operationId: any(named: 'operationId'),
        ),
      ).thenThrow(Exception('boom'));

      await expectLater(cubit.submitQuestion('q1'), throwsException);
      expect(cubit.state.error, 'Something went wrong. Please try again.');
    });

    test('a successful call clears a previous error and busy flag', () async {
      when(
        () => repository.lockPaper(
          any(),
          any(),
          operationId: any(named: 'operationId'),
        ),
      ).thenThrow(Exception('failed-precondition'));
      await expectLater(cubit.lockPaper('paper-1'), throwsException);
      expect(cubit.state.error, isNotNull);

      when(
        () => repository.requestPaperApproval(
          any(),
          any(),
          operationId: any(named: 'operationId'),
        ),
      ).thenAnswer((_) async {});
      await cubit.requestPaperApproval('paper-1');
      expect(cubit.state.error, isNull);
      expect(cubit.state.isBusy, isFalse);
    });
  });

  group('online mutations (no offline support wired)', () {
    test(
      'saveQuestionDraft calls the repository directly when offline support is absent',
      () async {
        when(
          () => repository.saveQuestionDraft(
            any(),
            operationId: any(named: 'operationId'),
          ),
        ).thenAnswer((_) async {});

        await cubit.saveQuestionDraft(question());

        verify(
          () => repository.saveQuestionDraft(
            any(),
            operationId: any(named: 'operationId'),
          ),
        ).called(1);
        expect(cubit.state.queuedOffline, isFalse);
      },
    );

    test('reportIncident returns the client-generated incident id', () async {
      String? capturedIncidentId;
      when(
        () => repository.reportIncident(
          any(),
          incidentId: any(named: 'incidentId'),
          sittingId: any(named: 'sittingId'),
          type: any(named: 'type'),
          description: any(named: 'description'),
          studentIds: any(named: 'studentIds'),
        ),
      ).thenAnswer((invocation) async {
        capturedIncidentId = invocation.namedArguments[#incidentId] as String?;
        return 'server-id';
      });

      final incidentId = await cubit.reportIncident(
        sittingId: 'sitting-1',
        type: ExamIncidentType.lateArrival,
        description: 'Arrived late',
      );

      // The repository is called with the same client-generated id the
      // cubit returns, not the server's echoed value - offline replay
      // depends on this being stable.
      expect(incidentId, isNotEmpty);
      expect(capturedIncidentId, incidentId);
    });
  });

  group('offline queueing (networkInfo + offlineQueue wired)', () {
    late _MockNetworkInfo networkInfo;
    late _MockQueueDataSource queueDataSource;
    late ExamFactoryOfflineQueueService offlineQueue;
    late ExamFactoryCubit offlineCubit;

    setUp(() {
      networkInfo = _MockNetworkInfo();
      queueDataSource = _MockQueueDataSource();
      offlineQueue = ExamFactoryOfflineQueueService(
        dataSource: queueDataSource,
      );
      offlineCubit = ExamFactoryCubit(
        repository: repository,
        institutionId: institutionId,
        currentUserId: userId,
        networkInfo: networkInfo,
        offlineQueue: offlineQueue,
      );
      when(
        () => queueDataSource.enqueue(
          idempotencyKey: any(named: 'idempotencyKey'),
          institutionId: any(named: 'institutionId'),
          actorId: any(named: 'actorId'),
          actionType: any(named: 'actionType'),
          payloadJson: any(named: 'payloadJson'),
        ),
      ).thenAnswer((_) async {});
    });

    tearDown(() => offlineCubit.close());

    test(
      'goes straight online when connected, never touching the queue',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => repository.saveQuestionDraft(
            any(),
            operationId: any(named: 'operationId'),
          ),
        ).thenAnswer((_) async {});

        await offlineCubit.saveQuestionDraft(question());

        verify(
          () => repository.saveQuestionDraft(
            any(),
            operationId: any(named: 'operationId'),
          ),
        ).called(1);
        verifyNever(
          () => queueDataSource.enqueue(
            idempotencyKey: any(named: 'idempotencyKey'),
            institutionId: any(named: 'institutionId'),
            actorId: any(named: 'actorId'),
            actionType: any(named: 'actionType'),
            payloadJson: any(named: 'payloadJson'),
          ),
        );
        expect(offlineCubit.state.queuedOffline, isFalse);
      },
    );

    test(
      'queues the action and never calls the repository when offline',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        await offlineCubit.saveQuestionDraft(question());

        verifyNever(
          () => repository.saveQuestionDraft(
            any(),
            operationId: any(named: 'operationId'),
          ),
        );
        verify(
          () => queueDataSource.enqueue(
            idempotencyKey: any(named: 'idempotencyKey'),
            institutionId: institutionId,
            actorId: userId,
            actionType: ExamFactoryQueueActionType.saveQuestionDraft,
            payloadJson: any(named: 'payloadJson'),
          ),
        ).called(1);
        expect(offlineCubit.state.queuedOffline, isTrue);
        expect(offlineCubit.state.isBusy, isFalse);
      },
    );

    test(
      'a paper approval/lock is never queued - it always goes through _guarded',
      () async {
        // lockPaper has no offline branch at all; confirm it still calls the
        // repository directly even while "offline" per NetworkInfo, since it
        // never consults networkInfo/offlineQueue in the first place.
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => repository.lockPaper(
            any(),
            any(),
            operationId: any(named: 'operationId'),
          ),
        ).thenAnswer((_) async {});

        await offlineCubit.lockPaper('paper-1');

        verify(
          () => repository.lockPaper(
            any(),
            any(),
            operationId: any(named: 'operationId'),
          ),
        ).called(1);
        verifyNever(
          () => queueDataSource.enqueue(
            idempotencyKey: any(named: 'idempotencyKey'),
            institutionId: any(named: 'institutionId'),
            actorId: any(named: 'actorId'),
            actionType: any(named: 'actionType'),
            payloadJson: any(named: 'payloadJson'),
          ),
        );
      },
    );
  });

  group('read-only stream passthroughs', () {
    test('watchQuestions forwards all filters to the repository', () {
      when(
        () => repository.watchQuestions(
          any(),
          seriesId: any(named: 'seriesId'),
          classId: any(named: 'classId'),
          subjectId: any(named: 'subjectId'),
          creatorId: any(named: 'creatorId'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      cubit.watchQuestions(
        seriesId: 'series-1',
        classId: 'p6',
        subjectId: 'maths',
        creatorId: userId,
        status: ExamQuestionStatus.approved,
      );

      verify(
        () => repository.watchQuestions(
          institutionId,
          seriesId: 'series-1',
          classId: 'p6',
          subjectId: 'maths',
          creatorId: userId,
          status: ExamQuestionStatus.approved,
        ),
      ).called(1);
    });

    test('selectSeries updates state.selectedSeriesId', () {
      expect(cubit.state.selectedSeriesId, isNull);
      cubit.selectSeries('series-1');
      expect(cubit.state.selectedSeriesId, 'series-1');
      cubit.selectSeries(null);
      // copyWith's ?? means a null argument keeps the previous value - this
      // is a real quirk of ExamFactoryState.copyWith, not a bug in the test.
      expect(cubit.state.selectedSeriesId, 'series-1');
    });
  });
}
