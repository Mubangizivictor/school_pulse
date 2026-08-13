import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/feature_toggles.dart';
import '../../domain/entities/institution_profile.dart';
import '../../domain/entities/campus_entities.dart';
import '../../domain/entities/hostel_entities.dart';
import '../../domain/entities/transport_structure_entities.dart';
import '../../domain/entities/fee_category_entities.dart';
import '../../domain/entities/assessment_grading_entities.dart';
import '../../domain/entities/timetable_config.dart';
import '../../domain/entities/attendance_config_entities.dart';
import '../../domain/entities/communication_config_entities.dart';
import '../../domain/entities/document_template_entities.dart';
import '../../domain/entities/custom_field_entities.dart';
import '../../domain/repositories/structure_repository.dart';
import '../datasources/structure_remote_data_source.dart';
import '../datasources/structure_local_data_source.dart';

/// Streams read live from Firestore (which already persists its own
/// offline cache) and side-effect write through to the Isar cache on
/// every emission, so a synchronous last-known-good copy is always on
/// disk for any future offline-only read path.
class StructureRepositoryImpl implements StructureRepository {
  final StructureRemoteDataSource remoteDataSource;
  final StructureLocalDataSource localDataSource;

  StructureRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<List<EducationalLevel>> watchLevels(String schoolId) {
    return remoteDataSource.watchLevels(schoolId).map((levels) {
      localDataSource.cacheLevels(levels);
      return levels;
    });
  }

  @override
  Future<void> addLevel(EducationalLevel level) =>
      remoteDataSource.saveLevel(level);

  @override
  Future<void> updateLevel(EducationalLevel level) =>
      remoteDataSource.saveLevel(level);

  @override
  Future<void> deleteLevel(String levelId) =>
      remoteDataSource.deleteLevel(levelId);

  @override
  Future<void> archiveLevel(String levelId) =>
      remoteDataSource.archiveLevel(levelId);

  @override
  Future<void> restoreLevel(String levelId) =>
      remoteDataSource.restoreLevel(levelId);

  @override
  Stream<List<AcademicYear>> watchAcademicYears(String schoolId) {
    return remoteDataSource.watchAcademicYears(schoolId).map((years) {
      localDataSource.cacheAcademicYears(years);
      return years;
    });
  }

  @override
  Future<void> addAcademicYear(AcademicYear year) =>
      remoteDataSource.saveAcademicYear(year);

  @override
  Future<void> updateAcademicYear(AcademicYear year) =>
      remoteDataSource.saveAcademicYear(year);

  @override
  Future<void> deleteAcademicYear(String yearId) =>
      remoteDataSource.deleteAcademicYear(yearId);

  @override
  Future<void> setCurrentAcademicYear(String yearId, String schoolId) =>
      remoteDataSource.setCurrentAcademicYear(yearId, schoolId);

  @override
  Future<void> archiveAcademicYear(String yearId) =>
      remoteDataSource.archiveAcademicYear(yearId);

  @override
  Future<void> restoreAcademicYear(String yearId) =>
      remoteDataSource.restoreAcademicYear(yearId);

  @override
  Stream<List<AcademicTerm>> watchAcademicTerms(String schoolId) {
    return remoteDataSource.watchAcademicTerms(schoolId).map((terms) {
      localDataSource.cacheAcademicTerms(terms);
      return terms;
    });
  }

  @override
  Future<void> addAcademicTerm(AcademicTerm term) =>
      remoteDataSource.saveAcademicTerm(term);

  @override
  Future<void> updateAcademicTerm(AcademicTerm term) =>
      remoteDataSource.saveAcademicTerm(term);

  @override
  Future<void> deleteAcademicTerm(String termId) =>
      remoteDataSource.deleteAcademicTerm(termId);

  @override
  Future<void> setCurrentAcademicTerm(String termId, String schoolId) =>
      remoteDataSource.setCurrentAcademicTerm(termId, schoolId);

  @override
  Future<void> archiveAcademicTerm(String termId) =>
      remoteDataSource.archiveAcademicTerm(termId);

  @override
  Future<void> restoreAcademicTerm(String termId) =>
      remoteDataSource.restoreAcademicTerm(termId);

  @override
  Stream<List<SchoolClass>> watchClasses(String schoolId) {
    return remoteDataSource.watchClasses(schoolId).map((classes) {
      localDataSource.cacheClasses(classes);
      return classes;
    });
  }

  @override
  Future<void> addClass(SchoolClass schoolClass) =>
      remoteDataSource.saveClass(schoolClass);

  @override
  Future<void> updateClass(SchoolClass schoolClass) =>
      remoteDataSource.saveClass(schoolClass);

  @override
  Future<void> deleteClass(String classId) =>
      remoteDataSource.deleteClass(classId);

  @override
  Future<void> archiveClass(String classId) =>
      remoteDataSource.archiveClass(classId);

  @override
  Future<void> restoreClass(String classId) =>
      remoteDataSource.restoreClass(classId);

  @override
  Stream<List<ClassStream>> watchStreams(String schoolId) {
    return remoteDataSource.watchStreams(schoolId).map((streams) {
      localDataSource.cacheStreams(streams);
      return streams;
    });
  }

  @override
  Future<void> addStream(ClassStream stream) =>
      remoteDataSource.saveStream(stream);

  @override
  Future<void> updateStream(ClassStream stream) =>
      remoteDataSource.saveStream(stream);

  @override
  Future<void> deleteStream(String streamId) =>
      remoteDataSource.deleteStream(streamId);

  @override
  Future<void> archiveStream(String streamId) =>
      remoteDataSource.archiveStream(streamId);

  @override
  Future<void> restoreStream(String streamId) =>
      remoteDataSource.restoreStream(streamId);

  @override
  Stream<List<Subject>> watchSubjects(String schoolId) {
    return remoteDataSource.watchSubjects(schoolId).map((subjects) {
      localDataSource.cacheSubjects(subjects);
      return subjects;
    });
  }

  @override
  Future<void> addSubject(Subject subject) =>
      remoteDataSource.saveSubject(subject);

  @override
  Future<void> updateSubject(Subject subject) =>
      remoteDataSource.saveSubject(subject);

  @override
  Future<void> deleteSubject(String subjectId) =>
      remoteDataSource.deleteSubject(subjectId);

  @override
  Stream<List<Department>> watchDepartments(String schoolId) {
    return remoteDataSource.watchDepartments(schoolId).map((departments) {
      localDataSource.cacheDepartments(departments);
      return departments;
    });
  }

  @override
  Future<void> addDepartment(Department department) =>
      remoteDataSource.saveDepartment(department);

  @override
  Future<void> updateDepartment(Department department) =>
      remoteDataSource.saveDepartment(department);

  @override
  Future<void> deleteDepartment(String departmentId) =>
      remoteDataSource.deleteDepartment(departmentId);

  @override
  Future<void> archiveDepartment(String departmentId) =>
      remoteDataSource.archiveDepartment(departmentId);

  @override
  Stream<List<StaffDesignation>> watchDesignations(String schoolId) {
    return remoteDataSource.watchDesignations(schoolId).map((designations) {
      localDataSource.cacheDesignations(designations);
      return designations;
    });
  }

  @override
  Future<void> addDesignation(StaffDesignation designation) =>
      remoteDataSource.saveDesignation(designation);

  @override
  Future<void> updateDesignation(StaffDesignation designation) =>
      remoteDataSource.saveDesignation(designation);

  @override
  Future<void> deleteDesignation(String designationId) =>
      remoteDataSource.deleteDesignation(designationId);

  @override
  Stream<List<StaffRole>> watchStaffRoles(String schoolId) {
    return remoteDataSource.watchStaffRoles(schoolId).map((roles) {
      localDataSource.cacheStaffRoles(roles);
      return roles;
    });
  }

  @override
  Future<void> addStaffRole(StaffRole role) =>
      remoteDataSource.saveStaffRole(role);

  @override
  Future<void> updateStaffRole(StaffRole role) =>
      remoteDataSource.saveStaffRole(role);

  @override
  Future<void> deleteStaffRole(String roleId) =>
      remoteDataSource.deleteStaffRole(roleId);

  @override
  Stream<FeatureToggles> watchFeatureToggles(String schoolId) =>
      remoteDataSource.watchFeatureToggles(schoolId);

  @override
  Future<void> updateFeatureToggles(FeatureToggles toggles, String schoolId) =>
      remoteDataSource.updateFeatureToggles(toggles, schoolId);

  @override
  Stream<InstitutionProfile> watchInstitutionProfile(String schoolId) =>
      remoteDataSource.watchInstitutionProfile(schoolId);

  @override
  Future<void> updateInstitutionProfile(
    InstitutionProfile profile,
    String schoolId,
  ) => remoteDataSource.updateInstitutionProfile(profile, schoolId);

  @override
  Stream<List<Campus>> watchCampuses(String schoolId) {
    return remoteDataSource.watchCampuses(schoolId).map((campuses) {
      localDataSource.cacheCampuses(campuses);
      return campuses;
    });
  }

  @override
  Future<void> addCampus(Campus campus) => remoteDataSource.saveCampus(campus);

  @override
  Future<void> updateCampus(Campus campus) =>
      remoteDataSource.saveCampus(campus);

  @override
  Future<void> deleteCampus(String campusId) =>
      remoteDataSource.deleteCampus(campusId);

  @override
  Future<void> archiveCampus(String campusId) =>
      remoteDataSource.archiveCampus(campusId);

  @override
  Stream<List<House>> watchHouses(String schoolId) {
    return remoteDataSource.watchHouses(schoolId).map((houses) {
      localDataSource.cacheHouses(houses);
      return houses;
    });
  }

  @override
  Future<void> addHouse(House house) => remoteDataSource.saveHouse(house);

  @override
  Future<void> updateHouse(House house) => remoteDataSource.saveHouse(house);

  @override
  Future<void> deleteHouse(String houseId) =>
      remoteDataSource.deleteHouse(houseId);

  @override
  Stream<List<Club>> watchClubs(String schoolId) {
    return remoteDataSource.watchClubs(schoolId).map((clubs) {
      localDataSource.cacheClubs(clubs);
      return clubs;
    });
  }

  @override
  Future<void> addClub(Club club) => remoteDataSource.saveClub(club);

  @override
  Future<void> updateClub(Club club) => remoteDataSource.saveClub(club);

  @override
  Future<void> deleteClub(String clubId) => remoteDataSource.deleteClub(clubId);

  @override
  Stream<List<Facility>> watchFacilities(String schoolId) {
    return remoteDataSource.watchFacilities(schoolId).map((facilities) {
      localDataSource.cacheFacilities(facilities);
      return facilities;
    });
  }

  @override
  Future<void> addFacility(Facility facility) =>
      remoteDataSource.saveFacility(facility);

  @override
  Future<void> updateFacility(Facility facility) =>
      remoteDataSource.saveFacility(facility);

  @override
  Future<void> deleteFacility(String facilityId) =>
      remoteDataSource.deleteFacility(facilityId);

  @override
  Stream<List<Hostel>> watchHostels(String schoolId) {
    return remoteDataSource.watchHostels(schoolId).map((hostels) {
      localDataSource.cacheHostels(hostels);
      return hostels;
    });
  }

  @override
  Future<void> addHostel(Hostel hostel) => remoteDataSource.saveHostel(hostel);

  @override
  Future<void> updateHostel(Hostel hostel) =>
      remoteDataSource.saveHostel(hostel);

  @override
  Future<void> deleteHostel(String hostelId) =>
      remoteDataSource.deleteHostel(hostelId);

  @override
  Stream<List<HostelRoom>> watchHostelRooms(String schoolId) {
    return remoteDataSource.watchHostelRooms(schoolId).map((rooms) {
      localDataSource.cacheHostelRooms(rooms);
      return rooms;
    });
  }

  @override
  Future<void> addHostelRoom(HostelRoom room) =>
      remoteDataSource.saveHostelRoom(room);

  @override
  Future<void> updateHostelRoom(HostelRoom room) =>
      remoteDataSource.saveHostelRoom(room);

  @override
  Future<void> deleteHostelRoom(String roomId) =>
      remoteDataSource.deleteHostelRoom(roomId);

  @override
  Stream<List<TransportRoute>> watchTransportRoutes(String schoolId) {
    return remoteDataSource.watchTransportRoutes(schoolId).map((routes) {
      localDataSource.cacheTransportRoutes(routes);
      return routes;
    });
  }

  @override
  Future<void> addTransportRoute(TransportRoute route) =>
      remoteDataSource.saveTransportRoute(route);

  @override
  Future<void> updateTransportRoute(TransportRoute route) =>
      remoteDataSource.saveTransportRoute(route);

  @override
  Future<void> deleteTransportRoute(String routeId) =>
      remoteDataSource.deleteTransportRoute(routeId);

  @override
  Stream<List<TransportStop>> watchTransportStops(String schoolId) {
    return remoteDataSource.watchTransportStops(schoolId).map((stops) {
      localDataSource.cacheTransportStops(stops);
      return stops;
    });
  }

  @override
  Future<void> addTransportStop(TransportStop stop) =>
      remoteDataSource.saveTransportStop(stop);

  @override
  Future<void> updateTransportStop(TransportStop stop) =>
      remoteDataSource.saveTransportStop(stop);

  @override
  Future<void> deleteTransportStop(String stopId) =>
      remoteDataSource.deleteTransportStop(stopId);

  @override
  Stream<List<TransportVehicle>> watchTransportVehicles(String schoolId) {
    return remoteDataSource.watchTransportVehicles(schoolId).map((vehicles) {
      localDataSource.cacheTransportVehicles(vehicles);
      return vehicles;
    });
  }

  @override
  Future<void> addTransportVehicle(TransportVehicle vehicle) =>
      remoteDataSource.saveTransportVehicle(vehicle);

  @override
  Future<void> updateTransportVehicle(TransportVehicle vehicle) =>
      remoteDataSource.saveTransportVehicle(vehicle);

  @override
  Future<void> deleteTransportVehicle(String vehicleId) =>
      remoteDataSource.deleteTransportVehicle(vehicleId);

  @override
  Stream<List<FeeCategory>> watchFeeCategories(String schoolId) {
    return remoteDataSource.watchFeeCategories(schoolId).map((categories) {
      localDataSource.cacheFeeCategories(categories);
      return categories;
    });
  }

  @override
  Future<void> addFeeCategory(FeeCategory category) =>
      remoteDataSource.saveFeeCategory(category);

  @override
  Future<void> updateFeeCategory(FeeCategory category) =>
      remoteDataSource.saveFeeCategory(category);

  @override
  Future<void> deleteFeeCategory(String categoryId) =>
      remoteDataSource.deleteFeeCategory(categoryId);

  @override
  Stream<List<AssessmentTypeDef>> watchAssessmentTypes(String schoolId) {
    return remoteDataSource.watchAssessmentTypes(schoolId).map((types) {
      localDataSource.cacheAssessmentTypes(types);
      return types;
    });
  }

  @override
  Future<void> addAssessmentType(AssessmentTypeDef type) =>
      remoteDataSource.saveAssessmentType(type);

  @override
  Future<void> updateAssessmentType(AssessmentTypeDef type) =>
      remoteDataSource.saveAssessmentType(type);

  @override
  Future<void> deleteAssessmentType(String typeId) =>
      remoteDataSource.deleteAssessmentType(typeId);

  @override
  Stream<List<GradingSystemDef>> watchGradingSystems(String schoolId) {
    return remoteDataSource.watchGradingSystems(schoolId).map((systems) {
      localDataSource.cacheGradingSystems(systems);
      return systems;
    });
  }

  @override
  Future<void> addGradingSystem(GradingSystemDef system) =>
      remoteDataSource.saveGradingSystem(system);

  @override
  Future<void> updateGradingSystem(GradingSystemDef system) =>
      remoteDataSource.saveGradingSystem(system);

  @override
  Future<void> deleteGradingSystem(String systemId) =>
      remoteDataSource.deleteGradingSystem(systemId);

  @override
  Stream<List<GradeBand>> watchGradeBands(String schoolId) {
    return remoteDataSource.watchGradeBands(schoolId).map((bands) {
      localDataSource.cacheGradeBands(bands);
      return bands;
    });
  }

  @override
  Future<void> addGradeBand(GradeBand band) =>
      remoteDataSource.saveGradeBand(band);

  @override
  Future<void> updateGradeBand(GradeBand band) =>
      remoteDataSource.saveGradeBand(band);

  @override
  Future<void> deleteGradeBand(String bandId) =>
      remoteDataSource.deleteGradeBand(bandId);

  @override
  Stream<TimetableConfig> watchTimetableConfig(String schoolId) =>
      remoteDataSource.watchTimetableConfig(schoolId);

  @override
  Future<void> updateTimetableConfig(TimetableConfig config, String schoolId) =>
      remoteDataSource.updateTimetableConfig(config, schoolId);

  @override
  Stream<List<AttendanceTypeDef>> watchAttendanceTypes(String schoolId) {
    return remoteDataSource.watchAttendanceTypes(schoolId).map((types) {
      localDataSource.cacheAttendanceTypes(types);
      return types;
    });
  }

  @override
  Future<void> addAttendanceType(AttendanceTypeDef type) =>
      remoteDataSource.saveAttendanceType(type);

  @override
  Future<void> updateAttendanceType(AttendanceTypeDef type) =>
      remoteDataSource.saveAttendanceType(type);

  @override
  Future<void> deleteAttendanceType(String typeId) =>
      remoteDataSource.deleteAttendanceType(typeId);

  @override
  Stream<List<AttendanceSessionDef>> watchAttendanceSessions(String schoolId) {
    return remoteDataSource.watchAttendanceSessions(schoolId).map((sessions) {
      localDataSource.cacheAttendanceSessions(sessions);
      return sessions;
    });
  }

  @override
  Future<void> addAttendanceSession(AttendanceSessionDef session) =>
      remoteDataSource.saveAttendanceSession(session);

  @override
  Future<void> updateAttendanceSession(AttendanceSessionDef session) =>
      remoteDataSource.saveAttendanceSession(session);

  @override
  Future<void> deleteAttendanceSession(String sessionId) =>
      remoteDataSource.deleteAttendanceSession(sessionId);

  @override
  Stream<List<AnnouncementCategoryDef>> watchAnnouncementCategories(
    String schoolId,
  ) {
    return remoteDataSource.watchAnnouncementCategories(schoolId).map((
      categories,
    ) {
      localDataSource.cacheAnnouncementCategories(categories);
      return categories;
    });
  }

  @override
  Future<void> addAnnouncementCategory(AnnouncementCategoryDef category) =>
      remoteDataSource.saveAnnouncementCategory(category);

  @override
  Future<void> updateAnnouncementCategory(AnnouncementCategoryDef category) =>
      remoteDataSource.saveAnnouncementCategory(category);

  @override
  Future<void> deleteAnnouncementCategory(String categoryId) =>
      remoteDataSource.deleteAnnouncementCategory(categoryId);

  @override
  Stream<List<NotificationCategoryDef>> watchNotificationCategories(
    String schoolId,
  ) {
    return remoteDataSource.watchNotificationCategories(schoolId).map((
      categories,
    ) {
      localDataSource.cacheNotificationCategories(categories);
      return categories;
    });
  }

  @override
  Future<void> addNotificationCategory(NotificationCategoryDef category) =>
      remoteDataSource.saveNotificationCategory(category);

  @override
  Future<void> updateNotificationCategory(NotificationCategoryDef category) =>
      remoteDataSource.saveNotificationCategory(category);

  @override
  Future<void> deleteNotificationCategory(String categoryId) =>
      remoteDataSource.deleteNotificationCategory(categoryId);

  @override
  Stream<List<MessageTemplateDef>> watchMessageTemplates(String schoolId) {
    return remoteDataSource.watchMessageTemplates(schoolId).map((templates) {
      localDataSource.cacheMessageTemplates(templates);
      return templates;
    });
  }

  @override
  Future<void> addMessageTemplate(MessageTemplateDef template) =>
      remoteDataSource.saveMessageTemplate(template);

  @override
  Future<void> updateMessageTemplate(MessageTemplateDef template) =>
      remoteDataSource.saveMessageTemplate(template);

  @override
  Future<void> deleteMessageTemplate(String templateId) =>
      remoteDataSource.deleteMessageTemplate(templateId);

  @override
  Stream<List<DocumentTemplateDef>> watchDocumentTemplates(String schoolId) {
    return remoteDataSource.watchDocumentTemplates(schoolId).map((templates) {
      localDataSource.cacheDocumentTemplates(templates);
      return templates;
    });
  }

  @override
  Future<void> addDocumentTemplate(DocumentTemplateDef template) =>
      remoteDataSource.saveDocumentTemplate(template);

  @override
  Future<void> updateDocumentTemplate(DocumentTemplateDef template) =>
      remoteDataSource.saveDocumentTemplate(template);

  @override
  Future<void> deleteDocumentTemplate(String templateId) =>
      remoteDataSource.deleteDocumentTemplate(templateId);

  @override
  Stream<List<CustomFieldDef>> watchCustomFields(String schoolId) {
    return remoteDataSource.watchCustomFields(schoolId).map((fields) {
      localDataSource.cacheCustomFields(fields);
      return fields;
    });
  }

  @override
  Future<void> addCustomField(CustomFieldDef field) =>
      remoteDataSource.saveCustomField(field);

  @override
  Future<void> updateCustomField(CustomFieldDef field) =>
      remoteDataSource.saveCustomField(field);

  @override
  Future<void> deleteCustomField(String fieldId) =>
      remoteDataSource.deleteCustomField(fieldId);
}
