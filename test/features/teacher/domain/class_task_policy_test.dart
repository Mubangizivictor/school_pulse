import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_task.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_task_policy.dart';

final _due = DateTime(2026, 6, 15, 9, 0);

ClassTask _task({
  String owner = 'teacher1',
  List<String> collaborators = const [],
  ClassTaskStatus status = ClassTaskStatus.pending,
  DateTime? dueAt,
  List<ClassTaskChecklistItem> checklist = const [],
}) {
  return ClassTask(
    id: 't1',
    schoolId: 'school1',
    academicYearId: '2026',
    title: 'Mark P7 fractions worksheets',
    dueAt: dueAt ?? _due,
    status: status,
    checklist: checklist,
    ownerUserId: owner,
    collaboratorUserIds: collaborators,
    createdAt: _due,
  );
}

void main() {
  group('saving a task', () {
    test('needs a title', () {
      expect(
        ClassTaskPolicy.canSave(
          title: 'x',
          dueAt: _due,
          remindAt: null,
          recurrence: TaskRecurrence.none,
        ).refusal,
        TaskRefusal.titleRequired,
      );
    });

    test('refuses a reminder that would arrive after the deadline', () {
      expect(
        ClassTaskPolicy.canSave(
          title: 'Mark worksheets',
          dueAt: _due,
          remindAt: _due.add(const Duration(hours: 2)),
          recurrence: TaskRecurrence.none,
        ).refusal,
        TaskRefusal.reminderAfterDue,
      );
    });

    test('allows a one-off task', () {
      expect(
        ClassTaskPolicy.canSave(
          title: 'Mark worksheets',
          dueAt: _due,
          remindAt: _due.subtract(const Duration(hours: 1)),
          recurrence: TaskRecurrence.none,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('recurrence', () {
    test('a repeating rule with no end is refused', () {
      // The runaway case: nothing would ever stop it generating.
      expect(
        ClassTaskPolicy.canSave(
          title: 'Daily roll call follow-up',
          dueAt: _due,
          remindAt: null,
          recurrence: const TaskRecurrence(frequency: 'daily'),
        ).refusal,
        TaskRefusal.unboundedRecurrence,
      );
    });

    test('an explicitly never-ending rule is allowed', () {
      // A school that genuinely wants one says so, rather than by omission.
      expect(
        ClassTaskPolicy.canSave(
          title: 'Daily roll call follow-up',
          dueAt: _due,
          remindAt: null,
          recurrence: const TaskRecurrence(frequency: 'daily', neverEnds: true),
        ).isAllowed,
        isTrue,
      );
    });

    test('an end date bounds it', () {
      expect(
        ClassTaskPolicy.canSave(
          title: 'Weekly marking',
          dueAt: _due,
          remindAt: null,
          recurrence: TaskRecurrence(
            frequency: 'weekly',
            endDate: _due.add(const Duration(days: 60)),
          ),
        ).isAllowed,
        isTrue,
      );
    });

    test('an absurd range is caught at the form, not in the task list', () {
      final decision = ClassTaskPolicy.canSave(
        title: 'Daily standup',
        dueAt: _due,
        // A mistyped year rather than an intention.
        recurrence: TaskRecurrence(
          frequency: 'daily',
          endDate: _due.add(const Duration(days: 3650)),
        ),
        remindAt: null,
      );

      expect(decision.refusal, TaskRefusal.recurrenceTooDense);
    });

    test('a capped occurrence count is respected', () {
      expect(
        ClassTaskPolicy.projectedOccurrences(
          const TaskRecurrence(frequency: 'daily', maxOccurrences: 10),
          from: _due,
        ),
        10,
      );
    });

    test('a non-repeating rule is one occurrence', () {
      expect(
        ClassTaskPolicy.projectedOccurrences(TaskRecurrence.none, from: _due),
        1,
      );
    });
  });

  group('ownership', () {
    test('the owner may edit', () {
      expect(
        ClassTaskPolicy.canEdit(task: _task(), userId: 'teacher1').isAllowed,
        isTrue,
      );
    });

    test('an invited collaborator may edit', () {
      expect(
        ClassTaskPolicy.canEdit(
          task: _task(collaborators: const ['hod1']),
          userId: 'hod1',
        ).isAllowed,
        isTrue,
      );
    });

    test('a colleague who was not invited may not', () {
      // A class teacher's list is not open to everyone who can see it.
      expect(
        ClassTaskPolicy.canEdit(task: _task(), userId: 'someoneElse').refusal,
        TaskRefusal.notOwner,
      );
    });
  });

  group('derived state', () {
    test('overdue follows the clock rather than a stored flag', () {
      final task = _task(dueAt: _due);

      expect(task.isOverdue(asOf: _due.add(const Duration(hours: 1))), isTrue);
      expect(task.isOverdue(asOf: _due.subtract(const Duration(hours: 1))), isFalse);
    });

    test('a completed task is never overdue', () {
      expect(
        _task(status: ClassTaskStatus.completed)
            .isOverdue(asOf: _due.add(const Duration(days: 5))),
        isFalse,
      );
    });

    test('checklist progress is null when there is no checklist', () {
      expect(_task().checklistProgress, isNull);
    });

    test('checklist progress counts completed items', () {
      final task = _task(checklist: const [
        ClassTaskChecklistItem(id: 'c1', title: 'Mark', isCompleted: true),
        ClassTaskChecklistItem(id: 'c2', title: 'Record'),
      ]);

      expect(task.checklistProgress, 0.5);
    });
  });

  group('categories', () {
    test('fall back to a working default set', () {
      expect(TaskCategories.from(const []), TaskCategories.defaults);
    });

    test('honour the school\'s own list', () {
      expect(TaskCategories.from(const ['Marking']), ['Marking']);
    });
  });
}
