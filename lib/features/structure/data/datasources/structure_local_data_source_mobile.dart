import 'package:isar/isar.dart';
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
import '../models/structure_isar_models.dart';
import 'structure_local_data_source.dart';

StructureLocalDataSource create({dynamic isar, dynamic remote}) =>
    StructureLocalDataSourceImpl(isar: isar as Isar);

class StructureLocalDataSourceImpl implements StructureLocalDataSource {
  final Isar isar;

  StructureLocalDataSourceImpl({required this.isar});

  @override
  Future<List<EducationalLevel>> getLevels() async {
    final cached = await isar.educationalLevelIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheLevels(List<EducationalLevel> levels) async {
    await isar.writeTxn(() async {
      await isar.educationalLevelIsars.clear();
      await isar.educationalLevelIsars.putAll(
        levels.map(EducationalLevelIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<AcademicYear>> getAcademicYears() async {
    final cached = await isar.academicYearIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAcademicYears(List<AcademicYear> years) async {
    await isar.writeTxn(() async {
      await isar.academicYearIsars.clear();
      await isar.academicYearIsars.putAll(
        years.map(AcademicYearIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<AcademicTerm>> getAcademicTerms() async {
    final cached = await isar.academicTermIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAcademicTerms(List<AcademicTerm> terms) async {
    await isar.writeTxn(() async {
      await isar.academicTermIsars.clear();
      await isar.academicTermIsars.putAll(
        terms.map(AcademicTermIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<SchoolClass>> getClasses() async {
    final cached = await isar.schoolClassIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheClasses(List<SchoolClass> classes) async {
    await isar.writeTxn(() async {
      await isar.schoolClassIsars.clear();
      await isar.schoolClassIsars.putAll(
        classes.map(SchoolClassIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<ClassStream>> getStreams() async {
    final cached = await isar.classStreamIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheStreams(List<ClassStream> streams) async {
    await isar.writeTxn(() async {
      await isar.classStreamIsars.clear();
      await isar.classStreamIsars.putAll(
        streams.map(ClassStreamIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<Subject>> getSubjects() async {
    final cached = await isar.subjectIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheSubjects(List<Subject> subjects) async {
    await isar.writeTxn(() async {
      await isar.subjectIsars.clear();
      await isar.subjectIsars.putAll(
        subjects.map(SubjectIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<Department>> getDepartments() async {
    final cached = await isar.departmentIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheDepartments(List<Department> departments) async {
    await isar.writeTxn(() async {
      await isar.departmentIsars.clear();
      await isar.departmentIsars.putAll(
        departments.map(DepartmentIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<StaffDesignation>> getDesignations() async {
    final cached = await isar.staffDesignationIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheDesignations(List<StaffDesignation> designations) async {
    await isar.writeTxn(() async {
      await isar.staffDesignationIsars.clear();
      await isar.staffDesignationIsars.putAll(
        designations.map(StaffDesignationIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<Campus>> getCampuses() async {
    final cached = await isar.campusIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheCampuses(List<Campus> campuses) async {
    await isar.writeTxn(() async {
      await isar.campusIsars.clear();
      await isar.campusIsars.putAll(
        campuses.map(CampusIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<House>> getHouses() async {
    final cached = await isar.houseIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheHouses(List<House> houses) async {
    await isar.writeTxn(() async {
      await isar.houseIsars.clear();
      await isar.houseIsars.putAll(houses.map(HouseIsar.fromEntity).toList());
    });
  }

  @override
  Future<List<Club>> getClubs() async {
    final cached = await isar.clubIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheClubs(List<Club> clubs) async {
    await isar.writeTxn(() async {
      await isar.clubIsars.clear();
      await isar.clubIsars.putAll(clubs.map(ClubIsar.fromEntity).toList());
    });
  }

  @override
  Future<List<Facility>> getFacilities() async {
    final cached = await isar.facilityIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheFacilities(List<Facility> facilities) async {
    await isar.writeTxn(() async {
      await isar.facilityIsars.clear();
      await isar.facilityIsars.putAll(
        facilities.map(FacilityIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<Hostel>> getHostels() async {
    final cached = await isar.hostelIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheHostels(List<Hostel> hostels) async {
    await isar.writeTxn(() async {
      await isar.hostelIsars.clear();
      await isar.hostelIsars.putAll(
        hostels.map(HostelIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<HostelRoom>> getHostelRooms() async {
    final cached = await isar.hostelRoomIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheHostelRooms(List<HostelRoom> rooms) async {
    await isar.writeTxn(() async {
      await isar.hostelRoomIsars.clear();
      await isar.hostelRoomIsars.putAll(
        rooms.map(HostelRoomIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<TransportRoute>> getTransportRoutes() async {
    final cached = await isar.transportRouteIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheTransportRoutes(List<TransportRoute> routes) async {
    await isar.writeTxn(() async {
      await isar.transportRouteIsars.clear();
      await isar.transportRouteIsars.putAll(
        routes.map(TransportRouteIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<TransportStop>> getTransportStops() async {
    final cached = await isar.transportStopIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheTransportStops(List<TransportStop> stops) async {
    await isar.writeTxn(() async {
      await isar.transportStopIsars.clear();
      await isar.transportStopIsars.putAll(
        stops.map(TransportStopIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<TransportVehicle>> getTransportVehicles() async {
    final cached = await isar.transportVehicleIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheTransportVehicles(List<TransportVehicle> vehicles) async {
    await isar.writeTxn(() async {
      await isar.transportVehicleIsars.clear();
      await isar.transportVehicleIsars.putAll(
        vehicles.map(TransportVehicleIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<FeeCategory>> getFeeCategories() async {
    final cached = await isar.structureFeeCategoryIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheFeeCategories(List<FeeCategory> categories) async {
    await isar.writeTxn(() async {
      await isar.structureFeeCategoryIsars.clear();
      await isar.structureFeeCategoryIsars.putAll(
        categories.map(StructureFeeCategoryIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<AssessmentTypeDef>> getAssessmentTypes() async {
    final cached = await isar.assessmentTypeDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAssessmentTypes(List<AssessmentTypeDef> types) async {
    await isar.writeTxn(() async {
      await isar.assessmentTypeDefIsars.clear();
      await isar.assessmentTypeDefIsars.putAll(
        types.map(AssessmentTypeDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<GradingSystemDef>> getGradingSystems() async {
    final cached = await isar.gradingSystemDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheGradingSystems(List<GradingSystemDef> systems) async {
    await isar.writeTxn(() async {
      await isar.gradingSystemDefIsars.clear();
      await isar.gradingSystemDefIsars.putAll(
        systems.map(GradingSystemDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<GradeBand>> getGradeBands() async {
    final cached = await isar.gradeBandIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheGradeBands(List<GradeBand> bands) async {
    await isar.writeTxn(() async {
      await isar.gradeBandIsars.clear();
      await isar.gradeBandIsars.putAll(
        bands.map(GradeBandIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<AttendanceTypeDef>> getAttendanceTypes() async {
    final cached = await isar.attendanceTypeDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAttendanceTypes(List<AttendanceTypeDef> types) async {
    await isar.writeTxn(() async {
      await isar.attendanceTypeDefIsars.clear();
      await isar.attendanceTypeDefIsars.putAll(
        types.map(AttendanceTypeDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<AttendanceSessionDef>> getAttendanceSessions() async {
    final cached = await isar.attendanceSessionDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAttendanceSessions(
    List<AttendanceSessionDef> sessions,
  ) async {
    await isar.writeTxn(() async {
      await isar.attendanceSessionDefIsars.clear();
      await isar.attendanceSessionDefIsars.putAll(
        sessions.map(AttendanceSessionDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<AnnouncementCategoryDef>> getAnnouncementCategories() async {
    final cached = await isar.announcementCategoryDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheAnnouncementCategories(
    List<AnnouncementCategoryDef> categories,
  ) async {
    await isar.writeTxn(() async {
      await isar.announcementCategoryDefIsars.clear();
      await isar.announcementCategoryDefIsars.putAll(
        categories.map(AnnouncementCategoryDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<NotificationCategoryDef>> getNotificationCategories() async {
    final cached = await isar.notificationCategoryDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheNotificationCategories(
    List<NotificationCategoryDef> categories,
  ) async {
    await isar.writeTxn(() async {
      await isar.notificationCategoryDefIsars.clear();
      await isar.notificationCategoryDefIsars.putAll(
        categories.map(NotificationCategoryDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<MessageTemplateDef>> getMessageTemplates() async {
    final cached = await isar.messageTemplateDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheMessageTemplates(List<MessageTemplateDef> templates) async {
    await isar.writeTxn(() async {
      await isar.messageTemplateDefIsars.clear();
      await isar.messageTemplateDefIsars.putAll(
        templates.map(MessageTemplateDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<DocumentTemplateDef>> getDocumentTemplates() async {
    final cached = await isar.documentTemplateDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheDocumentTemplates(
    List<DocumentTemplateDef> templates,
  ) async {
    await isar.writeTxn(() async {
      await isar.documentTemplateDefIsars.clear();
      await isar.documentTemplateDefIsars.putAll(
        templates.map(DocumentTemplateDefIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<CustomFieldDef>> getCustomFields() async {
    final cached = await isar.customFieldDefIsars.where().findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheCustomFields(List<CustomFieldDef> fields) async {
    await isar.writeTxn(() async {
      await isar.customFieldDefIsars.clear();
      await isar.customFieldDefIsars.putAll(
        fields.map(CustomFieldDefIsar.fromEntity).toList(),
      );
    });
  }
}
