import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

const schoolId = 'school-1';

const GradingSystemDef _system = GradingSystemDef(
  id: 'sys-1',
  schoolId: schoolId,
  name: 'Primary standard',
  levelIds: ['level-1'],
  maximumMark: 100,
);

List<GradeBand> _validBands({String gradingSystemId = 'sys-1'}) => [
  GradeBand(
    id: 'b1',
    schoolId: schoolId,
    gradingSystemId: gradingSystemId,
    grade: 'D1',
    minScore: 80,
    maxScore: 100,
    order: 0,
  ),
  GradeBand(
    id: 'b2',
    schoolId: schoolId,
    gradingSystemId: gradingSystemId,
    grade: 'D2',
    minScore: 70,
    maxScore: 79,
    order: 1,
  ),
  GradeBand(
    id: 'b3',
    schoolId: schoolId,
    gradingSystemId: gradingSystemId,
    grade: 'F9',
    minScore: 0,
    maxScore: 69,
    order: 2,
  ),
];

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_system);
    registerFallbackValue(<GradeBand>[]);
  });

  setUp(() {
    repository = _MockStructureRepository();
  });

  group('SaveGradingSystemWithBandsRequested', () {
    blocTest<StructureBloc, StructureState>(
      'writes the system and its complete band set as one atomic call',
      build: () {
        when(
          () => repository.saveGradingSystemWithBands(any(), any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        SaveGradingSystemWithBandsRequested(_system, _validBands()),
      ),
      verify: (_) {
        verify(
          () => repository.saveGradingSystemWithBands(_system, _validBands()),
        ).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a band set with a gap before any write',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        SaveGradingSystemWithBandsRequested(_system, [
          const GradeBand(
            id: 'b1',
            schoolId: schoolId,
            gradingSystemId: 'sys-1',
            grade: 'D1',
            minScore: 80,
            maxScore: 100,
          ),
          const GradeBand(
            id: 'b2',
            schoolId: schoolId,
            gradingSystemId: 'sys-1',
            grade: 'F9',
            minScore: 0,
            maxScore: 60,
          ),
        ]),
      ),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.saveGradingSystemWithBands(any(), any()),
      ),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects overlapping bands before any write',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        SaveGradingSystemWithBandsRequested(_system, [
          const GradeBand(
            id: 'b1',
            schoolId: schoolId,
            gradingSystemId: 'sys-1',
            grade: 'D1',
            minScore: 60,
            maxScore: 100,
          ),
          const GradeBand(
            id: 'b2',
            schoolId: schoolId,
            gradingSystemId: 'sys-1',
            grade: 'F9',
            minScore: 0,
            maxScore: 69,
          ),
        ]),
      ),
      verify: (_) => verifyNever(
        () => repository.saveGradingSystemWithBands(any(), any()),
      ),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a band set that does not reach the maximum mark',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        SaveGradingSystemWithBandsRequested(_system, [
          const GradeBand(
            id: 'b1',
            schoolId: schoolId,
            gradingSystemId: 'sys-1',
            grade: 'D1',
            minScore: 0,
            maxScore: 90,
          ),
        ]),
      ),
      verify: (_) => verifyNever(
        () => repository.saveGradingSystemWithBands(any(), any()),
      ),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects an empty name before any write',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        SaveGradingSystemWithBandsRequested(
          _system.copyWith(name: '  '),
          _validBands(),
        ),
      ),
      verify: (_) => verifyNever(
        () => repository.saveGradingSystemWithBands(any(), any()),
      ),
    );
  });

  group('SaveGradingSystemRequested (default switching)', () {
    blocTest<StructureBloc, StructureState>(
      'delegates directly to the repository - no separate update loop, so '
      'default-switching stays inside the datasource\'s one atomic batch',
      build: () {
        when(() => repository.addGradingSystem(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      seed: () => StructureState(
        gradingSystems: [
          _system.copyWith(id: 'old-default', isDefault: true),
        ],
      ),
      act: (bloc) => bloc.add(
        SaveGradingSystemRequested(_system.copyWith(id: 'new-default', isDefault: true)),
      ),
      verify: (_) {
        verify(
          () => repository.addGradingSystem(
            _system.copyWith(id: 'new-default', isDefault: true),
          ),
        ).called(1);
        // The bloc must never call updateGradingSystem itself for this -
        // that responsibility belongs entirely to the atomic datasource
        // batch inside saveGradingSystem/saveGradingSystemWithBands.
        verifyNever(() => repository.updateGradingSystem(any()));
      },
    );
  });
}
