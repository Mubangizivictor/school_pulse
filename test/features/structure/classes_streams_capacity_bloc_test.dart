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
    registerFallbackValue(
      const Department(id: 'fallback', schoolId: schoolId, name: 'Fallback'),
    );
    registerFallbackValue(<Subject>[]);
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
    when(() => repository.addClasses(any())).thenAnswer((_) async {});
    when(() => repository.addSubjects(any())).thenAnswer((_) async {});
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
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
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

    blocTest<StructureBloc, StructureState>(
      'accepts a stream with no capacity set under a class with no capacity set',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(classes: [_class(capacity: 0)]),
      act: (bloc) => bloc.add(
        SaveStreamRequested(_stream(id: 'blue', capacity: 0, name: 'Blue')),
      ),
      verify: (_) {
        verify(() => repository.addStream(any())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'accepts a no-limit stream even when the class has a capacity set',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(classes: [_class(capacity: 50)]),
      act: (bloc) => bloc.add(
        SaveStreamRequested(_stream(id: 'blue', capacity: 0, name: 'Blue')),
      ),
      verify: (_) {
        verify(() => repository.addStream(any())).called(1);
      },
    );
  });

  group('CreateStreamsRequested bulk setup', () {
    blocTest<StructureBloc, StructureState>(
      'writes streams applied to multiple classes as one batch',
      build: () {
        when(() => repository.addStreams(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      seed: () => StructureState(
        classes: [
          _class(id: 'class-1', capacity: 0),
          _class(id: 'class-2', capacity: 0).copyWith(name: 'Primary 2'),
        ],
      ),
      act: (bloc) => bloc.add(
        CreateStreamsRequested([
          _stream(id: 'a', capacity: 0, classId: 'class-1', name: 'East'),
          _stream(id: 'b', capacity: 0, classId: 'class-2', name: 'East'),
        ]),
      ),
      verify: (_) {
        final captured =
            verify(() => repository.addStreams(captureAny())).captured.single
                as List<ClassStream>;
        expect(captured.length, 2);
        expect(captured.every((item) => item.schoolId == schoolId), isTrue);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'rejects duplicate stream names within the same class before any write',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(classes: [_class(id: 'class-1', capacity: 0)]),
      act: (bloc) => bloc.add(
        CreateStreamsRequested([
          _stream(id: 'a', capacity: 0, classId: 'class-1', name: 'East'),
          _stream(id: 'b', capacity: 0, classId: 'class-1', name: 'East'),
        ]),
      ),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('unique name'),
        ),
      ],
      verify: (_) => verifyNever(() => repository.addStreams(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a cross-tenant selection before any write',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(classes: [_class(id: 'class-1', capacity: 0)]),
      act: (bloc) => bloc.add(
        CreateStreamsRequested([
          _stream(id: 'a', capacity: 0, classId: 'class-1', name: 'East'),
          _stream(
            id: 'b',
            capacity: 0,
            classId: 'class-1',
            name: 'West',
          ).copyWith(schoolId: 'another-school'),
        ]),
      ),
      verify: (_) => verifyNever(() => repository.addStreams(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a bulk stream that would exceed its class capacity',
      build: () => StructureBloc(repository: repository),
      seed: () =>
          StructureState(classes: [_class(id: 'class-1', capacity: 10)]),
      act: (bloc) => bloc.add(
        CreateStreamsRequested([
          _stream(id: 'a', capacity: 20, classId: 'class-1', name: 'East'),
        ]),
      ),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Class capacity: 10'),
        ),
      ],
      verify: (_) => verifyNever(() => repository.addStreams(any())),
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
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
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

  group('CreateClassesRequested bulk setup', () {
    blocTest<StructureBloc, StructureState>(
      'writes a valid selection as one batch with its ordering and capacity',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(levels: [_level()]),
      act: (bloc) => bloc.add(
        CreateClassesRequested([
          _class(id: 'one', capacity: 32).copyWith(order: 0),
          _class(id: 'two', capacity: 32).copyWith(name: 'Primary 2', order: 1),
        ]),
      ),
      verify: (_) {
        final captured =
            verify(() => repository.addClasses(captureAny())).captured.single
                as List<SchoolClass>;
        expect(captured.map((item) => item.order), [0, 1]);
        expect(captured.map((item) => item.capacity), [32, 32]);
        expect(captured.every((item) => item.schoolId == schoolId), isTrue);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'rejects duplicate custom names before any write',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(levels: [_level()]),
      act: (bloc) => bloc.add(
        CreateClassesRequested([_class(id: 'one'), _class(id: 'two')]),
      ),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (state) => state.errorMessage,
          'errorMessage',
          contains('unique name'),
        ),
      ],
      verify: (_) => verifyNever(() => repository.addClasses(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a cross-tenant selection before any write',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(levels: [_level()]),
      act: (bloc) => bloc.add(
        CreateClassesRequested([
          _class(id: 'one'),
          _class(
            id: 'two',
          ).copyWith(schoolId: 'another-school', name: 'Primary 2'),
        ]),
      ),
      verify: (_) => verifyNever(() => repository.addClasses(any())),
    );
  });

  group('ReorderClassesRequested', () {
    blocTest<StructureBloc, StructureState>(
      'calls repository.reorderClasses when no dependent streams exist',
      build: () {
        when(() => repository.reorderClasses(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      seed: () => StructureState(
        levels: [_level()],
        classes: [
          _class(id: 'one').copyWith(order: 0),
          _class(id: 'two').copyWith(name: 'Primary 2', order: 1),
        ],
      ),
      act: (bloc) => bloc.add(
        ReorderClassesRequested([
          _class(id: 'two').copyWith(name: 'Primary 2', order: 0),
          _class(id: 'one').copyWith(order: 1),
        ]),
      ),
      verify: (_) {
        verify(() => repository.reorderClasses(any())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'is blocked once a class in the batch has dependent streams',
      build: () => StructureBloc(repository: repository),
      seed: () => StructureState(
        levels: [_level()],
        classes: [
          _class(id: 'one').copyWith(order: 0),
          _class(id: 'two').copyWith(name: 'Primary 2', order: 1),
        ],
        streams: [_stream(id: 'stream-1', capacity: 10, classId: 'one')],
      ),
      act: (bloc) => bloc.add(
        ReorderClassesRequested([
          _class(id: 'two').copyWith(name: 'Primary 2', order: 0),
          _class(id: 'one').copyWith(order: 1),
        ]),
      ),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (state) => state.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ],
      verify: (_) => verifyNever(() => repository.reorderClasses(any())),
    );
  });

  group('CreateSubjectsRequested catalogue setup', () {
    blocTest<StructureBloc, StructureState>(
      'writes unique subjects in one tenant-scoped batch',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        const CreateSubjectsRequested([
          Subject(id: 'eng', schoolId: schoolId, name: 'English', code: 'ENG'),
          Subject(
            id: 'mat',
            schoolId: schoolId,
            name: 'Mathematics',
            code: 'MAT',
          ),
        ]),
      ),
      verify: (_) => verify(() => repository.addSubjects(any())).called(1),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects duplicate names before a bulk write',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        const CreateSubjectsRequested([
          Subject(id: 'eng1', schoolId: schoolId, name: 'English'),
          Subject(id: 'eng2', schoolId: schoolId, name: 'english'),
        ]),
      ),
      verify: (_) => verifyNever(() => repository.addSubjects(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a cross-tenant bulk selection',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        const CreateSubjectsRequested([
          Subject(id: 'eng', schoolId: schoolId, name: 'English'),
          Subject(id: 'mat', schoolId: 'other-school', name: 'Mathematics'),
        ]),
      ),
      verify: (_) => verifyNever(() => repository.addSubjects(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a duplicate code within the same bulk batch',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(
        const CreateSubjectsRequested([
          Subject(id: 'eng', schoolId: schoolId, name: 'English', code: 'X'),
          Subject(
            id: 'mat',
            schoolId: schoolId,
            name: 'Mathematics',
            code: 'X',
          ),
        ]),
      ),
      verify: (_) => verifyNever(() => repository.addSubjects(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a name already used by an existing active subject',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(
        subjects: [
          Subject(id: 'existing', schoolId: schoolId, name: 'English'),
        ],
      ),
      act: (bloc) => bloc.add(
        const CreateSubjectsRequested([
          Subject(id: 'new', schoolId: schoolId, name: 'English'),
        ]),
      ),
      verify: (_) => verifyNever(() => repository.addSubjects(any())),
    );
  });

  group('DeleteSubjectRequested', () {
    blocTest<StructureBloc, StructureState>(
      'is always blocked to protect curriculum/marks/report history - archive instead',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(
        subjects: [Subject(id: 'eng', schoolId: schoolId, name: 'English')],
      ),
      act: (bloc) => bloc.add(const DeleteSubjectRequested('eng')),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Deactivate'),
        ),
      ],
      verify: (_) => verifyNever(() => repository.deleteSubject(any())),
    );

    blocTest<StructureBloc, StructureState>(
      'ArchiveSubjectRequested calls repository.archiveSubject',
      build: () {
        when(() => repository.archiveSubject(any())).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const ArchiveSubjectRequested('eng')),
      verify: (_) {
        verify(() => repository.archiveSubject('eng')).called(1);
      },
    );
  });

  group('SaveDepartmentWithSubjectsRequested', () {
    blocTest<StructureBloc, StructureState>(
      'calls repository.saveDepartmentWithSubjects with the added/removed lists',
      build: () {
        when(
          () => repository.saveDepartmentWithSubjects(any(), any(), any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        SaveDepartmentWithSubjectsRequested(
          const Department(id: 'dept-1', schoolId: schoolId, name: 'Languages'),
          const [Subject(id: 'eng', schoolId: schoolId, name: 'English')],
          const [Subject(id: 'mat', schoolId: schoolId, name: 'Mathematics')],
        ),
      ),
      verify: (_) {
        verify(
          () => repository.saveDepartmentWithSubjects(
            const Department(
              id: 'dept-1',
              schoolId: schoolId,
              name: 'Languages',
            ),
            const [Subject(id: 'eng', schoolId: schoolId, name: 'English')],
            const [Subject(id: 'mat', schoolId: schoolId, name: 'Mathematics')],
          ),
        ).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'rejects a duplicate department name before any write',
      build: () => StructureBloc(repository: repository),
      seed: () => const StructureState(
        departments: [
          Department(id: 'existing', schoolId: schoolId, name: 'Languages'),
        ],
      ),
      act: (bloc) => bloc.add(
        const SaveDepartmentWithSubjectsRequested(
          Department(id: 'dept-2', schoolId: schoolId, name: 'languages'),
          [],
          [],
        ),
      ),
      // _validationFailed emits a null-error state first so repeat
      // errors re-trigger the SnackBar listener; assert the error itself.
      skip: 1,
      expect: () => [
        isA<StructureState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('already exists'),
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.saveDepartmentWithSubjects(any(), any(), any()),
      ),
    );
  });
}
