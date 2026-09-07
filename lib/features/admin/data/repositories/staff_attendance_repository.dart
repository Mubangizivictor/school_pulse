import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';

export 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';

class StaffAttendanceRepositoryImpl implements StaffAttendanceRepository {
  StaffAttendanceRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('staff_attendance');

  static String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  String docId(String staffId, DateTime day) => '${staffId}_${_dayKey(day)}';

  @override
  Stream<List<StaffAttendanceRecord>> watchDay({
    required String schoolId,
    required DateTime day,
    String? campusId,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    Query<Map<String, dynamic>> q = _col
        .where('schoolId', isEqualTo: schoolId)
        .where('clockIn', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('clockIn', isLessThan: Timestamp.fromDate(end));
    if (campusId != null) {
      q = q.where('campusId', isEqualTo: campusId);
    }
    return q.snapshots().map(
      (snap) => snap.docs
          .map((d) => StaffAttendanceRecord.fromMap(d.data()))
          .toList(),
    );
  }

  @override
  Future<List<StaffAttendanceRecord>> fetchRange({
    required String schoolId,
    required DateTime from,
    required DateTime to,
    String? campusId,
  }) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(
      to.year,
      to.month,
      to.day,
    ).add(const Duration(days: 1));
    Query<Map<String, dynamic>> q = _col
        .where('schoolId', isEqualTo: schoolId)
        .where('clockIn', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('clockIn', isLessThan: Timestamp.fromDate(end));
    if (campusId != null) {
      q = q.where('campusId', isEqualTo: campusId);
    }
    final snap = await q.get();
    return snap.docs
        .map((d) => StaffAttendanceRecord.fromMap(d.data()))
        .toList();
  }
}
