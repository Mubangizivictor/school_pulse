import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_behaviour.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_homework.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_work_policy.dart';

final _now = DateTime(2026, 6, 15, 10, 0);

ClassHomework _homework({
  ClassHomeworkStatus status = ClassHomeworkStatus.draft,
  DateTime? dueDate,
}) {
  return ClassHomework(
    id: 'hw1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    title: 'Fractions revision',
    dueDate: dueDate ?? _now.add(const Duration(days: 3)),
    status: status,
    createdAt: _now,
  );
}

ClassBehaviourRecord _record({
  String? disciplineCaseId,
  bool followUpRequired = false,
  bool followUpClosed = false,
}) {
  return ClassBehaviourRecord(
    id: 'b1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    studentId: 's1',
    categoryCode: 'merit',
    note: 'Helped a classmate with revision',
    followUpRequired: followUpRequired,
    followUpClosed: followUpClosed,
    disciplineCaseId: disciplineCaseId,
    recordedAt: _now,
  );
}

void main() {
  const roster = ['s1', 's2', 's3'];
  final categories = BehaviourCategoryResolver.defaults;

  group('saving homework', () {
    test('needs a title', () {
      final decision = ClassWorkPolicy.canSaveHomework(
        title: '  ',
        dueDate: _now.add(const Duration(days: 1)),
        existing: null,
        now: _now,
      );

      expect(decision.refusal, ClassWorkRefusal.titleRequired);
    });

    test('refuses a due date already in the past for new work', () {
      final decision = ClassWorkPolicy.canSaveHomework(
        title: 'Fractions revision',
        dueDate: _now.subtract(const Duration(days: 2)),
        existing: null,
        now: _now,
      );

      expect(decision.refusal, ClassWorkRefusal.dueDateInPast);
    });

    test('catches a mistyped year', () {
      final decision = ClassWorkPolicy.canSaveHomework(
        title: 'Fractions revision',
        dueDate: DateTime(2027, 6, 15),
        existing: null,
        now: _now,
      );

      expect(decision.refusal, ClassWorkRefusal.dueDateTooFar);
    });

    test('allows moving the due date of published work', () {
      // Extending an overdue assignment is legitimate; refusing it would
      // leave the teacher unable to fix it.
      final decision = ClassWorkPolicy.canSaveHomework(
        title: 'Fractions revision',
        dueDate: _now.subtract(const Duration(days: 1)),
        existing: _homework(status: ClassHomeworkStatus.published),
        now: _now,
      );

      expect(decision.isAllowed, isTrue);
    });

    test('refuses editing cancelled work', () {
      final decision = ClassWorkPolicy.canSaveHomework(
        title: 'Fractions revision',
        dueDate: _now.add(const Duration(days: 1)),
        existing: _homework(status: ClassHomeworkStatus.cancelled),
        now: _now,
      );

      expect(decision.refusal, ClassWorkRefusal.cancelled);
    });
  });

  group('publishing', () {
    test('is refused without the publish permission', () {
      // Drafting and reaching every parent in the class are different rights.
      final decision = ClassWorkPolicy.canPublish(
        homework: _homework(),
        hasPublishPermission: false,
      );

      expect(decision.refusal, ClassWorkRefusal.publishNotPermitted);
    });

    test('is refused for work already published', () {
      final decision = ClassWorkPolicy.canPublish(
        homework: _homework(status: ClassHomeworkStatus.published),
        hasPublishPermission: true,
      );

      expect(decision.refusal, ClassWorkRefusal.alreadyPublished);
    });

    test('is allowed for a draft with the permission', () {
      expect(
        ClassWorkPolicy.canPublish(
          homework: _homework(),
          hasPublishPermission: true,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('effective status', () {
    test('a published item past its due date reads as overdue', () {
      expect(
        _homework(
          status: ClassHomeworkStatus.published,
          dueDate: _now.subtract(const Duration(days: 1)),
        ).effectiveStatus(asOf: _now),
        ClassHomeworkStatus.overdue,
      );
    });

    test('within two days it reads as due soon', () {
      expect(
        _homework(
          status: ClassHomeworkStatus.published,
          dueDate: _now.add(const Duration(hours: 20)),
        ).effectiveStatus(asOf: _now),
        ClassHomeworkStatus.dueSoon,
      );
    });

    test('a draft is never re-derived from the clock', () {
      expect(
        _homework(
          dueDate: _now.subtract(const Duration(days: 5)),
        ).effectiveStatus(asOf: _now),
        ClassHomeworkStatus.draft,
      );
    });
  });

  group('recording behaviour', () {
    test('refuses a student outside the class', () {
      final decision = ClassWorkPolicy.canRecordBehaviour(
        studentId: 'intruder',
        rosterStudentIds: roster,
        categoryCode: 'merit',
        categories: categories,
        note: 'Helped a classmate',
      );

      expect(decision.refusal, ClassWorkRefusal.studentNotInClass);
    });

    test('refuses a category the school does not use', () {
      final decision = ClassWorkPolicy.canRecordBehaviour(
        studentId: 's1',
        rosterStudentIds: roster,
        categoryCode: 'invented',
        categories: categories,
        note: 'Helped a classmate',
      );

      expect(decision.refusal, ClassWorkRefusal.unknownCategory);
    });

    test('refuses an entry with no description', () {
      // Someone reads this years later; "ok" tells them nothing.
      final decision = ClassWorkPolicy.canRecordBehaviour(
        studentId: 's1',
        rosterStudentIds: roster,
        categoryCode: 'merit',
        categories: categories,
        note: 'ok',
      );

      expect(decision.refusal, ClassWorkRefusal.noteRequired);
    });

    test('allows a described entry for a student in the class', () {
      expect(
        ClassWorkPolicy.canRecordBehaviour(
          studentId: 's1',
          rosterStudentIds: roster,
          categoryCode: 'merit',
          categories: categories,
          note: 'Helped a classmate with revision',
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('amending a record', () {
    test('is allowed while it is still the class teacher\'s', () {
      expect(
        ClassWorkPolicy.canUpdateBehaviour(record: _record()).isAllowed,
        isTrue,
      );
    });

    test('is refused once escalated to a formal case', () {
      // Evidence must not move after the discipline office has acted on it.
      final decision = ClassWorkPolicy.canUpdateBehaviour(
        record: _record(disciplineCaseId: 'case1'),
      );

      expect(decision.refusal, ClassWorkRefusal.escalated);
    });
  });

  group('behaviour categories', () {
    test('fall back to defaults when a school configures none', () {
      expect(BehaviourCategoryResolver.from(const []), hasLength(8));
    });

    test('honour the school\'s own labels', () {
      final resolved = BehaviourCategoryResolver.from([
        (id: 'ubuntu', name: 'Ubuntu award', colorHex: '', isActive: true),
      ]);

      expect(resolved.single.label, 'Ubuntu award');
      expect(resolved.single.valence, BehaviourValence.achievement);
    });

    test('classify an unrecognisable category as a concern, not a merit', () {
      // Guessing positive would let an unknown code quietly improve a
      // student's conduct record.
      expect(
        BehaviourCategoryResolver.classify('zz', 'Zephyr'),
        BehaviourValence.concern,
      );
    });

    test('ignore deactivated categories', () {
      final resolved = BehaviourCategoryResolver.from([
        (id: 'merit', name: 'Merit', colorHex: '', isActive: true),
        (id: 'old', name: 'Retired', colorHex: '', isActive: false),
      ]);

      expect(resolved.map((c) => c.code), ['merit']);
    });

    test('serious concerns default to raising a follow-up', () {
      expect(
        ClassWorkPolicy.defaultFollowUpFor('disruption', categories),
        isTrue,
      );
      expect(ClassWorkPolicy.defaultFollowUpFor('merit', categories), isFalse);
    });
  });
}
