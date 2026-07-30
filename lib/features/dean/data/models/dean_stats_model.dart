import '../../domain/entities/academic_dashboard_stats.dart';

class DeanStatsModel extends AcademicDashboardStats {
  const DeanStatsModel({
    required super.totalStudents,
    required super.totalTeachers,
    required super.totalClasses,
    required super.totalSubjects,
    required super.currentAcademicYear,
    required super.currentTerm,
    required super.activeTimetables,
    required super.lessonsConductedToday,
    required super.lessonsMissedToday,
    required super.assessmentsPending,
    required super.marksPendingEntry,
    required super.reportCardsPendingApproval,
    required super.reportCardsPublished,
    required super.overallSchoolAverage,
    required super.topPerformingClasses,
    required super.bottomPerformingClasses,
    required super.subjectRankings,
    required super.attendanceTrend,
    required super.homeworkCompletionRate,
    required super.teacherLessonCompletionRate,
    required super.activeAlerts,
  });

  factory DeanStatsModel.fromJson(Map<String, dynamic> json) {
    return DeanStatsModel(
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      currentAcademicYear: json['currentAcademicYear'] ?? '',
      currentTerm: json['currentTerm'] ?? '',
      activeTimetables: json['activeTimetables'] ?? 0,
      lessonsConductedToday: json['lessonsConductedToday'] ?? 0,
      lessonsMissedToday: json['lessonsMissedToday'] ?? 0,
      assessmentsPending: json['assessmentsPending'] ?? 0,
      marksPendingEntry: json['marksPendingEntry'] ?? 0,
      reportCardsPendingApproval: json['reportCardsPendingApproval'] ?? 0,
      reportCardsPublished: json['reportCardsPublished'] ?? 0,
      overallSchoolAverage: (json['overallSchoolAverage'] ?? 0).toDouble(),
      topPerformingClasses: (json['topPerformingClasses'] as List? ?? [])
          .map((e) => ClassPerformanceModel.fromJson(e))
          .toList(),
      bottomPerformingClasses: (json['bottomPerformingClasses'] as List? ?? [])
          .map((e) => ClassPerformanceModel.fromJson(e))
          .toList(),
      subjectRankings: (json['subjectRankings'] as List? ?? [])
          .map((e) => SubjectPerformanceModel.fromJson(e))
          .toList(),
      attendanceTrend: (json['attendanceTrend'] ?? 0).toDouble(),
      homeworkCompletionRate: (json['homeworkCompletionRate'] ?? 0).toDouble(),
      teacherLessonCompletionRate: (json['teacherLessonCompletionRate'] ?? 0).toDouble(),
      activeAlerts: (json['activeAlerts'] as List? ?? [])
          .map((e) => AcademicAlertModel.fromJson(e))
          .toList(),
    );
  }
}

class ClassPerformanceModel extends ClassPerformance {
  const ClassPerformanceModel({
    required super.classId,
    required super.className,
    required super.average,
  });

  factory ClassPerformanceModel.fromJson(Map<String, dynamic> json) {
    return ClassPerformanceModel(
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class SubjectPerformanceModel extends SubjectPerformance {
  const SubjectPerformanceModel({
    required super.subjectId,
    required super.subjectName,
    required super.average,
  });

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SubjectPerformanceModel(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class AcademicAlertModel extends AcademicAlert {
  const AcademicAlertModel({
    required super.id,
    required super.title,
    required super.message,
    required super.severity,
    required super.timestamp,
  });

  factory AcademicAlertModel.fromJson(Map<String, dynamic> json) {
    return AcademicAlertModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
        orElse: () => AlertSeverity.low,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
