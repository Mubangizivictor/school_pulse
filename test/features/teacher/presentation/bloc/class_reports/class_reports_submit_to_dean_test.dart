import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_report_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';

class MockClassReportRepository extends Mock implements ClassReportRepository {}

ActiveResponsibilityContext _context() => ActiveResponsibilityContext(
  schoolId: 'school1',
  campusId: 'main',
  academicYearId: '2026',
  termId: '2026-t2',
  staffId: 'staff1',
  userId: 'user1',
  roleAssignmentId: 'ct1',
  roleType: StaffResponsibilityType.classTeacher,
  classId: 'p7',
  className: 'Primary 7',
  permissionScope: const PermissionScope(
    permissions: {},
    classId: 'p7',
    academicYearId: '2026',
  ),
  assignmentStartDate: DateTime(2026, 1, 1),
);

void main() {
  late ClassReportsBloc bloc;
  late MockClassReportRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(_context());
  });

  setUp(() {
    mockRepository = MockClassReportRepository();
    bloc = ClassReportsBloc(reportRepository: mockRepository);
  });

  tearDown(() => bloc.close());

  blocTest<ClassReportsBloc, ClassReportsState>(
    'submitting to the Dean reports how many were submitted vs failed',
    setUp: () {
      when(
        () => mockRepository.submitReportCardsToDean(
          context: any(named: 'context'),
          reportCardIds: ['rc1', 'rc2'],
        ),
      ).thenAnswer(
        (_) async => const Right(
          SubmitReportCardsResult(
            submitted: ['rc1'],
            failed: [
              SubmitReportCardFailure(
                reportCardId: 'rc2',
                reason: 'already_finalized',
              ),
            ],
          ),
        ),
      );
      when(
        () => mockRepository.getProfile(context: any(named: 'context')),
      ).thenAnswer((_) async => const Right(ReportProfile(id: 'default')));
      when(
        () => mockRepository.getEntries(context: any(named: 'context')),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockRepository.unapprovedSubjects(context: any(named: 'context')),
      ).thenAnswer((_) async => const Right([]));
    },
    build: () => bloc,
    seed: () => ClassReportsState(context: _context()),
    act: (bloc) => bloc.add(
      const ClassReportCardsSubmittedToDean(['rc1', 'rc2']),
    ),
    expect: () => [
      isA<ClassReportsState>().having((s) => s.isSaving, 'isSaving', true),
      isA<ClassReportsState>()
          .having((s) => s.isSaving, 'isSaving', false)
          .having(
            (s) => s.successMessage,
            'successMessage',
            contains('1 submitted, 1 could not be submitted'),
          ),
      isA<ClassReportsState>(), // the refresh's loading state
      isA<ClassReportsState>(), // the refresh's loaded state
    ],
    verify: (_) {
      verify(
        () => mockRepository.submitReportCardsToDean(
          context: any(named: 'context'),
          reportCardIds: ['rc1', 'rc2'],
        ),
      ).called(1);
    },
  );

  blocTest<ClassReportsBloc, ClassReportsState>(
    'a repository failure surfaces an error message instead of a silent no-op',
    setUp: () {
      when(
        () => mockRepository.submitReportCardsToDean(
          context: any(named: 'context'),
          reportCardIds: ['rc1'],
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('network down')));
      when(
        () => mockRepository.getProfile(context: any(named: 'context')),
      ).thenAnswer((_) async => const Right(ReportProfile(id: 'default')));
      when(
        () => mockRepository.getEntries(context: any(named: 'context')),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockRepository.unapprovedSubjects(context: any(named: 'context')),
      ).thenAnswer((_) async => const Right([]));
    },
    build: () => bloc,
    seed: () => ClassReportsState(context: _context()),
    act: (bloc) => bloc.add(const ClassReportCardsSubmittedToDean(['rc1'])),
    expect: () => [
      isA<ClassReportsState>().having((s) => s.isSaving, 'isSaving', true),
      isA<ClassReportsState>()
          .having((s) => s.isSaving, 'isSaving', false)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      isA<ClassReportsState>(), // the refresh's loading state
      isA<ClassReportsState>(), // the refresh's loaded state
    ],
  );
}
