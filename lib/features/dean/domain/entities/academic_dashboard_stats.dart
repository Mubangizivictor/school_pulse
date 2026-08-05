import 'package:equatable/equatable.dart';

class AcademicDashboardStats extends Equatable {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final int totalSubjects;
  final String currentAcademicYear;
  final String currentTerm;
  final int activeTimetables;
  final int lessonsConductedToday;
  final int lessonsMissedToday;
  final int assessmentsPending;
  final int marksPendingEntry;
  final int reportCardsPendingApproval;
  final int reportCardsPublished;
  final double overallSchoolAverage;
  final List<ClassPerformance> topPerformingClasses;
  final List<ClassPerformance> bottomPerformingClasses;
  final List<SubjectPerformance> subjectRankings;
  final double attendanceTrend;
  final double homeworkCompletionRate;
  final double teacherLessonCompletionRate;
  final List<AcademicAlert> activeAlerts;

  const AcademicDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.totalSubjects,
    required this.currentAcademicYear,
    required this.currentTerm,
    required this.activeTimetables,
    required this.lessonsConductedToday,
    required this.lessonsMissedToday,
    required this.assessmentsPending,
    required this.marksPendingEntry,
    required this.reportCardsPendingApproval,
    required this.reportCardsPublished,
    required this.overallSchoolAverage,
    required this.topPerformingClasses,
    required this.bottomPerformingClasses,
    required this.subjectRankings,
    required this.attendanceTrend,
    required this.homeworkCompletionRate,
    required this.teacherLessonCompletionRate,
    required this.activeAlerts,
  });

  @override
  List<Object?> get props => [
    totalStudents,
    totalTeachers,
    totalClasses,
    totalSubjects,
    currentAcademicYear,
    currentTerm,
    activeTimetables,
    lessonsConductedToday,
    lessonsMissedToday,
    assessmentsPending,
    marksPendingEntry,
    reportCardsPendingApproval,
    reportCardsPublished,
    overallSchoolAverage,
    topPerformingClasses,
    bottomPerformingClasses,
    subjectRankings,
    attendanceTrend,
    homeworkCompletionRate,
    teacherLessonCompletionRate,
    activeAlerts,
  ];
}

class ClassPerformance extends Equatable {
  final String classId;
  final String className;
  final double average;

  const ClassPerformance({
    required this.classId,
    required this.className,
    required this.average,
  });

  @override
  List<Object?> get props => [classId, className, average];
}

class SubjectPerformance extends Equatable {
  final String subjectId;
  final String subjectName;
  final double average;

  const SubjectPerformance({
    required this.subjectId,
    required this.subjectName,
    required this.average,
  });

  @override
  List<Object?> get props => [subjectId, subjectName, average];
}

enum AlertSeverity { low, medium, high, critical }

class AcademicAlert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const AcademicAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, title, message, severity, timestamp];
}
