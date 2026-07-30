import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/security_entities.dart';

part 'security_isar_models.g.dart';

@collection
class GateIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String gateId;

  late String name;
  late String type;
  late String location;
  late List<String> assignedOfficerIds;
  late String operatingHoursJson;
  late List<String> allowedUserRoles;
  late List<String> requiredVerificationMethods;
  @Index()
  late String schoolId;
  late bool isSynced;
  String? cameraId;

  GateIsar();

  factory GateIsar.fromEntity(Gate entity, {bool isSynced = true}) {
    return GateIsar()
      ..gateId = entity.id
      ..name = entity.name
      ..type = entity.type
      ..location = entity.location
      ..assignedOfficerIds = entity.assignedOfficerIds
      ..operatingHoursJson = jsonEncode(entity.operatingHours)
      ..allowedUserRoles = entity.allowedUserRoles
      ..requiredVerificationMethods = entity.requiredVerificationMethods
      ..schoolId = entity.schoolId
      ..isSynced = isSynced
      ..cameraId = entity.cameraId;
  }

  Gate toEntity() {
    Map<String, dynamic> operatingHours = const {};
    if (operatingHoursJson.isNotEmpty) {
      try {
        operatingHours = Map<String, dynamic>.from(jsonDecode(operatingHoursJson));
      } catch (_) {
        operatingHours = const {};
      }
    }
    return Gate(
      id: gateId,
      name: name,
      type: type,
      location: location,
      assignedOfficerIds: assignedOfficerIds,
      operatingHours: operatingHours,
      allowedUserRoles: allowedUserRoles,
      requiredVerificationMethods: requiredVerificationMethods,
      schoolId: schoolId,
      cameraId: cameraId,
    );
  }
}

@collection
class SecurityIncidentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String incidentId;

  late String type;
  late String description;
  late DateTime timestamp;
  late String location;
  late List<String> involvedPersonIds;
  late List<String> photoUrls;
  late String reportedByOfficerId;
  late String report;
  late String status;
  @Index()
  late String schoolId;
  late bool isSynced;
  String? cameraId;

  SecurityIncidentIsar();

  factory SecurityIncidentIsar.fromEntity(SecurityIncident entity, {bool isSynced = true}) {
    return SecurityIncidentIsar()
      ..incidentId = entity.id
      ..type = entity.type
      ..description = entity.description
      ..timestamp = entity.timestamp
      ..location = entity.location
      ..involvedPersonIds = entity.involvedPersonIds
      ..photoUrls = entity.photoUrls
      ..reportedByOfficerId = entity.reportedByOfficerId
      ..report = entity.report
      ..status = entity.status
      ..schoolId = entity.schoolId
      ..isSynced = isSynced
      ..cameraId = entity.cameraId;
  }

  SecurityIncident toEntity() {
    return SecurityIncident(
      id: incidentId,
      type: type,
      description: description,
      timestamp: timestamp,
      location: location,
      involvedPersonIds: involvedPersonIds,
      photoUrls: photoUrls,
      reportedByOfficerId: reportedByOfficerId,
      report: report,
      status: status,
      schoolId: schoolId,
      cameraId: cameraId,
    );
  }
}

@collection
class StudentMovementIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String movementId;

  late String studentId;
  late String studentName;
  late String className;
  @Index()
  late DateTime timestamp;
  @Index()
  late String gateId;
  late String direction;
  late String movementType;
  late String verificationMethod;
  late String officerId;
  late String deviceId;
  @Index()
  late String schoolId;
  String? pickupDetailsJson;
  late bool isSynced;

  StudentMovementIsar();

  factory StudentMovementIsar.fromEntity(StudentMovement entity, {bool isSynced = true}) {
    return StudentMovementIsar()
      ..movementId = entity.id
      ..studentId = entity.studentId
      ..studentName = entity.studentName
      ..className = entity.className
      ..timestamp = entity.timestamp
      ..gateId = entity.gateId
      ..direction = entity.direction
      ..movementType = entity.movementType
      ..verificationMethod = entity.verificationMethod
      ..officerId = entity.officerId
      ..deviceId = entity.deviceId
      ..schoolId = entity.schoolId
      ..pickupDetailsJson = entity.pickupDetails != null ? jsonEncode(entity.pickupDetails) : null
      ..isSynced = isSynced;
  }

  StudentMovement toEntity() {
    Map<String, dynamic>? pickupDetails;
    if (pickupDetailsJson != null && pickupDetailsJson!.isNotEmpty) {
      try {
        pickupDetails = Map<String, dynamic>.from(jsonDecode(pickupDetailsJson!));
      } catch (_) {
        pickupDetails = null;
      }
    }
    return StudentMovement(
      id: movementId,
      studentId: studentId,
      studentName: studentName,
      className: className,
      timestamp: timestamp,
      gateId: gateId,
      direction: direction,
      movementType: movementType,
      verificationMethod: verificationMethod,
      officerId: officerId,
      deviceId: deviceId,
      schoolId: schoolId,
      pickupDetails: pickupDetails,
    );
  }
}

@collection
class StaffMovementIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String movementId;

  late String staffId;
  late String staffName;
  @Index()
  late DateTime timestamp;
  @Index()
  late String gateId;
  late String direction;
  late String verificationMethod;
  late String officerId;
  @Index()
  late String schoolId;
  late bool isSynced;

  StaffMovementIsar();

  factory StaffMovementIsar.fromEntity(StaffMovement entity, {bool isSynced = true}) {
    return StaffMovementIsar()
      ..movementId = entity.id
      ..staffId = entity.staffId
      ..staffName = entity.staffName
      ..timestamp = entity.timestamp
      ..gateId = entity.gateId
      ..direction = entity.direction
      ..verificationMethod = entity.verificationMethod
      ..officerId = entity.officerId
      ..schoolId = entity.schoolId
      ..isSynced = isSynced;
  }

  StaffMovement toEntity() {
    return StaffMovement(
      id: movementId,
      staffId: staffId,
      staffName: staffName,
      timestamp: timestamp,
      gateId: gateId,
      direction: direction,
      verificationMethod: verificationMethod,
      officerId: officerId,
      schoolId: schoolId,
    );
  }
}

@collection
class EmergencyEventIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String eventId;

  late String type;
  late DateTime startTime;
  DateTime? endTime;
  late String description;
  late List<String> responseActions;
  late List<String> involvedPersonIds;
  @Index()
  late String status;
  @Index()
  late String schoolId;
  late bool isSynced;

  EmergencyEventIsar();

  factory EmergencyEventIsar.fromEntity(EmergencyEvent entity, {bool isSynced = true}) {
    return EmergencyEventIsar()
      ..eventId = entity.id
      ..type = entity.type
      ..startTime = entity.startTime
      ..endTime = entity.endTime
      ..description = entity.description
      ..responseActions = entity.responseActions
      ..involvedPersonIds = entity.involvedPersonIds
      ..status = entity.status
      ..schoolId = entity.schoolId
      ..isSynced = isSynced;
  }

  EmergencyEvent toEntity() {
    return EmergencyEvent(
      id: eventId,
      type: type,
      startTime: startTime,
      endTime: endTime,
      description: description,
      responseActions: responseActions,
      involvedPersonIds: involvedPersonIds,
      status: status,
      schoolId: schoolId,
    );
  }
}

@collection
class SecurityPatrolIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String patrolId;

  late String officerId;
  late String location;
  @Index()
  late DateTime timestamp;
  late String observations;
  late List<String> photoUrls;
  late List<String> issuesFound;
  @Index()
  late String schoolId;
  late bool isSynced;

  SecurityPatrolIsar();

  factory SecurityPatrolIsar.fromEntity(SecurityPatrol entity, {bool isSynced = true}) {
    return SecurityPatrolIsar()
      ..patrolId = entity.id
      ..officerId = entity.officerId
      ..location = entity.location
      ..timestamp = entity.timestamp
      ..observations = entity.observations
      ..photoUrls = entity.photoUrls
      ..issuesFound = entity.issuesFound
      ..schoolId = entity.schoolId
      ..isSynced = isSynced;
  }

  SecurityPatrol toEntity() {
    return SecurityPatrol(
      id: patrolId,
      officerId: officerId,
      location: location,
      timestamp: timestamp,
      observations: observations,
      photoUrls: photoUrls,
      issuesFound: issuesFound,
      schoolId: schoolId,
    );
  }
}

@collection
class LostAndFoundItemIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String itemId;

  late String description;
  late String locationFound;
  @Index()
  late DateTime dateFound;
  String? photoUrl;
  late String foundByPersonId;
  @Index()
  late bool isClaimed;
  String? claimDetailsJson;
  @Index()
  late String schoolId;
  late bool isSynced;

  LostAndFoundItemIsar();

  factory LostAndFoundItemIsar.fromEntity(LostAndFoundItem entity, {bool isSynced = true}) {
    return LostAndFoundItemIsar()
      ..itemId = entity.id
      ..description = entity.description
      ..locationFound = entity.locationFound
      ..dateFound = entity.dateFound
      ..photoUrl = entity.photoUrl
      ..foundByPersonId = entity.foundByPersonId
      ..isClaimed = entity.isClaimed
      ..claimDetailsJson = entity.claimDetails != null ? jsonEncode(entity.claimDetails) : null
      ..schoolId = entity.schoolId
      ..isSynced = isSynced;
  }

  LostAndFoundItem toEntity() {
    Map<String, dynamic>? claimDetails;
    if (claimDetailsJson != null && claimDetailsJson!.isNotEmpty) {
      try {
        claimDetails = Map<String, dynamic>.from(jsonDecode(claimDetailsJson!));
      } catch (_) {
        claimDetails = null;
      }
    }
    return LostAndFoundItem(
      id: itemId,
      description: description,
      locationFound: locationFound,
      dateFound: dateFound,
      photoUrl: photoUrl,
      foundByPersonId: foundByPersonId,
      isClaimed: isClaimed,
      claimDetails: claimDetails,
      schoolId: schoolId,
    );
  }
}

@collection
class PickupAuthorizationIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String authorizationId;

  @Index()
  late String studentId;
  late String parentId;
  late String authorizedPersonName;
  late String phone;
  late String relationship;
  String? photoUrl;
  String? idDocumentUrl;
  DateTime? expiryDate;
  @Index()
  late String schoolId;
  late bool isSynced;

  PickupAuthorizationIsar();

  factory PickupAuthorizationIsar.fromEntity(PickupAuthorization entity, {bool isSynced = true}) {
    return PickupAuthorizationIsar()
      ..authorizationId = entity.id
      ..studentId = entity.studentId
      ..parentId = entity.parentId
      ..authorizedPersonName = entity.authorizedPersonName
      ..phone = entity.phone
      ..relationship = entity.relationship
      ..photoUrl = entity.photoUrl
      ..idDocumentUrl = entity.idDocumentUrl
      ..expiryDate = entity.expiryDate
      ..schoolId = entity.schoolId
      ..isSynced = isSynced;
  }

  PickupAuthorization toEntity() {
    return PickupAuthorization(
      id: authorizationId,
      studentId: studentId,
      parentId: parentId,
      authorizedPersonName: authorizedPersonName,
      phone: phone,
      relationship: relationship,
      photoUrl: photoUrl,
      idDocumentUrl: idDocumentUrl,
      expiryDate: expiryDate,
      schoolId: schoolId,
    );
  }
}
