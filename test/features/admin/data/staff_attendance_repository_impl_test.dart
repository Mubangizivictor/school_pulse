import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/data/repositories/staff_attendance_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StaffAttendanceRepositoryImpl repo;

  const schoolA = 'school-a';
  const schoolB = 'school-b';
  final day = DateTime(2026, 9, 1);

  Future<void> seed(
    String id, {
    required String schoolId,
    required DateTime clockIn,
    String? campusId,
    String status = 'on_time',
  }) {
    return firestore.collection('staff_attendance').doc(id).set({
      'schoolId': schoolId,
      'staffId': id,
      'campusId': campusId,
      'clockIn': Timestamp.fromDate(clockIn),
      'status': status,
      'location': 'Gate',
    });
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = StaffAttendanceRepositoryImpl(firestore: firestore);
  });

  test('docId is deterministic per staff per day', () {
    expect(
      repo.docId('staff-1', DateTime(2026, 9, 1, 23)),
      'staff-1_2026-09-01',
    );
    expect(
      repo.docId('staff-1', DateTime(2026, 9, 1, 0)),
      'staff-1_2026-09-01',
    );
  });

  group('watchDay', () {
    test(
      'returns only records whose clockIn falls on the day, in tenant',
      () async {
        await seed('a', schoolId: schoolA, clockIn: DateTime(2026, 9, 1, 8));
        await seed(
          'b',
          schoolId: schoolA,
          clockIn: DateTime(2026, 9, 1, 23, 59),
        );
        await seed('c', schoolId: schoolA, clockIn: DateTime(2026, 9, 2, 0, 1));
        await seed('d', schoolId: schoolB, clockIn: DateTime(2026, 9, 1, 9));

        final records = await repo.watchDay(schoolId: schoolA, day: day).first;
        expect(records.map((r) => r.staffId).toSet(), {'a', 'b'});
      },
    );

    test('narrows to a campus when given', () async {
      await seed(
        'a',
        schoolId: schoolA,
        clockIn: DateTime(2026, 9, 1, 8),
        campusId: 'main',
      );
      await seed(
        'b',
        schoolId: schoolA,
        clockIn: DateTime(2026, 9, 1, 8),
        campusId: 'annex',
      );

      final records = await repo
          .watchDay(schoolId: schoolA, day: day, campusId: 'main')
          .first;
      expect(records.map((r) => r.staffId), ['a']);
    });

    test('emits an empty list when nothing matches', () async {
      final records = await repo.watchDay(schoolId: schoolA, day: day).first;
      expect(records, isEmpty);
    });
  });

  group('fetchRange', () {
    test('spans multiple days inclusive of the end day', () async {
      await seed('a', schoolId: schoolA, clockIn: DateTime(2026, 9, 1, 8));
      await seed('b', schoolId: schoolA, clockIn: DateTime(2026, 9, 3, 20));
      await seed('c', schoolId: schoolA, clockIn: DateTime(2026, 9, 4, 8));

      final records = await repo.fetchRange(
        schoolId: schoolA,
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 3),
      );
      expect(records.map((r) => r.staffId).toSet(), {'a', 'b'});
    });

    test('maps to typed records', () async {
      await seed(
        'a',
        schoolId: schoolA,
        clockIn: DateTime(2026, 9, 1, 8),
        status: 'late',
      );
      final records = await repo.fetchRange(
        schoolId: schoolA,
        from: day,
        to: day,
      );
      expect(records.single.status, StaffAttendanceStatus.late);
    });
  });

  group('watchShifts', () {
    test('reads tenant-scoped shift docs', () async {
      await firestore
          .collection('institutions')
          .doc(schoolA)
          .collection('staff_shifts')
          .doc('staff-1')
          .set({
            'scheduledStart': '08:00',
            'scheduledEnd': '16:00',
            'daysOfWeek': [1, 2, 3, 4, 5],
            'graceMinutes': 10,
          });

      final shifts = await repo.watchShifts(schoolId: schoolA).first;
      expect(shifts.single.staffId, 'staff-1');
      expect(shifts.single.scheduledStart, '08:00');
    });

    test('does not leak another school\'s shifts', () async {
      await firestore
          .collection('institutions')
          .doc(schoolB)
          .collection('staff_shifts')
          .doc('staff-1')
          .set({'scheduledStart': '08:00', 'scheduledEnd': '16:00'});

      final shifts = await repo.watchShifts(schoolId: schoolA).first;
      expect(shifts, isEmpty);
    });
  });

  group('watchLeaveForDay', () {
    test('only surfaces approved leave covering the day', () async {
      final col = firestore
          .collection('institutions')
          .doc(schoolA)
          .collection('staff_leave_requests');
      await col.doc('l1').set({
        'staffId': 'staff-1',
        'startDate': '2026-09-01',
        'endDate': '2026-09-03',
        'status': 'approved',
        'reason': 'x',
      });
      await col.doc('l2').set({
        'staffId': 'staff-2',
        'startDate': '2026-09-01',
        'endDate': '2026-09-03',
        'status': 'pending',
        'reason': 'x',
      });
      await col.doc('l3').set({
        'staffId': 'staff-3',
        'startDate': '2026-09-10',
        'endDate': '2026-09-12',
        'status': 'approved',
        'reason': 'x',
      });

      final leave = await repo
          .watchLeaveForDay(schoolId: schoolA, day: DateTime(2026, 9, 2))
          .first;
      expect(leave.map((l) => l.staffId), ['staff-1']);
    });
  });
}
