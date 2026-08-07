import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/entities/gate.dart';
import '../../domain/entities/movement_event.dart';
import '../../domain/entities/pickup_authorization.dart';
import '../../domain/entities/security_incident.dart';
import '../../domain/entities/visitor.dart';

/// Firestore access for the gate_ops module, all nested under
/// `schools/{schoolId}/...` per plan section 5 (fixing the old top-level
/// `visitors` collection's multi-tenancy inconsistency).
abstract class GateOpsRemoteDataSource {
  Stream<List<Gate>> watchGates(String schoolId);

  Future<void> recordMovementEvent(MovementEvent event);
  Stream<List<MovementEvent>> watchMovementEvents(
    String schoolId, {
    PersonType? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  });

  Future<void> checkInVisitor(Visitor visitor);
  Future<void> checkOutVisitor(String schoolId, String visitorId);
  Stream<List<Visitor>> watchVisitors(String schoolId);
  Future<List<Visitor>> getVisitorsOnce(String schoolId);

  Future<void> reportIncident(SecurityIncident incident);

  Future<void> triggerEmergency(EmergencyEvent emergency);
  Future<void> resolveEmergency(String schoolId, String emergencyId);
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId);

  Future<List<PickupAuthorization>> getPickupAuthorizations(
    String schoolId,
    String studentId,
  );
  Future<void> addPickupAuthorization(PickupAuthorization authorization);
}

class GateOpsRemoteDataSourceImpl implements GateOpsRemoteDataSource {
  final FirebaseFirestore firestore;

  GateOpsRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _gates(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('gates');

  CollectionReference<Map<String, dynamic>> _movementEvents(
    String schoolId,
  ) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('movement_events');

  CollectionReference<Map<String, dynamic>> _visitors(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('visitors');

  CollectionReference<Map<String, dynamic>> _incidents(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('security_incidents');

  CollectionReference<Map<String, dynamic>> _emergencies(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('emergency_events');

  CollectionReference<Map<String, dynamic>> _pickupAuthorizations(
    String schoolId,
  ) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('pickup_authorizations');

  @override
  Stream<List<Gate>> watchGates(String schoolId) {
    return _gates(schoolId).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => _gateFromDoc(schoolId, doc)).toList(),
    );
  }

  Gate _gateFromDoc(
    String schoolId,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Gate(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      assignedOfficerIds: List<String>.from(data['assignedOfficerIds'] ?? []),
      operatingHours: Map<String, dynamic>.from(data['operatingHours'] ?? {}),
      allowedUserRoles: List<String>.from(data['allowedUserRoles'] ?? []),
      requiredVerificationMethods: List<String>.from(
        data['requiredVerificationMethods'] ?? [],
      ),
      schoolId: schoolId,
      cameraId: data['cameraId'],
    );
  }

  @override
  Future<void> recordMovementEvent(MovementEvent event) async {
    // Writes to event.id (client-generated) rather than an auto-id, so the
    // offline-first repository's already-cached local row and this
    // Firestore doc share the same id.
    await _movementEvents(event.schoolId).doc(event.id).set({
      'schoolId': event.schoolId,
      'campusId': event.campusId,
      'gateId': event.gateId,
      'personType': event.personType.name,
      'personId': event.personId,
      'personName': event.personName,
      'direction': event.direction.name,
      'movementType': event.movementType,
      'verificationMethod': event.verificationMethod.id,
      'officerId': event.officerId,
      'officerRole': event.officerRole,
      'deviceId': event.deviceId,
      'deviceName': event.deviceName,
      'platform': event.platform,
      'appVersion': event.appVersion,
      'actionTimestamp': Timestamp.fromDate(event.actionTimestamp),
      'pickupParentCode': event.pickupParentCode,
      'pickupParentName': event.pickupParentName,
      'pickupPhoneNumber': event.pickupPhoneNumber,
    });
  }

  @override
  Stream<List<MovementEvent>> watchMovementEvents(
    String schoolId, {
    PersonType? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) {
    Query<Map<String, dynamic>> query = _movementEvents(schoolId);

    if (personType != null) {
      query = query.where('personType', isEqualTo: personType.name);
    }
    if (personId != null) {
      query = query.where('personId', isEqualTo: personId);
    }
    if (gateId != null) {
      query = query.where('gateId', isEqualTo: gateId);
    }
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query
          .where(
            'actionTimestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where('actionTimestamp', isLessThan: Timestamp.fromDate(end));
    }

    return query
        .orderBy('actionTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => _movementEventFromDoc(schoolId, d)).toList(),
        );
  }

  MovementEvent _movementEventFromDoc(
    String schoolId,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return MovementEvent(
      id: doc.id,
      schoolId: schoolId,
      campusId: data['campusId'],
      gateId: data['gateId'] ?? '',
      personType: PersonType.values.byName(data['personType'] ?? 'student'),
      personId: data['personId'] ?? '',
      personName: data['personName'] ?? '',
      direction: MovementDirection.values.byName(data['direction'] ?? 'in_'),
      movementType: data['movementType'] ?? '',
      verificationMethod:
          VerificationMethod.fromId(data['verificationMethod'] ?? '') ??
          VerificationMethod.none,
      officerId: data['officerId'] ?? '',
      officerRole: data['officerRole'] ?? '',
      deviceId: data['deviceId'] ?? '',
      deviceName: data['deviceName'],
      platform: data['platform'] ?? '',
      appVersion: data['appVersion'] ?? '',
      actionTimestamp: (data['actionTimestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      serverTimestamp: (data['serverTimestamp'] as Timestamp?)?.toDate(),
      syncStatus: SyncStatus.synced,
      pickupParentCode: data['pickupParentCode'],
      pickupParentName: data['pickupParentName'],
      pickupPhoneNumber: data['pickupPhoneNumber'],
    );
  }

  Map<String, dynamic> _visitorToMap(Visitor visitor) => {
    'schoolId': visitor.schoolId,
    'fullName': visitor.fullName,
    'phone': visitor.phone,
    'photoUrl': visitor.photoUrl,
    'purpose': visitor.purpose,
    'hostId': visitor.hostId,
    'hostName': visitor.hostName,
    'gateId': visitor.gateId,
    'arrivalTime': Timestamp.fromDate(visitor.arrivalTime),
    'departureTime': visitor.departureTime != null
        ? Timestamp.fromDate(visitor.departureTime!)
        : null,
    'status': visitor.status.name,
    'isQuickEntry': visitor.isQuickEntry,
    'badgeNumber': visitor.badgeNumber,
  };

  Visitor _visitorFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Visitor(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      purpose: data['purpose'] ?? '',
      hostId: data['hostId'],
      hostName: data['hostName'],
      gateId: data['gateId'] ?? '',
      arrivalTime: (data['arrivalTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      departureTime: (data['departureTime'] as Timestamp?)?.toDate(),
      status: VisitorStatus.values.byName(data['status'] ?? 'checkedIn'),
      isQuickEntry: data['isQuickEntry'] ?? true,
      badgeNumber: data['badgeNumber'],
      syncStatus: SyncStatus.synced,
    );
  }

  @override
  Future<void> checkInVisitor(Visitor visitor) async {
    await _visitors(visitor.schoolId).doc(visitor.id).set(_visitorToMap(visitor));
  }

  @override
  Future<void> checkOutVisitor(String schoolId, String visitorId) async {
    await _visitors(schoolId).doc(visitorId).update({
      'status': VisitorStatus.checkedOut.name,
      'departureTime': Timestamp.now(),
    });
  }

  @override
  Stream<List<Visitor>> watchVisitors(String schoolId) {
    return _visitors(schoolId).snapshots().map(
      (snapshot) => snapshot.docs.map(_visitorFromDoc).toList(),
    );
  }

  @override
  Future<List<Visitor>> getVisitorsOnce(String schoolId) async {
    final snapshot = await _visitors(schoolId).get();
    return snapshot.docs.map(_visitorFromDoc).toList();
  }

  @override
  Future<void> reportIncident(SecurityIncident incident) async {
    await _incidents(incident.schoolId).doc(incident.id).set({
      'schoolId': incident.schoolId,
      'gateId': incident.gateId,
      'type': incident.type,
      'description': incident.description,
      'timestamp': Timestamp.fromDate(incident.timestamp),
      'photoUrls': incident.photoUrls,
      'reportedByOfficerId': incident.reportedByOfficerId,
      'status': incident.status,
    });
  }

  @override
  Future<void> triggerEmergency(EmergencyEvent emergency) async {
    await _emergencies(emergency.schoolId).doc(emergency.id).set({
      'schoolId': emergency.schoolId,
      'gateId': emergency.gateId,
      'type': emergency.type,
      'startTime': Timestamp.fromDate(emergency.startTime),
      'endTime': emergency.endTime != null
          ? Timestamp.fromDate(emergency.endTime!)
          : null,
      'description': emergency.description,
      'officerId': emergency.officerId,
      'deviceId': emergency.deviceId,
      'status': emergency.status,
    });
  }

  @override
  Future<void> resolveEmergency(String schoolId, String emergencyId) async {
    await _emergencies(schoolId).doc(emergencyId).update({
      'status': 'Resolved',
      'endTime': Timestamp.now(),
    });
  }

  @override
  Stream<List<EmergencyEvent>> watchActiveEmergencies(String schoolId) {
    return _emergencies(schoolId)
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _emergencyFromDoc(schoolId, doc))
              .toList(),
        );
  }

  EmergencyEvent _emergencyFromDoc(
    String schoolId,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return EmergencyEvent(
      id: doc.id,
      schoolId: schoolId,
      gateId: data['gateId'] ?? '',
      type: data['type'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      description: data['description'] ?? '',
      officerId: data['officerId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      status: data['status'] ?? 'Active',
      syncStatus: SyncStatus.synced,
    );
  }

  @override
  Future<List<PickupAuthorization>> getPickupAuthorizations(
    String schoolId,
    String studentId,
  ) async {
    final snapshot = await _pickupAuthorizations(
      schoolId,
    ).where('studentId', isEqualTo: studentId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PickupAuthorization(
        id: doc.id,
        studentId: data['studentId'] ?? '',
        parentId: data['parentId'] ?? '',
        authorizedPersonName: data['authorizedPersonName'] ?? '',
        phone: data['phone'] ?? '',
        relationship: data['relationship'] ?? '',
        photoUrl: data['photoUrl'],
        idDocumentUrl: data['idDocumentUrl'],
        expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
        schoolId: schoolId,
      );
    }).toList();
  }

  @override
  Future<void> addPickupAuthorization(
    PickupAuthorization authorization,
  ) async {
    await _pickupAuthorizations(
      authorization.schoolId,
    ).doc(authorization.id).set({
      'studentId': authorization.studentId,
      'parentId': authorization.parentId,
      'authorizedPersonName': authorization.authorizedPersonName,
      'phone': authorization.phone,
      'relationship': authorization.relationship,
      'photoUrl': authorization.photoUrl,
      'idDocumentUrl': authorization.idDocumentUrl,
      'expiryDate': authorization.expiryDate != null
          ? Timestamp.fromDate(authorization.expiryDate!)
          : null,
    });
  }
}
