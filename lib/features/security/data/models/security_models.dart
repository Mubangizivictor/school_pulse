import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/security_entities.dart';

class GateModel extends Gate {
  const GateModel({
    required super.id,
    required super.name,
    required super.type,
    required super.location,
    required super.assignedOfficerIds,
    required super.operatingHours,
    required super.allowedUserRoles,
    required super.requiredVerificationMethods,
    required super.schoolId,
  });

  factory GateModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GateModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      assignedOfficerIds: List<String>.from(data['assignedOfficerIds'] ?? []),
      operatingHours: data['operatingHours'] ?? {},
      allowedUserRoles: List<String>.from(data['allowedUserRoles'] ?? []),
      requiredVerificationMethods: List<String>.from(data['requiredVerificationMethods'] ?? []),
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'location': location,
      'assignedOfficerIds': assignedOfficerIds,
      'operatingHours': operatingHours,
      'allowedUserRoles': allowedUserRoles,
      'requiredVerificationMethods': requiredVerificationMethods,
      'schoolId': schoolId,
    };
  }
}

class SecurityIncidentModel extends SecurityIncident {
  const SecurityIncidentModel({
    required super.id,
    required super.type,
    required super.description,
    required super.timestamp,
    required super.location,
    required super.involvedPersonIds,
    required super.photoUrls,
    required super.reportedByOfficerId,
    required super.report,
    required super.status,
    required super.schoolId,
  });

  factory SecurityIncidentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SecurityIncidentModel(
      id: doc.id,
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      involvedPersonIds: List<String>.from(data['involvedPersonIds'] ?? []),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      reportedByOfficerId: data['reportedByOfficerId'] ?? '',
      report: data['report'] ?? '',
      status: data['status'] ?? '',
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'involvedPersonIds': involvedPersonIds,
      'photoUrls': photoUrls,
      'reportedByOfficerId': reportedByOfficerId,
      'report': report,
      'status': status,
      'schoolId': schoolId,
    };
  }
}

class StudentMovementModel extends StudentMovement {
  const StudentMovementModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.className,
    required super.timestamp,
    required super.gateId,
    required super.direction,
    required super.movementType,
    required super.verificationMethod,
    required super.officerId,
    required super.deviceId,
    required super.schoolId,
    super.pickupDetails,
  });

  factory StudentMovementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudentMovementModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      className: data['className'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      gateId: data['gateId'] ?? '',
      direction: data['direction'] ?? '',
      movementType: data['movementType'] ?? '',
      verificationMethod: data['verificationMethod'] ?? '',
      officerId: data['officerId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      schoolId: data['schoolId'] ?? '',
      pickupDetails: data['pickupDetails'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'timestamp': Timestamp.fromDate(timestamp),
      'gateId': gateId,
      'direction': direction,
      'movementType': movementType,
      'verificationMethod': verificationMethod,
      'officerId': officerId,
      'deviceId': deviceId,
      'schoolId': schoolId,
      'pickupDetails': pickupDetails,
    };
  }
}

class StaffMovementModel extends StaffMovement {
  const StaffMovementModel({
    required super.id,
    required super.staffId,
    required super.staffName,
    required super.timestamp,
    required super.gateId,
    required super.direction,
    required super.verificationMethod,
    required super.officerId,
    required super.schoolId,
  });

  factory StaffMovementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StaffMovementModel(
      id: doc.id,
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      gateId: data['gateId'] ?? '',
      direction: data['direction'] ?? '',
      verificationMethod: data['verificationMethod'] ?? '',
      officerId: data['officerId'] ?? '',
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'timestamp': Timestamp.fromDate(timestamp),
      'gateId': gateId,
      'direction': direction,
      'verificationMethod': verificationMethod,
      'officerId': officerId,
      'schoolId': schoolId,
    };
  }
}

class EmergencyEventModel extends EmergencyEvent {
  const EmergencyEventModel({
    required super.id,
    required super.type,
    required super.startTime,
    super.endTime,
    required super.description,
    required super.responseActions,
    required super.involvedPersonIds,
    required super.status,
    required super.schoolId,
  });

  factory EmergencyEventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EmergencyEventModel(
      id: doc.id,
      type: data['type'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      description: data['description'] ?? '',
      responseActions: List<String>.from(data['responseActions'] ?? []),
      involvedPersonIds: List<String>.from(data['involvedPersonIds'] ?? []),
      status: data['status'] ?? '',
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'description': description,
      'responseActions': responseActions,
      'involvedPersonIds': involvedPersonIds,
      'status': status,
      'schoolId': schoolId,
    };
  }
}

class LostAndFoundItemModel extends LostAndFoundItem {
  const LostAndFoundItemModel({
    required super.id,
    required super.description,
    required super.locationFound,
    required super.dateFound,
    super.photoUrl,
    required super.foundByPersonId,
    required super.isClaimed,
    super.claimDetails,
    required super.schoolId,
  });

  factory LostAndFoundItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LostAndFoundItemModel(
      id: doc.id,
      description: data['description'] ?? '',
      locationFound: data['locationFound'] ?? '',
      dateFound: (data['dateFound'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      foundByPersonId: data['foundByPersonId'] ?? '',
      isClaimed: data['isClaimed'] ?? false,
      claimDetails: data['claimDetails'],
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'locationFound': locationFound,
      'dateFound': Timestamp.fromDate(dateFound),
      'photoUrl': photoUrl,
      'foundByPersonId': foundByPersonId,
      'isClaimed': isClaimed,
      'claimDetails': claimDetails,
      'schoolId': schoolId,
    };
  }
}

class SecurityPatrolModel extends SecurityPatrol {
  const SecurityPatrolModel({
    required super.id,
    required super.officerId,
    required super.location,
    required super.timestamp,
    required super.observations,
    required super.photoUrls,
    required super.issuesFound,
    required super.schoolId,
  });

  factory SecurityPatrolModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SecurityPatrolModel(
      id: doc.id,
      officerId: data['officerId'] ?? '',
      location: data['location'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      observations: data['observations'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      issuesFound: List<String>.from(data['issuesFound'] ?? []),
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'officerId': officerId,
      'location': location,
      'timestamp': Timestamp.fromDate(timestamp),
      'observations': observations,
      'photoUrls': photoUrls,
      'issuesFound': issuesFound,
      'schoolId': schoolId,
    };
  }
}

class PickupAuthorizationModel extends PickupAuthorization {
  const PickupAuthorizationModel({
    required super.id,
    required super.studentId,
    required super.parentId,
    required super.authorizedPersonName,
    required super.phone,
    required super.relationship,
    super.photoUrl,
    super.idDocumentUrl,
    super.expiryDate,
    required super.schoolId,
  });

  factory PickupAuthorizationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PickupAuthorizationModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      parentId: data['parentId'] ?? '',
      authorizedPersonName: data['authorizedPersonName'] ?? '',
      phone: data['phone'] ?? '',
      relationship: data['relationship'] ?? '',
      photoUrl: data['photoUrl'],
      idDocumentUrl: data['idDocumentUrl'],
      expiryDate: data['expiryDate'] != null ? (data['expiryDate'] as Timestamp).toDate() : null,
      schoolId: data['schoolId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'parentId': parentId,
      'authorizedPersonName': authorizedPersonName,
      'phone': phone,
      'relationship': relationship,
      'photoUrl': photoUrl,
      'idDocumentUrl': idDocumentUrl,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'schoolId': schoolId,
    };
  }
}
