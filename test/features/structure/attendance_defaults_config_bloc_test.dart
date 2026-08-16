import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_defaults_config.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

const _config = AttendanceDefaultsConfig(
  attendanceMode: 'Daily',
  markingWindow: 'Same session only',
  allowBackdatedAttendance: true,
  autoPresentOnAdmission: true,
);

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_config);
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

  group('Attendance defaults config events', () {
    blocTest<StructureBloc, StructureState>(
      'AttendanceDefaultsConfigUpdated emits the new config',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(const AttendanceDefaultsConfigUpdated(_config)),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.attendanceDefaultsConfig,
          'attendanceDefaultsConfig',
          _config,
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'UpdateAttendanceDefaultsConfigRequested calls repository.updateAttendanceDefaultsConfig',
      build: () {
        when(
          () => repository.updateAttendanceDefaultsConfig(any(), any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        const UpdateAttendanceDefaultsConfigRequested(_config, 'school-1'),
      ),
      verify: (_) {
        verify(
          () => repository.updateAttendanceDefaultsConfig(_config, 'school-1'),
        ).called(1);
      },
    );
  });
}
