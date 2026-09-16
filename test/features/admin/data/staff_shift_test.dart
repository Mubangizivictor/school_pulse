import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/data/models/staff_shift.dart';

void main() {
  group('StaffShift.fromMap', () {
    test('reads a full document', () {
      final s = StaffShift.fromMap('staff-1', {
        'campusId': 'campus-main',
        'scheduledStart': '08:00',
        'scheduledEnd': '16:00',
        'daysOfWeek': [1, 2, 3, 4, 5],
        'graceMinutes': 10,
      });
      expect(s.staffId, 'staff-1');
      expect(s.campusId, 'campus-main');
      expect(s.scheduledStart, '08:00');
      expect(s.scheduledEnd, '16:00');
      expect(s.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(s.graceMinutes, 10);
    });

    test('tolerates a sparse document', () {
      final s = StaffShift.fromMap('staff-1', const {});
      expect(s.scheduledStart, '');
      expect(s.daysOfWeek, isEmpty);
      expect(s.graceMinutes, 0);
    });
  });

  test('coversDay checks the weekday against daysOfWeek', () {
    // Monday 2026-09-14
    final monday = DateTime(2026, 9, 14);
    final saturday = DateTime(2026, 9, 19);
    const shift = StaffShift(
      staffId: 's1',
      scheduledStart: '08:00',
      scheduledEnd: '16:00',
      daysOfWeek: [1, 2, 3, 4, 5],
    );
    expect(shift.coversDay(monday), isTrue);
    expect(shift.coversDay(saturday), isFalse);
  });

  test('scheduledStartOn combines the time-of-day with a calendar date', () {
    const shift = StaffShift(
      staffId: 's1',
      scheduledStart: '08:30',
      scheduledEnd: '16:00',
      daysOfWeek: [1],
    );
    final day = DateTime(2026, 9, 14);
    expect(shift.scheduledStartOn(day), DateTime(2026, 9, 14, 8, 30));
  });

  test('scheduledStartOn returns null for a malformed time', () {
    const shift = StaffShift(
      staffId: 's1',
      scheduledStart: 'bad',
      scheduledEnd: '16:00',
      daysOfWeek: [1],
    );
    expect(shift.scheduledStartOn(DateTime(2026, 9, 14)), isNull);
  });

  group('StaffLeaveRequest', () {
    test('fromMap reads a full document', () {
      final now = DateTime(2026, 9, 1, 10);
      final l = StaffLeaveRequest.fromMap('leave-1', {
        'staffId': 'staff-1',
        'startDate': '2026-09-10',
        'endDate': '2026-09-12',
        'status': 'approved',
        'reason': 'Family event',
        'approvedBy': 'admin-1',
        'approvedAt': Timestamp.fromDate(now),
      });
      expect(l.id, 'leave-1');
      expect(l.isApproved, isTrue);
      expect(l.isPending, isFalse);
      expect(l.approvedAt, now);
    });

    test('coversDay is inclusive of both endpoints', () {
      const l = StaffLeaveRequest(
        id: 'leave-1',
        staffId: 's1',
        startDate: '2026-09-10',
        endDate: '2026-09-12',
        status: 'approved',
        reason: 'x',
      );
      expect(l.coversDay(DateTime(2026, 9, 10)), isTrue);
      expect(l.coversDay(DateTime(2026, 9, 11)), isTrue);
      expect(l.coversDay(DateTime(2026, 9, 12)), isTrue);
      expect(l.coversDay(DateTime(2026, 9, 9)), isFalse);
      expect(l.coversDay(DateTime(2026, 9, 13)), isFalse);
    });

    test('fromMap defaults status to pending', () {
      final l = StaffLeaveRequest.fromMap('leave-1', const {
        'staffId': 's1',
        'startDate': '2026-09-10',
        'endDate': '2026-09-12',
        'reason': 'x',
      });
      expect(l.isPending, isTrue);
    });
  });
}
