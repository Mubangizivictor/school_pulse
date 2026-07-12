import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/bloc/receptionist_state.dart';

abstract class ReceptionistRemoteDataSource {
  Future<List<Appointment>> getUpcomingAppointments();
  Future<int> getTotalVisitorsToday();
  Future<void> scheduleAppointment(Appointment appointment);
}

class ReceptionistRemoteDataSourceImpl implements ReceptionistRemoteDataSource {
  final FirebaseFirestore firestore;

  ReceptionistRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<Appointment>> getUpcomingAppointments() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final snapshot = await firestore
        .collection('appointments')
        .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('time', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Appointment(
        id: doc.id,
        visitorName: data['visitorName'] ?? '',
        purpose: data['purpose'] ?? '',
        time: (data['time'] as Timestamp).toDate(),
        status: data['status'] ?? 'Scheduled',
      );
    }).toList();
  }

  @override
  Future<int> getTotalVisitorsToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await firestore
        .collection('visitor_logs')
        .where('entryTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }

  @override
  Future<void> scheduleAppointment(Appointment appointment) async {
    await firestore.collection('appointments').add({
      'visitorName': appointment.visitorName,
      'purpose': appointment.purpose,
      'time': Timestamp.fromDate(appointment.time),
      'status': appointment.status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
