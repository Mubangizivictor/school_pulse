import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/data/models/staff_shift.dart';
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

  @override
  Stream<List<StaffShift>> watchShifts({required String schoolId}) {
    return _firestore
        .collection('institutions')
        .doc(schoolId)
        .collection('staff_shifts')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => StaffShift.fromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Stream<List<StaffLeaveRequest>> watchLeaveForDay({
    required String schoolId,
    required DateTime day,
  }) {
    // Server-side range filter narrows candidates; exact coverage of `day`
    // (including approval status) is finished client-side via
    // StaffLeaveRequest.coversDay, since Firestore can't express "day
    // between startDate and endDate" as a single range query here.
    return _firestore
        .collection('institutions')
        .doc(schoolId)
        .collection('staff_leave_requests')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => StaffLeaveRequest.fromMap(d.id, d.data()))
              .where((l) => l.coversDay(day))
              .toList(),
        );
  }

  @override
  Future<void> clockIn({
    required String schoolId,
    required String staffId,
    required DateTime day,
    String? location,
    String? operationId,
  }) async {
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
    await functions.httpsCallable('clockInStaff').call({
      'schoolId': schoolId,
      'staffId': staffId,
      if (location != null) 'location': location,
      if (operationId != null) 'operationId': operationId,
    });
  }

  @override
  Future<void> correct({
    required String schoolId,
    required String staffId,
    required DateTime day,
    required String reason,
    required Map<String, dynamic> patch,
    String? operationId,
  }) async {
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
    await functions.httpsCallable('correctStaffAttendance').call({
      'schoolId': schoolId,
      'staffId': staffId,
      'day': DateFormat('yyyy-MM-dd').format(day),
      'reason': reason,
      'patch': patch,
      if (operationId != null) 'operationId': operationId,
    });
  }
}
