import 'package:equatable/equatable.dart';

class Gate extends Equatable {
  final String id;
  final String name;
  final String type; // Main, Student, Staff, Boarding, etc.
  final String location;
  final List<String> assignedOfficerIds;
  final Map<String, dynamic> operatingHours;
  final List<String> allowedUserRoles;
  final List<String> requiredVerificationMethods;
  final String schoolId;
  // CCTV integration readiness only (not implemented) - a future camera
  // feed can be associated with this gate without another schema change.
  final String? cameraId;

  const Gate({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.assignedOfficerIds,
    required this.operatingHours,
    required this.allowedUserRoles,
    required this.requiredVerificationMethods,
    required this.schoolId,
    this.cameraId,
  });

  @override
  List<Object?> get props => [id, name, type, location, assignedOfficerIds, operatingHours, allowedUserRoles, requiredVerificationMethods, schoolId, cameraId];
}

class SecurityIncident extends Equatable {
  final String id;
  final String type; // Theft, Fighting, Bullying, etc.
  final String description;
  final DateTime timestamp;
  final String location;
  final List<String> involvedPersonIds;
  final List<String> photoUrls;
  final String reportedByOfficerId;
  final String report;
  final String status; // Pending, Investigating, Resolved
  final String schoolId;
  // CCTV integration readiness only (not implemented) - lets a future phase
  // attach the camera/footage reference that covers this incident.
  final String? cameraId;

  const SecurityIncident({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.location,
    required this.involvedPersonIds,
    required this.photoUrls,
    required this.reportedByOfficerId,
    required this.report,
    required this.status,
    required this.schoolId,
    this.cameraId,
  });

  @override
  List<Object?> get props => [id, type, description, timestamp, location, involvedPersonIds, photoUrls, reportedByOfficerId, report, status, schoolId, cameraId];
}

class StudentMovement extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final DateTime timestamp;
  final String gateId;
  final String direction; // In, Out
  final String movementType; // Arrival, Departure, Late Arrival, Early Departure, Boarding
  final String verificationMethod;
  final String officerId;
  final String deviceId;
  final String schoolId;
  final Map<String, dynamic>? pickupDetails;

  const StudentMovement({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.timestamp,
    required this.gateId,
    required this.direction,
    required this.movementType,
    required this.verificationMethod,
    required this.officerId,
    required this.deviceId,
    required this.schoolId,
    this.pickupDetails,
  });

  @override
  List<Object?> get props => [id, studentId, studentName, className, timestamp, gateId, direction, movementType, verificationMethod, officerId, deviceId, schoolId, pickupDetails];
}

class StaffMovement extends Equatable {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime timestamp;
  final String gateId;
  final String direction; // In, Out
  final String verificationMethod;
  final String officerId;
  final String schoolId;

  const StaffMovement({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.timestamp,
    required this.gateId,
    required this.direction,
    required this.verificationMethod,
    required this.officerId,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [id, staffId, staffName, timestamp, gateId, direction, verificationMethod, officerId, schoolId];
}

class EmergencyEvent extends Equatable {
  final String id;
  final String type; // Fire, Medical, Security, Intruder
  final DateTime startTime;
  final DateTime? endTime;
  final String description;
  final List<String> responseActions;
  final List<String> involvedPersonIds;
  final String status; // Active, Resolved
  final String schoolId;

  const EmergencyEvent({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.description,
    required this.responseActions,
    required this.involvedPersonIds,
    required this.status,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [id, type, startTime, endTime, description, responseActions, involvedPersonIds, status, schoolId];
}

class LostAndFoundItem extends Equatable {
  final String id;
  final String description;
  final String locationFound;
  final DateTime dateFound;
  final String? photoUrl;
  final String foundByPersonId;
  final bool isClaimed;
  final Map<String, dynamic>? claimDetails;
  final String schoolId;

  const LostAndFoundItem({
    required this.id,
    required this.description,
    required this.locationFound,
    required this.dateFound,
    this.photoUrl,
    required this.foundByPersonId,
    required this.isClaimed,
    this.claimDetails,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [id, description, locationFound, dateFound, photoUrl, foundByPersonId, isClaimed, claimDetails, schoolId];
}

class SecurityPatrol extends Equatable {
  final String id;
  final String officerId;
  final String location;
  final DateTime timestamp;
  final String observations;
  final List<String> photoUrls;
  final List<String> issuesFound;
  final String schoolId;

  const SecurityPatrol({
    required this.id,
    required this.officerId,
    required this.location,
    required this.timestamp,
    required this.observations,
    required this.photoUrls,
    required this.issuesFound,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [id, officerId, location, timestamp, observations, photoUrls, issuesFound, schoolId];
}

class PickupAuthorization extends Equatable {
  final String id;
  final String studentId;
  final String parentId;
  final String authorizedPersonName;
  final String phone;
  final String relationship;
  final String? photoUrl;
  final String? idDocumentUrl;
  final DateTime? expiryDate;
  final String schoolId;

  const PickupAuthorization({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.authorizedPersonName,
    required this.phone,
    required this.relationship,
    this.photoUrl,
    this.idDocumentUrl,
    this.expiryDate,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [id, studentId, parentId, authorizedPersonName, phone, relationship, photoUrl, idDocumentUrl, expiryDate, schoolId];
}
