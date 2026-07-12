import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visitor.dart';
import '../models/appointment.dart';

class VisitorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Visitor>> getVisitors() {
    return _firestore
        .collection('visitors')
        .orderBy('checkIn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Visitor.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<Visitor>> getVisitorsOnce() async {
    final snapshot = await _firestore
        .collection('visitors')
        .orderBy('checkIn', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Visitor.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addVisitor(Visitor visitor) async {
    await _firestore.collection('visitors').add(visitor.toMap());
  }

  Future<void> checkOutVisitor(String id) async {
    await _firestore.collection('visitors').doc(id).update({
      'checkOut': Timestamp.now(),
    });
  }

  // Appointment Logic
  Stream<List<Appointment>> getAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> createAppointment(Appointment appointment) async {
    await _firestore.collection('appointments').add(appointment.toMap());
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore.collection('appointments').doc(id).update({
      'status': status,
    });
  }
}
