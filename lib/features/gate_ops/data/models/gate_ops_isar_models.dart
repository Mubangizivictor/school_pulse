import 'package:isar/isar.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/visitor.dart';

part 'gate_ops_isar_models.g.dart';

@collection
class GateIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String gateId;

  late String name;
  late String type;
  late String location;
  late List<String> assignedOfficerIds;
  // Two plain strings instead of the domain entity's `operatingHours` Map,
  // since Isar has no native Map support and a custom converter isn't worth
  // it here (plan section 4).
  String? openTime;
  String? closeTime;
  late List<String> allowedUserRoles;
  late List<String> requiredVerificationMethods;
  @Index()
  late String schoolId;
  String? cameraId;
  late bool isSynced;

  GateIsar();

  factory GateIsar.fromEntity(Gate entity, {bool isSynced = true}) {
    return GateIsar()
      ..gateId = entity.id
      ..name = entity.name
      ..type = entity.type
      ..location = entity.location
      ..assignedOfficerIds = entity.assignedOfficerIds
      ..openTime = entity.operatingHours['open'] as String?
      ..closeTime = entity.operatingHours['close'] as String?
      ..allowedUserRoles = entity.allowedUserRoles
      ..requiredVerificationMethods = entity.requiredVerificationMethods
      ..schoolId = entity.schoolId
      ..cameraId = entity.cameraId
      ..isSynced = isSynced;
  }

  Gate toEntity() {
    return Gate(
      id: gateId,
      name: name,
      type: type,
      location: location,
      assignedOfficerIds: assignedOfficerIds,
      operatingHours: {
        if (openTime != null) 'open': openTime,
        if (closeTime != null) 'close': closeTime,
      },
      allowedUserRoles: allowedUserRoles,
      requiredVerificationMethods: requiredVerificationMethods,
      schoolId: schoolId,
      cameraId: cameraId,
    );
  }
}

@collection
class MovementEventIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String eventId;

  @Index()
  late String schoolId;
  String? campusId;
  @Index()
  late String gateId;
  late String personType;
  @Index()
  late String personId;
  late String personName;
  late String direction;
  late String movementType;
  late String verificationMethod;
  late String officerId;
  late String officerRole;
  late String deviceId;
  String? deviceName;
  late String platform;
  late String appVersion;
  @Index()
  late DateTime actionTimestamp;
  DateTime? serverTimestamp;
  @Index()
  late String syncStatus;
  String? pickupParentCode;
  String? pickupParentName;
  String? pickupPhoneNumber;

  MovementEventIsar();

  factory MovementEventIsar.fromEntity(MovementEvent entity) {
    return MovementEventIsar()
      ..eventId = entity.id
      ..schoolId = entity.schoolId
      ..campusId = entity.campusId
      ..gateId = entity.gateId
      ..personType = entity.personType.name
      ..personId = entity.personId
      ..personName = entity.personName
      ..direction = entity.direction.name
      ..movementType = entity.movementType
      ..verificationMethod = entity.verificationMethod.id
      ..officerId = entity.officerId
      ..officerRole = entity.officerRole
      ..deviceId = entity.deviceId
      ..deviceName = entity.deviceName
      ..platform = entity.platform
      ..appVersion = entity.appVersion
      ..actionTimestamp = entity.actionTimestamp
      ..serverTimestamp = entity.serverTimestamp
      ..syncStatus = entity.syncStatus.name
      ..pickupParentCode = entity.pickupParentCode
      ..pickupParentName = entity.pickupParentName
      ..pickupPhoneNumber = entity.pickupPhoneNumber;
  }

  MovementEvent toEntity() {
    return MovementEvent(
      id: eventId,
      schoolId: schoolId,
      campusId: campusId,
      gateId: gateId,
      personType: PersonType.values.byName(personType),
      personId: personId,
      personName: personName,
      direction: MovementDirection.values.byName(direction),
      movementType: movementType,
      verificationMethod:
          VerificationMethod.fromId(verificationMethod) ??
          VerificationMethod.none,
      officerId: officerId,
      officerRole: officerRole,
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
      appVersion: appVersion,
      actionTimestamp: actionTimestamp,
      serverTimestamp: serverTimestamp,
      syncStatus: SyncStatus.values.byName(syncStatus),
      pickupParentCode: pickupParentCode,
      pickupParentName: pickupParentName,
      pickupPhoneNumber: pickupPhoneNumber,
    );
  }
}

@collection
class VisitorIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String visitorId;

  @Index()
  late String schoolId;
  late String fullName;
  String? phone;
  String? photoLocalPath;
  String? photoUrl;
  late String purpose;
  String? hostId;
  String? hostName;
  late String gateId;
  @Index()
  late DateTime arrivalTime;
  DateTime? departureTime;
  @Index()
  late String status;
  late bool isQuickEntry;
  String? badgeNumber;
  @Index()
  late String syncStatus;

  VisitorIsar();

  factory VisitorIsar.fromEntity(Visitor entity) {
    return VisitorIsar()
      ..visitorId = entity.id
      ..schoolId = entity.schoolId
      ..fullName = entity.fullName
      ..phone = entity.phone
      ..photoLocalPath = entity.photoLocalPath
      ..photoUrl = entity.photoUrl
      ..purpose = entity.purpose
      ..hostId = entity.hostId
      ..hostName = entity.hostName
      ..gateId = entity.gateId
      ..arrivalTime = entity.arrivalTime
      ..departureTime = entity.departureTime
      ..status = entity.status.name
      ..isQuickEntry = entity.isQuickEntry
      ..badgeNumber = entity.badgeNumber
      ..syncStatus = entity.syncStatus.name;
  }

  Visitor toEntity() {
    return Visitor(
      id: visitorId,
      schoolId: schoolId,
      fullName: fullName,
      phone: phone,
      photoLocalPath: photoLocalPath,
      photoUrl: photoUrl,
      purpose: purpose,
      hostId: hostId,
      hostName: hostName,
      gateId: gateId,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      status: VisitorStatus.values.byName(status),
      isQuickEntry: isQuickEntry,
      badgeNumber: badgeNumber,
      syncStatus: SyncStatus.values.byName(syncStatus),
    );
  }
}

@collection
class SecurityIncidentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String incidentId;

  @Index()
  late String schoolId;
  late String type;
  late String description;
  @Index()
  late DateTime timestamp;
  late String gateId;
  late List<String> photoUrls;
  late String reportedByOfficerId;
  late String status;
  late String syncStatus;

  SecurityIncidentIsar();

  factory SecurityIncidentIsar.fromEntity(SecurityIncident entity) {
    return SecurityIncidentIsar()
      ..incidentId = entity.id
      ..schoolId = entity.schoolId
      ..type = entity.type
      ..description = entity.description
      ..timestamp = entity.timestamp
      ..gateId = entity.gateId
      ..photoUrls = entity.photoUrls
      ..reportedByOfficerId = entity.reportedByOfficerId
      ..status = entity.status
      ..syncStatus = entity.syncStatus.name;
  }

  SecurityIncident toEntity() {
    return SecurityIncident(
      id: incidentId,
      schoolId: schoolId,
      gateId: gateId,
      type: type,
      description: description,
      timestamp: timestamp,
      photoUrls: photoUrls,
      reportedByOfficerId: reportedByOfficerId,
      status: status,
      syncStatus: SyncStatus.values.byName(syncStatus),
    );
  }
}

@collection
class EmergencyEventIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String eventId;

  @Index()
  late String schoolId;
  late String type;
  @Index()
  late DateTime startTime;
  DateTime? endTime;
  late String description;
  late String gateId;
  late String officerId;
  late String deviceId;
  @Index()
  late String status;
  late String syncStatus;

  EmergencyEventIsar();

  factory EmergencyEventIsar.fromEntity(EmergencyEvent entity) {
    return EmergencyEventIsar()
      ..eventId = entity.id
      ..schoolId = entity.schoolId
      ..type = entity.type
      ..startTime = entity.startTime
      ..endTime = entity.endTime
      ..description = entity.description
      ..gateId = entity.gateId
      ..officerId = entity.officerId
      ..deviceId = entity.deviceId
      ..status = entity.status
      ..syncStatus = entity.syncStatus.name;
  }

  EmergencyEvent toEntity() {
    return EmergencyEvent(
      id: eventId,
      schoolId: schoolId,
      gateId: gateId,
      type: type,
      startTime: startTime,
      endTime: endTime,
      description: description,
      officerId: officerId,
      deviceId: deviceId,
      status: status,
      syncStatus: SyncStatus.values.byName(syncStatus),
    );
  }
}
