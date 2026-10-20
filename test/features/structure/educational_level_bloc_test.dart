import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

EducationalLevel _level({String id = 'level-1', bool isActive = true}) =>
    EducationalLevel(
      id: id,
      schoolId: 'school-1',
      name: 'Primary',
      isActive: isActive,
    );

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_level());
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

  group('EducationalLevel events (previously unreachable from the UI)', () {
    blocTest<StructureBloc, StructureState>(
      'LevelsUpdated emits the new level list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(LevelsUpdated([_level()])),
      expect: () => [
        isA<StructureState>().having((s) => s.levels, 'levels', [_level()]),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'SaveLevelRequested calls repository.addLevel',
      build: () {
        when(() => repository.addLevel(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(SaveLevelRequested(_level())),
      verify: (_) {
        verify(() => repository.addLevel(_level())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteLevelRequested calls repository.deleteLevel',
      build: () {
        when(() => repository.deleteLevel(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const DeleteLevelRequested('level-1')),
      verify: (_) {
        verify(() => repository.deleteLevel('level-1')).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'ArchiveLevelRequested calls repository.archiveLevel instead of deleting',
      build: () {
        when(() => repository.archiveLevel(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const ArchiveLevelRequested('level-1')),
      verify: (_) {
        verify(() => repository.archiveLevel('level-1')).called(1);
        verifyNever(() => repository.deleteLevel(any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'LoadStructureData subscribes to watchLevels for the given school',
      build: () {
        when(
          () => repository.watchLevels('school-1'),
        ).thenAnswer((_) => Stream.value([_level()]));
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LoadStructureData('school-1')),
      expect: () => [
        isA<StructureState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<StructureState>().having((s) => s.levels, 'levels', [_level()]),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteLevelRequested is blocked when classes depend on the level',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(
        levels: [_level()],
        classes: [
          SchoolClass(
            id: 'class-1',
            schoolId: 'school-1',
            name: 'P1',
            levelId: 'level-1',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeleteLevelRequested('level-1')),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.deleteLevel(any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'ReorderLevelsRequested calls repository.reorderLevels with the new order',
      build: () {
        when(() => repository.reorderLevels(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        ReorderLevelsRequested([
          _level(id: 'level-2').copyWith(order: 0),
          _level(id: 'level-1').copyWith(order: 1),
        ]),
      ),
      verify: (_) {
        verify(() => repository.reorderLevels(any())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'SaveLevelWithReorderRequested calls repository.saveLevelsBatch atomically',
      build: () {
        when(() => repository.saveLevelsBatch(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        SaveLevelWithReorderRequested([
          _level(id: 'level-new').copyWith(name: 'Secondary', order: 0),
          _level(id: 'level-1').copyWith(order: 1),
        ]),
      ),
      verify: (_) {
        verify(() => repository.saveLevelsBatch(any())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'SaveLevelWithReorderRequested rejects a duplicate active level name',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(levels: [_level(id: 'level-1')]),
      act: (bloc) => bloc.add(
        SaveLevelWithReorderRequested([
          _level(id: 'level-new').copyWith(name: 'Primary', order: 1),
        ]),
      ),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.saveLevelsBatch(any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'Structure entry finishes loading without waiting for optional modules',
      build: () {
        when(
          () => repository.watchLevels(any()),
        ).thenAnswer((_) => Stream.value(<EducationalLevel>[]));
        when(
          () => repository.watchAcademicYears(any()),
        ).thenAnswer((_) => Stream.value(<AcademicYear>[]));
        when(
          () => repository.watchAcademicTerms(any()),
        ).thenAnswer((_) => Stream.value(<AcademicTerm>[]));
        when(
          () => repository.watchClasses(any()),
        ).thenAnswer((_) => Stream.value(<SchoolClass>[]));
        when(
          () => repository.watchSubjects(any()),
        ).thenAnswer((_) => Stream.value(<Subject>[]));
        when(
          () => repository.watchInstitutionProfile(any()),
        ).thenAnswer((_) => Stream.value(const InstitutionProfile()));
        when(
          () => repository.watchGradingSystems(any()),
        ).thenAnswer((_) => Stream.value(<GradingSystemDef>[]));
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LoadStructureData('school-1')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.state.isLoading, isFalse),
    );
  });
}
