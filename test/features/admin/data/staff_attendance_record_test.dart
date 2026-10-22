import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';

void main() {
  group('StaffAttendanceStatus', () {
    test('wire round-trips for every value', () {
      for (final s in StaffAttendanceStatus.values) {
        expect(StaffAttendanceStatus.fromWire(s.wire), s);
      }
    });

    test('legacy and unknown wire values fall back to onTime', () {
      expect(
        StaffAttendanceStatus.fromWire('on_time'),
        StaffAttendanceStatus.onTime,
      );
      expect(
        StaffAttendanceStatus.fromWire('late'),
        StaffAttendanceStatus.late,
      );
      expect(
        StaffAttendanceStatus.fromWire('garbage'),
        StaffAttendanceStatus.onTime,
      );
      expect(
        StaffAttendanceStatus.fromWire(null),
        StaffAttendanceStatus.onTime,
      );
      expect(StaffAttendanceStatus.fromWire(42), StaffAttendanceStatus.onTime);
    });

    test('notClockedIn is not in the correctable set', () {
      expect(
        StaffAttendanceStatus.correctable.contains(
          StaffAttendanceStatus.notClockedIn,
        ),
        isFalse,
      );
      expect(StaffAttendanceStatus.correctable, hasLength(4));
    });
  });

  group('StaffAttendanceRecord.fromMap', () {
    test('reads a full document', () {
      final now = DateTime(2026, 9, 1, 8, 45);
      final out = DateTime(2026, 9, 1, 17, 0);
      final r = StaffAttendanceRecord.fromMap({
        'schoolId': 'school-a',
        'staffId': 'staff-1',
        'campusId': 'campus-main',
        'clockIn': Timestamp.fromDate(now),
        'clockOut': Timestamp.fromDate(out),
        'status': 'late',
        'location': 'Sports complex',
        'lastCorrectionAt': Timestamp.fromDate(now),
        'lastCorrectedBy': 'admin-1',
      });
      expect(r.schoolId, 'school-a');
      expect(r.campusId, 'campus-main');
      expect(r.clockIn, now);
      expect(r.clockOut, out);
      expect(r.status, StaffAttendanceStatus.late);
      expect(r.location, 'Sports complex');
      expect(r.wasCorrected, isTrue);
      expect(r.lastCorrectedBy, 'admin-1');
    });

    test('tolerates a sparse legacy document', () {
      final r = StaffAttendanceRecord.fromMap({
        'schoolId': 'school-a',
        'staffId': 'staff-1',
        'clockIn': Timestamp.fromDate(DateTime(2026, 9, 1, 8)),
        'status': 'on_time',
      });
      expect(r.campusId, isNull);
      expect(r.clockOut, isNull);
      expect(r.status, StaffAttendanceStatus.onTime);
      expect(r.location, 'Main Gate');
      expect(r.wasCorrected, isFalse);
    });

    test('missing clockIn does not throw', () {
      final r = StaffAttendanceRecord.fromMap({
        'schoolId': 'school-a',
        'staffId': 'staff-1',
      });
      expect(r.clockIn.millisecondsSinceEpoch, 0);
    });
  });

  test('toMap omits null correction fields', () {
    final map = StaffAttendanceRecord(
      schoolId: 's',
      staffId: 'x',
      clockIn: DateTime(2026, 9, 1, 8),
      status: StaffAttendanceStatus.onTime,
      location: 'Gate',
    ).toMap();
    expect(map.containsKey('lastCorrectionAt'), isFalse);
    expect(map.containsKey('lastCorrectedBy'), isFalse);
    expect(map['status'], 'on_time');
  });
}
