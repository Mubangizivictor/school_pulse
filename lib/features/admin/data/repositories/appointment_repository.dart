import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Appointment Logic
  Stream<List<Appointment>> getAppointments(String schoolId) {
    return _firestore
        .collection('appointments')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createAppointment(
    Appointment appointment,
    String schoolId,
  ) async {
    await _firestore.collection('appointments').add({
      ...appointment.toMap(),
      'schoolId': schoolId,
    });
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore.collection('appointments').doc(id).update({
      'status': status,
    });
  }
}
