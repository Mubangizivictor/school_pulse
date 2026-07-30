import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppointmentRemoteDataSource {
  Stream<List<Map<String, dynamic>>> watchAppointmentTypes(String schoolId);
  Future<void> saveAppointmentType(String id, Map<String, dynamic> data);
  Future<void> deleteAppointmentType(String id);

  Future<Map<String, dynamic>?> getStaffAvailability(String staffId);
  Future<void> saveStaffAvailability(String staffId, Map<String, dynamic> data);

  Future<List<Map<String, dynamic>>> getStaffByRoles(String schoolId, List<String> roleNames);
  Future<List<Map<String, dynamic>>> getStudentsByIds(List<String> ids);

  /// Appointments already booked for [staffId] on the calendar day containing
  /// [dayStart] (00:00-23:59), used to exclude taken slots when computing
  /// availability.
  Future<List<Map<String, dynamic>>> getStaffAppointmentsOnDate(String staffId, DateTime dayStart);

  Future<String> createAppointment(Map<String, dynamic> data);
  Future<void> updateAppointment(String id, Map<String, dynamic> data);

  Stream<List<Map<String, dynamic>>> watchForParent(String parentId, String schoolId);
  Stream<List<Map<String, dynamic>>> watchForStaff(String staffId, String schoolId);
  Stream<List<Map<String, dynamic>>> watchForSchool(String schoolId);

  Future<void> addNote(String appointmentId, Map<String, dynamic> data);
  Stream<List<Map<String, dynamic>>> watchNotes(String appointmentId);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;

  AppointmentRemoteDataSourceImpl(this.firestore);

  static const _typesCollection = 'appointment_types';
  static const _availabilityCollection = 'staff_availability';
  static const _appointmentsCollection = 'meeting_appointments';

  List<Map<String, dynamic>> _withId(QuerySnapshot snap) =>
      snap.docs.map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id}).toList();

  @override
  Stream<List<Map<String, dynamic>>> watchAppointmentTypes(String schoolId) {
    return firestore
        .collection(_typesCollection)
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(_withId);
  }

  @override
  Future<void> saveAppointmentType(String id, Map<String, dynamic> data) async {
    await firestore.collection(_typesCollection).doc(id).set(data, SetOptions(merge: true));
  }

  @override
  Future<void> deleteAppointmentType(String id) async {
    await firestore.collection(_typesCollection).doc(id).delete();
  }

  @override
  Future<Map<String, dynamic>?> getStaffAvailability(String staffId) async {
    final doc = await firestore.collection(_availabilityCollection).doc(staffId).get();
    return doc.data();
  }

  @override
  Future<void> saveStaffAvailability(String staffId, Map<String, dynamic> data) async {
    await firestore.collection(_availabilityCollection).doc(staffId).set(data, SetOptions(merge: true));
  }

  @override
  Future<List<Map<String, dynamic>>> getStaffByRoles(String schoolId, List<String> roleNames) async {
    if (roleNames.isEmpty) {
      final snap = await firestore
          .collection('users')
          .where('schoolId', isEqualTo: schoolId)
          .where('role', isNotEqualTo: 'parent')
          .get();
      return _withId(snap);
    }
    final snap = await firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('role', whereIn: roleNames)
        .get();
    return _withId(snap);
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = <Map<String, dynamic>>[];
    // Firestore whereIn caps at 30 values per query.
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final snap = await firestore
          .collection('students')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(_withId(snap));
    }
    return results;
  }

  @override
  Future<List<Map<String, dynamic>>> getStaffAppointmentsOnDate(String staffId, DateTime dayStart) async {
    final start = DateTime(dayStart.year, dayStart.month, dayStart.day);
    final end = start.add(const Duration(days: 1));
    final snap = await firestore
        .collection(_appointmentsCollection)
        .where('staffId', isEqualTo: staffId)
        .where('scheduledStart', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledStart', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: ['pending', 'approved', 'rescheduleProposed'])
        .get();
    return _withId(snap);
  }

  @override
  Future<String> createAppointment(Map<String, dynamic> data) async {
    final ref = await firestore.collection(_appointmentsCollection).add(data);
    return ref.id;
  }

  @override
  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await firestore.collection(_appointmentsCollection).doc(id).update(data);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchForParent(String parentId, String schoolId) {
    return firestore
        .collection(_appointmentsCollection)
        .where('schoolId', isEqualTo: schoolId)
        .where('requesterId', isEqualTo: parentId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map(_withId);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchForStaff(String staffId, String schoolId) {
    return firestore
        .collection(_appointmentsCollection)
        .where('schoolId', isEqualTo: schoolId)
        .where('staffId', isEqualTo: staffId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map(_withId);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchForSchool(String schoolId) {
    return firestore
        .collection(_appointmentsCollection)
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map(_withId);
  }

  @override
  Future<void> addNote(String appointmentId, Map<String, dynamic> data) async {
    await firestore
        .collection(_appointmentsCollection)
        .doc(appointmentId)
        .collection('private_notes')
        .add(data);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchNotes(String appointmentId) {
    return firestore
        .collection(_appointmentsCollection)
        .doc(appointmentId)
        .collection('private_notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_withId);
  }
}
