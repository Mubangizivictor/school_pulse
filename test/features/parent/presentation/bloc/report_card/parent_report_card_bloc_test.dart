import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/parent/data/parent_report_card_remote_data_source.dart';
import 'package:school_pulse/features/parent/presentation/bloc/report_card/parent_report_card_bloc.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

class MockParentReportCardRemoteDataSource extends Mock
    implements ParentReportCardRemoteDataSource {}

CanonicalReportCard _card({String id = 'rc1'}) => CanonicalReportCard(
  reportCardId: id,
  schoolId: 'schoolA',
  studentId: 'studentA',
  studentName: 'Student A',
  academicYearId: '2026',
  termId: 't2',
  classId: 'p7',
  isFinalized: true,
  financialAccessStatus: FinancialAccessStatus.released,
  pdfUrl: 'schools/schoolA/reportCards/rc1/1.pdf',
);

void main() {
  late ParentReportCardBloc bloc;
  late MockParentReportCardRemoteDataSource ds;

  setUp(() {
    ds = MockParentReportCardRemoteDataSource();
    bloc = ParentReportCardBloc(dataSource: ds);
    when(
      () => ds.getRestrictionMessage(any()),
    ).thenAnswer((_) async => 'Please contact the school bursar.');
    when(
      () => ds.recordParentView(any(), isDownload: any(named: 'isDownload')),
    ).thenAnswer((_) async {});
  });

  tearDown(() => bloc.close());

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'loads only the reports Firestore rules actually returned for this student',
    setUp: () {
      when(
        () => ds.getReleasedReportCards(
          schoolId: 'schoolA',
          studentId: 'studentA',
          parentId: any(named: 'parentId'),
        ),
      ).thenAnswer((_) async => [_card()]);
    },
    build: () => bloc,
    act: (bloc) => bloc.add(
      const ParentReportCardsRequested(
        schoolId: 'schoolA',
        studentId: 'studentA',
      ),
    ),
    expect: () => [
      isA<ParentReportCardState>().having((s) => s.isLoading, 'loading', true),
      isA<ParentReportCardState>()
          .having((s) => s.isLoading, 'loading', false)
          .having((s) => s.reportCards.length, 'reportCards', 1),
    ],
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'an empty result pulls the configured restriction message and is not an error',
    setUp: () {
      when(
        () => ds.getReleasedReportCards(
          schoolId: any(named: 'schoolId'),
          studentId: any(named: 'studentId'),
          parentId: any(named: 'parentId'),
        ),
      ).thenAnswer((_) async => []);
    },
    build: () => bloc,
    act: (bloc) => bloc.add(
      const ParentReportCardsRequested(
        schoolId: 'schoolA',
        studentId: 'studentA',
      ),
    ),
    expect: () => [
      isA<ParentReportCardState>().having((s) => s.isLoading, 'loading', true),
      isA<ParentReportCardState>()
          .having((s) => s.isLoading, 'loading', false)
          .having((s) => s.reportCards, 'reportCards', isEmpty)
          .having((s) => s.errorMessage, 'error', isNull)
          .having(
            (s) => s.restrictionMessage,
            'restrictionMessage',
            'Please contact the school bursar.',
          ),
    ],
    verify: (_) {
      verify(() => ds.getRestrictionMessage('schoolA')).called(1);
    },
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'opening a report fires a best-effort parent-view audit ping',
    build: () => bloc,
    act: (bloc) => bloc.add(const ParentReportCardOpened('rc1')),
    verify: (_) {
      verify(() => ds.recordParentView('rc1')).called(1);
    },
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'requesting the official PDF returns a signed URL and records a download',
    setUp: () {
      when(
        () => ds.getOfficialPdfDownloadUrl('rc1'),
      ).thenAnswer((_) async => 'https://signed.example/rc1.pdf');
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ParentReportCardPdfRequested('rc1')),
    expect: () => [
      isA<ParentReportCardState>().having(
        (s) => s.isDownloading,
        'downloading',
        true,
      ),
      isA<ParentReportCardState>()
          .having((s) => s.isDownloading, 'downloading', false)
          .having(
            (s) => s.downloadUrl,
            'downloadUrl',
            'https://signed.example/rc1.pdf',
          ),
    ],
    verify: (_) {
      verify(() => ds.recordParentView('rc1', isDownload: true)).called(1);
    },
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'a denied PDF request (access revoked underneath them) surfaces an error',
    setUp: () {
      when(
        () => ds.getOfficialPdfDownloadUrl('rc1'),
      ).thenThrow(Exception('permission-denied'));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ParentReportCardPdfRequested('rc1')),
    expect: () => [
      isA<ParentReportCardState>().having(
        (s) => s.isDownloading,
        'downloading',
        true,
      ),
      isA<ParentReportCardState>()
          .having((s) => s.isDownloading, 'downloading', false)
          .having((s) => s.errorMessage, 'error', isNotNull),
    ],
  );
}
