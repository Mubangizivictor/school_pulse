import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

AttendanceTypeDef _type({String id = 'type-1'}) =>
    AttendanceTypeDef(id: id, schoolId: 'school-1', name: 'Present');

AttendanceSessionDef _session({String id = 'session-1'}) =>
    AttendanceSessionDef(id: id, schoolId: 'school-1', name: 'Morning');

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_type());
    registerFallbackValue(_session());
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

  group('Attendance type events', () {
    blocTest<StructureBloc, StructureState>(
      'AttendanceTypesUpdated emits the new type list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(AttendanceTypesUpdated([_type()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.attendanceTypes,
          'attendanceTypes',
          [_type()],
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'SaveAttendanceTypeRequested calls repository.addAttendanceType',
      build: () {
        when(
          () => repository.addAttendanceType(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(SaveAttendanceTypeRequested(_type())),
      verify: (_) {
        verify(() => repository.addAttendanceType(_type())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteAttendanceTypeRequested calls repository.deleteAttendanceType',
      build: () {
        when(
          () => repository.deleteAttendanceType(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const DeleteAttendanceTypeRequested('type-1')),
      verify: (_) {
        verify(() => repository.deleteAttendanceType('type-1')).called(1);
      },
    );
  });

  group('Attendance session events', () {
    blocTest<StructureBloc, StructureState>(
      'AttendanceSessionsUpdated emits the new session list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(AttendanceSessionsUpdated([_session()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.attendanceSessions,
          'attendanceSessions',
          [_session()],
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'SaveAttendanceSessionRequested calls repository.addAttendanceSession',
      build: () {
        when(
          () => repository.addAttendanceSession(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(SaveAttendanceSessionRequested(_session())),
      verify: (_) {
        verify(() => repository.addAttendanceSession(_session())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteAttendanceSessionRequested calls repository.deleteAttendanceSession',
      build: () {
        when(
          () => repository.deleteAttendanceSession(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) =>
          bloc.add(const DeleteAttendanceSessionRequested('session-1')),
      verify: (_) {
        verify(() => repository.deleteAttendanceSession('session-1')).called(1);
      },
    );
  });
}
