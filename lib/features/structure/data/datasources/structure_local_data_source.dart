import 'package:isar/isar.dart';
import '../models/structure_isar_models.dart';

abstract class StructureLocalDataSource {
  Future<List<EducationalLevelIsar>> getLevels();
  Future<void> cacheLevels(List<EducationalLevelIsar> levels);

  Future<List<AcademicYearIsar>> getAcademicYears();
  Future<void> cacheAcademicYears(List<AcademicYearIsar> years);

  Future<List<AcademicTermIsar>> getAcademicTerms();
  Future<void> cacheAcademicTerms(List<AcademicTermIsar> terms);

  Future<List<SchoolClassIsar>> getClasses();
  Future<void> cacheClasses(List<SchoolClassIsar> classes);

  Future<List<ClassStreamIsar>> getStreams();
  Future<void> cacheStreams(List<ClassStreamIsar> streams);

  Future<List<SubjectIsar>> getSubjects();
  Future<void> cacheSubjects(List<SubjectIsar> subjects);

  Future<List<DepartmentIsar>> getDepartments();
  Future<void> cacheDepartments(List<DepartmentIsar> departments);

  Future<List<StaffDesignationIsar>> getDesignations();
  Future<void> cacheDesignations(List<StaffDesignationIsar> designations);

  Future<List<StaffRoleIsar>> getStaffRoles();
  Future<void> cacheStaffRoles(List<StaffRoleIsar> roles);

  Future<List<CampusIsar>> getCampuses();
  Future<void> cacheCampuses(List<CampusIsar> campuses);

  Future<List<HouseIsar>> getHouses();
  Future<void> cacheHouses(List<HouseIsar> houses);

  Future<List<ClubIsar>> getClubs();
  Future<void> cacheClubs(List<ClubIsar> clubs);

  Future<List<FacilityIsar>> getFacilities();
  Future<void> cacheFacilities(List<FacilityIsar> facilities);

  Future<List<HostelIsar>> getHostels();
  Future<void> cacheHostels(List<HostelIsar> hostels);

  Future<List<HostelRoomIsar>> getHostelRooms();
  Future<void> cacheHostelRooms(List<HostelRoomIsar> rooms);

  Future<List<TransportRouteIsar>> getTransportRoutes();
  Future<void> cacheTransportRoutes(List<TransportRouteIsar> routes);

  Future<List<TransportStopIsar>> getTransportStops();
  Future<void> cacheTransportStops(List<TransportStopIsar> stops);

  Future<List<TransportVehicleIsar>> getTransportVehicles();
  Future<void> cacheTransportVehicles(List<TransportVehicleIsar> vehicles);

  Future<List<StructureFeeCategoryIsar>> getFeeCategories();
  Future<void> cacheFeeCategories(List<StructureFeeCategoryIsar> categories);

  Future<List<AssessmentTypeDefIsar>> getAssessmentTypes();
  Future<void> cacheAssessmentTypes(List<AssessmentTypeDefIsar> types);

  Future<List<GradingSystemDefIsar>> getGradingSystems();
  Future<void> cacheGradingSystems(List<GradingSystemDefIsar> systems);

  Future<List<GradeBandIsar>> getGradeBands();
  Future<void> cacheGradeBands(List<GradeBandIsar> bands);

  Future<List<AttendanceTypeDefIsar>> getAttendanceTypes();
  Future<void> cacheAttendanceTypes(List<AttendanceTypeDefIsar> types);

  Future<List<AttendanceSessionDefIsar>> getAttendanceSessions();
  Future<void> cacheAttendanceSessions(List<AttendanceSessionDefIsar> sessions);

  Future<List<AnnouncementCategoryDefIsar>> getAnnouncementCategories();
  Future<void> cacheAnnouncementCategories(List<AnnouncementCategoryDefIsar> categories);

  Future<List<NotificationCategoryDefIsar>> getNotificationCategories();
  Future<void> cacheNotificationCategories(List<NotificationCategoryDefIsar> categories);

  Future<List<MessageTemplateDefIsar>> getMessageTemplates();
  Future<void> cacheMessageTemplates(List<MessageTemplateDefIsar> templates);

  Future<List<DocumentTemplateDefIsar>> getDocumentTemplates();
  Future<void> cacheDocumentTemplates(List<DocumentTemplateDefIsar> templates);

  Future<List<CustomFieldDefIsar>> getCustomFields();
  Future<void> cacheCustomFields(List<CustomFieldDefIsar> fields);
}

class StructureLocalDataSourceImpl implements StructureLocalDataSource {
  final Isar isar;

  StructureLocalDataSourceImpl({required this.isar});

  @override
  Future<List<EducationalLevelIsar>> getLevels() async {
    return await isar.educationalLevelIsars.where().findAll();
  }

  @override
  Future<void> cacheLevels(List<EducationalLevelIsar> levels) async {
    await isar.writeTxn(() async {
      await isar.educationalLevelIsars.clear();
      await isar.educationalLevelIsars.putAll(levels);
    });
  }

  @override
  Future<List<AcademicYearIsar>> getAcademicYears() async {
    return await isar.academicYearIsars.where().findAll();
  }

  @override
  Future<void> cacheAcademicYears(List<AcademicYearIsar> years) async {
    await isar.writeTxn(() async {
      await isar.academicYearIsars.clear();
      await isar.academicYearIsars.putAll(years);
    });
  }

  @override
  Future<List<AcademicTermIsar>> getAcademicTerms() async {
    return await isar.academicTermIsars.where().findAll();
  }

  @override
  Future<void> cacheAcademicTerms(List<AcademicTermIsar> terms) async {
    await isar.writeTxn(() async {
      await isar.academicTermIsars.clear();
      await isar.academicTermIsars.putAll(terms);
    });
  }

  @override
  Future<List<SchoolClassIsar>> getClasses() async {
    return await isar.schoolClassIsars.where().findAll();
  }

  @override
  Future<void> cacheClasses(List<SchoolClassIsar> classes) async {
    await isar.writeTxn(() async {
      await isar.schoolClassIsars.clear();
      await isar.schoolClassIsars.putAll(classes);
    });
  }

  @override
  Future<List<ClassStreamIsar>> getStreams() async {
    return await isar.classStreamIsars.where().findAll();
  }

  @override
  Future<void> cacheStreams(List<ClassStreamIsar> streams) async {
    await isar.writeTxn(() async {
      await isar.classStreamIsars.clear();
      await isar.classStreamIsars.putAll(streams);
    });
  }

  @override
  Future<List<SubjectIsar>> getSubjects() async {
    return await isar.subjectIsars.where().findAll();
  }

  @override
  Future<void> cacheSubjects(List<SubjectIsar> subjects) async {
    await isar.writeTxn(() async {
      await isar.subjectIsars.clear();
      await isar.subjectIsars.putAll(subjects);
    });
  }

  @override
  Future<List<DepartmentIsar>> getDepartments() async {
    return await isar.departmentIsars.where().findAll();
  }

  @override
  Future<void> cacheDepartments(List<DepartmentIsar> departments) async {
    await isar.writeTxn(() async {
      await isar.departmentIsars.clear();
      await isar.departmentIsars.putAll(departments);
    });
  }

  @override
  Future<List<StaffDesignationIsar>> getDesignations() async {
    return await isar.staffDesignationIsars.where().findAll();
  }

  @override
  Future<void> cacheDesignations(List<StaffDesignationIsar> designations) async {
    await isar.writeTxn(() async {
      await isar.staffDesignationIsars.clear();
      await isar.staffDesignationIsars.putAll(designations);
    });
  }

  @override
  Future<List<StaffRoleIsar>> getStaffRoles() async {
    return await isar.staffRoleIsars.where().findAll();
  }

  @override
  Future<void> cacheStaffRoles(List<StaffRoleIsar> roles) async {
    await isar.writeTxn(() async {
      await isar.staffRoleIsars.clear();
      await isar.staffRoleIsars.putAll(roles);
    });
  }

  @override
  Future<List<CampusIsar>> getCampuses() async => isar.campusIsars.where().findAll();

  @override
  Future<void> cacheCampuses(List<CampusIsar> campuses) async {
    await isar.writeTxn(() async {
      await isar.campusIsars.clear();
      await isar.campusIsars.putAll(campuses);
    });
  }

  @override
  Future<List<HouseIsar>> getHouses() async => isar.houseIsars.where().findAll();

  @override
  Future<void> cacheHouses(List<HouseIsar> houses) async {
    await isar.writeTxn(() async {
      await isar.houseIsars.clear();
      await isar.houseIsars.putAll(houses);
    });
  }

  @override
  Future<List<ClubIsar>> getClubs() async => isar.clubIsars.where().findAll();

  @override
  Future<void> cacheClubs(List<ClubIsar> clubs) async {
    await isar.writeTxn(() async {
      await isar.clubIsars.clear();
      await isar.clubIsars.putAll(clubs);
    });
  }

  @override
  Future<List<FacilityIsar>> getFacilities() async => isar.facilityIsars.where().findAll();

  @override
  Future<void> cacheFacilities(List<FacilityIsar> facilities) async {
    await isar.writeTxn(() async {
      await isar.facilityIsars.clear();
      await isar.facilityIsars.putAll(facilities);
    });
  }

  @override
  Future<List<HostelIsar>> getHostels() async => isar.hostelIsars.where().findAll();

  @override
  Future<void> cacheHostels(List<HostelIsar> hostels) async {
    await isar.writeTxn(() async {
      await isar.hostelIsars.clear();
      await isar.hostelIsars.putAll(hostels);
    });
  }

  @override
  Future<List<HostelRoomIsar>> getHostelRooms() async => isar.hostelRoomIsars.where().findAll();

  @override
  Future<void> cacheHostelRooms(List<HostelRoomIsar> rooms) async {
    await isar.writeTxn(() async {
      await isar.hostelRoomIsars.clear();
      await isar.hostelRoomIsars.putAll(rooms);
    });
  }

  @override
  Future<List<TransportRouteIsar>> getTransportRoutes() async =>
      isar.transportRouteIsars.where().findAll();

  @override
  Future<void> cacheTransportRoutes(List<TransportRouteIsar> routes) async {
    await isar.writeTxn(() async {
      await isar.transportRouteIsars.clear();
      await isar.transportRouteIsars.putAll(routes);
    });
  }

  @override
  Future<List<TransportStopIsar>> getTransportStops() async =>
      isar.transportStopIsars.where().findAll();

  @override
  Future<void> cacheTransportStops(List<TransportStopIsar> stops) async {
    await isar.writeTxn(() async {
      await isar.transportStopIsars.clear();
      await isar.transportStopIsars.putAll(stops);
    });
  }

  @override
  Future<List<TransportVehicleIsar>> getTransportVehicles() async =>
      isar.transportVehicleIsars.where().findAll();

  @override
  Future<void> cacheTransportVehicles(List<TransportVehicleIsar> vehicles) async {
    await isar.writeTxn(() async {
      await isar.transportVehicleIsars.clear();
      await isar.transportVehicleIsars.putAll(vehicles);
    });
  }

  @override
  Future<List<StructureFeeCategoryIsar>> getFeeCategories() async =>
      isar.structureFeeCategoryIsars.where().findAll();

  @override
  Future<void> cacheFeeCategories(List<StructureFeeCategoryIsar> categories) async {
    await isar.writeTxn(() async {
      await isar.structureFeeCategoryIsars.clear();
      await isar.structureFeeCategoryIsars.putAll(categories);
    });
  }

  @override
  Future<List<AssessmentTypeDefIsar>> getAssessmentTypes() async =>
      isar.assessmentTypeDefIsars.where().findAll();

  @override
  Future<void> cacheAssessmentTypes(List<AssessmentTypeDefIsar> types) async {
    await isar.writeTxn(() async {
      await isar.assessmentTypeDefIsars.clear();
      await isar.assessmentTypeDefIsars.putAll(types);
    });
  }

  @override
  Future<List<GradingSystemDefIsar>> getGradingSystems() async =>
      isar.gradingSystemDefIsars.where().findAll();

  @override
  Future<void> cacheGradingSystems(List<GradingSystemDefIsar> systems) async {
    await isar.writeTxn(() async {
      await isar.gradingSystemDefIsars.clear();
      await isar.gradingSystemDefIsars.putAll(systems);
    });
  }

  @override
  Future<List<GradeBandIsar>> getGradeBands() async => isar.gradeBandIsars.where().findAll();

  @override
  Future<void> cacheGradeBands(List<GradeBandIsar> bands) async {
    await isar.writeTxn(() async {
      await isar.gradeBandIsars.clear();
      await isar.gradeBandIsars.putAll(bands);
    });
  }

  @override
  Future<List<AttendanceTypeDefIsar>> getAttendanceTypes() async =>
      isar.attendanceTypeDefIsars.where().findAll();

  @override
  Future<void> cacheAttendanceTypes(List<AttendanceTypeDefIsar> types) async {
    await isar.writeTxn(() async {
      await isar.attendanceTypeDefIsars.clear();
      await isar.attendanceTypeDefIsars.putAll(types);
    });
  }

  @override
  Future<List<AttendanceSessionDefIsar>> getAttendanceSessions() async =>
      isar.attendanceSessionDefIsars.where().findAll();

  @override
  Future<void> cacheAttendanceSessions(List<AttendanceSessionDefIsar> sessions) async {
    await isar.writeTxn(() async {
      await isar.attendanceSessionDefIsars.clear();
      await isar.attendanceSessionDefIsars.putAll(sessions);
    });
  }

  @override
  Future<List<AnnouncementCategoryDefIsar>> getAnnouncementCategories() async =>
      isar.announcementCategoryDefIsars.where().findAll();

  @override
  Future<void> cacheAnnouncementCategories(List<AnnouncementCategoryDefIsar> categories) async {
    await isar.writeTxn(() async {
      await isar.announcementCategoryDefIsars.clear();
      await isar.announcementCategoryDefIsars.putAll(categories);
    });
  }

  @override
  Future<List<NotificationCategoryDefIsar>> getNotificationCategories() async =>
      isar.notificationCategoryDefIsars.where().findAll();

  @override
  Future<void> cacheNotificationCategories(List<NotificationCategoryDefIsar> categories) async {
    await isar.writeTxn(() async {
      await isar.notificationCategoryDefIsars.clear();
      await isar.notificationCategoryDefIsars.putAll(categories);
    });
  }

  @override
  Future<List<MessageTemplateDefIsar>> getMessageTemplates() async =>
      isar.messageTemplateDefIsars.where().findAll();

  @override
  Future<void> cacheMessageTemplates(List<MessageTemplateDefIsar> templates) async {
    await isar.writeTxn(() async {
      await isar.messageTemplateDefIsars.clear();
      await isar.messageTemplateDefIsars.putAll(templates);
    });
  }

  @override
  Future<List<DocumentTemplateDefIsar>> getDocumentTemplates() async =>
      isar.documentTemplateDefIsars.where().findAll();

  @override
  Future<void> cacheDocumentTemplates(List<DocumentTemplateDefIsar> templates) async {
    await isar.writeTxn(() async {
      await isar.documentTemplateDefIsars.clear();
      await isar.documentTemplateDefIsars.putAll(templates);
    });
  }

  @override
  Future<List<CustomFieldDefIsar>> getCustomFields() async =>
      isar.customFieldDefIsars.where().findAll();

  @override
  Future<void> cacheCustomFields(List<CustomFieldDefIsar> fields) async {
    await isar.writeTxn(() async {
      await isar.customFieldDefIsars.clear();
      await isar.customFieldDefIsars.putAll(fields);
    });
  }
}
