import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/qr_attendance_record.dart';

/// Shared, Isar-free Firestore fan-out logic used by both the mobile and
/// web AttendanceQrRepository implementations - routes a scan into the
/// same tenant-scoped collection its module already uses for
/// manually-entered records, rather than a dead-end parallel collection.
mixin AttendanceQrFirestoreWriter {
  FirebaseFirestore get firestore;

  Future<void> writeToScopedCollection(QrAttendanceRecord record) async {
    switch (record.module) {
      case 'boarding':
        await firestore.collection('boarding_attendance').add({
          'schoolId': record.schoolId,
          'studentId': record.studentUniqueId,
          'studentName': record.studentName,
          'dormitoryId': record.className,
          'date': Timestamp.fromDate(record.timestamp),
          'type': 'Evening',
          'status': _boardingStatusFor(record.status),
          'recordedBy': record.scannedBy,
        });
      case 'staff':
        await firestore
            .collection('staff_attendance')
            .doc('${record.studentUniqueId}_${_dateKey(record.timestamp)}')
            .set({
              'schoolId': record.schoolId,
              'staffId': record.studentUniqueId,
              'clockIn': Timestamp.fromDate(record.timestamp),
              'status': record.status == QrAttendanceStatus.late
                  ? 'late'
                  : 'on_time',
              'location': 'QR Scan',
            });
      default:
        await firestore
            .collection('attendance_records')
            .doc('${record.studentUniqueId}_${_dateKey(record.timestamp)}')
            .set({
              'schoolId': record.schoolId,
              'studentId': record.studentUniqueId,
              'className': record.className,
              'date': Timestamp.fromDate(record.timestamp),
              'status': record.status.name,
              'note': '',
              'updatedAt': FieldValue.serverTimestamp(),
            });
    }
  }

  String _boardingStatusFor(QrAttendanceStatus status) {
    switch (status) {
      case QrAttendanceStatus.present:
      case QrAttendanceStatus.late:
        return 'Present';
      case QrAttendanceStatus.excused:
        return 'Leave';
      case QrAttendanceStatus.absent:
        return 'Absent';
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
