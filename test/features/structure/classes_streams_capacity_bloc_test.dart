import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

const schoolId = 'school-1';

const _levelId = 'level-1';

EducationalLevel _level() =>
    const EducationalLevel(id: _levelId, schoolId: schoolId, name: 'Primary');

SchoolClass _class({int capacity = 50, String id = 'class-1'}) => SchoolClass(
  id: id,
  schoolId: schoolId,
  name: 'Primary 1',
  levelId: _levelId,
  capacity: capacity,
);

ClassStream _stream({
  required String id,
  required int capacity,
  bool isActive = true,
  String classId = 'class-1',
  String name = '',
}) => ClassStream(
  id: id,
  schoolId: schoolId,
  name: name.isEmpty ? id : name,
  classId: classId,
  capacity: capacity,
  isActive: isActive,
);

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_class());
    registerFallbackValue(_stream(id: 'x', capacity: 1));
  });

  setUp(() {
    repository = _MockStructureRepository();
    for (final stub in <void Function()>[
      () => when(
        () => repository.watchLevels(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAcademicYears(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAcademicTerms(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchClasses(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchStreams(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchSubjects(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchDepartments(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchDesignations(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchFeatureToggles(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchInstitutionProfile(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchCampuses(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchHouses(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchClubs(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchFacilities(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchHostels(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchHostelRooms(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchTransportRoutes(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchTransportStops(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchTransportVehicles(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchFeeCategories(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAssessmentTypes(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchGradingSystems(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchGradeBands(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchTimetableConfig(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAttendanceDefaultsConfig(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchCommunicationDefaultsConfig(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAttendanceTypes(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAttendanceSessions(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchAnnouncementCategories(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchNotificationCategories(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchMessageTemplates(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchDocumentTemplates(any()),
      ).thenAnswer((_) => const Stream.empty()),
      () => when(
        () => repository.watchCustomFields(any()),
      ).thenAnswer((_) => const Stream.empty()),
    ]) {
      stub();
    }
    when(() => repository.addClass(any())).thenAnswer((_) async {});
    when(() => repository.addStream(any())).thenAnswer((_) async {});
  });

  group('SaveStreamRequested capacity enforcement', () {
    blocTest<StructureBloc, StructureState>(
      'accepts a stream that fits within remaining class capacity',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(classes: [_class(capacity: 50)]),
      act: (bloc) => bloc.add(
        SaveStreamRequested(_stream(id: 'blue', capacity: 30, name: 'Blue')),
      ),
      verify: (_) {
        verify(() => repository.addStream(any())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a stream that would push total over class capacity',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(
        classes: [_class(capacity: 50)],
        streams: [_stream(id: 'blue', capacity: 30, name: 'Blue')],
      ),
      act: (bloc) => bloc.add(
        SaveStreamRequested(_stream(id: 'red', capacity: 25, name: 'Red')),
      ),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Class capacity: 50'),
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.addStream(any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'accepts a second stream that exactly fills remaining capacity',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(
        classes: [_class(capacity: 50)],
        streams: [_stream(id: 'blue', capacity: 30, name: 'Blue')],
      ),
      act: (bloc) => bloc.add(
        SaveStreamRequested(_stream(id: 'red', capacity: 20, name: 'Red')),
      ),
      verify: (_) {
        verify(() => repository.addStream(any())).called(1);
      },
    );
  });

  group('SaveClassRequested capacity-reduction enforcement', () {
    blocTest<StructureBloc, StructureState>(
      'rejects reducing class capacity below active stream allocation',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(
        levels: [_level()],
        classes: [_class(capacity: 50)],
        streams: [
          _stream(id: 'blue', capacity: 30, name: 'Blue'),
          _stream(id: 'red', capacity: 20, name: 'Red'),
        ],
      ),
      act: (bloc) => bloc.add(SaveClassRequested(_class(capacity: 40))),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('active streams already allocate 50 places'),
        ),
      ],
      verify: (_) {
        verifyNever(() => repository.addClass(any()));
      },
    );

    blocTest<StructureBloc, StructureState>(
      'allows reducing class capacity once an active stream is deactivated',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(
        levels: [_level()],
        classes: [_class(capacity: 50)],
        streams: [
          _stream(id: 'blue', capacity: 30, name: 'Blue', isActive: false),
          _stream(id: 'red', capacity: 20, name: 'Red'),
        ],
      ),
      act: (bloc) => bloc.add(SaveClassRequested(_class(capacity: 40))),
      verify: (_) {
        verify(() => repository.addClass(any())).called(1);
      },
    );
  });
}
