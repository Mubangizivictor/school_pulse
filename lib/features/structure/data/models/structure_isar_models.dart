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

part 'structure_isar_models.g.dart';

@collection
class EducationalLevelIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String levelId;

  late String schoolId;
  late String name;
  late String code;
  late int order;
  late String description;
  late bool isActive;

  EducationalLevelIsar();

  factory EducationalLevelIsar.fromEntity(EducationalLevel e) {
    return EducationalLevelIsar()
      ..levelId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..order = e.order
      ..description = e.description
      ..isActive = e.isActive;
  }

  EducationalLevel toEntity() {
    return EducationalLevel(
      id: levelId,
      schoolId: schoolId,
      name: name,
      code: code,
      order: order,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class AcademicYearIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String yearId;

  late String schoolId;
  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late bool isCurrent;
  late bool isArchived;

  AcademicYearIsar();

  factory AcademicYearIsar.fromEntity(AcademicYear e) {
    return AcademicYearIsar()
      ..yearId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..startDate = e.startDate
      ..endDate = e.endDate
      ..isCurrent = e.isCurrent
      ..isArchived = e.isArchived;
  }

  AcademicYear toEntity() {
    return AcademicYear(
      id: yearId,
      schoolId: schoolId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      isArchived: isArchived,
    );
  }
}

@collection
class AcademicTermIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String termId;

  late String schoolId;
  late String academicYearId;
  late String name;
  late int order;
  late DateTime startDate;
  late DateTime endDate;
  late bool isCurrent;
  late String periodType;
  late bool isArchived;

  AcademicTermIsar();

  factory AcademicTermIsar.fromEntity(AcademicTerm e) {
    return AcademicTermIsar()
      ..termId = e.id
      ..schoolId = e.schoolId
      ..academicYearId = e.academicYearId
      ..name = e.name
      ..order = e.order
      ..startDate = e.startDate
      ..endDate = e.endDate
      ..isCurrent = e.isCurrent
      ..periodType = e.periodType.name
      ..isArchived = e.isArchived;
  }

  AcademicTerm toEntity() {
    return AcademicTerm(
      id: termId,
      schoolId: schoolId,
      academicYearId: academicYearId,
      name: name,
      order: order,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      periodType: AcademicPeriodType.values.firstWhere(
        (t) => t.name == periodType,
        orElse: () => AcademicPeriodType.term,
      ),
      isArchived: isArchived,
    );
  }
}

@collection
class SchoolClassIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String classId;

  late String schoolId;
  late String name;
  late String code;
  late String levelId;
  late int capacity;
  late String description;
  late bool isActive;

  SchoolClassIsar();

  factory SchoolClassIsar.fromEntity(SchoolClass e) {
    return SchoolClassIsar()
      ..classId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..levelId = e.levelId
      ..capacity = e.capacity
      ..description = e.description
      ..isActive = e.isActive;
  }

  SchoolClass toEntity() {
    return SchoolClass(
      id: classId,
      schoolId: schoolId,
      name: name,
      code: code,
      levelId: levelId,
      capacity: capacity,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class ClassStreamIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String streamId;

  late String schoolId;
  late String name;
  late String code;
  late String classId;
  late int capacity;
  late bool isActive;

  ClassStreamIsar();

  factory ClassStreamIsar.fromEntity(ClassStream e) {
    return ClassStreamIsar()
      ..streamId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..classId = e.classId
      ..capacity = e.capacity
      ..isActive = e.isActive;
  }

  ClassStream toEntity() {
    return ClassStream(
      id: streamId,
      schoolId: schoolId,
      name: name,
      code: code,
      classId: classId,
      capacity: capacity,
      isActive: isActive,
    );
  }
}

@collection
class SubjectIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String subjectId;

  late String schoolId;
  late String name;
  late String code;
  late String departmentId;
  late String color;
  late String description;
  late bool isElective;
  late bool isPractical;
  late int creditUnits;
  late bool isActive;
  List<String> assignedLevelIds = [];
  List<String> assignedClassIds = [];

  SubjectIsar();

  factory SubjectIsar.fromEntity(Subject e) {
    return SubjectIsar()
      ..subjectId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..departmentId = e.departmentId
      ..color = e.color
      ..description = e.description
      ..isElective = e.isElective
      ..isPractical = e.isPractical
      ..creditUnits = e.creditUnits
      ..isActive = e.isActive
      ..assignedLevelIds = e.assignedLevelIds
      ..assignedClassIds = e.assignedClassIds;
  }

  Subject toEntity() {
    return Subject(
      id: subjectId,
      schoolId: schoolId,
      name: name,
      code: code,
      departmentId: departmentId,
      color: color,
      description: description,
      isElective: isElective,
      isPractical: isPractical,
      creditUnits: creditUnits,
      isActive: isActive,
      assignedLevelIds: assignedLevelIds,
      assignedClassIds: assignedClassIds,
    );
  }
}

@collection
class DepartmentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String departmentId;

  late String schoolId;
  late String name;
  late String code;
  late String description;
  late String headOfDepartmentStaffId;
  late bool isActive;

  DepartmentIsar();

  factory DepartmentIsar.fromEntity(Department e) {
    return DepartmentIsar()
      ..departmentId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..description = e.description
      ..headOfDepartmentStaffId = e.headOfDepartmentStaffId
      ..isActive = e.isActive;
  }

  Department toEntity() {
    return Department(
      id: departmentId,
      schoolId: schoolId,
      name: name,
      code: code,
      description: description,
      headOfDepartmentStaffId: headOfDepartmentStaffId,
      isActive: isActive,
    );
  }
}

@collection
class StaffDesignationIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String designationId;

  late String schoolId;
  late String name;
  late String description;
  late bool isActive;

  StaffDesignationIsar();

  factory StaffDesignationIsar.fromEntity(StaffDesignation e) {
    return StaffDesignationIsar()
      ..designationId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..description = e.description
      ..isActive = e.isActive;
  }

  StaffDesignation toEntity() {
    return StaffDesignation(
      id: designationId,
      schoolId: schoolId,
      name: name,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class StaffRoleIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String roleId;

  late String schoolId;
  late String name;
  late String designationId;
  late String description;
  late bool isActive;

  StaffRoleIsar();

  factory StaffRoleIsar.fromEntity(StaffRole e) {
    return StaffRoleIsar()
      ..roleId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..designationId = e.designationId
      ..description = e.description
      ..isActive = e.isActive;
  }

  StaffRole toEntity() {
    return StaffRole(
      id: roleId,
      schoolId: schoolId,
      name: name,
      designationId: designationId,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class CampusIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String campusId;

  late String schoolId;
  late String name;
  late String code;
  late String address;
  late String district;
  String? contactPhone;
  String? contactEmail;
  String? headStaffId;
  late bool isPrimary;
  late bool isActive;
  late int order;
  DateTime? archivedAt;

  CampusIsar();

  factory CampusIsar.fromEntity(Campus e) {
    return CampusIsar()
      ..campusId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..address = e.address
      ..district = e.district
      ..contactPhone = e.contactPhone
      ..contactEmail = e.contactEmail
      ..headStaffId = e.headStaffId
      ..isPrimary = e.isPrimary
      ..isActive = e.isActive
      ..order = e.order
      ..archivedAt = e.archivedAt;
  }

  Campus toEntity() {
    return Campus(
      id: campusId,
      schoolId: schoolId,
      name: name,
      code: code,
      address: address,
      district: district,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      headStaffId: headStaffId,
      isPrimary: isPrimary,
      isActive: isActive,
      order: order,
      archivedAt: archivedAt,
    );
  }
}

@collection
class HouseIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String houseId;

  late String schoolId;
  late String name;
  late String colorHex;
  late String description;
  late bool isActive;

  HouseIsar();

  factory HouseIsar.fromEntity(House e) {
    return HouseIsar()
      ..houseId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..colorHex = e.colorHex
      ..description = e.description
      ..isActive = e.isActive;
  }

  House toEntity() {
    return House(
      id: houseId,
      schoolId: schoolId,
      name: name,
      colorHex: colorHex,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class ClubIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String clubId;

  late String schoolId;
  late String name;
  late String category;
  late String description;
  late String patronName;
  late bool isActive;

  ClubIsar();

  factory ClubIsar.fromEntity(Club e) {
    return ClubIsar()
      ..clubId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..category = e.category
      ..description = e.description
      ..patronName = e.patronName
      ..isActive = e.isActive;
  }

  Club toEntity() {
    return Club(
      id: clubId,
      schoolId: schoolId,
      name: name,
      category: category,
      description: description,
      patronName: patronName,
      isActive: isActive,
    );
  }
}

@collection
class FacilityIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String facilityId;

  late String schoolId;
  late String name;
  late String facilityType;
  late String location;
  late int capacity;
  late String description;
  late bool isActive;

  FacilityIsar();

  factory FacilityIsar.fromEntity(Facility e) {
    return FacilityIsar()
      ..facilityId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..facilityType = e.facilityType
      ..location = e.location
      ..capacity = e.capacity
      ..description = e.description
      ..isActive = e.isActive;
  }

  Facility toEntity() {
    return Facility(
      id: facilityId,
      schoolId: schoolId,
      name: name,
      facilityType: facilityType,
      location: location,
      capacity: capacity,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class HostelIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String hostelId;

  late String schoolId;
  late String name;
  late String gender;
  late String wardenName;
  late String wardenContact;
  late int capacity;
  late String description;
  late bool isActive;

  HostelIsar();

  factory HostelIsar.fromEntity(Hostel e) {
    return HostelIsar()
      ..hostelId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..gender = e.gender
      ..wardenName = e.wardenName
      ..wardenContact = e.wardenContact
      ..capacity = e.capacity
      ..description = e.description
      ..isActive = e.isActive;
  }

  Hostel toEntity() {
    return Hostel(
      id: hostelId,
      schoolId: schoolId,
      name: name,
      gender: gender,
      wardenName: wardenName,
      wardenContact: wardenContact,
      capacity: capacity,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class HostelRoomIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String roomId;

  late String schoolId;
  late String hostelId;
  late String blockName;
  late String roomNumber;
  late int bedCapacity;
  late bool isActive;

  HostelRoomIsar();

  factory HostelRoomIsar.fromEntity(HostelRoom e) {
    return HostelRoomIsar()
      ..roomId = e.id
      ..schoolId = e.schoolId
      ..hostelId = e.hostelId
      ..blockName = e.blockName
      ..roomNumber = e.roomNumber
      ..bedCapacity = e.bedCapacity
      ..isActive = e.isActive;
  }

  HostelRoom toEntity() {
    return HostelRoom(
      id: roomId,
      schoolId: schoolId,
      hostelId: hostelId,
      blockName: blockName,
      roomNumber: roomNumber,
      bedCapacity: bedCapacity,
      isActive: isActive,
    );
  }
}

@collection
class TransportRouteIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String routeId;

  late String schoolId;
  late String name;
  late String code;
  late String description;
  late bool isActive;

  TransportRouteIsar();

  factory TransportRouteIsar.fromEntity(TransportRoute e) {
    return TransportRouteIsar()
      ..routeId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..description = e.description
      ..isActive = e.isActive;
  }

  TransportRoute toEntity() {
    return TransportRoute(
      id: routeId,
      schoolId: schoolId,
      name: name,
      code: code,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class TransportStopIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String stopId;

  late String schoolId;
  late String routeId;
  late String name;
  late int order;
  late String pickupTime;
  late String zone;
  late bool isActive;

  TransportStopIsar();

  factory TransportStopIsar.fromEntity(TransportStop e) {
    return TransportStopIsar()
      ..stopId = e.id
      ..schoolId = e.schoolId
      ..routeId = e.routeId
      ..name = e.name
      ..order = e.order
      ..pickupTime = e.pickupTime
      ..zone = e.zone
      ..isActive = e.isActive;
  }

  TransportStop toEntity() {
    return TransportStop(
      id: stopId,
      schoolId: schoolId,
      routeId: routeId,
      name: name,
      order: order,
      pickupTime: pickupTime,
      zone: zone,
      isActive: isActive,
    );
  }
}

@collection
class TransportVehicleIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String vehicleId;

  late String schoolId;
  late String busNumber;
  late String plateNumber;
  late int capacity;
  late String driverName;
  late String routeId;
  late bool isActive;

  TransportVehicleIsar();

  factory TransportVehicleIsar.fromEntity(TransportVehicle e) {
    return TransportVehicleIsar()
      ..vehicleId = e.id
      ..schoolId = e.schoolId
      ..busNumber = e.busNumber
      ..plateNumber = e.plateNumber
      ..capacity = e.capacity
      ..driverName = e.driverName
      ..routeId = e.routeId
      ..isActive = e.isActive;
  }

  TransportVehicle toEntity() {
    return TransportVehicle(
      id: vehicleId,
      schoolId: schoolId,
      busNumber: busNumber,
      plateNumber: plateNumber,
      capacity: capacity,
      driverName: driverName,
      routeId: routeId,
      isActive: isActive,
    );
  }
}

@collection
class StructureFeeCategoryIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String feeCategoryId;

  late String schoolId;
  late String name;
  late String code;
  late String description;
  late bool isMandatory;
  late bool isActive;

  StructureFeeCategoryIsar();

  factory StructureFeeCategoryIsar.fromEntity(FeeCategory e) {
    return StructureFeeCategoryIsar()
      ..feeCategoryId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..code = e.code
      ..description = e.description
      ..isMandatory = e.isMandatory
      ..isActive = e.isActive;
  }

  FeeCategory toEntity() {
    return FeeCategory(
      id: feeCategoryId,
      schoolId: schoolId,
      name: name,
      code: code,
      description: description,
      isMandatory: isMandatory,
      isActive: isActive,
    );
  }
}

@collection
class AssessmentTypeDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String assessmentTypeId;

  late String schoolId;
  late String name;
  late double weightPercentage;
  late String description;
  late bool isActive;

  AssessmentTypeDefIsar();

  factory AssessmentTypeDefIsar.fromEntity(AssessmentTypeDef e) {
    return AssessmentTypeDefIsar()
      ..assessmentTypeId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..weightPercentage = e.weightPercentage
      ..description = e.description
      ..isActive = e.isActive;
  }

  AssessmentTypeDef toEntity() {
    return AssessmentTypeDef(
      id: assessmentTypeId,
      schoolId: schoolId,
      name: name,
      weightPercentage: weightPercentage,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class GradingSystemDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String gradingSystemId;

  late String schoolId;
  late String name;
  late String type;
  late bool isDefault;
  late bool isActive;

  GradingSystemDefIsar();

  factory GradingSystemDefIsar.fromEntity(GradingSystemDef e) {
    return GradingSystemDefIsar()
      ..gradingSystemId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..type = e.type
      ..isDefault = e.isDefault
      ..isActive = e.isActive;
  }

  GradingSystemDef toEntity() {
    return GradingSystemDef(
      id: gradingSystemId,
      schoolId: schoolId,
      name: name,
      type: type,
      isDefault: isDefault,
      isActive: isActive,
    );
  }
}

@collection
class GradeBandIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String gradeBandId;

  late String schoolId;
  late String gradingSystemId;
  late String grade;
  late double minScore;
  late double maxScore;
  late String remarks;
  late int order;

  GradeBandIsar();

  factory GradeBandIsar.fromEntity(GradeBand e) {
    return GradeBandIsar()
      ..gradeBandId = e.id
      ..schoolId = e.schoolId
      ..gradingSystemId = e.gradingSystemId
      ..grade = e.grade
      ..minScore = e.minScore
      ..maxScore = e.maxScore
      ..remarks = e.remarks
      ..order = e.order;
  }

  GradeBand toEntity() {
    return GradeBand(
      id: gradeBandId,
      schoolId: schoolId,
      gradingSystemId: gradingSystemId,
      grade: grade,
      minScore: minScore,
      maxScore: maxScore,
      remarks: remarks,
      order: order,
    );
  }
}

@collection
class AttendanceTypeDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String attendanceTypeId;

  late String schoolId;
  late String name;
  late String colorHex;
  late bool isActive;

  AttendanceTypeDefIsar();

  factory AttendanceTypeDefIsar.fromEntity(AttendanceTypeDef e) {
    return AttendanceTypeDefIsar()
      ..attendanceTypeId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..colorHex = e.colorHex
      ..isActive = e.isActive;
  }

  AttendanceTypeDef toEntity() {
    return AttendanceTypeDef(
      id: attendanceTypeId,
      schoolId: schoolId,
      name: name,
      colorHex: colorHex,
      isActive: isActive,
    );
  }
}

@collection
class AttendanceSessionDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String attendanceSessionId;

  late String schoolId;
  late String name;
  late bool isActive;

  AttendanceSessionDefIsar();

  factory AttendanceSessionDefIsar.fromEntity(AttendanceSessionDef e) {
    return AttendanceSessionDefIsar()
      ..attendanceSessionId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..isActive = e.isActive;
  }

  AttendanceSessionDef toEntity() {
    return AttendanceSessionDef(
      id: attendanceSessionId,
      schoolId: schoolId,
      name: name,
      isActive: isActive,
    );
  }
}

@collection
class AnnouncementCategoryDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String announcementCategoryId;

  late String schoolId;
  late String name;
  late bool isActive;

  AnnouncementCategoryDefIsar();

  factory AnnouncementCategoryDefIsar.fromEntity(AnnouncementCategoryDef e) {
    return AnnouncementCategoryDefIsar()
      ..announcementCategoryId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..isActive = e.isActive;
  }

  AnnouncementCategoryDef toEntity() {
    return AnnouncementCategoryDef(
      id: announcementCategoryId,
      schoolId: schoolId,
      name: name,
      isActive: isActive,
    );
  }
}

@collection
class NotificationCategoryDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String notificationCategoryId;

  late String schoolId;
  late String name;
  late bool isActive;

  NotificationCategoryDefIsar();

  factory NotificationCategoryDefIsar.fromEntity(NotificationCategoryDef e) {
    return NotificationCategoryDefIsar()
      ..notificationCategoryId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..isActive = e.isActive;
  }

  NotificationCategoryDef toEntity() {
    return NotificationCategoryDef(
      id: notificationCategoryId,
      schoolId: schoolId,
      name: name,
      isActive: isActive,
    );
  }
}

@collection
class MessageTemplateDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String messageTemplateId;

  late String schoolId;
  late String name;
  late String channel;
  late String subject;
  late String body;
  late bool isActive;

  MessageTemplateDefIsar();

  factory MessageTemplateDefIsar.fromEntity(MessageTemplateDef e) {
    return MessageTemplateDefIsar()
      ..messageTemplateId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..channel = e.channel
      ..subject = e.subject
      ..body = e.body
      ..isActive = e.isActive;
  }

  MessageTemplateDef toEntity() {
    return MessageTemplateDef(
      id: messageTemplateId,
      schoolId: schoolId,
      name: name,
      channel: channel,
      subject: subject,
      body: body,
      isActive: isActive,
    );
  }
}

@collection
class DocumentTemplateDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String documentTemplateId;

  late String schoolId;
  late String name;
  late String templateType;
  late String description;
  late bool isActive;

  DocumentTemplateDefIsar();

  factory DocumentTemplateDefIsar.fromEntity(DocumentTemplateDef e) {
    return DocumentTemplateDefIsar()
      ..documentTemplateId = e.id
      ..schoolId = e.schoolId
      ..name = e.name
      ..templateType = e.templateType
      ..description = e.description
      ..isActive = e.isActive;
  }

  DocumentTemplateDef toEntity() {
    return DocumentTemplateDef(
      id: documentTemplateId,
      schoolId: schoolId,
      name: name,
      templateType: templateType,
      description: description,
      isActive: isActive,
    );
  }
}

@collection
class CustomFieldDefIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String customFieldId;

  late String schoolId;
  late String appliesTo;
  late String fieldName;
  late String fieldType;
  List<String> options = [];
  late bool isRequired;
  late bool isActive;

  CustomFieldDefIsar();

  factory CustomFieldDefIsar.fromEntity(CustomFieldDef e) {
    return CustomFieldDefIsar()
      ..customFieldId = e.id
      ..schoolId = e.schoolId
      ..appliesTo = e.appliesTo
      ..fieldName = e.fieldName
      ..fieldType = e.fieldType
      ..options = e.options
      ..isRequired = e.isRequired
      ..isActive = e.isActive;
  }

  CustomFieldDef toEntity() {
    return CustomFieldDef(
      id: customFieldId,
      schoolId: schoolId,
      appliesTo: appliesTo,
      fieldName: fieldName,
      fieldType: fieldType,
      options: options,
      isRequired: isRequired,
      isActive: isActive,
    );
  }
}
