import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/academic/domain/entities/report_card.dart';
import 'package:school_pulse/features/academic/domain/usecases/manage_report_cards.dart';
import 'package:school_pulse/features/dean/domain/usecases/get_dean_stats.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';

class MockGetDeanStats extends Mock implements GetDeanStats {}
class MockGetReportCards extends Mock implements GetReportCards {}
class MockSignReportCard extends Mock implements SignReportCard {}
class FakeSignReportParams extends Fake implements SignReportParams {}

void main() {
  late DeanBloc bloc;
  late MockGetDeanStats mockGetDeanStats;
  late MockGetReportCards mockGetReportCards;
  late MockSignReportCard mockSignReportCard;

  setUpAll(() {
    registerFallbackValue(FakeSignReportParams());
    registerFallbackValue(ReportCardStatus.pending);
  });

  setUp(() {
    mockGetDeanStats = MockGetDeanStats();
    mockGetReportCards = MockGetReportCards();
    mockSignReportCard = MockSignReportCard();
    bloc = DeanBloc(
      getDeanStats: mockGetDeanStats,
      getReportCards: mockGetReportCards,
      signReportCard: mockSignReportCard,
    );
  });

  const tReportCard = ReportCard(
    id: '1',
    studentId: 'student1',
    studentName: 'John Doe',
    className: 'P1',
    term: 'Term 1',
    year: '2023',
    status: ReportCardStatus.pending,
  );

  group('DeanSignReportCardRequested', () {
    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanOperationSuccess, DeanLoading, DeanReportCardsLoaded] when Dean signs successfully',
      build: () {
        when(() => mockSignReportCard(any())).thenAnswer((_) async => const Right(null));
        when(() => mockGetReportCards(
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeanSignReportCardRequested(
        reportCardId: '1',
        signerId: 'dean1',
        isHeadTeacher: false,
      )),
      expect: () => [
        DeanLoading(),
        const DeanOperationSuccess('Report card signed successfully'),
        DeanLoading(),
        const DeanReportCardsLoaded([]),
      ],
      verify: (_) {
        verify(() => mockSignReportCard(any())).called(1);
      },
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanOperationSuccess, DeanLoading, DeanReportCardsLoaded] and then reload list with deanSigned status when Head Teacher signs',
      build: () {
        when(() => mockSignReportCard(any())).thenAnswer((_) async => const Right(null));
        when(() => mockGetReportCards(
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeanSignReportCardRequested(
        reportCardId: '1',
        signerId: 'admin1',
        isHeadTeacher: true,
      )),
      expect: () => [
        DeanLoading(),
        const DeanOperationSuccess('Report card signed successfully'),
        DeanLoading(),
        const DeanReportCardsLoaded([]),
      ],
      verify: (_) {
        verify(() => mockSignReportCard(any())).called(1);
      },
    );
  });
}
