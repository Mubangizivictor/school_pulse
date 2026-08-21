import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/finance/data/datasources/bursar_report_release_remote_data_source.dart';
import 'package:school_pulse/features/finance/presentation/bloc/report_release/bursar_report_release_bloc.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

class MockBursarReportReleaseRemoteDataSource extends Mock
    implements BursarReportReleaseRemoteDataSource {}

CanonicalReportCard _card({
  String id = 'rc1',
  FinancialAccessStatus status = FinancialAccessStatus.held,
}) => CanonicalReportCard(
  reportCardId: id,
  schoolId: 'schoolA',
  studentId: 'studentA',
  studentName: 'Student A',
  academicYearId: '2026',
  termId: 't2',
  classId: 'p7',
  isFinalized: true,
  financialAccessStatus: status,
);

void main() {
  late BursarReportReleaseBloc bloc;
  late MockBursarReportReleaseRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockBursarReportReleaseRemoteDataSource();
    bloc = BursarReportReleaseBloc(dataSource: mockDataSource);
  });

  tearDown(() => bloc.close());

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'loads finalized report cards and buckets them by financial access status',
    setUp: () {
      when(
        () => mockDataSource.getFinalizedReportCards(
          schoolId: 'schoolA',
          classId: null,
          academicYearId: null,
          termId: null,
        ),
      ).thenAnswer(
        (_) async => [
          _card(id: 'rc1', status: FinancialAccessStatus.held),
          _card(id: 'rc2', status: FinancialAccessStatus.released),
        ],
      );
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const BursarReportReleaseRequested('schoolA')),
    expect: () => [
      isA<BursarReportReleaseState>().having(
        (s) => s.isLoading,
        'isLoading',
        true,
      ),
      isA<BursarReportReleaseState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.held.length, 'held.length', 1)
          .having((s) => s.released.length, 'released.length', 1),
    ],
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'releasing report cards calls the data source with the reason and refreshes',
    setUp: () {
      when(
        () => mockDataSource.setFinancialAccess(
          reportCardIds: ['rc1'],
          action: 'release',
          reason: 'Fees cleared',
        ),
      ).thenAnswer(
        (_) async => {
          'succeeded': ['rc1'],
          'failed': [],
        },
      );
      when(
        () => mockDataSource.getFinalizedReportCards(
          schoolId: any(named: 'schoolId'),
          classId: any(named: 'classId'),
          academicYearId: any(named: 'academicYearId'),
          termId: any(named: 'termId'),
        ),
      ).thenAnswer((_) async => []);
    },
    build: () => bloc,
    seed: () => const BursarReportReleaseState(schoolId: 'schoolA'),
    act: (bloc) => bloc.add(
      const BursarReportAccessChanged(
        reportCardIds: ['rc1'],
        action: 'release',
        reason: 'Fees cleared',
      ),
    ),
    expect: () => [
      isA<BursarReportReleaseState>().having(
        (s) => s.isActing,
        'isActing',
        true,
      ),
      isA<BursarReportReleaseState>()
          .having((s) => s.isActing, 'isActing', false)
          .having((s) => s.successMessage, 'successMessage', isNotNull),
      isA<BursarReportReleaseState>(),
      isA<BursarReportReleaseState>(),
    ],
    verify: (_) {
      verify(
        () => mockDataSource.setFinancialAccess(
          reportCardIds: ['rc1'],
          action: 'release',
          reason: 'Fees cleared',
        ),
      ).called(1);
    },
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'a partial failure in a bulk action is reported, not hidden',
    setUp: () {
      when(
        () => mockDataSource.setFinancialAccess(
          reportCardIds: ['rc1', 'rc2'],
          action: 'release',
          reason: 'Term-end release',
        ),
      ).thenAnswer(
        (_) async => {
          'succeeded': ['rc1'],
          'failed': [
            {'reportCardId': 'rc2', 'reason': 'failed-precondition'},
          ],
        },
      );
      when(
        () => mockDataSource.getFinalizedReportCards(
          schoolId: any(named: 'schoolId'),
          classId: any(named: 'classId'),
          academicYearId: any(named: 'academicYearId'),
          termId: any(named: 'termId'),
        ),
      ).thenAnswer((_) async => []);
    },
    build: () => bloc,
    seed: () => const BursarReportReleaseState(schoolId: 'schoolA'),
    act: (bloc) => bloc.add(
      const BursarReportAccessChanged(
        reportCardIds: ['rc1', 'rc2'],
        action: 'release',
        reason: 'Term-end release',
      ),
    ),
    expect: () => [
      isA<BursarReportReleaseState>().having(
        (s) => s.isActing,
        'isActing',
        true,
      ),
      isA<BursarReportReleaseState>()
          .having((s) => s.isActing, 'isActing', false)
          .having(
            (s) => s.successMessage,
            'successMessage',
            contains('1 updated, 1 could not be updated'),
          ),
      isA<BursarReportReleaseState>(),
      isA<BursarReportReleaseState>(),
    ],
  );
}
