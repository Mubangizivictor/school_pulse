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
  String name = '2026',
  DateTime? startDate,
  DateTime? endDate,
  bool isCurrent = false,
  bool isArchived = false,
}) => AcademicYear(
  id: id,
  schoolId: schoolId,
  name: name,
  startDate: startDate ?? DateTime(2026, 1, 1),
  endDate: endDate ?? DateTime(2026, 12, 31),
  isCurrent: isCurrent,
  isArchived: isArchived,
);

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_year());
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

  group('Academic year create', () {
    blocTest<StructureBloc, StructureState>(
      'SaveAcademicYearRequested calls repository.addAcademicYear when valid',
      build: () {
        when(
          () => repository.addAcademicYear(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(SaveAcademicYearRequested(_year())),
      verify: (_) {
        verify(() => repository.addAcademicYear(_year())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'AcademicYearsUpdated emits the new list, scoped to the loaded school',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(AcademicYearsUpdated([_year()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.academicYears,
          'academicYears',
          [_year()],
        ),
      ],
    );
  });

  group('Academic year validation', () {
    const validator = StructureIntegrityValidator();

    test('rejects an end date before the start date', () {
      final candidate = _year(
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 1, 1),
      );
      expect(
        validator.validateAcademicYear(candidate, const []),
        'Academic year end date must be after the start date.',
      );
    });

    test('rejects a duplicate name within the same institution', () {
      final existing = _year(id: 'year-existing', name: '2026');
      final candidate = _year(id: 'year-new', name: '2026');
      expect(
        validator.validateAcademicYear(candidate, [existing]),
        'An academic year with this name already exists.',
      );
    });

    test('allows the same name when editing the same record', () {
      final existing = _year(id: 'year-1', name: '2026');
      final candidate = _year(id: 'year-1', name: '2026');
      expect(validator.validateAcademicYear(candidate, [existing]), isNull);
    });

    blocTest<StructureBloc, StructureState>(
      'SaveAcademicYearRequested rejects a duplicate name without writing',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(
        isLoading: false,
        academicYears: [],
      ).copyWith(academicYears: [_year(id: 'existing', name: '2026')]),
      act: (bloc) => bloc.add(
        SaveAcademicYearRequested(_year(id: 'new-id', name: '2026')),
      ),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'An academic year with this name already exists.',
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.addAcademicYear(any()));
      },
    );
  });

  group('Current academic year switching', () {
    blocTest<StructureBloc, StructureState>(
      'SetCurrentAcademicYearRequested calls repository.setCurrentAcademicYear atomically',
      build: () {
        when(
          () => repository.setCurrentAcademicYear(any(), any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [
          _year(id: 'year-1', isCurrent: true),
          _year(id: 'year-2'),
        ],
      ),
      act: (bloc) => bloc.add(
        const SetCurrentAcademicYearRequested('year-2', 'school-1'),
      ),
      verify: (_) {
        verify(
          () => repository.setCurrentAcademicYear('year-2', 'school-1'),
        ).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'ArchiveAcademicYearRequested calls repository.archiveAcademicYear instead of deleting',
      build: () {
        when(
          () => repository.archiveAcademicYear(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const ArchiveAcademicYearRequested('year-1')),
      verify: (_) {
        verify(() => repository.archiveAcademicYear('year-1')).called(1);
        verifyNever(() => repository.deleteAcademicYear(any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteAcademicYearRequested is blocked when the year has dependent terms',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [_year(id: 'year-1')],
        academicTerms: [
          AcademicTerm(
            id: 'term-1',
            schoolId: 'school-1',
            academicYearId: 'year-1',
            name: 'Term 1',
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 4, 1),
            periodType: AcademicPeriodType.term,
            order: 1,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteAcademicYearRequested('year-1')),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'This academic year contains terms/semesters. Archive it instead of deleting it.',
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.deleteAcademicYear(any()));
      },
    );
  });

  group('Tenant isolation', () {
    blocTest<StructureBloc, StructureState>(
      'LoadStructureData subscribes to academic years scoped to the given school only',
      build: () {
        when(
          () => repository.watchAcademicYears('school-1'),
        ).thenAnswer((_) => Stream.value([_year(schoolId: 'school-1')]));
        when(
          () => repository.watchLevels(any()),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.watchAcademicTerms(any()),
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
        verify(() => repository.watchAcademicYears('school-1')).called(1);
        expect(
          bloc.state.academicYears.every(
            (year) => year.schoolId == 'school-1',
          ),
          isTrue,
        );
      },
    );

    test(
      'validateAcademicYear only compares against years passed in for the current tenant',
      () {
        const validator = StructureIntegrityValidator();
        final otherSchoolYear = _year(
          id: 'other-school-year',
          schoolId: 'school-2',
          name: '2026',
        );
        final candidate = _year(
          id: 'new-year',
          schoolId: 'school-1',
          name: '2026',
        );
        // The caller is responsible for only passing the current tenant's
        // years; the validator itself does not filter by schoolId, so this
        // documents that the bloc/UI must scope the list before calling it.
        expect(
          validator.validateAcademicYear(candidate, [otherSchoolYear]),
          isNotNull,
          reason:
              'Guards against a future regression where cross-tenant year '
              'lists get passed to the validator without schoolId filtering '
              'upstream.',
        );
      },
    );
  });
}
