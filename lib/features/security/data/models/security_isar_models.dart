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
  late String operatingHoursJson; // Store as JSON string
  late List<String> allowedUserRoles;
  late List<String> requiredVerificationMethods;
  late String schoolId;

  GateIsar();

  factory GateIsar.fromEntity(Gate entity) {
    return GateIsar()
      ..gateId = entity.id
      ..name = entity.name
      ..type = entity.type
      ..location = entity.location
      ..assignedOfficerIds = entity.assignedOfficerIds
      ..operatingHoursJson = '' // Simplified for now
      ..allowedUserRoles = entity.allowedUserRoles
      ..requiredVerificationMethods = entity.requiredVerificationMethods
      ..schoolId = entity.schoolId;
  }

  Gate toEntity() {
    return Gate(
      id: gateId,
      name: name,
      type: type,
      location: location,
      assignedOfficerIds: assignedOfficerIds,
      operatingHours: const {}, // Simplified
      allowedUserRoles: allowedUserRoles,
      requiredVerificationMethods: requiredVerificationMethods,
      schoolId: schoolId,
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
  late String schoolId;
  late bool isSynced;

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
      ..isSynced = isSynced;
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
  late DateTime timestamp;
  late String gateId;
  late String direction;
  late String movementType;
  late String verificationMethod;
  late String officerId;
  late String deviceId;
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
      ..pickupDetailsJson = null // Simplified
      ..isSynced = isSynced;
  }

  StudentMovement toEntity() {
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
      pickupDetails: null, // Simplified
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
  late String status;
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
  late DateTime timestamp;
  late String observations;
  late List<String> photoUrls;
  late List<String> issuesFound;
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
