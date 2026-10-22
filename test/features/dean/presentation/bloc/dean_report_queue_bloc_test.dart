import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/dean/data/datasources/dean_report_queue_remote_data_source.dart';
import 'package:school_pulse/features/dean/presentation/bloc/report_queue/dean_report_queue_bloc.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

class MockDeanReportQueueRemoteDataSource extends Mock
    implements DeanReportQueueRemoteDataSource {}

CanonicalReportCard _card({
  String id = 'rc1',
  AcademicWorkflowStatus status = AcademicWorkflowStatus.submittedToDean,
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
);

void main() {
  late DeanReportQueueBloc bloc;
  late MockDeanReportQueueRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDeanReportQueueRemoteDataSource();
    bloc = DeanReportQueueBloc(dataSource: mockDataSource);
  });

  tearDown(() => bloc.close());

  group('DeanReportQueueBloc - loading the queue', () {
    blocTest<DeanReportQueueBloc, DeanReportQueueState>(
      'loads pending and signed report cards for the school',
      setUp: () {
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: 'schoolA',
            statuses: const [AcademicWorkflowStatus.submittedToDean],
          ),
        ).thenAnswer((_) async => [_card()]);
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: 'schoolA',
            statuses: const [
              AcademicWorkflowStatus.deanSigned,
              AcademicWorkflowStatus.submittedToHeadteacher,
              AcademicWorkflowStatus.academicallyFinalized,
            ],
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const DeanReportQueueRequested('schoolA')),
      expect: () => [
        isA<DeanReportQueueState>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        isA<DeanReportQueueState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.pending.length, 'pending.length', 1)
            .having((s) => s.signed.length, 'signed.length', 0),
      ],
    );

    blocTest<DeanReportQueueBloc, DeanReportQueueState>(
      'surfaces an error message when the queue fails to load',
      setUp: () {
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: any(named: 'schoolId'),
            statuses: any(named: 'statuses'),
          ),
        ).thenThrow(Exception('network error'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const DeanReportQueueRequested('schoolA')),
      expect: () => [
        isA<DeanReportQueueState>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        isA<DeanReportQueueState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('DeanReportQueueBloc - returning a report', () {
    blocTest<DeanReportQueueBloc, DeanReportQueueState>(
      'calls returnByDean with the given reason and reports success',
      setUp: () {
        when(
          () => mockDataSource.returnByDean(
            reportCardId: 'rc1',
            reason: 'Marks look wrong',
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
      seed: () => const DeanReportQueueState(schoolId: 'schoolA'),
      act: (bloc) => bloc.add(
        const DeanReportCardReturned(
          reportCardId: 'rc1',
          reason: 'Marks look wrong',
        ),
      ),
      expect: () => [
        isA<DeanReportQueueState>().having((s) => s.isActing, 'isActing', true),
        isA<DeanReportQueueState>()
            .having((s) => s.isActing, 'isActing', false)
            .having((s) => s.successMessage, 'successMessage', isNotNull),
        isA<DeanReportQueueState>(), // the re-fetch's loading state
        isA<DeanReportQueueState>(), // the re-fetch's loaded state
      ],
      verify: (_) {
        verify(
          () => mockDataSource.returnByDean(
            reportCardId: 'rc1',
            reason: 'Marks look wrong',
          ),
        ).called(1);
      },
    );
  });

  group('DeanReportQueueBloc - signing a report', () {
    blocTest<DeanReportQueueBloc, DeanReportQueueState>(
      'signs then forwards to the Headteacher in one action',
      setUp: () {
        when(
          () => mockDataSource.signAsDean(
            reportCardId: 'rc1',
            expectedVersion: 1,
            expectedSourceHash: 'hash1',
          ),
        ).thenAnswer((_) async {});
        when(() => mockDataSource.submitToHeadteacher(['rc1'])).thenAnswer(
          (_) async => {
            'submitted': ['rc1'],
            'failed': [],
          },
        );
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: any(named: 'schoolId'),
            statuses: any(named: 'statuses'),
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      seed: () => const DeanReportQueueState(schoolId: 'schoolA'),
      act: (bloc) => bloc.add(DeanReportCardSigned(_card())),
      expect: () => [
        isA<DeanReportQueueState>().having((s) => s.isActing, 'isActing', true),
        isA<DeanReportQueueState>()
            .having((s) => s.isActing, 'isActing', false)
            .having((s) => s.successMessage, 'successMessage', isNotNull),
        isA<DeanReportQueueState>(),
        isA<DeanReportQueueState>(),
      ],
      verify: (_) {
        verify(
          () => mockDataSource.signAsDean(
            reportCardId: 'rc1',
            expectedVersion: 1,
            expectedSourceHash: 'hash1',
          ),
        ).called(1);
        verify(() => mockDataSource.submitToHeadteacher(['rc1'])).called(1);
      },
    );

    blocTest<DeanReportQueueBloc, DeanReportQueueState>(
      'a signing failure (stale version/hash) surfaces an error, not a silent no-op',
      setUp: () {
        when(
          () => mockDataSource.signAsDean(
            reportCardId: 'rc1',
            expectedVersion: 1,
            expectedSourceHash: 'hash1',
          ),
        ).thenThrow(Exception('failed-precondition: stale version'));
        when(
          () => mockDataSource.getReportCardsByStatus(
            schoolId: any(named: 'schoolId'),
            statuses: any(named: 'statuses'),
          ),
        ).thenAnswer((_) async => []);
      },
      build: () => bloc,
      seed: () => const DeanReportQueueState(schoolId: 'schoolA'),
      act: (bloc) => bloc.add(DeanReportCardSigned(_card())),
      expect: () => [
        isA<DeanReportQueueState>().having((s) => s.isActing, 'isActing', true),
        isA<DeanReportQueueState>()
            .having((s) => s.isActing, 'isActing', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        isA<DeanReportQueueState>(),
        isA<DeanReportQueueState>(),
      ],
      verify: (_) {
        verifyNever(() => mockDataSource.submitToHeadteacher(any()));
      },
    );
  });
}
