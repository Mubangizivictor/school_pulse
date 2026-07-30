import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/security_models.dart';

abstract class SecurityRemoteDataSource {
  // Gates
  Stream<List<GateModel>> watchGates(String schoolId);
  Future<void> createGate(GateModel gate);
  Future<void> updateGate(GateModel gate);

  // Student Movement
  Future<void> recordStudentMovement(StudentMovementModel movement);
  Stream<List<StudentMovementModel>> watchStudentMovements(String schoolId, {DateTime? date, String? gateId});
  
  // Staff Movement
  Future<void> recordStaffMovement(StaffMovementModel movement);
  Stream<List<StaffMovementModel>> watchStaffMovements(String schoolId, {DateTime? date, String? gateId});

  // Pickup Management
  Future<List<PickupAuthorizationModel>> getPickupAuthorizations(String studentId);
  Future<void> addPickupAuthorization(PickupAuthorizationModel authorization);

  // Incidents
  Future<void> reportIncident(SecurityIncidentModel incident);
  Stream<List<SecurityIncidentModel>> watchIncidents(String schoolId);
  Future<void> updateIncidentStatus(String incidentId, String status, String resolution);

  // Emergency
  Future<void> triggerEmergency(EmergencyEventModel event);
  Stream<List<EmergencyEventModel>> watchActiveEmergencies(String schoolId);
  Future<void> resolveEmergency(String emergencyId, DateTime endTime, List<String> actions);

  // Patrols
  Future<void> recordPatrol(SecurityPatrolModel patrol);
  Stream<List<SecurityPatrolModel>> watchPatrols(String schoolId);

  // Lost and Found
  Future<void> reportFoundItem(LostAndFoundItemModel item);
  Future<void> claimItem(String itemId, Map<String, dynamic> claimDetails);
  Stream<List<LostAndFoundItemModel>> watchLostAndFound(String schoolId);

  // Dashboard Stats
  Future<Map<String, dynamic>> getSecurityDashboardStats(String schoolId);
}

class SecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  final FirebaseFirestore firestore;

  SecurityRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<GateModel>> watchGates(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('gates')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GateModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> createGate(GateModel gate) async {
    await firestore
        .collection('schools')
        .doc(gate.schoolId)
        .collection('gates')
        .add(gate.toFirestore());
  }

  @override
  Future<void> updateGate(GateModel gate) async {
    await firestore
        .collection('schools')
        .doc(gate.schoolId)
        .collection('gates')
        .doc(gate.id)
        .update(gate.toFirestore());
  }

  @override
  Future<void> recordStudentMovement(StudentMovementModel movement) async {
    await firestore
        .collection('schools')
        .doc(movement.schoolId)
        .collection('student_movements')
        .add(movement.toFirestore());
  }

  @override
  Stream<List<StudentMovementModel>> watchStudentMovements(String schoolId, {DateTime? date, String? gateId}) {
    Query query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('student_movements');
    
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query.where('timestamp', isGreaterThanOrEqualTo: start).where('timestamp', isLessThan: end);
    }
    
    if (gateId != null) {
      query = query.where('gateId', isEqualTo: gateId);
    }

    return query.orderBy('timestamp', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => StudentMovementModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> recordStaffMovement(StaffMovementModel movement) async {
    await firestore
        .collection('schools')
        .doc(movement.schoolId)
        .collection('staff_movements')
        .add(movement.toFirestore());
  }

  @override
  Stream<List<StaffMovementModel>> watchStaffMovements(String schoolId, {DateTime? date, String? gateId}) {
    Query query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('staff_movements');
    
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query.where('timestamp', isGreaterThanOrEqualTo: start).where('timestamp', isLessThan: end);
    }
    
    if (gateId != null) {
      query = query.where('gateId', isEqualTo: gateId);
    }

    return query.orderBy('timestamp', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => StaffMovementModel.fromFirestore(doc)).toList());
  }

  @override
  Future<List<PickupAuthorizationModel>> getPickupAuthorizations(String studentId) async {
    final snapshot = await firestore
        .collectionGroup('pickup_authorizations')
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs.map((doc) => PickupAuthorizationModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addPickupAuthorization(PickupAuthorizationModel authorization) async {
    await firestore
        .collection('schools')
        .doc(authorization.schoolId)
        .collection('pickup_authorizations')
        .add(authorization.toFirestore());
  }

  @override
  Future<void> reportIncident(SecurityIncidentModel incident) async {
    await firestore
        .collection('schools')
        .doc(incident.schoolId)
        .collection('security_incidents')
        .add(incident.toFirestore());
  }

  @override
  Stream<List<SecurityIncidentModel>> watchIncidents(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('security_incidents')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SecurityIncidentModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateIncidentStatus(String incidentId, String status, String resolution) async {
     final snapshot = await firestore.collectionGroup('security_incidents').where(FieldPath.documentId, isEqualTo: incidentId).get();
     if(snapshot.docs.isNotEmpty) {
       await snapshot.docs.first.reference.update({
         'status': status,
         'report': resolution,
       });
     }
  }

  @override
  Future<void> triggerEmergency(EmergencyEventModel event) async {
    await firestore
        .collection('schools')
        .doc(event.schoolId)
        .collection('emergency_events')
        .add(event.toFirestore());
  }

  @override
  Stream<List<EmergencyEventModel>> watchActiveEmergencies(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('emergency_events')
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EmergencyEventModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> resolveEmergency(String emergencyId, DateTime endTime, List<String> actions) async {
    final snapshot = await firestore.collectionGroup('emergency_events').where(FieldPath.documentId, isEqualTo: emergencyId).get();
     if(snapshot.docs.isNotEmpty) {
       await snapshot.docs.first.reference.update({
         'status': 'Resolved',
         'endTime': Timestamp.fromDate(endTime),
         'responseActions': actions,
       });
     }
  }

  @override
  Future<void> recordPatrol(SecurityPatrolModel patrol) async {
    await firestore
        .collection('schools')
        .doc(patrol.schoolId)
        .collection('security_patrols')
        .add(patrol.toFirestore());
  }

  @override
  Stream<List<SecurityPatrolModel>> watchPatrols(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('security_patrols')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SecurityPatrolModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> reportFoundItem(LostAndFoundItemModel item) async {
    await firestore
        .collection('schools')
        .doc(item.schoolId)
        .collection('lost_and_found')
        .add(item.toFirestore());
  }

  @override
  Future<void> claimItem(String itemId, Map<String, dynamic> claimDetails) async {
    final snapshot = await firestore.collectionGroup('lost_and_found').where(FieldPath.documentId, isEqualTo: itemId).get();
     if(snapshot.docs.isNotEmpty) {
       await snapshot.docs.first.reference.update({
         'isClaimed': true,
         'claimDetails': claimDetails,
       });
     }
  }

  @override
  Stream<List<LostAndFoundItemModel>> watchLostAndFound(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('lost_and_found')
        .orderBy('dateFound', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LostAndFoundItemModel.fromFirestore(doc)).toList());
  }

  @override
  Future<Map<String, dynamic>> getSecurityDashboardStats(String schoolId) async {
    // This would typically involve several count queries or a cloud function.
    // For now, return placeholders or do basic counts if possible.
    final studentsIn = await firestore.collection('schools').doc(schoolId).collection('student_movements').where('direction', isEqualTo: 'In').where('timestamp', isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(hours: 24))).get();
    final visitorsIn = await firestore.collection('schools').doc(schoolId).collection('visitors').where('status', isEqualTo: 'Checked In').get();
    final incidentsToday = await firestore.collection('schools').doc(schoolId).collection('security_incidents').where('timestamp', isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(hours: 24))).get();
    
    return {
      'studentsCheckedInToday': studentsIn.docs.length,
      'visitorsCurrentlyInside': visitorsIn.docs.length,
      'incidentsToday': incidentsToday.docs.length,
    };
  }
}
