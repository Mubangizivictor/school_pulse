import '../entities/class_attendance.dart';

/// Why a register action was refused.
enum AttendanceRefusal {
  notMarkedYet,
  alreadySubmitted,
  locked,
  outsideCorrectionWindow,
  reasonRequired,
  futureDate,
  tooFarBack,
  unknownStatus,
  studentNotInClass,
}

/// The outcome of asking whether a register action is allowed.
class AttendanceDecision {
  final bool isAllowed;
  final AttendanceRefusal? refusal;
  final String? message;

  /// True when the action is refused *now* but would be allowed as a
  /// correction request routed to the academic office.
  final bool needsCorrectionRequest;

  const AttendanceDecision.allowed()
    : isAllowed = true,
      refusal = null,
      message = null,
      needsCorrectionRequest = false;

  const AttendanceDecision.refused(
    this.refusal,
    this.message, {
    this.needsCorrectionRequest = false,
  }) : isAllowed = false;
}

/// The rules governing when a class register may be taken, changed and
/// corrected.
///
/// Kept as pure functions with no repository or Firestore behind them: these
/// are the decisions that put an absence on a child's permanent record, and
/// they should be readable and testable without a network. The repository
/// enforces them, the security rules enforce them again server-side.
class ClassAttendancePolicy {
  const ClassAttendancePolicy._();

  /// How long after submission a teacher holding the edit permission may
  /// still correct their own register without the academic office. Beyond
  /// this, the correction is a request, not a write.
  static const Duration correctionWindow = Duration(hours: 24);

  /// How far back a register may be taken at all. A teacher catching up on
  /// yesterday is ordinary; one filling in last month is backdating and goes
  /// through the correction workflow.
  static const Duration backdateLimit = Duration(days: 7);

  /// Whether a register may be created or drafted for [date].
  static AttendanceDecision canTakeFor({
    required DateTime date,
    required DateTime now,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (day.isAfter(today)) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.futureDate,
        'Attendance cannot be taken for a date in the future.',
      );
    }

    if (today.difference(day) > backdateLimit) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.tooFarBack,
        'This date is outside the period a register can still be taken for. '
        'Ask the academic office to open it.',
        needsCorrectionRequest: true,
      );
    }

    return const AttendanceDecision.allowed();
  }

  /// Whether an existing register may be saved over.
  ///
  /// A draft is freely editable. A submitted one needs the edit permission
  /// and a reason, and only inside [correctionWindow] - after that it is the
  /// academic office's. A locked one has no teacher path at all.
  static AttendanceDecision canEdit({
    required ClassAttendanceSession session,
    required bool hasEditPermission,
    required bool hasHistoricalPermission,
    required String? reason,
    required DateTime now,
  }) {
    if (session.isLocked) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.locked,
        'This register has been closed by the academic office.',
        needsCorrectionRequest: true,
      );
    }

    if (!session.isSubmitted) return const AttendanceDecision.allowed();

    if (!hasEditPermission) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.alreadySubmitted,
        'This register has been submitted. You do not have permission to '
        'change it.',
        needsCorrectionRequest: true,
      );
    }

    if (reason == null || reason.trim().length < 5) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.reasonRequired,
        'Give a reason for changing a submitted register.',
      );
    }

    final submittedAt = session.submittedAt;
    final expired =
        submittedAt != null && now.difference(submittedAt) > correctionWindow;

    // Holding the historical permission is what turns an expired window from
    // a refusal into an ordinary edit - that is the whole distinction between
    // a class teacher and the academic office here.
    if (expired && !hasHistoricalPermission) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.outsideCorrectionWindow,
        'The correction period for this register has passed. Request a '
        'correction from the academic office.',
        needsCorrectionRequest: true,
      );
    }

    return const AttendanceDecision.allowed();
  }

  /// Whether a register is complete enough to submit.
  ///
  /// Every student on the roster must carry a mark. Submitting with gaps
  /// would silently record the unmarked as whatever the reader assumes, and
  /// the assumption is always absence.
  static AttendanceDecision canSubmit({
    required ClassAttendanceSession session,
    required List<String> rosterStudentIds,
  }) {
    if (session.isLocked) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.locked,
        'This register has been closed by the academic office.',
      );
    }

    final unmarked = session.unmarkedFrom(rosterStudentIds);
    if (unmarked.isNotEmpty) {
      return AttendanceDecision.refused(
        AttendanceRefusal.notMarkedYet,
        unmarked.length == 1
            ? '1 student has not been marked yet.'
            : '${unmarked.length} students have not been marked yet.',
      );
    }

    return const AttendanceDecision.allowed();
  }

  /// Whether [statusCode] is one the school actually offers. A code that is
  /// not in the configured list cannot be classified, so it must not reach
  /// the register at all.
  static AttendanceDecision canMark({
    required String statusCode,
    required List<ClassAttendanceOption> options,
    required String studentId,
    required List<String> rosterStudentIds,
  }) {
    if (!rosterStudentIds.contains(studentId)) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.studentNotInClass,
        'That student is not on this class register.',
      );
    }

    if (!options.any((o) => o.code == statusCode)) {
      return const AttendanceDecision.refused(
        AttendanceRefusal.unknownStatus,
        'That attendance status is not one your school uses.',
      );
    }

    return const AttendanceDecision.allowed();
  }
}
