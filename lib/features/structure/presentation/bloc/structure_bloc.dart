import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/structure_repository.dart';
import 'structure_event.dart';
import 'structure_state.dart';

class StructureBloc extends Bloc<StructureEvent, StructureState> {
  final StructureRepository repository;

  StreamSubscription? _levelsSub;
  StreamSubscription? _yearsSub;
  StreamSubscription? _termsSub;
  StreamSubscription? _classesSub;
  StreamSubscription? _streamsSub;
  StreamSubscription? _subjectsSub;
  StreamSubscription? _departmentsSub;
  StreamSubscription? _designationsSub;
  StreamSubscription? _staffRolesSub;
  StreamSubscription? _togglesSub;
  StreamSubscription? _institutionProfileSub;
  StreamSubscription? _campusesSub;
  StreamSubscription? _housesSub;
  StreamSubscription? _clubsSub;
  StreamSubscription? _facilitiesSub;
  StreamSubscription? _hostelsSub;
  StreamSubscription? _hostelRoomsSub;
  StreamSubscription? _transportRoutesSub;
  StreamSubscription? _transportStopsSub;
  StreamSubscription? _transportVehiclesSub;
  StreamSubscription? _feeCategoriesSub;
  StreamSubscription? _assessmentTypesSub;
  StreamSubscription? _gradingSystemsSub;
  StreamSubscription? _gradeBandsSub;
  StreamSubscription? _timetableConfigSub;
  StreamSubscription? _attendanceTypesSub;
  StreamSubscription? _attendanceSessionsSub;
  StreamSubscription? _announcementCategoriesSub;
  StreamSubscription? _notificationCategoriesSub;
  StreamSubscription? _messageTemplatesSub;
  StreamSubscription? _documentTemplatesSub;
  StreamSubscription? _customFieldsSub;

  StructureBloc({required this.repository}) : super(const StructureState()) {
    on<LoadStructureData>(_onLoad);
    on<LevelsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, levels: event.levels)));
    on<AcademicYearsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, academicYears: event.years)));
    on<AcademicTermsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, academicTerms: event.terms)));
    on<ClassesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, classes: event.classes)));
    on<StreamsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, streams: event.streams)));
    on<SubjectsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, subjects: event.subjects)));
    on<DepartmentsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, departments: event.departments)));
    on<DesignationsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, designations: event.designations)));
    on<StaffRolesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, staffRoles: event.roles)));
    on<FeatureTogglesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, featureToggles: event.toggles)));
    on<InstitutionProfileUpdated>((event, emit) => emit(state.copyWith(isLoading: false, institutionProfile: event.profile)));
    on<CampusesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, campuses: event.campuses)));
    on<HousesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, houses: event.houses)));
    on<ClubsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, clubs: event.clubs)));
    on<FacilitiesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, facilities: event.facilities)));
    on<HostelsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, hostels: event.hostels)));
    on<HostelRoomsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, hostelRooms: event.rooms)));
    on<TransportRoutesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, transportRoutes: event.routes)));
    on<TransportStopsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, transportStops: event.stops)));
    on<TransportVehiclesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, transportVehicles: event.vehicles)));
    on<FeeCategoriesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, feeCategories: event.categories)));
    on<AssessmentTypesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, assessmentTypes: event.types)));
    on<GradingSystemsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, gradingSystems: event.systems)));
    on<GradeBandsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, gradeBands: event.bands)));
    on<TimetableConfigUpdated>((event, emit) => emit(state.copyWith(isLoading: false, timetableConfig: event.config)));
    on<AttendanceTypesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, attendanceTypes: event.types)));
    on<AttendanceSessionsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, attendanceSessions: event.sessions)));
    on<AnnouncementCategoriesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, announcementCategories: event.categories)));
    on<NotificationCategoriesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, notificationCategories: event.categories)));
    on<MessageTemplatesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, messageTemplates: event.templates)));
    on<DocumentTemplatesUpdated>((event, emit) => emit(state.copyWith(isLoading: false, documentTemplates: event.templates)));
    on<CustomFieldsUpdated>((event, emit) => emit(state.copyWith(isLoading: false, customFields: event.fields)));
    on<StructureLoadFailed>((event, emit) => emit(state.copyWith(isLoading: false, errorMessage: event.message)));

    on<SaveLevelRequested>((event, emit) => repository.addLevel(event.level));
    on<DeleteLevelRequested>((event, emit) => repository.deleteLevel(event.levelId));
    on<ArchiveLevelRequested>((event, emit) => repository.archiveLevel(event.levelId));

    on<SaveAcademicYearRequested>((event, emit) => repository.addAcademicYear(event.year));
    on<DeleteAcademicYearRequested>((event, emit) => repository.deleteAcademicYear(event.yearId));
    on<SetCurrentAcademicYearRequested>((event, emit) => repository.setCurrentAcademicYear(event.yearId, event.schoolId));

    on<SaveAcademicTermRequested>((event, emit) => repository.addAcademicTerm(event.term));
    on<DeleteAcademicTermRequested>((event, emit) => repository.deleteAcademicTerm(event.termId));
    on<SetCurrentAcademicTermRequested>((event, emit) => repository.setCurrentAcademicTerm(event.termId, event.schoolId));

    on<SaveClassRequested>((event, emit) => repository.addClass(event.schoolClass));
    on<DeleteClassRequested>((event, emit) => repository.deleteClass(event.classId));
    on<ArchiveClassRequested>((event, emit) => repository.archiveClass(event.classId));

    on<SaveStreamRequested>((event, emit) => repository.addStream(event.stream));
    on<DeleteStreamRequested>((event, emit) => repository.deleteStream(event.streamId));

    on<SaveSubjectRequested>((event, emit) => repository.addSubject(event.subject));
    on<DeleteSubjectRequested>((event, emit) => repository.deleteSubject(event.subjectId));

    on<SaveDepartmentRequested>((event, emit) => repository.addDepartment(event.department));
    on<DeleteDepartmentRequested>((event, emit) => repository.deleteDepartment(event.departmentId));
    on<ArchiveDepartmentRequested>((event, emit) => repository.archiveDepartment(event.departmentId));

    on<SaveDesignationRequested>((event, emit) => repository.addDesignation(event.designation));
    on<DeleteDesignationRequested>((event, emit) => repository.deleteDesignation(event.designationId));

    on<SaveStaffRoleRequested>((event, emit) => repository.addStaffRole(event.role));
    on<DeleteStaffRoleRequested>((event, emit) => repository.deleteStaffRole(event.roleId));

    on<UpdateFeatureTogglesRequested>((event, emit) => repository.updateFeatureToggles(event.toggles, event.schoolId));

    on<UpdateInstitutionProfileRequested>((event, emit) => repository.updateInstitutionProfile(event.profile, event.schoolId));

    on<SaveCampusRequested>((event, emit) => repository.addCampus(event.campus));
    on<DeleteCampusRequested>((event, emit) => repository.deleteCampus(event.campusId));
    on<ArchiveCampusRequested>((event, emit) => repository.archiveCampus(event.campusId));

    on<SaveHouseRequested>((event, emit) => repository.addHouse(event.house));
    on<DeleteHouseRequested>((event, emit) => repository.deleteHouse(event.houseId));

    on<SaveClubRequested>((event, emit) => repository.addClub(event.club));
    on<DeleteClubRequested>((event, emit) => repository.deleteClub(event.clubId));

    on<SaveFacilityRequested>((event, emit) => repository.addFacility(event.facility));
    on<DeleteFacilityRequested>((event, emit) => repository.deleteFacility(event.facilityId));

    on<SaveHostelRequested>((event, emit) => repository.addHostel(event.hostel));
    on<DeleteHostelRequested>((event, emit) => repository.deleteHostel(event.hostelId));

    on<SaveHostelRoomRequested>((event, emit) => repository.addHostelRoom(event.room));
    on<DeleteHostelRoomRequested>((event, emit) => repository.deleteHostelRoom(event.roomId));

    on<SaveTransportRouteRequested>((event, emit) => repository.addTransportRoute(event.route));
    on<DeleteTransportRouteRequested>((event, emit) => repository.deleteTransportRoute(event.routeId));

    on<SaveTransportStopRequested>((event, emit) => repository.addTransportStop(event.stop));
    on<DeleteTransportStopRequested>((event, emit) => repository.deleteTransportStop(event.stopId));

    on<SaveTransportVehicleRequested>((event, emit) => repository.addTransportVehicle(event.vehicle));
    on<DeleteTransportVehicleRequested>((event, emit) => repository.deleteTransportVehicle(event.vehicleId));

    on<SaveFeeCategoryRequested>((event, emit) => repository.addFeeCategory(event.category));
    on<DeleteFeeCategoryRequested>((event, emit) => repository.deleteFeeCategory(event.categoryId));

    on<SaveAssessmentTypeRequested>((event, emit) => repository.addAssessmentType(event.type));
    on<DeleteAssessmentTypeRequested>((event, emit) => repository.deleteAssessmentType(event.typeId));

    on<SaveGradingSystemRequested>((event, emit) => repository.addGradingSystem(event.system));
    on<DeleteGradingSystemRequested>((event, emit) => repository.deleteGradingSystem(event.systemId));

    on<SaveGradeBandRequested>((event, emit) => repository.addGradeBand(event.band));
    on<DeleteGradeBandRequested>((event, emit) => repository.deleteGradeBand(event.bandId));

    on<UpdateTimetableConfigRequested>((event, emit) => repository.updateTimetableConfig(event.config, event.schoolId));

    on<SaveAttendanceTypeRequested>((event, emit) => repository.addAttendanceType(event.type));
    on<DeleteAttendanceTypeRequested>((event, emit) => repository.deleteAttendanceType(event.typeId));

    on<SaveAttendanceSessionRequested>((event, emit) => repository.addAttendanceSession(event.session));
    on<DeleteAttendanceSessionRequested>((event, emit) => repository.deleteAttendanceSession(event.sessionId));

    on<SaveAnnouncementCategoryRequested>((event, emit) => repository.addAnnouncementCategory(event.category));
    on<DeleteAnnouncementCategoryRequested>((event, emit) => repository.deleteAnnouncementCategory(event.categoryId));

    on<SaveNotificationCategoryRequested>((event, emit) => repository.addNotificationCategory(event.category));
    on<DeleteNotificationCategoryRequested>((event, emit) => repository.deleteNotificationCategory(event.categoryId));

    on<SaveMessageTemplateRequested>((event, emit) => repository.addMessageTemplate(event.template));
    on<DeleteMessageTemplateRequested>((event, emit) => repository.deleteMessageTemplate(event.templateId));

    on<SaveDocumentTemplateRequested>((event, emit) => repository.addDocumentTemplate(event.template));
    on<DeleteDocumentTemplateRequested>((event, emit) => repository.deleteDocumentTemplate(event.templateId));

    on<SaveCustomFieldRequested>((event, emit) => repository.addCustomField(event.field));
    on<DeleteCustomFieldRequested>((event, emit) => repository.deleteCustomField(event.fieldId));
  }

  Future<void> _onLoad(LoadStructureData event, Emitter<StructureState> emit) async {
    await _levelsSub?.cancel();
    await _yearsSub?.cancel();
    await _termsSub?.cancel();
    await _classesSub?.cancel();
    await _streamsSub?.cancel();
    await _subjectsSub?.cancel();
    await _departmentsSub?.cancel();
    await _designationsSub?.cancel();
    await _staffRolesSub?.cancel();
    await _togglesSub?.cancel();
    await _institutionProfileSub?.cancel();
    await _campusesSub?.cancel();
    await _housesSub?.cancel();
    await _clubsSub?.cancel();
    await _facilitiesSub?.cancel();
    await _hostelsSub?.cancel();
    await _hostelRoomsSub?.cancel();
    await _transportRoutesSub?.cancel();
    await _transportStopsSub?.cancel();
    await _transportVehiclesSub?.cancel();
    await _feeCategoriesSub?.cancel();
    await _assessmentTypesSub?.cancel();
    await _gradingSystemsSub?.cancel();
    await _gradeBandsSub?.cancel();
    await _timetableConfigSub?.cancel();
    await _attendanceTypesSub?.cancel();
    await _attendanceSessionsSub?.cancel();
    await _announcementCategoriesSub?.cancel();
    await _notificationCategoriesSub?.cancel();
    await _messageTemplatesSub?.cancel();
    await _documentTemplatesSub?.cancel();
    await _customFieldsSub?.cancel();

    _levelsSub = repository.watchLevels(event.schoolId).listen(
          (levels) => add(LevelsUpdated(levels)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _yearsSub = repository.watchAcademicYears(event.schoolId).listen(
          (years) => add(AcademicYearsUpdated(years)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _termsSub = repository.watchAcademicTerms(event.schoolId).listen(
          (terms) => add(AcademicTermsUpdated(terms)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _classesSub = repository.watchClasses(event.schoolId).listen(
          (classes) => add(ClassesUpdated(classes)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _streamsSub = repository.watchStreams(event.schoolId).listen(
          (streams) => add(StreamsUpdated(streams)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _subjectsSub = repository.watchSubjects(event.schoolId).listen(
          (subjects) => add(SubjectsUpdated(subjects)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _departmentsSub = repository.watchDepartments(event.schoolId).listen(
          (departments) => add(DepartmentsUpdated(departments)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _designationsSub = repository.watchDesignations(event.schoolId).listen(
          (designations) => add(DesignationsUpdated(designations)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _staffRolesSub = repository.watchStaffRoles(event.schoolId).listen(
          (roles) => add(StaffRolesUpdated(roles)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _togglesSub = repository.watchFeatureToggles(event.schoolId).listen(
          (toggles) => add(FeatureTogglesUpdated(toggles)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _institutionProfileSub = repository.watchInstitutionProfile(event.schoolId).listen(
          (profile) => add(InstitutionProfileUpdated(profile)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _campusesSub = repository.watchCampuses(event.schoolId).listen(
          (campuses) => add(CampusesUpdated(campuses)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _housesSub = repository.watchHouses(event.schoolId).listen(
          (houses) => add(HousesUpdated(houses)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _clubsSub = repository.watchClubs(event.schoolId).listen(
          (clubs) => add(ClubsUpdated(clubs)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _facilitiesSub = repository.watchFacilities(event.schoolId).listen(
          (facilities) => add(FacilitiesUpdated(facilities)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _hostelsSub = repository.watchHostels(event.schoolId).listen(
          (hostels) => add(HostelsUpdated(hostels)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _hostelRoomsSub = repository.watchHostelRooms(event.schoolId).listen(
          (rooms) => add(HostelRoomsUpdated(rooms)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _transportRoutesSub = repository.watchTransportRoutes(event.schoolId).listen(
          (routes) => add(TransportRoutesUpdated(routes)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _transportStopsSub = repository.watchTransportStops(event.schoolId).listen(
          (stops) => add(TransportStopsUpdated(stops)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _transportVehiclesSub = repository.watchTransportVehicles(event.schoolId).listen(
          (vehicles) => add(TransportVehiclesUpdated(vehicles)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _feeCategoriesSub = repository.watchFeeCategories(event.schoolId).listen(
          (categories) => add(FeeCategoriesUpdated(categories)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _assessmentTypesSub = repository.watchAssessmentTypes(event.schoolId).listen(
          (types) => add(AssessmentTypesUpdated(types)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _gradingSystemsSub = repository.watchGradingSystems(event.schoolId).listen(
          (systems) => add(GradingSystemsUpdated(systems)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _gradeBandsSub = repository.watchGradeBands(event.schoolId).listen(
          (bands) => add(GradeBandsUpdated(bands)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _timetableConfigSub = repository.watchTimetableConfig(event.schoolId).listen(
          (config) => add(TimetableConfigUpdated(config)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _attendanceTypesSub = repository.watchAttendanceTypes(event.schoolId).listen(
          (types) => add(AttendanceTypesUpdated(types)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _attendanceSessionsSub = repository.watchAttendanceSessions(event.schoolId).listen(
          (sessions) => add(AttendanceSessionsUpdated(sessions)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _announcementCategoriesSub = repository.watchAnnouncementCategories(event.schoolId).listen(
          (categories) => add(AnnouncementCategoriesUpdated(categories)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _notificationCategoriesSub = repository.watchNotificationCategories(event.schoolId).listen(
          (categories) => add(NotificationCategoriesUpdated(categories)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _messageTemplatesSub = repository.watchMessageTemplates(event.schoolId).listen(
          (templates) => add(MessageTemplatesUpdated(templates)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _documentTemplatesSub = repository.watchDocumentTemplates(event.schoolId).listen(
          (templates) => add(DocumentTemplatesUpdated(templates)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
    _customFieldsSub = repository.watchCustomFields(event.schoolId).listen(
          (fields) => add(CustomFieldsUpdated(fields)),
          onError: (e) => add(StructureLoadFailed(e.toString())),
        );
  }

  @override
  Future<void> close() {
    _levelsSub?.cancel();
    _yearsSub?.cancel();
    _termsSub?.cancel();
    _classesSub?.cancel();
    _streamsSub?.cancel();
    _subjectsSub?.cancel();
    _departmentsSub?.cancel();
    _designationsSub?.cancel();
    _staffRolesSub?.cancel();
    _togglesSub?.cancel();
    _institutionProfileSub?.cancel();
    _campusesSub?.cancel();
    _housesSub?.cancel();
    _clubsSub?.cancel();
    _facilitiesSub?.cancel();
    _hostelsSub?.cancel();
    _hostelRoomsSub?.cancel();
    _transportRoutesSub?.cancel();
    _transportStopsSub?.cancel();
    _transportVehiclesSub?.cancel();
    _feeCategoriesSub?.cancel();
    _assessmentTypesSub?.cancel();
    _gradingSystemsSub?.cancel();
    _gradeBandsSub?.cancel();
    _timetableConfigSub?.cancel();
    _attendanceTypesSub?.cancel();
    _attendanceSessionsSub?.cancel();
    _announcementCategoriesSub?.cancel();
    _notificationCategoriesSub?.cancel();
    _messageTemplatesSub?.cancel();
    _documentTemplatesSub?.cancel();
    _customFieldsSub?.cancel();
    return super.close();
  }
}
