import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/services/structure_integrity_validator.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

AcademicYear _year({
  String id = 'year-1',
  String schoolId = 'school-1',
  bool isCurrent = true,
}) => AcademicYear(
  id: id,
  schoolId: schoolId,
  name: '2026',
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 12, 31),
  isCurrent: isCurrent,
);

AcademicTerm _term({
  String id = 'term-1',
  String schoolId = 'school-1',
  String academicYearId = 'year-1',
  String name = 'Term 1',
  DateTime? startDate,
  DateTime? endDate,
  bool isCurrent = false,
  bool isArchived = false,
  AcademicPeriodType periodType = AcademicPeriodType.term,
}) => AcademicTerm(
  id: id,
  schoolId: schoolId,
  academicYearId: academicYearId,
  name: name,
  startDate: startDate ?? DateTime(2026, 1, 1),
  endDate: endDate ?? DateTime(2026, 4, 1),
  isCurrent: isCurrent,
  isArchived: isArchived,
  periodType: periodType,
);

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_term());
  });

  setUp(() {
    repository = _MockStructureRepository();
    when(
      () => repository.watchLevels(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAcademicYears(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAcademicTerms(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchClasses(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchStreams(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchSubjects(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchDepartments(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchDesignations(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchFeatureToggles(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchInstitutionProfile(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchCampuses(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchHouses(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchClubs(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchFacilities(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchHostels(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchHostelRooms(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchTransportRoutes(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchTransportStops(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchTransportVehicles(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchFeeCategories(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAssessmentTypes(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchGradingSystems(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchGradeBands(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchTimetableConfig(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAttendanceDefaultsConfig(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchCommunicationDefaultsConfig(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAttendanceTypes(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAttendanceSessions(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchAnnouncementCategories(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchNotificationCategories(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchMessageTemplates(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchDocumentTemplates(any()),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.watchCustomFields(any()),
    ).thenAnswer((_) => const Stream.empty());
  });

  group('Calendar system selection', () {
    const validator = StructureIntegrityValidator();

    test('first period in a year may be either terms or semesters', () {
      final year = _year();
      final term = _term(periodType: AcademicPeriodType.term);
      final semester = _term(
        id: 'sem-1',
        name: 'Semester 1',
        periodType: AcademicPeriodType.semester,
      );
      expect(validator.validateAcademicTerm(term, [year], const []), isNull);
      expect(
        validator.validateAcademicTerm(semester, [year], const []),
        isNull,
      );
    });

    test(
      'a second period must match the year\'s already-chosen system',
      () {
        final year = _year();
        final existingTerm = _term(id: 'term-1');
        final semesterAttempt = _term(
          id: 'sem-1',
          name: 'Semester 1',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 8, 1),
          periodType: AcademicPeriodType.semester,
        );
        expect(
          validator.validateAcademicTerm(
            semesterAttempt,
            [year],
            [existingTerm],
          ),
          contains('cannot be mixed'),
        );
      },
    );
  });

  group('Period validation', () {
    blocTest<StructureBloc, StructureState>(
      'SaveAcademicTermRequested calls repository.addAcademicTerm when valid',
      build: () {
        when(() => repository.addAcademicTerm(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [_year()],
      ),
      act: (bloc) => bloc.add(SaveAcademicTermRequested(_term())),
      verify: (_) {
        verify(() => repository.addAcademicTerm(_term())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'SaveAcademicTermRequested rejects a period outside its academic year',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [_year()],
      ),
      act: (bloc) => bloc.add(
        SaveAcademicTermRequested(
          _term(startDate: DateTime(2025, 1, 1), endDate: DateTime(2025, 4, 1)),
        ),
      ),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('must fall inside'),
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.addAcademicTerm(any()));
      },
    );
  });

  group('Chronological sorting', () {
    test('periods sort by start date regardless of insertion order', () {
      final unsorted = [
        _term(id: 'term-3', startDate: DateTime(2026, 8, 2), endDate: DateTime(2026, 12, 31)),
        _term(id: 'term-1', startDate: DateTime(2026, 1, 1), endDate: DateTime(2026, 4, 1)),
        _term(id: 'term-2', startDate: DateTime(2026, 4, 2), endDate: DateTime(2026, 8, 1)),
      ];
      final sorted = [...unsorted]
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      expect(sorted.map((t) => t.id).toList(), [
        'term-1',
        'term-2',
        'term-3',
      ]);
    });
  });

  group('Current period switching', () {
    blocTest<StructureBloc, StructureState>(
      'SetCurrentAcademicTermRequested calls repository.setCurrentAcademicTerm atomically',
      build: () {
        when(
          () => repository.setCurrentAcademicTerm(any(), any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [_year()],
        academicTerms: [_term(isCurrent: true), _term(id: 'term-2')],
      ),
      act: (bloc) => bloc.add(
        const SetCurrentAcademicTermRequested('term-2', 'school-1'),
      ),
      verify: (_) {
        verify(
          () => repository.setCurrentAcademicTerm('term-2', 'school-1'),
        ).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'SetCurrentAcademicTermRequested is blocked when the term\'s year is not current',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [_year(isCurrent: false)],
        academicTerms: [_term()],
      ),
      act: (bloc) => bloc.add(
        const SetCurrentAcademicTermRequested('term-1', 'school-1'),
      ),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.setCurrentAcademicTerm(any(), any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'ArchiveAcademicTermRequested calls repository.archiveAcademicTerm instead of deleting',
      build: () {
        when(
          () => repository.archiveAcademicTerm(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const ArchiveAcademicTermRequested('term-1')),
      verify: (_) {
        verify(() => repository.archiveAcademicTerm('term-1')).called(1);
        verifyNever(() => repository.deleteAcademicTerm(any()));
      },
    );
  });

  group('Tenant isolation', () {
    blocTest<StructureBloc, StructureState>(
      'LoadStructureData subscribes to academic terms scoped to the given school only',
      build: () {
        when(
          () => repository.watchAcademicTerms('school-1'),
        ).thenAnswer((_) => Stream.value([_term(schoolId: 'school-1')]));
        when(
          () => repository.watchLevels(any()),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.watchAcademicYears(any()),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.watchClasses(any()),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.watchSubjects(any()),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.watchInstitutionProfile(any()),
        ).thenAnswer((_) => Stream.value(const InstitutionProfile()));
        when(
          () => repository.watchGradingSystems(any()),
        ).thenAnswer((_) => Stream.value(const <GradingSystemDef>[]));
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LoadStructureData('school-1')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        verify(() => repository.watchAcademicTerms('school-1')).called(1);
        expect(
          bloc.state.academicTerms.every(
            (term) => term.schoolId == 'school-1',
          ),
          isTrue,
        );
      },
    );
  });
}
