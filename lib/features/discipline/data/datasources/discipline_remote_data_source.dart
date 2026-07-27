import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import '../models/discipline_incident_model.dart';
import '../models/counseling_session_model.dart';

abstract class DisciplineRemoteDataSource {
  Future<List<DisciplineIncidentModel>> getDisciplineIncidents(String studentId);
  Future<List<DisciplineIncidentModel>> getRecentDisciplineIncidents();
  Future<void> logIncident(DisciplineIncidentModel incident);
  
  Future<List<CounselingSessionModel>> getCounselingSessions();
  Future<void> logCounselingSession(CounselingSessionModel session);
}

class DisciplineRemoteDataSourceImpl implements DisciplineRemoteDataSource {
  final FirebaseFirestore firestore;

  DisciplineRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DisciplineIncidentModel>> getDisciplineIncidents(String studentId) async {
    final snapshot = await firestore
        .collection('discipline_incidents')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => DisciplineIncidentModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<DisciplineIncidentModel>> getRecentDisciplineIncidents() async {
    final snapshot = await firestore
        .collection('discipline_incidents')
        .orderBy('date', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => DisciplineIncidentModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> logIncident(DisciplineIncidentModel incident) async {
    await firestore.collection('discipline_incidents').add(incident.toFirestore());
    await _notifyParentAndClassTeacher(incident);
  }

  /// Writes to the same 'alerts' collection the parent Notifications screen
  /// (queried by studentId) and the staff notification bell (queried by
  /// userId) already read, so both sides find out without any new
  /// infrastructure. Best-effort: an incident is still logged even if a
  /// lookup or write here fails.
  Future<void> _notifyParentAndClassTeacher(DisciplineIncidentModel incident) async {
    try {
      final studentDoc = await firestore.collection('students').doc(incident.studentId).get();
      final studentName = studentDoc.data()?['name'] as String? ?? 'A student';
      final className = studentDoc.data()?['className'] as String?;

      await firestore.collection('alerts').add({
        'studentId': incident.studentId,
        'title': 'Discipline Incident Logged',
        'message': '$studentName: ${incident.description}',
        'severity': incident.severity.name,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (className != null && className.isNotEmpty) {
        final teacherSnapshot = await firestore
            .collection('users')
            .where('role', isEqualTo: 'classTeacher')
            .where('assignedClass', isEqualTo: className)
            .limit(1)
            .get();
        if (teacherSnapshot.docs.isNotEmpty) {
          final teacherId = teacherSnapshot.docs.first.id;
          await NotificationService().sendDirectNotification(
            userId: teacherId,
            title: 'Discipline Incident: $studentName',
            body: incident.description,
          );
        }
      }
    } catch (_) {
      // Notification failures shouldn't roll back the incident record.
    }
  }

  @override
  Future<List<CounselingSessionModel>> getCounselingSessions() async {
    final snapshot = await firestore
        .collection('counseling_sessions')
        .orderBy('date', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => CounselingSessionModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> logCounselingSession(CounselingSessionModel session) async {
    await firestore.collection('counseling_sessions').add(session.toFirestore());
  }
}
