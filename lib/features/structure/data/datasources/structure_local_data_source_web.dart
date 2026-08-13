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
import 'structure_local_data_source.dart';

StructureLocalDataSource create({dynamic isar, dynamic remote}) =>
    const StructureLocalDataSourceWeb();

/// No local database on web. StructureRepositoryImpl reads live from
/// StructureRemoteDataSource.watch* and only ever calls this datasource's
/// cache* methods as a fire-and-forget side effect (no get* method here is
/// on any real read path) - so on web every get* returns empty and every
/// cache* is a no-op with no behavior change.
class StructureLocalDataSourceWeb implements StructureLocalDataSource {
  const StructureLocalDataSourceWeb();

  @override
  Future<List<EducationalLevel>> getLevels() async => [];
  @override
  Future<void> cacheLevels(List<EducationalLevel> levels) async {}

  @override
  Future<List<AcademicYear>> getAcademicYears() async => [];
  @override
  Future<void> cacheAcademicYears(List<AcademicYear> years) async {}

  @override
  Future<List<AcademicTerm>> getAcademicTerms() async => [];
  @override
  Future<void> cacheAcademicTerms(List<AcademicTerm> terms) async {}

  @override
  Future<List<SchoolClass>> getClasses() async => [];
  @override
  Future<void> cacheClasses(List<SchoolClass> classes) async {}

  @override
  Future<List<ClassStream>> getStreams() async => [];
  @override
  Future<void> cacheStreams(List<ClassStream> streams) async {}

  @override
  Future<List<Subject>> getSubjects() async => [];
  @override
  Future<void> cacheSubjects(List<Subject> subjects) async {}

  @override
  Future<List<Department>> getDepartments() async => [];
  @override
  Future<void> cacheDepartments(List<Department> departments) async {}

  @override
  Future<List<StaffDesignation>> getDesignations() async => [];
  @override
  Future<void> cacheDesignations(List<StaffDesignation> designations) async {}

  @override
  Future<List<StaffRole>> getStaffRoles() async => [];
  @override
  Future<void> cacheStaffRoles(List<StaffRole> roles) async {}

  @override
  Future<List<Campus>> getCampuses() async => [];
  @override
  Future<void> cacheCampuses(List<Campus> campuses) async {}

  @override
  Future<List<House>> getHouses() async => [];
  @override
  Future<void> cacheHouses(List<House> houses) async {}

  @override
  Future<List<Club>> getClubs() async => [];
  @override
  Future<void> cacheClubs(List<Club> clubs) async {}

  @override
  Future<List<Facility>> getFacilities() async => [];
  @override
  Future<void> cacheFacilities(List<Facility> facilities) async {}

  @override
  Future<List<Hostel>> getHostels() async => [];
  @override
  Future<void> cacheHostels(List<Hostel> hostels) async {}

  @override
  Future<List<HostelRoom>> getHostelRooms() async => [];
  @override
  Future<void> cacheHostelRooms(List<HostelRoom> rooms) async {}

  @override
  Future<List<TransportRoute>> getTransportRoutes() async => [];
  @override
  Future<void> cacheTransportRoutes(List<TransportRoute> routes) async {}

  @override
  Future<List<TransportStop>> getTransportStops() async => [];
  @override
  Future<void> cacheTransportStops(List<TransportStop> stops) async {}

  @override
  Future<List<TransportVehicle>> getTransportVehicles() async => [];
  @override
  Future<void> cacheTransportVehicles(List<TransportVehicle> vehicles) async {}

  @override
  Future<List<FeeCategory>> getFeeCategories() async => [];
  @override
  Future<void> cacheFeeCategories(List<FeeCategory> categories) async {}

  @override
  Future<List<AssessmentTypeDef>> getAssessmentTypes() async => [];
  @override
  Future<void> cacheAssessmentTypes(List<AssessmentTypeDef> types) async {}

  @override
  Future<List<GradingSystemDef>> getGradingSystems() async => [];
  @override
  Future<void> cacheGradingSystems(List<GradingSystemDef> systems) async {}

  @override
  Future<List<GradeBand>> getGradeBands() async => [];
  @override
  Future<void> cacheGradeBands(List<GradeBand> bands) async {}

  @override
  Future<List<AttendanceTypeDef>> getAttendanceTypes() async => [];
  @override
  Future<void> cacheAttendanceTypes(List<AttendanceTypeDef> types) async {}

  @override
  Future<List<AttendanceSessionDef>> getAttendanceSessions() async => [];
  @override
  Future<void> cacheAttendanceSessions(
    List<AttendanceSessionDef> sessions,
  ) async {}

  @override
  Future<List<AnnouncementCategoryDef>> getAnnouncementCategories() async => [];
  @override
  Future<void> cacheAnnouncementCategories(
    List<AnnouncementCategoryDef> categories,
  ) async {}

  @override
  Future<List<NotificationCategoryDef>> getNotificationCategories() async => [];
  @override
  Future<void> cacheNotificationCategories(
    List<NotificationCategoryDef> categories,
  ) async {}

  @override
  Future<List<MessageTemplateDef>> getMessageTemplates() async => [];
  @override
  Future<void> cacheMessageTemplates(
    List<MessageTemplateDef> templates,
  ) async {}

  @override
  Future<List<DocumentTemplateDef>> getDocumentTemplates() async => [];
  @override
  Future<void> cacheDocumentTemplates(
    List<DocumentTemplateDef> templates,
  ) async {}

  @override
  Future<List<CustomFieldDef>> getCustomFields() async => [];
  @override
  Future<void> cacheCustomFields(List<CustomFieldDef> fields) async {}
}
