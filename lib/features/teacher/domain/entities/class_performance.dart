import 'package:equatable/equatable.dart';

/// One approved mark a student earned on one assessment component, for the
/// per-subject drill-down. Distinct from [StudentPerformanceSummary], which
/// only carries the subject-level average.
class StudentAssessmentResult extends Equatable {
  final String assessmentId;
  final String componentId;
  final String assessmentTitle;
  final String componentName;
  final double score;
  final double maximumMark;
  final DateTime? assessmentDate;

  const StudentAssessmentResult({
    required this.assessmentId,
    required this.componentId,
    this.assessmentTitle = '',
    this.componentName = '',
    required this.score,
    required this.maximumMark,
    this.assessmentDate,
  });

  double get percentage => maximumMark > 0 ? (score / maximumMark) * 100 : 0;

  /// What the tile shows as its title - the assessment name, or the
  /// component name when the assessment carries no title of its own.
  String get displayName =>
      assessmentTitle.isNotEmpty ? assessmentTitle : componentName;

  @override
  List<Object?> get props => [
    assessmentId,
    componentId,
    assessmentTitle,
    componentName,
    score,
    maximumMark,
    assessmentDate,
  ];
}

/// One student's standing across every subject, as the Class Teacher sees it.
///
/// Built only from marks the Assessment engine has already approved. Marks
/// still in draft are counted as missing rather than folded into an average,
/// because a mean over half-entered papers is a number nobody should act on.
class StudentPerformanceSummary extends Equatable {
  final String studentId;
  final String studentName;

  /// Subject id to the student's percentage in it, approved marks only.
  final Map<String, double> subjectPercentages;

  /// Subjects with an assessment this term whose marks are not yet approved.
  final int missingSubjects;

  /// Attendance rate over the term, from the Attendance engine. Null when no
  /// register has been taken yet.
  final double? attendanceRate;

  /// Open behaviour follow-ups, from the class behaviour records.
  final int openBehaviourFollowUps;

  /// The previous term's average, where one exists, so a trend can be shown
  /// without this panel storing its own history.
  final double? previousAverage;

  const StudentPerformanceSummary({
    required this.studentId,
    this.studentName = '',
    this.subjectPercentages = const {},
    this.missingSubjects = 0,
    this.attendanceRate,
    this.openBehaviourFollowUps = 0,
    this.previousAverage,
  });

  /// Mean across subjects with approved marks. Null when none are approved -
  /// deliberately not zero, which would read as total failure.
  double? get average {
    if (subjectPercentages.isEmpty) return null;
    final total = subjectPercentages.values.reduce((a, b) => a + b);
    return total / subjectPercentages.length;
  }

  double? get trend {
    final current = average;
    final previous = previousAverage;
    if (current == null || previous == null) return null;
    return current - previous;
  }

  bool get hasApprovedMarks => subjectPercentages.isNotEmpty;

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    subjectPercentages,
    missingSubjects,
    attendanceRate,
    openBehaviourFollowUps,
    previousAverage,
  ];
}

/// How one subject is going across the whole class.
class SubjectPerformanceSummary extends Equatable {
  final String subjectId;
  final String subjectName;
  final double? average;
  final int studentsWithMarks;
  final int studentsExpected;
  final double? highest;
  final double? lowest;

  const SubjectPerformanceSummary({
    required this.subjectId,
    this.subjectName = '',
    this.average,
    this.studentsWithMarks = 0,
    this.studentsExpected = 0,
    this.highest,
    this.lowest,
  });

  /// How much of the class has approved marks in this subject. Surfaced
  /// because an average over four students out of thirty is not a class
  /// average, and the screen should not present it as one.
  double? get coverage {
    if (studentsExpected == 0) return null;
    return studentsWithMarks / studentsExpected;
  }

  bool get isComplete => studentsWithMarks >= studentsExpected;

  @override
  List<Object?> get props => [
    subjectId,
    subjectName,
    average,
    studentsWithMarks,
    studentsExpected,
    highest,
    lowest,
  ];
}

/// Why a student was surfaced for the teacher's attention.
///
/// Phrased as a situation, never as a label on the child: these strings reach
/// the screen, and "needs academic support" is a thing a teacher can act on
/// where "weak student" is a thing a child carries.
enum AttentionReason {
  lowAverage,
  decliningTrend,
  lowAttendance,
  missingMarks,
  behaviourFollowUp;

  String get label => switch (this) {
    AttentionReason.lowAverage => 'Needs academic support',
    AttentionReason.decliningTrend => 'Marks have slipped',
    AttentionReason.lowAttendance => 'Attendance concern',
    AttentionReason.missingMarks => 'Incomplete data',
    AttentionReason.behaviourFollowUp => 'Behaviour follow-up open',
  };
}

/// A student the panel is surfacing, and why.
class StudentNeedingAttention extends Equatable {
  final StudentPerformanceSummary student;
  final List<AttentionReason> reasons;

  const StudentNeedingAttention({required this.student, required this.reasons});

  /// True when the only thing flagged is absent data. Worth separating,
  /// because chasing a colleague for marks is a different action from
  /// supporting a struggling child.
  bool get isDataOnly =>
      reasons.length == 1 && reasons.first == AttentionReason.missingMarks;

  @override
  List<Object?> get props => [student, reasons];
}

/// Everything the Class Performance screen renders.
class ClassPerformanceSummary extends Equatable {
  final List<StudentPerformanceSummary> students;
  final List<SubjectPerformanceSummary> subjects;
  final List<StudentNeedingAttention> needingAttention;

  /// The pass mark the school configured, carried so the screen can say what
  /// the pass rate is measured against rather than implying a universal 50.
  final double passMark;

  const ClassPerformanceSummary({
    this.students = const [],
    this.subjects = const [],
    this.needingAttention = const [],
    this.passMark = 50,
  });

  /// Class mean across students who have any approved marks. Null when none
  /// do - the screen shows a dash rather than a zero.
  double? get classAverage {
    final averages = students
        .map((s) => s.average)
        .whereType<double>()
        .toList();
    if (averages.isEmpty) return null;
    return averages.reduce((a, b) => a + b) / averages.length;
  }

  /// Share of students at or above the school's pass mark, among those with
  /// approved marks. Null when nothing is approved yet.
  double? get passRate {
    final averages = students
        .map((s) => s.average)
        .whereType<double>()
        .toList();
    if (averages.isEmpty) return null;
    final passing = averages.where((a) => a >= passMark).length;
    return (passing / averages.length) * 100;
  }

  int get studentsWithMarks => students.where((s) => s.hasApprovedMarks).length;

  int get studentsAwaitingMarks =>
      students.where((s) => !s.hasApprovedMarks).length;

  StudentPerformanceSummary? get topPerformer {
    final ranked = students.where((s) => s.average != null).toList()
      ..sort((a, b) => b.average!.compareTo(a.average!));
    return ranked.firstOrNull;
  }

  @override
  List<Object?> get props => [students, subjects, needingAttention, passMark];
}
