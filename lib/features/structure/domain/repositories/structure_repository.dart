import '../entities/structure_entities.dart';
import '../entities/feature_toggles.dart';
import '../entities/institution_profile.dart';
import '../entities/campus_entities.dart';
import '../entities/hostel_entities.dart';
import '../entities/transport_structure_entities.dart';
import '../entities/fee_category_entities.dart';
import '../entities/assessment_grading_entities.dart';
import '../entities/timetable_config.dart';
import '../entities/attendance_config_entities.dart';
import '../entities/communication_config_entities.dart';
import '../entities/document_template_entities.dart';
import '../entities/custom_field_entities.dart';

/// Single source of truth for a school's educational structure and
/// master data. Other modules that need this data should depend on this
/// interface (or the entities it returns) rather than duplicating their
/// own copies.
abstract class StructureRepository {
  // Educational Levels
  Stream<List<EducationalLevel>> watchLevels(String schoolId);
  Future<void> addLevel(EducationalLevel level);
  Future<void> updateLevel(EducationalLevel level);
  Future<void> deleteLevel(String levelId);
  Future<void> archiveLevel(String levelId);

  // Academic Years
  Stream<List<AcademicYear>> watchAcademicYears(String schoolId);
  Future<void> addAcademicYear(AcademicYear year);
  Future<void> updateAcademicYear(AcademicYear year);
  Future<void> deleteAcademicYear(String yearId);
  Future<void> setCurrentAcademicYear(String yearId, String schoolId);

  // Academic Terms
  Stream<List<AcademicTerm>> watchAcademicTerms(String schoolId);
  Future<void> addAcademicTerm(AcademicTerm term);
  Future<void> updateAcademicTerm(AcademicTerm term);
  Future<void> deleteAcademicTerm(String termId);
  Future<void> setCurrentAcademicTerm(String termId, String schoolId);

  // Classes
  Stream<List<SchoolClass>> watchClasses(String schoolId);
  Future<void> addClass(SchoolClass schoolClass);
  Future<void> updateClass(SchoolClass schoolClass);
  Future<void> deleteClass(String classId);
  Future<void> archiveClass(String classId);

  // Streams / Sections
  Stream<List<ClassStream>> watchStreams(String schoolId);
  Future<void> addStream(ClassStream stream);
  Future<void> updateStream(ClassStream stream);
  Future<void> deleteStream(String streamId);

  // Subjects
  Stream<List<Subject>> watchSubjects(String schoolId);
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);

  // Departments
  Stream<List<Department>> watchDepartments(String schoolId);
  Future<void> addDepartment(Department department);
  Future<void> updateDepartment(Department department);
  Future<void> deleteDepartment(String departmentId);
  Future<void> archiveDepartment(String departmentId);

  // Staff Designations
  Stream<List<StaffDesignation>> watchDesignations(String schoolId);
  Future<void> addDesignation(StaffDesignation designation);
  Future<void> updateDesignation(StaffDesignation designation);
  Future<void> deleteDesignation(String designationId);

  // Staff Roles
  Stream<List<StaffRole>> watchStaffRoles(String schoolId);
  Future<void> addStaffRole(StaffRole role);
  Future<void> updateStaffRole(StaffRole role);
  Future<void> deleteStaffRole(String roleId);

  // Feature Toggles
  Stream<FeatureToggles> watchFeatureToggles(String schoolId);
  Future<void> updateFeatureToggles(FeatureToggles toggles, String schoolId);

  // Institution Profile
  Stream<InstitutionProfile> watchInstitutionProfile(String schoolId);
  Future<void> updateInstitutionProfile(InstitutionProfile profile, String schoolId);

  // Campuses
  Stream<List<Campus>> watchCampuses(String schoolId);
  Future<void> addCampus(Campus campus);
  Future<void> updateCampus(Campus campus);
  Future<void> deleteCampus(String campusId);
  Future<void> archiveCampus(String campusId);

  // Houses
  Stream<List<House>> watchHouses(String schoolId);
  Future<void> addHouse(House house);
  Future<void> updateHouse(House house);
  Future<void> deleteHouse(String houseId);

  // Clubs & Societies
  Stream<List<Club>> watchClubs(String schoolId);
  Future<void> addClub(Club club);
  Future<void> updateClub(Club club);
  Future<void> deleteClub(String clubId);

  // Facilities
  Stream<List<Facility>> watchFacilities(String schoolId);
  Future<void> addFacility(Facility facility);
  Future<void> updateFacility(Facility facility);
  Future<void> deleteFacility(String facilityId);

  // Hostels
  Stream<List<Hostel>> watchHostels(String schoolId);
  Future<void> addHostel(Hostel hostel);
  Future<void> updateHostel(Hostel hostel);
  Future<void> deleteHostel(String hostelId);

  // Hostel Rooms
  Stream<List<HostelRoom>> watchHostelRooms(String schoolId);
  Future<void> addHostelRoom(HostelRoom room);
  Future<void> updateHostelRoom(HostelRoom room);
  Future<void> deleteHostelRoom(String roomId);

  // Transport Routes
  Stream<List<TransportRoute>> watchTransportRoutes(String schoolId);
  Future<void> addTransportRoute(TransportRoute route);
  Future<void> updateTransportRoute(TransportRoute route);
  Future<void> deleteTransportRoute(String routeId);

  // Transport Stops
  Stream<List<TransportStop>> watchTransportStops(String schoolId);
  Future<void> addTransportStop(TransportStop stop);
  Future<void> updateTransportStop(TransportStop stop);
  Future<void> deleteTransportStop(String stopId);

  // Transport Vehicles
  Stream<List<TransportVehicle>> watchTransportVehicles(String schoolId);
  Future<void> addTransportVehicle(TransportVehicle vehicle);
  Future<void> updateTransportVehicle(TransportVehicle vehicle);
  Future<void> deleteTransportVehicle(String vehicleId);

  // Fee Categories
  Stream<List<FeeCategory>> watchFeeCategories(String schoolId);
  Future<void> addFeeCategory(FeeCategory category);
  Future<void> updateFeeCategory(FeeCategory category);
  Future<void> deleteFeeCategory(String categoryId);

  // Assessment Types
  Stream<List<AssessmentTypeDef>> watchAssessmentTypes(String schoolId);
  Future<void> addAssessmentType(AssessmentTypeDef type);
  Future<void> updateAssessmentType(AssessmentTypeDef type);
  Future<void> deleteAssessmentType(String typeId);

  // Grading Systems
  Stream<List<GradingSystemDef>> watchGradingSystems(String schoolId);
  Future<void> addGradingSystem(GradingSystemDef system);
  Future<void> updateGradingSystem(GradingSystemDef system);
  Future<void> deleteGradingSystem(String systemId);

  // Grade Bands
  Stream<List<GradeBand>> watchGradeBands(String schoolId);
  Future<void> addGradeBand(GradeBand band);
  Future<void> updateGradeBand(GradeBand band);
  Future<void> deleteGradeBand(String bandId);

  // Timetable Config
  Stream<TimetableConfig> watchTimetableConfig(String schoolId);
  Future<void> updateTimetableConfig(TimetableConfig config, String schoolId);

  // Attendance Types
  Stream<List<AttendanceTypeDef>> watchAttendanceTypes(String schoolId);
  Future<void> addAttendanceType(AttendanceTypeDef type);
  Future<void> updateAttendanceType(AttendanceTypeDef type);
  Future<void> deleteAttendanceType(String typeId);

  // Attendance Sessions
  Stream<List<AttendanceSessionDef>> watchAttendanceSessions(String schoolId);
  Future<void> addAttendanceSession(AttendanceSessionDef session);
  Future<void> updateAttendanceSession(AttendanceSessionDef session);
  Future<void> deleteAttendanceSession(String sessionId);

  // Announcement Categories
  Stream<List<AnnouncementCategoryDef>> watchAnnouncementCategories(String schoolId);
  Future<void> addAnnouncementCategory(AnnouncementCategoryDef category);
  Future<void> updateAnnouncementCategory(AnnouncementCategoryDef category);
  Future<void> deleteAnnouncementCategory(String categoryId);

  // Notification Categories
  Stream<List<NotificationCategoryDef>> watchNotificationCategories(String schoolId);
  Future<void> addNotificationCategory(NotificationCategoryDef category);
  Future<void> updateNotificationCategory(NotificationCategoryDef category);
  Future<void> deleteNotificationCategory(String categoryId);

  // Message Templates
  Stream<List<MessageTemplateDef>> watchMessageTemplates(String schoolId);
  Future<void> addMessageTemplate(MessageTemplateDef template);
  Future<void> updateMessageTemplate(MessageTemplateDef template);
  Future<void> deleteMessageTemplate(String templateId);

  // Document Templates
  Stream<List<DocumentTemplateDef>> watchDocumentTemplates(String schoolId);
  Future<void> addDocumentTemplate(DocumentTemplateDef template);
  Future<void> updateDocumentTemplate(DocumentTemplateDef template);
  Future<void> deleteDocumentTemplate(String templateId);

  // Custom Fields
  Stream<List<CustomFieldDef>> watchCustomFields(String schoolId);
  Future<void> addCustomField(CustomFieldDef field);
  Future<void> updateCustomField(CustomFieldDef field);
  Future<void> deleteCustomField(String fieldId);
}
