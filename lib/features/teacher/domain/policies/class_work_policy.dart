import '../entities/class_behaviour.dart';
import '../entities/class_homework.dart';

/// Why a homework or behaviour action was refused.
enum ClassWorkRefusal {
  titleRequired,
  dueDateInPast,
  dueDateTooFar,
  publishNotPermitted,
  alreadyPublished,
  cancelled,
  noteRequired,
  unknownCategory,
  studentNotInClass,
  escalated,
}

class ClassWorkDecision {
  final bool isAllowed;
  final ClassWorkRefusal? refusal;
  final String? message;

  const ClassWorkDecision.allowed()
    : isAllowed = true,
      refusal = null,
      message = null;

  const ClassWorkDecision.refused(this.refusal, this.message)
    : isAllowed = false;
}

/// The rules governing class work a teacher sets and the conduct they record.
///
/// Pure functions, like [ClassAttendancePolicy]: a behaviour note follows a
/// child for years, so the rules deciding whether one may be written should be
/// readable and testable without a network behind them.
class ClassWorkPolicy {
  const ClassWorkPolicy._();

  /// How far ahead work may be set. Beyond a term's length it is almost
  /// certainly a mistyped year.
  static const Duration maxLeadTime = Duration(days: 180);

  static ClassWorkDecision canSaveHomework({
    required String title,
    required DateTime dueDate,
    required ClassHomework? existing,
    required DateTime now,
  }) {
    if (title.trim().length < 3) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.titleRequired,
        'Give the assignment a title.',
      );
    }

    if (existing?.status == ClassHomeworkStatus.cancelled) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.cancelled,
        'This assignment was cancelled and cannot be edited.',
      );
    }

    // Only checked for new or still-draft work: moving the due date of
    // something already published is a legitimate extension, and refusing it
    // would leave a teacher unable to fix an overdue item.
    if (existing == null || existing.isDraft) {
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
      if (due.isBefore(today)) {
        return const ClassWorkDecision.refused(
          ClassWorkRefusal.dueDateInPast,
          'The due date has already passed.',
        );
      }
      if (due.difference(today) > maxLeadTime) {
        return const ClassWorkDecision.refused(
          ClassWorkRefusal.dueDateTooFar,
          'That due date is more than six months away. Check the year.',
        );
      }
    }

    return const ClassWorkDecision.allowed();
  }

  /// Publishing is what reaches students and parents, so it is gated
  /// separately from being able to draft.
  static ClassWorkDecision canPublish({
    required ClassHomework homework,
    required bool hasPublishPermission,
  }) {
    if (!hasPublishPermission) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.publishNotPermitted,
        'You do not have permission to publish work to your class.',
      );
    }
    if (homework.status == ClassHomeworkStatus.cancelled) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.cancelled,
        'This assignment was cancelled.',
      );
    }
    if (homework.status.isPublished) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.alreadyPublished,
        'This assignment has already been published.',
      );
    }
    return const ClassWorkDecision.allowed();
  }

  static ClassWorkDecision canRecordBehaviour({
    required String studentId,
    required List<String> rosterStudentIds,
    required String categoryCode,
    required List<BehaviourCategory> categories,
    required String note,
  }) {
    if (!rosterStudentIds.contains(studentId)) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.studentNotInClass,
        'That student is not in your class.',
      );
    }

    if (!categories.any((c) => c.code == categoryCode)) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.unknownCategory,
        'That category is not one your school uses.',
      );
    }

    // A conduct entry with no description is unusable to whoever reads it
    // later - and someone will, possibly years later.
    if (note.trim().length < 5) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.noteRequired,
        'Describe what happened.',
      );
    }

    return const ClassWorkDecision.allowed();
  }

  /// Whether the class teacher may still amend a record they wrote.
  ///
  /// Once escalated into a formal case, the record belongs to the Discipline
  /// Office and the teacher's copy becomes read-only - otherwise the evidence
  /// could move after the office had acted on it.
  static ClassWorkDecision canUpdateBehaviour({
    required ClassBehaviourRecord record,
  }) {
    if (record.isEscalated) {
      return const ClassWorkDecision.refused(
        ClassWorkRefusal.escalated,
        'This is now a formal discipline case and is handled by the '
        'discipline office.',
      );
    }
    return const ClassWorkDecision.allowed();
  }

  /// The follow-up default for a category, used when the teacher has not
  /// chosen one explicitly.
  static bool defaultFollowUpFor(
    String categoryCode,
    List<BehaviourCategory> categories,
  ) {
    return categories
            .where((c) => c.code == categoryCode)
            .firstOrNull
            ?.defaultsToFollowUp ??
        false;
  }
}
