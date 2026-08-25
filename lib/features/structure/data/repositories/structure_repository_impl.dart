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
import '../../domain/entities/attendance_defaults_config.dart';
import '../../domain/entities/communication_config_entities.dart';
import '../../domain/entities/communication_defaults_config.dart';
import '../../domain/entities/document_template_entities.dart';
import '../../domain/entities/custom_field_entities.dart';
import '../../domain/repositories/structure_repository.dart';
import '../datasources/structure_remote_data_source.dart';
import '../datasources/structure_local_data_source.dart';

/// Streams read live from Firestore and side-effect write through to the
/// Isar cache on every emission. [_cached] additionally emits that cache
/// first (when non-empty) before the live stream's own emissions, so a
/// Structure screen opened offline shows the last-known-good data
/// immediately instead of an indefinite loading skeleton while the
/// `.snapshots()` listener waits for connectivity - the cache existed but
/// had no read path until now.
class StructureRepositoryImpl implements StructureRepository {
  final StructureRemoteDataSource remoteDataSource;
  final StructureLocalDataSource localDataSource;

  StructureRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Stream<List<T>> _cached<T>(
    Future<List<T>> Function() readCache,
    Stream<List<T>> live,
    Future<void> Function(List<T>) writeCache,
  ) async* {
    final cached = await readCache();
    if (cached.isNotEmpty) yield cached;
    await for (final value in live) {
      await writeCache(value);
      yield value;
    }
  }

  @override
  Stream<List<EducationalLevel>> watchLevels(String schoolId) => _cached(
    localDataSource.getLevels,
    remoteDataSource.watchLevels(schoolId),
    localDataSource.cacheLevels,
  );

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
  Future<void> reorderLevels(List<EducationalLevel> orderedLevels) =>
      remoteDataSource.reorderLevels(orderedLevels);

  @override
  Future<void> saveLevelsBatch(List<EducationalLevel> levels) =>
      remoteDataSource.saveLevelsBatch(levels);

  @override
  Stream<List<AcademicYear>> watchAcademicYears(String schoolId) => _cached(
    localDataSource.getAcademicYears,
    remoteDataSource.watchAcademicYears(schoolId),
    localDataSource.cacheAcademicYears,
  );

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
  Stream<List<AcademicTerm>> watchAcademicTerms(String schoolId) => _cached(
    localDataSource.getAcademicTerms,
    remoteDataSource.watchAcademicTerms(schoolId),
    localDataSource.cacheAcademicTerms,
  );

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
  Stream<List<SchoolClass>> watchClasses(String schoolId) => _cached(
    localDataSource.getClasses,
    remoteDataSource.watchClasses(schoolId),
    localDataSource.cacheClasses,
  );

  @override
  Future<void> addClass(SchoolClass schoolClass) =>
      remoteDataSource.saveClass(schoolClass);

  @override
  Future<void> addClasses(List<SchoolClass> classes) =>
      remoteDataSource.saveClasses(classes);

  @override
  Future<void> reorderClasses(List<SchoolClass> orderedClasses) =>
      remoteDataSource.reorderClasses(orderedClasses);

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
  Stream<List<ClassStream>> watchStreams(String schoolId) => _cached(
    localDataSource.getStreams,
    remoteDataSource.watchStreams(schoolId),
    localDataSource.cacheStreams,
  );

  @override
  Future<void> addStream(ClassStream stream) =>
      remoteDataSource.saveStream(stream);

  @override
  Future<void> addStreams(List<ClassStream> streams) =>
      remoteDataSource.saveStreams(streams);

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
  Stream<List<Subject>> watchSubjects(String schoolId) => _cached(
    localDataSource.getSubjects,
    remoteDataSource.watchSubjects(schoolId),
    localDataSource.cacheSubjects,
  );

  @override
  Future<void> addSubject(Subject subject) =>
      remoteDataSource.saveSubject(subject);

  @override
  Future<void> addSubjects(List<Subject> subjects) =>
      remoteDataSource.saveSubjects(subjects);

  @override
  Future<void> updateSubject(Subject subject) =>
      remoteDataSource.saveSubject(subject);

  @override
  Future<void> deleteSubject(String subjectId) =>
      remoteDataSource.deleteSubject(subjectId);

  @override
  Future<void> archiveSubject(String subjectId) =>
      remoteDataSource.archiveSubject(subjectId);

  @override
  Stream<List<Department>> watchDepartments(String schoolId) => _cached(
    localDataSource.getDepartments,
    remoteDataSource.watchDepartments(schoolId),
    localDataSource.cacheDepartments,
  );

  @override
  Future<void> addDepartment(Department department) =>
      remoteDataSource.saveDepartment(department);

  @override
  Future<void> saveDepartmentWithSubjects(
    Department department,
    List<Subject> addedSubjects,
    List<Subject> removedSubjects,
  ) => remoteDataSource.saveDepartmentWithSubjects(
    department,
    addedSubjects,
    removedSubjects,
  );

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
  Stream<List<StaffDesignation>> watchDesignations(String schoolId) => _cached(
    localDataSource.getDesignations,
    remoteDataSource.watchDesignations(schoolId),
    localDataSource.cacheDesignations,
  );

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
  Future<void> archiveDesignation(String designationId) =>
      remoteDataSource.archiveDesignation(designationId);

  @override
  Future<void> restoreDesignation(String designationId) =>
      remoteDataSource.restoreDesignation(designationId);

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
  Stream<List<Campus>> watchCampuses(String schoolId) => _cached(
    localDataSource.getCampuses,
    remoteDataSource.watchCampuses(schoolId),
    localDataSource.cacheCampuses,
  );

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
  Stream<List<House>> watchHouses(String schoolId) => _cached(
    localDataSource.getHouses,
    remoteDataSource.watchHouses(schoolId),
    localDataSource.cacheHouses,
  );

  @override
  Future<void> addHouse(House house) => remoteDataSource.saveHouse(house);

  @override
  Future<void> updateHouse(House house) => remoteDataSource.saveHouse(house);

  @override
  Future<void> deleteHouse(String houseId) =>
      remoteDataSource.deleteHouse(houseId);

  @override
  Stream<List<Club>> watchClubs(String schoolId) => _cached(
    localDataSource.getClubs,
    remoteDataSource.watchClubs(schoolId),
    localDataSource.cacheClubs,
  );

  @override
  Future<void> addClub(Club club) => remoteDataSource.saveClub(club);

  @override
  Future<void> updateClub(Club club) => remoteDataSource.saveClub(club);

  @override
  Future<void> deleteClub(String clubId) => remoteDataSource.deleteClub(clubId);

  @override
  Stream<List<Facility>> watchFacilities(String schoolId) => _cached(
    localDataSource.getFacilities,
    remoteDataSource.watchFacilities(schoolId),
    localDataSource.cacheFacilities,
  );

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
  Stream<List<Hostel>> watchHostels(String schoolId) => _cached(
    localDataSource.getHostels,
    remoteDataSource.watchHostels(schoolId),
    localDataSource.cacheHostels,
  );

  @override
  Future<void> addHostel(Hostel hostel) => remoteDataSource.saveHostel(hostel);

  @override
  Future<void> updateHostel(Hostel hostel) =>
      remoteDataSource.saveHostel(hostel);

  @override
  Future<void> deleteHostel(String hostelId) =>
      remoteDataSource.deleteHostel(hostelId);

  @override
  Stream<List<HostelRoom>> watchHostelRooms(String schoolId) => _cached(
    localDataSource.getHostelRooms,
    remoteDataSource.watchHostelRooms(schoolId),
    localDataSource.cacheHostelRooms,
  );

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
  Stream<List<TransportRoute>> watchTransportRoutes(String schoolId) => _cached(
    localDataSource.getTransportRoutes,
    remoteDataSource.watchTransportRoutes(schoolId),
    localDataSource.cacheTransportRoutes,
  );

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
  Stream<List<TransportStop>> watchTransportStops(String schoolId) => _cached(
    localDataSource.getTransportStops,
    remoteDataSource.watchTransportStops(schoolId),
    localDataSource.cacheTransportStops,
  );

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
  Stream<List<TransportVehicle>> watchTransportVehicles(String schoolId) =>
      _cached(
        localDataSource.getTransportVehicles,
        remoteDataSource.watchTransportVehicles(schoolId),
        localDataSource.cacheTransportVehicles,
      );

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
  Stream<List<FeeCategory>> watchFeeCategories(String schoolId) => _cached(
    localDataSource.getFeeCategories,
    remoteDataSource.watchFeeCategories(schoolId),
    localDataSource.cacheFeeCategories,
  );

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
  Stream<List<AssessmentTypeDef>> watchAssessmentTypes(String schoolId) =>
      _cached(
        localDataSource.getAssessmentTypes,
        remoteDataSource.watchAssessmentTypes(schoolId),
        localDataSource.cacheAssessmentTypes,
      );

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
  Stream<List<GradingSystemDef>> watchGradingSystems(String schoolId) =>
      _cached(
        localDataSource.getGradingSystems,
        remoteDataSource.watchGradingSystems(schoolId),
        localDataSource.cacheGradingSystems,
      );

  @override
  Future<void> addGradingSystem(GradingSystemDef system) =>
      remoteDataSource.saveGradingSystem(system);

  @override
  Future<void> saveGradingSystemWithBands(
    GradingSystemDef system,
    List<GradeBand> bands,
  ) => remoteDataSource.saveGradingSystemWithBands(system, bands);

  @override
  Future<void> updateGradingSystem(GradingSystemDef system) =>
      remoteDataSource.saveGradingSystem(system);

  @override
  Future<void> deleteGradingSystem(String systemId) =>
      remoteDataSource.deleteGradingSystem(systemId);

  @override
  Stream<List<GradeBand>> watchGradeBands(String schoolId) => _cached(
    localDataSource.getGradeBands,
    remoteDataSource.watchGradeBands(schoolId),
    localDataSource.cacheGradeBands,
  );

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
  Stream<AttendanceDefaultsConfig> watchAttendanceDefaultsConfig(
    String schoolId,
  ) => remoteDataSource.watchAttendanceDefaultsConfig(schoolId);

  @override
  Future<void> updateAttendanceDefaultsConfig(
    AttendanceDefaultsConfig config,
    String schoolId,
  ) => remoteDataSource.updateAttendanceDefaultsConfig(config, schoolId);

  @override
  Stream<CommunicationDefaultsConfig> watchCommunicationDefaultsConfig(
    String schoolId,
  ) => remoteDataSource.watchCommunicationDefaultsConfig(schoolId);

  @override
  Future<void> updateCommunicationDefaultsConfig(
    CommunicationDefaultsConfig config,
    String schoolId,
  ) => remoteDataSource.updateCommunicationDefaultsConfig(config, schoolId);

  @override
  Stream<List<AttendanceTypeDef>> watchAttendanceTypes(String schoolId) =>
      _cached(
        localDataSource.getAttendanceTypes,
        remoteDataSource.watchAttendanceTypes(schoolId),
        localDataSource.cacheAttendanceTypes,
      );

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
  Stream<List<AttendanceSessionDef>> watchAttendanceSessions(String schoolId) =>
      _cached(
        localDataSource.getAttendanceSessions,
        remoteDataSource.watchAttendanceSessions(schoolId),
        localDataSource.cacheAttendanceSessions,
      );

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
  ) => _cached(
    localDataSource.getAnnouncementCategories,
    remoteDataSource.watchAnnouncementCategories(schoolId),
    localDataSource.cacheAnnouncementCategories,
  );

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
  ) => _cached(
    localDataSource.getNotificationCategories,
    remoteDataSource.watchNotificationCategories(schoolId),
    localDataSource.cacheNotificationCategories,
  );

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
  Stream<List<MessageTemplateDef>> watchMessageTemplates(String schoolId) =>
      _cached(
        localDataSource.getMessageTemplates,
        remoteDataSource.watchMessageTemplates(schoolId),
        localDataSource.cacheMessageTemplates,
      );

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
  Stream<List<DocumentTemplateDef>> watchDocumentTemplates(String schoolId) =>
      _cached(
        localDataSource.getDocumentTemplates,
        remoteDataSource.watchDocumentTemplates(schoolId),
        localDataSource.cacheDocumentTemplates,
      );

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
  Stream<List<CustomFieldDef>> watchCustomFields(String schoolId) => _cached(
    localDataSource.getCustomFields,
    remoteDataSource.watchCustomFields(schoolId),
    localDataSource.cacheCustomFields,
  );

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
