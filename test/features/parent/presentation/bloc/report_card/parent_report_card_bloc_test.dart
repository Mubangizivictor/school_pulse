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
  late MockParentReportCardRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockParentReportCardRemoteDataSource();
    bloc = ParentReportCardBloc(dataSource: mockDataSource);
  });

  tearDown(() => bloc.close());

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'loads only the reports Firestore rules actually returned for this student',
    setUp: () {
      when(
        () => mockDataSource.getReleasedReportCards(
          schoolId: 'schoolA',
          studentId: 'studentA',
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
      isA<ParentReportCardState>().having(
        (s) => s.isLoading,
        'isLoading',
        true,
      ),
      isA<ParentReportCardState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.reportCards.length, 'reportCards.length', 1),
    ],
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'an empty result (nothing released yet) is a normal, not-an-error state',
    setUp: () {
      when(
        () => mockDataSource.getReleasedReportCards(
          schoolId: any(named: 'schoolId'),
          studentId: any(named: 'studentId'),
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
      isA<ParentReportCardState>().having(
        (s) => s.isLoading,
        'isLoading',
        true,
      ),
      isA<ParentReportCardState>()
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.reportCards, 'reportCards', isEmpty)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'requesting the official PDF returns a signed download URL',
    setUp: () {
      when(
        () => mockDataSource.getOfficialPdfDownloadUrl('rc1'),
      ).thenAnswer((_) async => 'https://signed.example/rc1.pdf');
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ParentReportCardPdfRequested('rc1')),
    expect: () => [
      isA<ParentReportCardState>().having(
        (s) => s.isDownloading,
        'isDownloading',
        true,
      ),
      isA<ParentReportCardState>()
          .having((s) => s.isDownloading, 'isDownloading', false)
          .having(
            (s) => s.downloadUrl,
            'downloadUrl',
            'https://signed.example/rc1.pdf',
          ),
    ],
  );

  blocTest<ParentReportCardBloc, ParentReportCardState>(
    'a denied PDF request (e.g. access revoked underneath them) surfaces an error',
    setUp: () {
      when(
        () => mockDataSource.getOfficialPdfDownloadUrl('rc1'),
      ).thenThrow(Exception('permission-denied'));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ParentReportCardPdfRequested('rc1')),
    expect: () => [
      isA<ParentReportCardState>().having(
        (s) => s.isDownloading,
        'isDownloading',
        true,
      ),
      isA<ParentReportCardState>()
          .having((s) => s.isDownloading, 'isDownloading', false)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );
}
