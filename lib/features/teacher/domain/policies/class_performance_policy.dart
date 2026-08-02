import '../entities/class_performance.dart';

/// The thresholds that decide whether a student is surfaced for attention.
///
/// Held as data with school-configurable values rather than as constants in
/// the comparison, because what counts as a low average differs between a
/// primary school and an A-level stream, and neither should have to accept
/// the other's numbers.
class AttentionThresholds {
  /// Average at or below which a student is surfaced.
  final double lowAverage;

  /// Drop against the previous term, in percentage points, that counts as a
  /// slip worth noticing.
  final double declineBy;

  /// Attendance rate at or below which attendance is flagged.
  final double lowAttendanceRate;

  /// How many subjects may be missing approved marks before it is worth
  /// saying so.
  final int missingSubjectsAllowed;

  const AttentionThresholds({
    this.lowAverage = 40,
    this.declineBy = 10,
    this.lowAttendanceRate = 80,
    this.missingSubjectsAllowed = 1,
  });

  /// Sensible starting values for a school that has configured none.
  static const AttentionThresholds defaults = AttentionThresholds();

  static AttentionThresholds from(Map<String, dynamic>? config) {
    if (config == null) return defaults;
    return AttentionThresholds(
      lowAverage: (config['lowAverage'] as num?)?.toDouble() ?? 40,
      declineBy: (config['declineBy'] as num?)?.toDouble() ?? 10,
      lowAttendanceRate:
          (config['lowAttendanceRate'] as num?)?.toDouble() ?? 80,
      missingSubjectsAllowed:
          (config['missingSubjectsAllowed'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Decides which students the Class Performance screen surfaces, and why.
///
/// Deliberately not a score or a ranking of "risk": the output is a list of
/// situations a teacher can act on, each of which can be resolved. A student
/// whose marks arrive, or whose attendance recovers, drops off the list on
/// the next load - nothing here writes a flag onto the child's record.
class ClassPerformancePolicy {
  const ClassPerformancePolicy._();

  static List<AttentionReason> reasonsFor(
    StudentPerformanceSummary student,
    AttentionThresholds thresholds,
  ) {
    final reasons = <AttentionReason>[];

    final average = student.average;
    if (average != null && average <= thresholds.lowAverage) {
      reasons.add(AttentionReason.lowAverage);
    }

    final trend = student.trend;
    if (trend != null && trend <= -thresholds.declineBy) {
      reasons.add(AttentionReason.decliningTrend);
    }

    final attendance = student.attendanceRate;
    if (attendance != null && attendance <= thresholds.lowAttendanceRate) {
      reasons.add(AttentionReason.lowAttendance);
    }

    if (student.missingSubjects > thresholds.missingSubjectsAllowed) {
      reasons.add(AttentionReason.missingMarks);
    }

    if (student.openBehaviourFollowUps > 0) {
      reasons.add(AttentionReason.behaviourFollowUp);
    }

    return reasons;
  }

  /// The students to surface, most reasons first so the teacher sees the
  /// clearest cases at the top.
  static List<StudentNeedingAttention> needingAttention(
    List<StudentPerformanceSummary> students,
    AttentionThresholds thresholds,
  ) {
    final flagged = <StudentNeedingAttention>[];

    for (final student in students) {
      final reasons = reasonsFor(student, thresholds);
      if (reasons.isEmpty) continue;
      flagged.add(StudentNeedingAttention(student: student, reasons: reasons));
    }

    flagged.sort((a, b) {
      // Anything about the child outranks a gap in the paperwork.
      if (a.isDataOnly != b.isDataOnly) return a.isDataOnly ? 1 : -1;
      return b.reasons.length.compareTo(a.reasons.length);
    });

    return flagged;
  }
}
