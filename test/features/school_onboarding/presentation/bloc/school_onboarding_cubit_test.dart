import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/school_onboarding/domain/entities/education_level_selection.dart';
import 'package:school_pulse/features/school_onboarding/domain/entities/school_setup_draft.dart';
import 'package:school_pulse/features/school_onboarding/domain/repositories/school_onboarding_repository.dart';
import 'package:school_pulse/features/school_onboarding/presentation/bloc/school_onboarding_cubit.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

class _MockSchoolOnboardingRepository extends Mock
    implements SchoolOnboardingRepository {}

class _MockStructureRepository extends Mock implements StructureRepository {}

void main() {
  late _MockSchoolOnboardingRepository repository;
  late _MockStructureRepository structureRepository;

  setUpAll(() {
    registerFallbackValue(const SchoolSetupDraft());
    registerFallbackValue(const <EducationalLevel>[]);
  });

  setUp(() {
    repository = _MockSchoolOnboardingRepository();
    structureRepository = _MockStructureRepository();
    when(() => repository.watchDraft()).thenAnswer(
      (_) => Stream.value(const SchoolSetupDraft()),
    );
    when(() => repository.saveDraft(any())).thenAnswer((_) async {});
    when(() => structureRepository.saveLevelsBatch(any())).thenAnswer(
      (_) async {},
    );
  });

  SchoolOnboardingCubit buildCubit() => SchoolOnboardingCubit(
    repository: repository,
    structureRepository: structureRepository,
    schoolId: 'school-a',
  );

  test('initial load restores draft from watchDraft stream', () async {
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.draft, const SchoolSetupDraft());
    await cubit.close();
  });

  blocTest<SchoolOnboardingCubit, SchoolOnboardingCubitState>(
    'applyTemplate preselects the template preset levels and clears custom flag',
    build: buildCubit,
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.applyTemplate('primary');
    },
    verify: (cubit) {
      expect(cubit.state.draft.templateId, 'primary');
      expect(cubit.state.draft.isCustomSelection, isFalse);
      expect(cubit.state.draft.selectedLevels, hasLength(1));
      expect(cubit.state.draft.selectedLevels.single.category,
          LevelCategory.primary);
    },
  );

  blocTest<SchoolOnboardingCubit, SchoolOnboardingCubitState>(
    'editing selection away from the applied template marks it custom',
    build: buildCubit,
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.applyTemplate('primary');
      cubit.setSelectedLevels([
        ...cubit.state.draft.selectedLevels,
        kUgandaLevelOptions[2],
      ]);
    },
    verify: (cubit) {
      expect(cubit.state.draft.isCustomSelection, isTrue);
    },
  );

  blocTest<SchoolOnboardingCubit, SchoolOnboardingCubitState>(
    'removeLevel drops the level from the selection',
    build: buildCubit,
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.applyTemplate('combined');
      cubit.removeLevel('ug-secondary');
    },
    verify: (cubit) {
      expect(
        cubit.state.draft.selectedLevels.map((l) => l.id),
        isNot(contains('ug-secondary')),
      );
    },
  );

  test('canContinueFromLevelsStep is false with no levels selected', () async {
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.canContinueFromLevelsStep, isFalse);
    await cubit.close();
  });

  test('canContinueFromLevelsStep is false with duplicate custom names',
      () async {
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);
    cubit.setSelectedLevels(const [
      SelectableLevel(
        id: 'c1',
        category: LevelCategory.custom,
        name: 'Vocational',
        isCustom: true,
      ),
      SelectableLevel(
        id: 'c2',
        category: LevelCategory.custom,
        name: 'vocational',
        isCustom: true,
      ),
    ]);
    expect(cubit.state.canContinueFromLevelsStep, isFalse);
    await cubit.close();
  });

  test('provisionLevels writes via saveLevelsBatch and records provisioned ids',
      () async {
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);
    cubit.applyTemplate('primary');
    await Future<void>.delayed(Duration.zero);

    await cubit.provisionLevels();

    final captured = verify(
      () => structureRepository.saveLevelsBatch(captureAny()),
    ).captured;
    expect(captured, hasLength(1));
    final levels = captured.single as List<EducationalLevel>;
    expect(levels.single.name, 'Primary');
    expect(cubit.state.draft.provisionedLevelIds, hasLength(1));
    await cubit.close();
  });

  test('provisionLevels surfaces an error and does not swallow it', () async {
    when(() => structureRepository.saveLevelsBatch(any())).thenThrow(
      StateError('write failed'),
    );
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);
    cubit.applyTemplate('primary');
    await Future<void>.delayed(Duration.zero);

    await expectLater(cubit.provisionLevels(), throwsA(isA<StateError>()));
    expect(cubit.state.errorMessage, isNotNull);
    await cubit.close();
  });

  test('nextStep advances currentStepIndex and remembers the step', () async {
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);

    cubit.nextStep();

    expect(cubit.state.currentStepIndex, 1);
    verify(() => repository.saveDraft(any())).called(greaterThan(0));
    await cubit.close();
  });
}
