import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';

class _MockResponsibilityService extends Mock
    implements ActiveResponsibilityService {}

class _MockAssignmentRepository extends Mock
    implements StaffAssignmentRepository {}

class _MockCalendarService extends Mock implements AcademicCalendarService {}

const _period = AcademicPeriod(
  academicYearId: '2026',
  academicYearName: '2025/2026',
  termId: 't2',
  termName: 'Term 2',
);

StaffRoleAssignment _assignment({
  required String id,
  String subjectId = 'maths',
  String subjectName = 'Mathematics',
  String classId = 'g10a',
  StaffResponsibilityType roleType = StaffResponsibilityType.subjectTeacher,
}) {
  return StaffRoleAssignment(
    id: id,
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: roleType,
    academicYearId: '2026',
    subjectId: subjectId,
    subjectName: subjectName,
    classId: classId,
    className: 'Grade 10',
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );
}

ActiveResponsibilityContext _contextFor(StaffRoleAssignment a) =>
    ActiveResponsibilityContext.fromAssignment(
      a,
      termId: 't2',
      termName: 'Term 2',
    );

void main() {
  late _MockResponsibilityService service;
  late _MockAssignmentRepository repository;
  late _MockCalendarService calendar;

  final maths10a = _assignment(id: 'a1');
  final maths10b = _assignment(id: 'a2', classId: 'g10b');
  final ict10a = _assignment(id: 'a3', subjectId: 'ict', subjectName: 'ICT');
  final classTeacher = _assignment(
    id: 'a4',
    roleType: StaffResponsibilityType.classTeacher,
  );

  setUp(() {
    service = _MockResponsibilityService();
    repository = _MockAssignmentRepository();
    calendar = _MockCalendarService();

    when(
      () => calendar.getCurrentPeriod(any()),
    ).thenAnswer((_) async => _period);
    when(
      () => repository.watchAssignments(
        schoolId: any(named: 'schoolId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) => const Stream.empty());
  });

  SubjectTeacherContextBloc build() => SubjectTeacherContextBloc(
    responsibilityService: service,
    assignmentRepository: repository,
    calendarService: calendar,
  );

  group('loading responsibilities', () {
    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'activates the restored assignment and lists every valid one',
      setUp: () {
        when(
          () => service.resolve(
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right(
            ResponsibilityResolution(
              available: [maths10a, maths10b, ict10a, classTeacher],
              active: _contextFor(maths10a),
            ),
          ),
        );
      },
      build: build,
      act: (bloc) => bloc.add(
        const ContextRequested(schoolId: 'school1', userId: 'user1'),
      ),
      verify: (bloc) {
        expect(bloc.state.active?.subjectId, 'maths');
        expect(bloc.state.available, hasLength(4));
        // One account, four responsibilities - three subject rows and a class
        // teaching row, no second login involved.
        expect(bloc.state.subjectAssignments, hasLength(3));
        expect(bloc.state.classTeacherAssignment?.id, 'a4');
      },
    );

    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'reports no academic year instead of an empty panel',
      setUp: () {
        when(
          () => calendar.getCurrentPeriod(any()),
        ).thenAnswer((_) async => const AcademicPeriod(academicYearId: ''));
      },
      build: build,
      act: (bloc) => bloc.add(
        const ContextRequested(schoolId: 'school1', userId: 'user1'),
      ),
      verify: (bloc) {
        expect(
          bloc.state.unavailableReason,
          ContextUnavailableReason.noAcademicYear,
        );
        expect(bloc.state.active, isNull);
      },
    );

    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'reports no assignments when the teacher holds none',
      setUp: () {
        when(
          () => service.resolve(
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => const Right(ResponsibilityResolution()));
      },
      build: build,
      act: (bloc) => bloc.add(
        const ContextRequested(schoolId: 'school1', userId: 'user1'),
      ),
      verify: (bloc) {
        expect(
          bloc.state.unavailableReason,
          ContextUnavailableReason.noAssignments,
        );
      },
    );

    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'surfaces the notice when the previous responsibility is gone',
      setUp: () {
        when(
          () => service.resolve(
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right(
            ResponsibilityResolution(
              available: [maths10b],
              active: _contextFor(maths10b),
              switchReason:
                  'Your previous responsibility is no longer available.',
            ),
          ),
        );
      },
      build: build,
      act: (bloc) => bloc.add(
        const ContextRequested(schoolId: 'school1', userId: 'user1'),
      ),
      verify: (bloc) => expect(bloc.state.notice, isNotNull),
    );

    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'never shows a raw backend error to the teacher',
      setUp: () {
        when(
          () => service.resolve(
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => const Left(
            ServerFailure(
              '[cloud_firestore/permission-denied] Missing permissions on '
              '/schools/school1/staff_role_assignments',
            ),
          ),
        );
      },
      build: build,
      act: (bloc) => bloc.add(
        const ContextRequested(schoolId: 'school1', userId: 'user1'),
      ),
      verify: (bloc) {
        expect(bloc.state.errorMessage, isNot(contains('firestore')));
        expect(bloc.state.errorMessage, isNot(contains('/schools/')));
      },
    );
  });

  group('switching responsibility', () {
    setUp(() {
      when(
        () => service.resolve(
          schoolId: any(named: 'schoolId'),
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => Right(
          ResponsibilityResolution(
            available: [maths10a, maths10b, ict10a],
            active: _contextFor(maths10a),
          ),
        ),
      );
    });

    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'moves the whole panel to the chosen subject and class',
      setUp: () {
        when(
          () => service.switchTo(
            assignmentId: any(named: 'assignmentId'),
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => Right(_contextFor(ict10a)));
        when(
          () => repository.getValidAssignments(
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
            academicYearId: any(named: 'academicYearId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right([maths10a, maths10b, ict10a]));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ContextRequested(schoolId: 'school1', userId: 'user1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ContextSwitched('a3'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.active?.subjectId, 'ict');
        expect(bloc.state.active?.roleAssignmentId, 'a3');
        // Nothing from the previous assignment is left in the context.
        expect(bloc.state.active?.subjectName, 'ICT');
      },
    );

    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'refuses a switch to an assignment the admin has suspended',
      setUp: () {
        when(
          () => service.switchTo(
            assignmentId: any(named: 'assignmentId'),
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => const Left(
            AssignmentInvalidFailure(
              'This responsibility has been suspended by the school admin.',
            ),
          ),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ContextRequested(schoolId: 'school1', userId: 'user1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ContextSwitched('a2'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.errorMessage, contains('suspended'));
        // The teacher stays on the responsibility they were already using.
        expect(bloc.state.active?.roleAssignmentId, 'a1');
      },
    );
  });

  group('revalidation', () {
    blocTest<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      'flags the assignment as suspended when it is revoked mid-session',
      setUp: () {
        when(
          () => service.resolve(
            schoolId: any(named: 'schoolId'),
            userId: any(named: 'userId'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => Right(
            ResponsibilityResolution(
              available: [maths10a],
              active: _contextFor(maths10a),
            ),
          ),
        );
        when(
          () => service.revalidate(),
        ).thenAnswer((_) async => const Left(AssignmentInvalidFailure()));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ContextRequested(schoolId: 'school1', userId: 'user1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ContextRevalidated());
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(
        bloc.state.unavailableReason,
        ContextUnavailableReason.assignmentSuspended,
      ),
    );
  });
}
