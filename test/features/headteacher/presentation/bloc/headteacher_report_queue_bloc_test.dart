import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/headteacher/data/datasources/headteacher_report_queue_remote_data_source.dart';
import 'package:school_pulse/features/headteacher/presentation/bloc/headteacher_report_queue_bloc.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

class MockHeadteacherReportQueueRemoteDataSource extends Mock
    implements HeadteacherReportQueueRemoteDataSource {}

CanonicalReportCard _card({
  String id = 'rc1',
  AcademicWorkflowStatus status = AcademicWorkflowStatus.submittedToHeadteacher,
}) => CanonicalReportCard(
  reportCardId: id,
  schoolId: 'schoolA',
  studentId: 'studentA',
  studentName: 'Student A',
  academicYearId: '2026',
  termId: 't2',
  classId: 'p7',
  academicStatus: status,
  version: 1,
  sourceHash: 'hash1',
  deanDecision: const StageDecision(
    decision: 'signed',
    actorUid: 'deanA',
    actorDisplayName: 'Dean A',
    reportVersion: 1,
  ),
);

void main() {
  late HeadteacherReportQueueBloc bloc;
  late MockHeadteacherReportQueueRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHeadteacherReportQueueRemoteDataSource();
    bloc = HeadteacherReportQueueBloc(dataSource: mockDataSource);
  });

  tearDown(() => bloc.close());

  group('HeadteacherReportQueueBloc - loading the queue', () {
    blocTest<HeadteacherReportQueueBloc, HeadteacherReportQueueState>(
      'loads pending and finalized report cards for the school',
      setUp: () {
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: 'schoolA',
            statuses: const [AcademicWorkflowStatus.submittedToHeadteacher],
          ),
        ).thenAnswer((_) async => [_card()]);
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: 'schoolA',
            statuses: const [AcademicWorkflowStatus.academicallyFinalized],
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const HeadteacherReportQueueRequested('schoolA')),
      expect: () => [
        isA<HeadteacherReportQueueState>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        isA<HeadteacherReportQueueState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.pending.length, 'pending.length', 1),
      ],
    );
  });

  group('HeadteacherReportQueueBloc - finalizing a report', () {
    blocTest<HeadteacherReportQueueBloc, HeadteacherReportQueueState>(
      'signs the report and reports success',
      setUp: () {
        when(
          () => mockDataSource.signAsHeadteacher(
            reportCardId: 'rc1',
            expectedVersion: 1,
            expectedSourceHash: 'hash1',
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: any(named: 'schoolId'),
            statuses: any(named: 'statuses'),
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      seed: () => const HeadteacherReportQueueState(schoolId: 'schoolA'),
      act: (bloc) => bloc.add(HeadteacherReportCardSigned(_card())),
      expect: () => [
        isA<HeadteacherReportQueueState>().having(
          (s) => s.isActing,
          'isActing',
          true,
        ),
        isA<HeadteacherReportQueueState>()
            .having((s) => s.isActing, 'isActing', false)
            .having((s) => s.successMessage, 'successMessage', isNotNull),
        isA<HeadteacherReportQueueState>(),
        isA<HeadteacherReportQueueState>(),
      ],
      verify: (_) {
        verify(
          () => mockDataSource.signAsHeadteacher(
            reportCardId: 'rc1',
            expectedVersion: 1,
            expectedSourceHash: 'hash1',
          ),
        ).called(1);
      },
    );

    blocTest<HeadteacherReportQueueBloc, HeadteacherReportQueueState>(
      'a failure to finalize (e.g. no live Dean signature) surfaces an error',
      setUp: () {
        when(
          () => mockDataSource.signAsHeadteacher(
            reportCardId: 'rc1',
            expectedVersion: 1,
            expectedSourceHash: 'hash1',
          ),
        ).thenThrow(Exception('failed-precondition: no dean signature'));
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: any(named: 'schoolId'),
            statuses: any(named: 'statuses'),
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      seed: () => const HeadteacherReportQueueState(schoolId: 'schoolA'),
      act: (bloc) => bloc.add(HeadteacherReportCardSigned(_card())),
      expect: () => [
        isA<HeadteacherReportQueueState>().having(
          (s) => s.isActing,
          'isActing',
          true,
        ),
        isA<HeadteacherReportQueueState>()
            .having((s) => s.isActing, 'isActing', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        isA<HeadteacherReportQueueState>(),
        isA<HeadteacherReportQueueState>(),
      ],
    );
  });

  group('HeadteacherReportQueueBloc - returning a report', () {
    blocTest<HeadteacherReportQueueBloc, HeadteacherReportQueueState>(
      'calls returnByHeadteacher with the reason and academicContentChanged flag',
      setUp: () {
        when(
          () => mockDataSource.returnByHeadteacher(
            reportCardId: 'rc1',
            reason: 'Grade miscalculated',
            academicContentChanged: true,
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: any(named: 'schoolId'),
            statuses: any(named: 'statuses'),
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      seed: () => const HeadteacherReportQueueState(schoolId: 'schoolA'),
      act: (bloc) => bloc.add(
        const HeadteacherReportCardReturned(
          reportCardId: 'rc1',
          reason: 'Grade miscalculated',
        ),
      ),
      expect: () => [
        isA<HeadteacherReportQueueState>().having(
          (s) => s.isActing,
          'isActing',
          true,
        ),
        isA<HeadteacherReportQueueState>()
            .having((s) => s.isActing, 'isActing', false)
            .having((s) => s.successMessage, 'successMessage', isNotNull),
        isA<HeadteacherReportQueueState>(),
        isA<HeadteacherReportQueueState>(),
      ],
      verify: (_) {
        verify(
          () => mockDataSource.returnByHeadteacher(
            reportCardId: 'rc1',
            reason: 'Grade miscalculated',
            academicContentChanged: true,
          ),
        ).called(1);
      },
    );
  });
}
