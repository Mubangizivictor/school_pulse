import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_dashboard_stats.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_intervention.dart';
import 'package:school_pulse/features/dean/domain/entities/assessment_moderation.dart';
import 'package:school_pulse/features/dean/domain/entities/lesson_tracking.dart';
import 'package:school_pulse/features/dean/domain/entities/today_operations.dart';
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
            () => mockRepository.approveAssessmentMarks(
              schoolId: any(named: 'schoolId'),
              assessmentId: any(named: 'assessmentId'),
            ),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const ApproveAssessmentMarksRequested(
            schoolId: 'school1',
            assessmentId: 'a1',
          ),
        ),
        expect: () => [
          DeanLoading(),
          const DeanOperationSuccess('Assessment marks approved'),
        ],
      );
    });
  });

  final tOperations = const TodaysOperations(
    lessonsScheduled: 210,
    lessonsCompleted: 168,
    lessonsInProgress: 12,
    lessonsMissed: 5,
    assessmentsToday: 8,
    awaitingConfirmation: 3,
    teacherAbsences: 4,
    substituteLessons: 3,
    examinationsToday: 1,
    meetingsToday: 2,
  );

  final tLessonRecord = LessonRecord(
    id: "ml1",
    subjectId: "s2",
    subjectName: "English",
    classId: "c4",
    className: "P.6 Green",
    teacherId: "t2",
    teacherName: "Jane Smith",
    scheduledAt: DateTime(2024, 1, 1),
    status: LessonStatus.missed,
  );

  final tAssessment = AssessmentModeration(
    id: "ao1",
    assessmentId: "as1",
    title: "Mid-Term Algebra Test",
    className: "Year 10A",
    subjectName: "Mathematics",
    teacherName: "John Doe",
    submissionCount: 28,
    totalStudents: 30,
    averageScore: 72.5,
    createdAt: DateTime(2024, 1, 1),
  );

  group('DeanBloc - Todays Operations', () {
    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, TodaysOperationsLoaded] when operations fetched successfully',
      build: () {
        when(
          () => mockRepository.getTodaysOperations(),
        ).thenAnswer((_) async => Right(tOperations));
        return bloc;
      },
      act: (bloc) => bloc.add(TodaysOperationsRequested()),
      expect: () => [DeanLoading(), TodaysOperationsLoaded(tOperations)],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanError] when fetching operations fails',
      build: () {
        when(
          () => mockRepository.getTodaysOperations(),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(TodaysOperationsRequested()),
      expect: () => [DeanLoading(), const DeanError('Error')],
    );
  });

  group('DeanBloc - Missed Lessons', () {
    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, MissedLessonsLoaded] when missed lessons fetched successfully',
      build: () {
        when(() => mockRepository.getMissedLessons()).thenAnswer(
          (_) async => Right(([tLessonRecord], <String, bool>{"ml1": false})),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(MissedLessonsRequested()),
      expect: () => [
        DeanLoading(),
        MissedLessonsLoaded([tLessonRecord], const {"ml1": false}),
      ],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanError] when fetching missed lessons fails',
      build: () {
        when(
          () => mockRepository.getMissedLessons(),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(MissedLessonsRequested()),
      expect: () => [DeanLoading(), const DeanError('Error')],
    );
  });

  group('DeanBloc - Assessments Overview', () {
    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, AssessmentsOverviewLoaded] when assessments fetched successfully',
      build: () {
        when(
          () => mockRepository.getAssessmentsOverview(schoolId: 'school1'),
        ).thenAnswer((_) async => Right([tAssessment]));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const AssessmentsOverviewRequested(schoolId: 'school1')),
      expect: () => [
        DeanLoading(),
        AssessmentsOverviewLoaded([tAssessment]),
      ],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanError] when fetching assessments fails',
      build: () {
        when(
          () => mockRepository.getAssessmentsOverview(schoolId: 'school1'),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const AssessmentsOverviewRequested(schoolId: 'school1')),
      expect: () => [DeanLoading(), const DeanError('Error')],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanOperationSuccess] when assessment created successfully',
      build: () {
        when(
          () => mockRepository.createAssessment(
            schoolId: 'school1',
            campusId: any(named: 'campusId'),
            title: 'Mid-Term',
            subjectId: 'Mathematics',
            classId: 'S2A',
            type: 'Test',
            maximumMark: 100,
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const CreateAssessmentRequested(
          schoolId: 'school1',
          title: 'Mid-Term',
          subjectId: 'Mathematics',
          classId: 'S2A',
          type: 'Test',
          maximumMark: 100,
        ),
      ),
      expect: () => [
        DeanLoading(),
        const DeanOperationSuccess('Assessment created'),
      ],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanError] when creating an assessment fails',
      build: () {
        when(
          () => mockRepository.createAssessment(
            schoolId: 'school1',
            campusId: any(named: 'campusId'),
            title: 'Mid-Term',
            subjectId: 'Mathematics',
            classId: 'S2A',
            type: 'Test',
            maximumMark: 100,
          ),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const CreateAssessmentRequested(
          schoolId: 'school1',
          title: 'Mid-Term',
          subjectId: 'Mathematics',
          classId: 'S2A',
          type: 'Test',
          maximumMark: 100,
        ),
      ),
      expect: () => [DeanLoading(), const DeanError('Error')],
    );
  });

  group('DeanBloc - Student Academic Profile', () {
    final tProfile = <String, dynamic>{
      'studentId': 'st1',
      'studentName': 'Namono Grace',
    };

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, StudentAcademicProfileLoaded] when profile fetched successfully',
      build: () {
        when(
          () => mockRepository.getStudentAcademicProfile('st1'),
        ).thenAnswer((_) async => Right(tProfile));
        return bloc;
      },
      act: (bloc) => bloc.add(const StudentAcademicProfileRequested('st1')),
      expect: () => [DeanLoading(), StudentAcademicProfileLoaded(tProfile)],
    );

    blocTest<DeanBloc, DeanState>(
      'should emit [DeanLoading, DeanError] when fetching profile fails',
      build: () {
        when(
          () => mockRepository.getStudentAcademicProfile('st1'),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const StudentAcademicProfileRequested('st1')),
      expect: () => [DeanLoading(), const DeanError('Error')],
    );
  });
}
