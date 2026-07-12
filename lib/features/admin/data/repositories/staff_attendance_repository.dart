import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_attendance_record.dart';

/// Docs are keyed by "{staffId}_{yyyy-mm-dd}" so there's at most one
/// clock-in record per staff member per day.
class StaffAttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _todayKeySuffix() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Stream<Map<String, StaffAttendanceRecord>> watchToday() {
    final start = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('staff_attendance')
        .where('clockIn', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('clockIn', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      final map = <String, StaffAttendanceRecord>{};
      for (final doc in snapshot.docs) {
        final record = StaffAttendanceRecord.fromMap(doc.data());
        map[record.staffId] = record;
      }
      return map;
    });
  }

  String todayDocId(String staffId) => '${staffId}_${_todayKeySuffix()}';
}
