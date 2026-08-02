import '../entities/class_task.dart';

enum TaskRefusal {
  titleRequired,
  notOwner,
  unboundedRecurrence,
  recurrenceTooDense,
  reminderAfterDue,
  alreadyCompleted,
}

class TaskDecision {
  final bool isAllowed;
  final TaskRefusal? refusal;
  final String? message;

  const TaskDecision.allowed()
      : isAllowed = true,
        refusal = null,
        message = null;

  const TaskDecision.refused(this.refusal, this.message) : isAllowed = false;
}

/// The rules for the class teacher's own working list.
///
/// Lighter than the rest of the panel on purpose - a task is the teacher's
/// note to themselves, not a record about a child. The one thing worth
/// guarding hard is recurrence, because a rule with no end generates rows
/// forever and it is the teacher's own list that fills up.
class ClassTaskPolicy {
  const ClassTaskPolicy._();

  /// The most occurrences one recurrence rule may generate at a time. A
  /// daily task for a year is 365 rows; anything past this is a mistyped
  /// end date rather than an intention.
  static const int maxGeneratedOccurrences = 400;

  static TaskDecision canSave({
    required String title,
    required DateTime dueAt,
    required DateTime? remindAt,
    required TaskRecurrence recurrence,
  }) {
    if (title.trim().length < 3) {
      return const TaskDecision.refused(
        TaskRefusal.titleRequired,
        'Give the task a title.',
      );
    }

    if (remindAt != null && remindAt.isAfter(dueAt)) {
      return const TaskDecision.refused(
        TaskRefusal.reminderAfterDue,
        'The reminder would arrive after the task is due.',
      );
    }

    if (recurrence.repeats && !recurrence.isBounded) {
      return const TaskDecision.refused(
        TaskRefusal.unboundedRecurrence,
        'Set an end date or a number of repeats.',
      );
    }

    final occurrences = projectedOccurrences(recurrence, from: dueAt);
    if (occurrences > maxGeneratedOccurrences) {
      return TaskDecision.refused(
        TaskRefusal.recurrenceTooDense,
        'That repeats $occurrences times. Shorten the range or reduce how '
        'often it repeats.',
      );
    }

    return const TaskDecision.allowed();
  }

  /// Only the owner or an invited collaborator may touch a task. A class
  /// teacher's list is not open to every colleague who can see it.
  static TaskDecision canEdit({
    required ClassTask task,
    required String userId,
  }) {
    if (task.ownerUserId != userId &&
        !task.collaboratorUserIds.contains(userId)) {
      return const TaskDecision.refused(
        TaskRefusal.notOwner,
        'This task belongs to another staff member.',
      );
    }
    return const TaskDecision.allowed();
  }

  /// How many rows a recurrence would produce, so an unreasonable rule is
  /// refused at the form rather than discovered as a full task list.
  static int projectedOccurrences(
    TaskRecurrence recurrence, {
    required DateTime from,
  }) {
    if (!recurrence.repeats) return 1;
    if (recurrence.maxOccurrences != null) return recurrence.maxOccurrences!;

    // Never-ending rules generate on demand rather than up front, so they
    // cost one row now.
    final end = recurrence.endDate;
    if (end == null) return 1;

    final days = end.difference(from).inDays;
    if (days <= 0) return 1;

    return switch (recurrence.frequency) {
      'daily' => days,
      'weekly' => (days / 7).ceil() *
          (recurrence.weekdays.isEmpty ? 1 : recurrence.weekdays.length),
      'monthly' => (days / 30).ceil(),
      _ => 1,
    };
  }
}
