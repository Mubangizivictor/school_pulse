import 'package:equatable/equatable.dart';

/// The result of reducing a window of attendance marks into one rate.
///
/// [ratePercent] is null rather than 0 when [totalMarked] is zero - "no
/// data yet" and "0% attendance" are different facts, and collapsing them
/// silently would make an empty register look like a perfect absence
/// record on a dashboard.
class AttendanceSummary extends Equatable {
  final int present;
  final int authorisedAbsent;
  final int unauthorisedAbsent;
  final int totalMarked;
  final double? ratePercent;

  const AttendanceSummary({
    required this.present,
    required this.authorisedAbsent,
    required this.unauthorisedAbsent,
    required this.totalMarked,
    required this.ratePercent,
  });

  @override
  List<Object?> get props => [present, authorisedAbsent, unauthorisedAbsent, totalMarked, ratePercent];
}

/// What one mark counts as when reducing a window into an [AttendanceSummary].
///
/// This is deliberately the same 3-bucket shape as the Class/Subject Teacher
/// panels' AttendanceClassification/LessonAttendanceStatus, but defined here
/// rather than imported from lib/features/teacher/ - this feature is read by
/// parent/student/admin dashboards that have no reason to depend on the
/// teacher panel's domain layer, and boarding's raw-string statuses have no
/// natural home in either of those enums anyway.
enum MarkClassification { present, authorisedAbsent, unauthorisedAbsent }

/// Pure reduction of a window's marks into a rate. No I/O, no repository
/// dependency - callers already hold the raw records (an AcademicBloc state,
/// a ClassAttendanceSession's entries, a boarding roll-call stream) and only
/// need a consistent, tested formula instead of another inline
/// `present / total * 100`.
class AttendanceRateCalculator {
  const AttendanceRateCalculator._();

  static AttendanceSummary summarize(Iterable<MarkClassification> marks) {
    var present = 0;
    var authorisedAbsent = 0;
    var unauthorisedAbsent = 0;

    for (final mark in marks) {
      switch (mark) {
        case MarkClassification.present:
          present++;
        case MarkClassification.authorisedAbsent:
          authorisedAbsent++;
        case MarkClassification.unauthorisedAbsent:
          unauthorisedAbsent++;
      }
    }

    final total = present + authorisedAbsent + unauthorisedAbsent;
    return AttendanceSummary(
      present: present,
      authorisedAbsent: authorisedAbsent,
      unauthorisedAbsent: unauthorisedAbsent,
      totalMarked: total,
      ratePercent: total == 0 ? null : (present / total) * 100,
    );
  }

  /// The days-open-normalized variant used by the term/session report
  /// (attendance_summary_screen.dart) - a legitimately different formula
  /// (present-days / total-possible-days rather than present / marked),
  /// exposed as its own named method rather than silently changing what
  /// the simple-ratio callers above get.
  static AttendanceSummary summarizeAgainstDaysOpen({
    required int presentDays,
    required int daysOpen,
  }) {
    return AttendanceSummary(
      present: presentDays,
      authorisedAbsent: 0,
      unauthorisedAbsent: daysOpen - presentDays,
      totalMarked: daysOpen,
      ratePercent: daysOpen == 0 ? null : (presentDays / daysOpen) * 100,
    );
  }
}

/// Maps this app's StudentStatus enum (present/absent/late) - used by
/// AttendanceRecord, the flat model attendance_records/AcademicBloc still
/// serve to parent/student dashboards - onto the shared classification.
MarkClassification classifyStudentStatus(String statusName) {
  switch (statusName) {
    case 'present':
    case 'late':
      return MarkClassification.present;
    default:
      return MarkClassification.unauthorisedAbsent;
  }
}

/// Maps boarding's raw-string status ('Present'/'Absent'/'Late'/'Leave'/
/// 'Sick') onto the shared classification. Kept separate from
/// classifyStudentStatus because boarding's vocabulary already
/// distinguishes an authorised absence (Leave/Sick) from an unauthorised
/// one (Absent) - collapsing that distinction would lose real information
/// the class/subject engine's AttendanceClassification already preserves
/// for its own statuses.
MarkClassification classifyBoardingStatus(String status) {
  switch (status) {
    case 'Present':
    case 'Late':
      return MarkClassification.present;
    case 'Leave':
    case 'Sick':
      return MarkClassification.authorisedAbsent;
    default:
      return MarkClassification.unauthorisedAbsent;
  }
}
