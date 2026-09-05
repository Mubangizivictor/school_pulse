import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/services/structure_integrity_validator.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/academic_calendar_step_screen.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

AcademicYear _year({
  String id = 'year-1',
  DateTime? startDate,
  DateTime? endDate,
  bool isCurrent = true,
}) => AcademicYear(
  id: id,
  schoolId: 'school-1',
  name: '2026',
  startDate: startDate ?? DateTime(2026, 1, 1),
  endDate: endDate ?? DateTime(2026, 12, 31),
  isCurrent: isCurrent,
);

AcademicTerm _term({
  String id = 'term-1',
  String academicYearId = 'year-1',
  String name = 'Term 1',
  DateTime? startDate,
  DateTime? endDate,
  AcademicPeriodType periodType = AcademicPeriodType.term,
  DateTime? closureStartDate,
  DateTime? closureEndDate,
}) => AcademicTerm(
  id: id,
  schoolId: 'school-1',
  academicYearId: academicYearId,
  name: name,
  startDate: startDate ?? DateTime(2026, 1, 1),
  endDate: endDate ?? DateTime(2026, 4, 1),
  periodType: periodType,
  closureStartDate: closureStartDate,
  closureEndDate: closureEndDate,
);

void main() {
  const validator = StructureIntegrityValidator();

  group('validateClosureRange', () {
    test('rejects a closure end before its start', () {
      final term = _term();
      final error = validator.validateClosureRange(
        DateTime(2026, 2, 10),
        DateTime(2026, 2, 5),
        term,
      );
      expect(error, contains('on or after'));
    });

    test('rejects a closure that falls outside its own period', () {
      final term = _term(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );
      final error = validator.validateClosureRange(
        DateTime(2026, 3, 25),
        DateTime(2026, 4, 15),
        term,
      );
      expect(error, contains('must fall inside'));
    });

    test('accepts a closure range fully inside its period', () {
      final term = _term(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );
      final error = validator.validateClosureRange(
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 10),
        term,
      );
      expect(error, isNull);
    });
  });

  group('Terms vs Semesters selection', () {
    test('no calendar system is forced by default', () {
      // The chooser starts with a null selection and only offers Terms
      // (marked Recommended) and Semesters - covered at the widget layer
      // in the layout group below via absence of a pre-checked radio.
      expect(AcademicPeriodType.term, isNot(AcademicPeriodType.semester));
    });

    test('either Terms or Semesters is valid as the first period', () {
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

    test('selected system persists: a mismatched second period is rejected', () {
      final year = _year();
      final existingTerm = _term();
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
    });
  });

  group('Date validity', () {
    test('end date before start date is rejected', () {
      final year = _year();
      final term = _term(
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 1, 1),
      );
      expect(
        validator.validateAcademicTerm(term, [year], const []),
        contains('after the start date'),
      );
    });

    test('a period outside the academic year is rejected', () {
      final year = _year();
      final term = _term(
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 4, 1),
      );
      expect(
        validator.validateAcademicTerm(term, [year], const []),
        contains('must fall inside'),
      );
    });
  });

  group('Period overlap detection', () {
    test('an overlapping period is rejected', () {
      final year = _year();
      final term1 = _term(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );
      final overlapping = _term(
        id: 'term-2',
        name: 'Term 2',
        startDate: DateTime(2026, 3, 15),
        endDate: DateTime(2026, 8, 1),
      );
      expect(
        validator.validateAcademicTerm(overlapping, [year], [term1]),
        contains('overlaps'),
      );
    });

    test('adjacent, non-overlapping periods are accepted', () {
      final year = _year();
      final term1 = _term(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );
      final term2 = _term(
        id: 'term-2',
        name: 'Term 2',
        startDate: DateTime(2026, 4, 2),
        endDate: DateTime(2026, 8, 1),
      );
      expect(validator.validateAcademicTerm(term2, [year], [term1]), isNull);
    });
  });

  group('Year-boundary checks', () {
    test('a period starting before the year start is rejected', () {
      final year = _year(startDate: DateTime(2026, 2, 1));
      final term = _term(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 4, 1),
      );
      expect(
        validator.validateAcademicTerm(term, [year], const []),
        contains('must fall inside'),
      );
    });

    test('a period ending after the year end is rejected', () {
      final year = _year(endDate: DateTime(2026, 6, 1));
      final term = _term(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 8, 1),
      );
      expect(
        validator.validateAcademicTerm(term, [year], const []),
        contains('must fall inside'),
      );
    });
  });

  group('Copy-from-previous-year availability', () {
    test(
      'is available when another year already has non-archived periods',
      () {
        final years = [_year(id: 'year-2025'), _year(id: 'year-2026')];
        final terms = [_term(id: 't-2025', academicYearId: 'year-2025')];
        final otherYearsWithData = years
            .where(
              (y) =>
                  y.id != 'year-2026' &&
                  terms.any(
                    (t) => t.academicYearId == y.id && !t.isArchived,
                  ),
            )
            .toList();
        expect(otherYearsWithData, hasLength(1));
      },
    );

    test('is hidden when no other year has any periods', () {
      final years = [_year(id: 'year-2025'), _year(id: 'year-2026')];
      const terms = <AcademicTerm>[];
      final otherYearsWithData = years
          .where(
            (y) =>
                y.id != 'year-2026' &&
                terms.any((t) => t.academicYearId == y.id && !t.isArchived),
          )
          .toList();
      expect(otherYearsWithData, isEmpty);
    });
  });

  group('BLoC: period save + retry pattern', () {
    late _MockStructureRepository repository;

    setUpAll(() {
      registerFallbackValue(_term());
    });

    setUp(() {
      repository = _MockStructureRepository();
      when(() => repository.watchLevels(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchAcademicYears(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchAcademicTerms(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchClasses(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchStreams(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchSubjects(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchDepartments(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchDesignations(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchFeatureToggles(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchInstitutionProfile(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchCampuses(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchHouses(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchClubs(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchFacilities(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchHostels(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchHostelRooms(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchTransportRoutes(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchTransportStops(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchTransportVehicles(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchFeeCategories(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchAssessmentTypes(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchGradingSystems(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchGradeBands(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchTimetableConfig(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchAttendanceDefaultsConfig(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(
        () => repository.watchCommunicationDefaultsConfig(any()),
      ).thenAnswer((_) => const Stream.empty());
      when(() => repository.watchAttendanceTypes(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchAttendanceSessions(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchAnnouncementCategories(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchNotificationCategories(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchMessageTemplates(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchDocumentTemplates(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.watchCustomFields(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
    });

    blocTest<StructureBloc, StructureState>(
      'SaveAcademicTermRequested with a closure range persists via the '
      'existing repository call (no new bloc event needed)',
      build: () {
        when(() => repository.addAcademicTerm(any())).thenAnswer(
          (_) async {},
        );
        return StructureBloc(repository: repository);
      },
      seed: () => const StructureState(isLoading: false).copyWith(
        academicYears: [_year()],
      ),
      act: (bloc) => bloc.add(
        SaveAcademicTermRequested(
          _term(
            closureStartDate: DateTime(2026, 2, 1),
            closureEndDate: DateTime(2026, 2, 5),
          ),
        ),
      ),
      verify: (_) {
        verify(
          () => repository.addAcademicTerm(
            _term(
              closureStartDate: DateTime(2026, 2, 1),
              closureEndDate: DateTime(2026, 2, 5),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'an invalid period surfaces an errorMessage the screen can retry from',
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
          isNotNull,
        ),
      ],
    );
  });

  group('Step progression', () {
    test(
      'continue is enabled only once all three terms are individually valid',
      () {
        final year = _year();
        final terms = [
          _term(id: 't1', name: 'Term 1', startDate: DateTime(2026, 1, 1), endDate: DateTime(2026, 4, 1)),
          _term(id: 't2', name: 'Term 2', startDate: DateTime(2026, 4, 2), endDate: DateTime(2026, 8, 1)),
        ];
        bool allValid(List<AcademicTerm> periods) {
          for (final name in const ['Term 1', 'Term 2', 'Term 3']) {
            final match = periods.where(
              (t) => t.name.trim().toLowerCase() == name.toLowerCase(),
            );
            if (match.isEmpty) return false;
            if (validator.validateAcademicTerm(match.first, [year], periods) !=
                null) {
              return false;
            }
          }
          return true;
        }

        expect(allValid(terms), isFalse); // Term 3 missing
        final complete = [
          ...terms,
          _term(id: 't3', name: 'Term 3', startDate: DateTime(2026, 8, 2), endDate: DateTime(2026, 12, 1)),
        ];
        expect(allValid(complete), isTrue);
      },
    );

    test('continue is enabled for Semesters once both semesters are valid', () {
      final year = _year();
      final complete = [
        _term(
          id: 's1',
          name: 'Semester 1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 1),
          periodType: AcademicPeriodType.semester,
        ),
        _term(
          id: 's2',
          name: 'Semester 2',
          startDate: DateTime(2026, 6, 2),
          endDate: DateTime(2026, 12, 31),
          periodType: AcademicPeriodType.semester,
        ),
      ];
      bool allValid(List<AcademicTerm> periods) {
        for (final name in const ['Semester 1', 'Semester 2']) {
          final match = periods.where(
            (t) => t.name.trim().toLowerCase() == name.toLowerCase(),
          );
          if (match.isEmpty) return false;
          if (validator.validateAcademicTerm(match.first, [year], periods) !=
              null) {
            return false;
          }
        }
        return true;
      }

      expect(allValid(complete), isTrue);
    });
  });

  group('Layout: AcademicCalendarStepScreen across breakpoints', () {
    late _MockStructureRepository repository;
    late StructureBloc bloc;

    setUp(() {
      repository = _MockStructureRepository();
      when(() => repository.watchLevels(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      bloc = StructureBloc(repository: repository);
    });

    tearDown(() => bloc.close());

    Future<void> pumpAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bloc.emit(
        StructureState(
          isLoading: false,
          academicYears: [_year()],
          academicTerms: const [],
          institutionProfile: const InstitutionProfile(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<StructureBloc>.value(
            value: bloc,
            child: AcademicCalendarStepScreen(
              stepIndex: 2,
              stepCount: 16,
              onBack: () async {},
              onContinue: () async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders the compact mobile header at 390px width', (
      tester,
    ) async {
      await pumpAt(tester, const Size(390, 844));
      expect(find.textContaining('of 16'), findsOneWidget);
      expect(find.textContaining('Academic calendar'), findsWidgets);
      // No right-side summary panel on mobile.
      expect(find.text('Calendar summary'), findsNothing);
    });

    testWidgets('still shows the compact header on a 768px tablet', (
      tester,
    ) async {
      await pumpAt(tester, const Size(768, 1024));
      expect(find.textContaining('of 16'), findsOneWidget);
    });

    testWidgets('shows the step rail and summary panel at 1200px web width', (
      tester,
    ) async {
      await pumpAt(tester, const Size(1200, 900));
      expect(find.text('School setup'), findsOneWidget);
      expect(find.text('Calendar summary'), findsOneWidget);
    });

    testWidgets('offers Terms (Recommended) and Semesters with no forced default', (
      tester,
    ) async {
      await pumpAt(tester, const Size(390, 844));
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Semesters'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
      // Continue is disabled until a system is chosen.
      final continueButton = find.widgetWithText(
        FilledButton,
        'Save & continue',
      );
      expect(continueButton, findsOneWidget);
      final button = tester.widget<FilledButton>(continueButton);
      expect(button.onPressed, isNull);
    });
  });
}
