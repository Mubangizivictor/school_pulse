import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/document_template_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

DocumentTemplateDef _template({String id = 'template-1'}) =>
    DocumentTemplateDef(
      id: id,
      schoolId: 'school-1',
      name: 'Report Card',
      templateType: 'Report Card',
    );

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_template());
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

  group('Document template events', () {
    blocTest<StructureBloc, StructureState>(
      'DocumentTemplatesUpdated emits the new template list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(DocumentTemplatesUpdated([_template()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.documentTemplates,
          'documentTemplates',
          [_template()],
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'SaveDocumentTemplateRequested calls repository.addDocumentTemplate',
      build: () {
        when(
          () => repository.addDocumentTemplate(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(SaveDocumentTemplateRequested(_template())),
      verify: (_) {
        verify(() => repository.addDocumentTemplate(_template())).called(1);
      },
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteDocumentTemplateRequested calls repository.deleteDocumentTemplate',
      build: () {
        when(
          () => repository.deleteDocumentTemplate(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) =>
          bloc.add(const DeleteDocumentTemplateRequested('template-1')),
      verify: (_) {
        verify(() => repository.deleteDocumentTemplate('template-1')).called(1);
      },
    );
  });
}
