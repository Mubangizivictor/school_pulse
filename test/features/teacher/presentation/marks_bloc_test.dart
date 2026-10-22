import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/domain/policies/marks_entry_policy.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_student_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/marks_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/subject_student_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class _MockMarksRepository extends Mock implements MarksRepository {}

class _MockStudentRepository extends Mock implements SubjectStudentRepository {}

class _MockClassStudentRepository extends Mock
    implements ClassStudentRepository {}

class _FakeContext extends Fake implements ActiveResponsibilityContext {}

class _FakeAssessment extends Fake implements SubjectAssessment {}

class _FakeComponent extends Fake implements AssessmentComponent {}

void main() {
  late _MockMarksRepository marksRepository;
  late _MockStudentRepository studentRepository;
  late _MockClassStudentRepository classStudentRepository;

  final assignment = StaffRoleAssignment(
    id: 'a1',
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: StaffResponsibilityType.subjectTeacher,
    academicYearId: '2026',
    subjectId: 'maths',
    subjectName: 'Mathematics',
    classId: 'g10a',
    className: 'Grade 10A',
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );

  final context = ActiveResponsibilityContext.fromAssignment(
    assignment,
    termId: 't2',
    termName: 'Term 2',
  );

  const component = AssessmentComponent(
    id: 'c1',
    assessmentId: 'as1',
    name: 'Whole paper',
    maximumMark: 100,
  );

  const assessment = SubjectAssessment(
    id: 'as1',
    schoolId: 'school1',
    academicYearId: '2026',
    subjectId: 'maths',
    classId: 'g10a',
    title: 'Mid Term Test',
    maximumMark: 100,
    components: [component],
  );

  setUpAll(() {
    registerFallbackValue(_FakeContext());
    registerFallbackValue(_FakeAssessment());
    registerFallbackValue(_FakeComponent());
    registerFallbackValue(const <StudentMarkEntry>[]);
  });

  setUp(() {
    marksRepository = _MockMarksRepository();
    studentRepository = _MockStudentRepository();
    classStudentRepository = _MockClassStudentRepository();
    when(
      () => marksRepository.getAssessments(
        context: any(named: 'context'),
        subjectId: any(named: 'subjectId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Right([assessment]));
    when(
      () => studentRepository.getSubjectStudents(
        context: any(named: 'context'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Right([]));
  });

  MarksBloc build() => MarksBloc(
    marksRepository: marksRepository,
    studentRepository: studentRepository,
    classStudentRepository: classStudentRepository,
  );

  group('MarksRequested', () {
    blocTest<MarksBloc, MarksState>(
      'loads assessments and the subject roster',
      build: build,
      act: (bloc) => bloc.add(MarksRequested(context)),
      expect: () => [
        isA<MarksState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MarksState>().having((s) => s.isLoading, 'isLoading', false).having(
          (s) => s.assessments,
          'assessments',
          [assessment],
        ),
      ],
    );
  });

  group('MarksAssessmentSelected', () {
    blocTest<MarksBloc, MarksState>(
      'auto-selects the only component and loads its existing marks',
      setUp: () {
        when(
          () => marksRepository.getMarks(
            context: any(named: 'context'),
            assessment: any(named: 'assessment'),
            component: any(named: 'component'),
          ),
        ).thenAnswer((_) async => const Right([]));
      },
      build: build,
      seed: () => MarksState(context: context),
      act: (bloc) => bloc.add(const MarksAssessmentSelected(assessment)),
      expect: () => [
        isA<MarksState>().having(
          (s) => s.selectedAssessment,
          'selectedAssessment',
          assessment,
        ),
        isA<MarksState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MarksState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.selectedComponent, 'selectedComponent', component),
      ],
    );
  });

  group('MarksEntryChanged', () {
    blocTest<MarksBloc, MarksState>(
      'records a scored entry locally without touching the repository',
      build: build,
      seed: () => MarksState(
        context: context,
        selectedAssessment: assessment,
        selectedComponent: component,
      ),
      act: (bloc) =>
          bloc.add(const MarksEntryChanged(studentId: 's1', score: 78)),
      expect: () => [
        isA<MarksState>().having(
          (s) => s.entries['s1']?.score,
          'entries[s1].score',
          78,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => marksRepository.saveDraft(
            context: any(named: 'context'),
            assessment: any(named: 'assessment'),
            component: any(named: 'component'),
            entries: any(named: 'entries'),
          ),
        );
      },
    );
  });

  group('MarksReviewRequested', () {
    blocTest<MarksBloc, MarksState>(
      'surfaces a refusal so the submit button stays disabled',
      setUp: () {
        when(
          () => marksRepository.review(
            context: any(named: 'context'),
            assessment: any(named: 'assessment'),
            component: any(named: 'component'),
            entries: any(named: 'entries'),
          ),
        ).thenAnswer(
          (_) async => const Right(
            MarksSubmissionReport(
              totalStudents: 3,
              entered: 1,
              pending: 2,
              absent: 0,
              exempted: 0,
              invalid: 0,
              refusal: SubmissionRefusal.missingMarks,
            ),
          ),
        );
      },
      build: build,
      seed: () => MarksState(
        context: context,
        selectedAssessment: assessment,
        selectedComponent: component,
      ),
      act: (bloc) => bloc.add(const MarksReviewRequested()),
      expect: () => [
        isA<MarksState>().having((s) => s.isSaving, 'isSaving', true),
        isA<MarksState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.review?.canSubmit, 'review.canSubmit', false),
      ],
    );
  });
}
