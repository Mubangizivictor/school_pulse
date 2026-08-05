import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_dashboard_stats.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_intervention.dart';
import 'package:school_pulse/features/dean/domain/repositories/dean_repository.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';

class MockDeanRepository extends Mock implements DeanRepository {}

void main() {
  late DeanBloc bloc;
  late MockDeanRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      AcademicIntervention(
        id: 'fallback',
        studentId: 'fallback',
        studentName: 'fallback',
        reason: 'fallback',
        type: InterventionType.remedial,
        status: InterventionStatus.pending,
        startDate: DateTime(2024),
        assignedTo: const [],
        outcomes: '',
      ),
    );
  });

  setUp(() {
    mockRepository = MockDeanRepository();
    bloc = DeanBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final tStats = AcademicDashboardStats(
    totalStudents: 100,
    totalTeachers: 10,
    totalClasses: 5,
    totalSubjects: 5,
    currentAcademicYear: '2024',
    currentTerm: 'Term 1',
    activeTimetables: 5,
    lessonsConductedToday: 20,
    lessonsMissedToday: 2,
    assessmentsPending: 3,
    marksPendingEntry: 10,
    reportCardsPendingApproval: 50,
    reportCardsPublished: 0,
    overallSchoolAverage: 75.0,
    topPerformingClasses: const [],
    bottomPerformingClasses: const [],
    subjectRankings: const [],
    attendanceTrend: 0.5,
    homeworkCompletionRate: 85.0,
    teacherLessonCompletionRate: 90.0,
    activeAlerts: const [],
  );

  final tIntervention = AcademicIntervention(
    id: '1',
    studentId: 's1',
    studentName: 'John Doe',
    reason: 'Poor performance',
    type: InterventionType.remedial,
    status: InterventionStatus.pending,
    startDate: DateTime.now(),
    assignedTo: const [],
    outcomes: '',
  );

  group('DeanBloc - Dashboard', () {
    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, AcademicDashboardLoaded] when stats fetched successfully',
      build: () {
        when(
          () => mockRepository.getAcademicDashboardStats(),
        ).thenAnswer((_) async => Right(tStats));
        return bloc;
      },
      act: (bloc) => bloc.add(AcademicDashboardRequested()),
      expect: () => [DeanLoading(), AcademicDashboardLoaded(tStats)],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanError] when fetching stats fails',
      build: () {
        when(
          () => mockRepository.getAcademicDashboardStats(),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(AcademicDashboardRequested()),
      expect: () => [DeanLoading(), const DeanError('Error')],
    );
    group('DeanBloc - Interventions', () {
      blocTest<DeanBloc, DeanState>(
        'should emit [DeanLoading, InterventionsLoaded] when interventions fetched successfully',
        build: () {
          when(
            () => mockRepository.getInterventions(),
          ).thenAnswer((_) async => Right([tIntervention]));
          return bloc;
        },
        act: (bloc) => bloc.add(InterventionsRequested()),
        expect: () => [
          DeanLoading(),
          InterventionsLoaded([tIntervention]),
        ],
      );

      blocTest<DeanBloc, DeanState>(
        'should emit [DeanLoading, DeanOperationSuccess] when intervention created successfully',
        build: () {
          when(
            () => mockRepository.createIntervention(any()),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateInterventionRequested(tIntervention)),
        expect: () => [
          DeanLoading(),
          const DeanOperationSuccess('Intervention plan created'),
        ],
      );
    });

    group('DeanBloc - QA & Approvals', () {
      blocTest<DeanBloc, DeanState>(
        'should emit [DeanLoading, DeanOperationSuccess] when assessment marks approved',
        build: () {
          when(
            () => mockRepository.approveAssessmentMarks(any()),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(const ApproveAssessmentMarksRequested('a1')),
        expect: () => [
          DeanLoading(),
          const DeanOperationSuccess('Assessment marks approved'),
        ],
      );
    });
  });
}
