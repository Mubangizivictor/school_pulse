import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/domain/entities/communication_config_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

class _MockStructureRepository extends Mock implements StructureRepository {}

AnnouncementCategoryDef _announcement({String id = 'ann-1'}) =>
    AnnouncementCategoryDef(id: id, schoolId: 'school-1', name: 'Academic');

NotificationCategoryDef _notification({String id = 'notif-1'}) =>
    NotificationCategoryDef(id: id, schoolId: 'school-1', name: 'Fee Reminder');

MessageTemplateDef _template({String id = 'msg-1'}) => MessageTemplateDef(
  id: id,
  schoolId: 'school-1',
  name: 'Fee Due',
  body: 'Your fee is due.',
);

void main() {
  late _MockStructureRepository repository;

  setUpAll(() {
    registerFallbackValue(_announcement());
    registerFallbackValue(_notification());
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
      () => repository.watchStaffRoles(any()),
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

  group('Announcement category events', () {
    blocTest<StructureBloc, StructureState>(
      'AnnouncementCategoriesUpdated emits the new category list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(AnnouncementCategoriesUpdated([_announcement()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.announcementCategories,
          'announcementCategories',
          [_announcement()],
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'SaveAnnouncementCategoryRequested calls repository.addAnnouncementCategory',
      build: () {
        when(
          () => repository.addAnnouncementCategory(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) =>
          bloc.add(SaveAnnouncementCategoryRequested(_announcement())),
      verify: (_) {
        verify(
          () => repository.addAnnouncementCategory(_announcement()),
        ).called(1);
      },
    );
  });

  group('Notification category events', () {
    blocTest<StructureBloc, StructureState>(
      'NotificationCategoriesUpdated emits the new category list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(NotificationCategoriesUpdated([_notification()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.notificationCategories,
          'notificationCategories',
          [_notification()],
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'DeleteNotificationCategoryRequested calls repository.deleteNotificationCategory',
      build: () {
        when(
          () => repository.deleteNotificationCategory(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) =>
          bloc.add(const DeleteNotificationCategoryRequested('notif-1')),
      verify: (_) {
        verify(
          () => repository.deleteNotificationCategory('notif-1'),
        ).called(1);
      },
    );
  });

  group('Message template events', () {
    blocTest<StructureBloc, StructureState>(
      'MessageTemplatesUpdated emits the new template list',
      build: () => StructureBloc(repository: repository),
      act: (bloc) => bloc.add(MessageTemplatesUpdated([_template()])),
      expect: () => [
        isA<StructureState>().having(
          (s) => s.messageTemplates,
          'messageTemplates',
          [_template()],
        ),
      ],
    );

    blocTest<StructureBloc, StructureState>(
      'SaveMessageTemplateRequested calls repository.addMessageTemplate',
      build: () {
        when(
          () => repository.addMessageTemplate(any()),
        ).thenAnswer((_) async {});
        return StructureBloc(repository: repository);
      },
      act: (bloc) => bloc.add(SaveMessageTemplateRequested(_template())),
      verify: (_) {
        verify(() => repository.addMessageTemplate(_template())).called(1);
      },
    );
  });
}
