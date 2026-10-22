import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/finance/data/datasources/bursar_report_release_remote_data_source.dart';
import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';
import 'package:school_pulse/features/finance/presentation/bloc/report_release/bursar_report_release_bloc.dart';

class MockDs extends Mock implements BursarReportReleaseRemoteDataSource {}

ReportReleaseEligibilityRow _row({
  String id = 'rc1',
  String name = 'Student A',
  ReportReleaseUiStatus status = ReportReleaseUiStatus.withheldForFees,
  int balance = 100000,
  String? streamId,
  ReportReleaseException? exception,
}) => ReportReleaseEligibilityRow(
  reportCardId: id,
  studentId: 'stu_$id',
  studentName: name,
  classId: 'p7',
  streamId: streamId,
  academicYearId: '2026',
  termId: 't2',
  financialAccessStatus: status == ReportReleaseUiStatus.automaticallyAvailable
      ? 'released'
      : 'held',
  financialAccessSource: 'auto',
  uiStatus: status,
  balanceUgx: balance,
  clearance: ClearanceResult(
    cleared: status == ReportReleaseUiStatus.automaticallyAvailable,
    mode: 'fullBalance',
    balanceUgx: balance,
  ),
  exception: exception,
);

const _facets = ReportPeriodFacets(
  years: ['2026'],
  terms: ['t2', 't1'],
  classes: ['p7', 'p6'],
  streams: ['east', 'west'],
);

ReportReleaseEligibilityResult _result(
  List<ReportReleaseEligibilityRow> rows,
) => ReportReleaseEligibilityResult(
  rows: rows,
  policy: const FinancialClearancePolicy(),
);

void main() {
  late BursarReportReleaseBloc bloc;
  late MockDs ds;

  setUp(() {
    ds = MockDs();
    bloc = BursarReportReleaseBloc(dataSource: ds);
    when(
      () => ds.getReportPeriods(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => _facets);
    when(
      () => ds.getEligibility(
        academicYearId: any(named: 'academicYearId'),
        termId: any(named: 'termId'),
        classId: any(named: 'classId'),
      ),
    ).thenAnswer(
      (_) async => _result([
        _row(id: 'rc1', status: ReportReleaseUiStatus.withheldForFees),
        _row(
          id: 'rc2',
          status: ReportReleaseUiStatus.automaticallyAvailable,
          balance: 0,
        ),
      ]),
    );
  });

  tearDown(() => bloc.close());

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'started: loads facets, picks the newest year/first term, then loads rows',
    build: () => bloc,
    act: (b) => b.add(const BursarReportReleaseStarted('schoolA')),
    expect: () => [
      isA<BursarReportReleaseState>().having(
        (s) => s.isLoading,
        'loading',
        true,
      ),
      isA<BursarReportReleaseState>()
          .having((s) => s.academicYearId, 'year', '2026')
          .having((s) => s.termId, 'term', 't2'),
      isA<BursarReportReleaseState>()
          .having((s) => s.isLoading, 'loading', false)
          .having((s) => s.allRows.length, 'rows', 2)
          .having(
            (s) => s.section(ReportReleaseUiStatus.withheldForFees).length,
            'withheld',
            1,
          )
          .having(
            (s) =>
                s.section(ReportReleaseUiStatus.automaticallyAvailable).length,
            'auto',
            1,
          ),
    ],
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'learner search filters in memory without refetching',
    build: () => bloc,
    seed: () => BursarReportReleaseState(
      academicYearId: '2026',
      termId: 't2',
      allRows: [
        _row(id: 'rc1', name: 'Aisha Namwano'),
        _row(id: 'rc2', name: 'Brian Okello'),
      ],
    ),
    act: (b) =>
        b.add(const BursarReportReleaseFiltersChanged(learnerQuery: 'okello')),
    verify: (_) {
      verifyNever(
        () => ds.getEligibility(
          academicYearId: any(named: 'academicYearId'),
          termId: any(named: 'termId'),
          classId: any(named: 'classId'),
        ),
      );
    },
    expect: () => [
      isA<BursarReportReleaseState>().having(
        (s) => s.visibleRows.map((r) => r.studentName).toList(),
        'visible',
        ['Brian Okello'],
      ),
    ],
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'changing the term refetches',
    build: () => bloc,
    seed: () =>
        const BursarReportReleaseState(academicYearId: '2026', termId: 't2'),
    act: (b) => b.add(
      const BursarReportReleaseFiltersChanged(
        academicYearId: '2026',
        termId: 't1',
      ),
    ),
    verify: (_) {
      verify(
        () => ds.getEligibility(
          academicYearId: '2026',
          termId: 't1',
          classId: null,
        ),
      ).called(1);
    },
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'granting an exception calls the datasource and reloads',
    build: () => bloc,
    seed: () =>
        const BursarReportReleaseState(academicYearId: '2026', termId: 't2'),
    setUp: () {
      when(
        () => ds.grantException(
          studentId: any(named: 'studentId'),
          academicYearId: any(named: 'academicYearId'),
          termId: any(named: 'termId'),
          reasonCode: any(named: 'reasonCode'),
          reasonNote: any(named: 'reasonNote'),
          expiresAt: any(named: 'expiresAt'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async => {'status': 'active'});
    },
    act: (b) => b.add(
      const BursarReleaseExceptionGranted(
        studentId: 'stu_rc1',
        academicYearId: '2026',
        termId: 't2',
        reasonCode: 'paymentPlan',
      ),
    ),
    expect: () => [
      isA<BursarReportReleaseState>().having((s) => s.isActing, 'acting', true),
      isA<BursarReportReleaseState>()
          .having((s) => s.isActing, 'acting', false)
          .having((s) => s.successMessage, 'msg', isNotNull),
      isA<BursarReportReleaseState>(), // reload
    ],
    verify: (_) {
      verify(
        () => ds.grantException(
          studentId: 'stu_rc1',
          academicYearId: '2026',
          termId: 't2',
          reasonCode: 'paymentPlan',
          reasonNote: null,
          expiresAt: null,
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).called(1);
    },
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'a duplicate-exception error is surfaced with a friendly message',
    build: () => bloc,
    seed: () =>
        const BursarReportReleaseState(academicYearId: '2026', termId: 't2'),
    setUp: () {
      when(
        () => ds.grantException(
          studentId: any(named: 'studentId'),
          academicYearId: any(named: 'academicYearId'),
          termId: any(named: 'termId'),
          reasonCode: any(named: 'reasonCode'),
          reasonNote: any(named: 'reasonNote'),
          expiresAt: any(named: 'expiresAt'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenThrow(Exception('already-exists: duplicate'));
    },
    act: (b) => b.add(
      const BursarReleaseExceptionGranted(
        studentId: 'stu_rc1',
        academicYearId: '2026',
        termId: 't2',
        reasonCode: 'hardship',
      ),
    ),
    expect: () => [
      isA<BursarReportReleaseState>().having((s) => s.isActing, 'acting', true),
      isA<BursarReportReleaseState>().having(
        (s) => s.errorMessage,
        'error',
        contains('already exists'),
      ),
      isA<BursarReportReleaseState>(),
    ],
  );

  blocTest<BursarReportReleaseBloc, BursarReportReleaseState>(
    'reject routes to revokeException on a pending exception',
    build: () => bloc,
    seed: () =>
        const BursarReportReleaseState(academicYearId: '2026', termId: 't2'),
    setUp: () {
      when(
        () => ds.revokeException(
          exceptionId: any(named: 'exceptionId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => {'status': 'revoked'});
    },
    act: (b) =>
        b.add(const BursarReleaseExceptionRejected('exc1', 'Not eligible')),
    verify: (_) {
      verify(
        () => ds.revokeException(exceptionId: 'exc1', reason: 'Not eligible'),
      ).called(1);
    },
  );
}
