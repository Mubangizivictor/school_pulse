import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/attendance_qr_integration/data/repositories/attendance_qr_repository_web.dart';
import 'package:school_pulse/features/attendance_qr_integration/domain/entities/qr_attendance_record.dart';

void main() {
  final record = QrAttendanceRecord(
    id: 'legacy-record',
    studentUniqueId: 'student-a',
    studentName: 'Student A',
    className: 'class-a',
    status: QrAttendanceStatus.present,
    timestamp: DateTime(2026, 8, 14),
    scannedBy: 'staff-a',
    schoolId: 'school-a',
    module: 'students',
  );

  test(
    'legacy web QR adapter never creates a parallel attendance record',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = AttendanceQrRepositoryWeb(firestore);

      final result = await repository.saveAttendance(record);

      expect(result.isLeft(), true);
      expect(
        (await firestore.collection('attendance_records').get()).docs,
        isEmpty,
      );
    },
  );

  test('legacy QR sync does not report a false success', () async {
    final result = await AttendanceQrRepositoryWeb(
      FakeFirebaseFirestore(),
    ).syncWithFirebase();

    expect(result.isLeft(), true);
  });
}
