import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_attendance.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_attendance_policy.dart';

final _now = DateTime(2026, 6, 15, 10, 0);

ClassAttendanceSession _session({
  ClassAttendanceSessionStatus status = ClassAttendanceSessionStatus.draft,
  List<ClassAttendanceEntry> entries = const [],
  DateTime? submittedAt,
}) {
  return ClassAttendanceSession(
    id: 'p7_all_daily_2026-06-15',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    date: DateTime(2026, 6, 15),
    status: status,
    entries: entries,
    submittedAt: submittedAt,
  );
}

ClassAttendanceEntry _entry(String studentId, String code) =>
    ClassAttendanceEntry(studentId: studentId, statusCode: code);

void main() {
  const roster = ['s1', 's2', 's3'];

  group('taking a register for a date', () {
    test('today is allowed', () {
      expect(
        ClassAttendancePolicy.canTakeFor(date: _now, now: _now).isAllowed,
        isTrue,
      );
    });

    test('tomorrow is refused - a register cannot predict attendance', () {
      final decision = ClassAttendancePolicy.canTakeFor(
        date: _now.add(const Duration(days: 1)),
        now: _now,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.futureDate);
    });

    test('yesterday is ordinary catch-up, not backdating', () {
      expect(
        ClassAttendancePolicy.canTakeFor(
          date: _now.subtract(const Duration(days: 1)),
          now: _now,
        ).isAllowed,
        isTrue,
      );
    });

    test('last month routes to a correction request rather than a refusal', () {
      final decision = ClassAttendancePolicy.canTakeFor(
        date: _now.subtract(const Duration(days: 30)),
        now: _now,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.tooFarBack);
      expect(decision.needsCorrectionRequest, isTrue);
    });
  });

  group('editing a register', () {
    test('a draft is freely editable with no reason', () {
      expect(
        ClassAttendancePolicy.canEdit(
          session: _session(),
          hasEditPermission: false,
          hasHistoricalPermission: false,
          reason: null,
          now: _now,
        ).isAllowed,
        isTrue,
      );
    });

    test('a submitted register is refused without the edit permission', () {
      final decision = ClassAttendancePolicy.canEdit(
        session: _session(
          status: ClassAttendanceSessionStatus.submitted,
          submittedAt: _now,
        ),
        hasEditPermission: false,
        hasHistoricalPermission: false,
        reason: 'Marked the wrong student',
        now: _now,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.alreadySubmitted);
      expect(decision.needsCorrectionRequest, isTrue);
    });

    test('a submitted register needs a substantive reason', () {
      final decision = ClassAttendancePolicy.canEdit(
        session: _session(
          status: ClassAttendanceSessionStatus.submitted,
          submittedAt: _now,
        ),
        hasEditPermission: true,
        hasHistoricalPermission: false,
        reason: 'oops',
        now: _now,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.reasonRequired);
    });

    test(
      'is allowed inside the correction window with permission and reason',
      () {
        expect(
          ClassAttendancePolicy.canEdit(
            session: _session(
              status: ClassAttendanceSessionStatus.submitted,
              submittedAt: _now.subtract(const Duration(hours: 2)),
            ),
            hasEditPermission: true,
            hasHistoricalPermission: false,
            reason: 'Marked the wrong student',
            now: _now,
          ).isAllowed,
          isTrue,
        );
      },
    );

    test('past the window it becomes the academic office\'s call', () {
      final decision = ClassAttendancePolicy.canEdit(
        session: _session(
          status: ClassAttendanceSessionStatus.submitted,
          submittedAt: _now.subtract(const Duration(days: 3)),
        ),
        hasEditPermission: true,
        hasHistoricalPermission: false,
        reason: 'Marked the wrong student',
        now: _now,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.outsideCorrectionWindow);
      expect(decision.needsCorrectionRequest, isTrue);
    });

    test('the historical permission reopens an expired window', () {
      expect(
        ClassAttendancePolicy.canEdit(
          session: _session(
            status: ClassAttendanceSessionStatus.submitted,
            submittedAt: _now.subtract(const Duration(days: 3)),
          ),
          hasEditPermission: true,
          hasHistoricalPermission: true,
          reason: 'Marked the wrong student',
          now: _now,
        ).isAllowed,
        isTrue,
      );
    });

    test('a locked register has no teacher path at all', () {
      final decision = ClassAttendancePolicy.canEdit(
        session: _session(status: ClassAttendanceSessionStatus.locked),
        hasEditPermission: true,
        hasHistoricalPermission: true,
        reason: 'Marked the wrong student',
        now: _now,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.locked);
    });
  });

  group('submitting a register', () {
    test('is refused while any student is unmarked', () {
      final decision = ClassAttendancePolicy.canSubmit(
        session: _session(entries: [_entry('s1', 'present')]),
        rosterStudentIds: roster,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, AttendanceRefusal.notMarkedYet);
      expect(decision.message, contains('2 students'));
    });

    test('names a single unmarked student in the singular', () {
      final decision = ClassAttendancePolicy.canSubmit(
        session: _session(
          entries: [_entry('s1', 'present'), _entry('s2', 'absent')],
        ),
        rosterStudentIds: roster,
      );

      expect(decision.message, contains('1 student has'));
    });

    test('is allowed once every student carries a mark', () {
      expect(
        ClassAttendancePolicy.canSubmit(
          session: _session(
            entries: [
              _entry('s1', 'present'),
              _entry('s2', 'absent'),
              _entry('s3', 'late'),
            ],
          ),
          rosterStudentIds: roster,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('marking one student', () {
    final options = AttendanceStatusResolver.defaults;

    test('refuses a student who is not on this register', () {
      final decision = ClassAttendancePolicy.canMark(
        statusCode: 'present',
        options: options,
        studentId: 'intruder',
        rosterStudentIds: roster,
      );

      expect(decision.refusal, AttendanceRefusal.studentNotInClass);
    });

    test('refuses a status the school does not offer', () {
      final decision = ClassAttendancePolicy.canMark(
        statusCode: 'teleported',
        options: options,
        studentId: 's1',
        rosterStudentIds: roster,
      );

      expect(decision.refusal, AttendanceRefusal.unknownStatus);
    });

    test('allows a configured status for a student on the roster', () {
      expect(
        ClassAttendancePolicy.canMark(
          statusCode: 'late',
          options: options,
          studentId: 's1',
          rosterStudentIds: roster,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('status classification', () {
    test('lateness counts as attendance', () {
      expect(
        AttendanceStatusResolver.classify('late', 'Late'),
        AttendanceClassification.present,
      );
    });

    test('medical and leave are authorised absence', () {
      expect(
        AttendanceStatusResolver.classify('medical', 'Medical'),
        AttendanceClassification.authorisedAbsence,
      );
      expect(
        AttendanceStatusResolver.classify('approvedLeave', 'Approved leave'),
        AttendanceClassification.authorisedAbsence,
      );
    });

    test('a custom status is classified from its name', () {
      expect(
        AttendanceStatusResolver.classify('sb', 'Sick Bay'),
        AttendanceClassification.authorisedAbsence,
      );
    });

    test('an unrecognisable status is treated as unauthorised absence', () {
      // The strict reading is deliberate: guessing "present" would quietly
      // inflate every attendance rate in the school.
      expect(
        AttendanceStatusResolver.classify('xy', 'Zephyr'),
        AttendanceClassification.unauthorisedAbsence,
      );
    });

    test('falls back to the shared defaults when a school configures none', () {
      expect(AttendanceStatusResolver.optionsFrom(const []), hasLength(6));
    });

    test('ignores deactivated statuses', () {
      final options = AttendanceStatusResolver.optionsFrom([
        (id: 'present', name: 'Present', colorHex: '', isActive: true),
        (id: 'absent', name: 'Absent', colorHex: '', isActive: true),
        (id: 'retired', name: 'Old status', colorHex: '', isActive: false),
      ]);

      expect(options.map((o) => o.code), ['present', 'absent']);
    });
  });

  group('session totals', () {
    test('count by classification, ignoring unmarked students', () {
      final session = _session(
        entries: [
          _entry('s1', 'present'),
          _entry('s2', 'late'),
          _entry('s3', 'medical'),
        ],
      );

      final counts = session.countsBy(AttendanceStatusResolver.defaults);

      expect(counts[AttendanceClassification.present], 2);
      expect(counts[AttendanceClassification.authorisedAbsence], 1);
      expect(counts[AttendanceClassification.unauthorisedAbsence], 0);
    });
  });
}
