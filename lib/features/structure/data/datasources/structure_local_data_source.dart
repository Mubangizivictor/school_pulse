import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/campus_entities.dart';
import '../../domain/entities/hostel_entities.dart';
import '../../domain/entities/transport_structure_entities.dart';
import '../../domain/entities/fee_category_entities.dart';
import '../../domain/entities/assessment_grading_entities.dart';
import '../../domain/entities/attendance_config_entities.dart';
import '../../domain/entities/communication_config_entities.dart';
import '../../domain/entities/document_template_entities.dart';
import '../../domain/entities/custom_field_entities.dart';

/// No Isar/isar-model import here on purpose - see
/// structure_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// structure_local_data_source_factory.dart's conditional import.
abstract class StructureLocalDataSource {
  Future<List<EducationalLevel>> getLevels();
  Future<void> cacheLevels(List<EducationalLevel> levels);

  Future<List<AcademicYear>> getAcademicYears();
  Future<void> cacheAcademicYears(List<AcademicYear> years);

  Future<List<AcademicTerm>> getAcademicTerms();
  Future<void> cacheAcademicTerms(List<AcademicTerm> terms);

  Future<List<SchoolClass>> getClasses();
  Future<void> cacheClasses(List<SchoolClass> classes);

  Future<List<ClassStream>> getStreams();
  Future<void> cacheStreams(List<ClassStream> streams);

  Future<List<Subject>> getSubjects();
  Future<void> cacheSubjects(List<Subject> subjects);

  Future<List<Department>> getDepartments();
  Future<void> cacheDepartments(List<Department> departments);

  Future<List<StaffDesignation>> getDesignations();
  Future<void> cacheDesignations(List<StaffDesignation> designations);

  Future<List<StaffRole>> getStaffRoles();
  Future<void> cacheStaffRoles(List<StaffRole> roles);

  Future<List<Campus>> getCampuses();
  Future<void> cacheCampuses(List<Campus> campuses);

  Future<List<House>> getHouses();
  Future<void> cacheHouses(List<House> houses);

  Future<List<Club>> getClubs();
  Future<void> cacheClubs(List<Club> clubs);

  Future<List<Facility>> getFacilities();
  Future<void> cacheFacilities(List<Facility> facilities);

  Future<List<Hostel>> getHostels();
  Future<void> cacheHostels(List<Hostel> hostels);

  Future<List<HostelRoom>> getHostelRooms();
  Future<void> cacheHostelRooms(List<HostelRoom> rooms);

  Future<List<TransportRoute>> getTransportRoutes();
  Future<void> cacheTransportRoutes(List<TransportRoute> routes);

  Future<List<TransportStop>> getTransportStops();
  Future<void> cacheTransportStops(List<TransportStop> stops);

  Future<List<TransportVehicle>> getTransportVehicles();
  Future<void> cacheTransportVehicles(List<TransportVehicle> vehicles);

  Future<List<FeeCategory>> getFeeCategories();
  Future<void> cacheFeeCategories(List<FeeCategory> categories);

  Future<List<AssessmentTypeDef>> getAssessmentTypes();
  Future<void> cacheAssessmentTypes(List<AssessmentTypeDef> types);

  Future<List<GradingSystemDef>> getGradingSystems();
  Future<void> cacheGradingSystems(List<GradingSystemDef> systems);

  Future<List<GradeBand>> getGradeBands();
  Future<void> cacheGradeBands(List<GradeBand> bands);

  Future<List<AttendanceTypeDef>> getAttendanceTypes();
  Future<void> cacheAttendanceTypes(List<AttendanceTypeDef> types);

  Future<List<AttendanceSessionDef>> getAttendanceSessions();
  Future<void> cacheAttendanceSessions(List<AttendanceSessionDef> sessions);

  Future<List<AnnouncementCategoryDef>> getAnnouncementCategories();
  Future<void> cacheAnnouncementCategories(
    List<AnnouncementCategoryDef> categories,
  );

  Future<List<NotificationCategoryDef>> getNotificationCategories();
  Future<void> cacheNotificationCategories(
    List<NotificationCategoryDef> categories,
  );

  Future<List<MessageTemplateDef>> getMessageTemplates();
  Future<void> cacheMessageTemplates(List<MessageTemplateDef> templates);

  Future<List<DocumentTemplateDef>> getDocumentTemplates();
  Future<void> cacheDocumentTemplates(List<DocumentTemplateDef> templates);

  Future<List<CustomFieldDef>> getCustomFields();
  Future<void> cacheCustomFields(List<CustomFieldDef> fields);
}
