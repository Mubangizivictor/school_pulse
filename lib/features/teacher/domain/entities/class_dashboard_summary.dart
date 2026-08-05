import 'package:equatable/equatable.dart';

import 'lesson.dart';

/// What happened in the class recently, as the dashboard's activity feed
/// shows it. Built from the audit trail rather than a separate feed
/// collection, so the list can never claim something the audit log does not.
class ClassActivityEntry extends Equatable {
  final String id;
  final String action;
  final String title;
  final String description;
  final DateTime occurredAt;
  final String? studentId;
  final String? entityType;
  final String? entityId;

  const ClassActivityEntry({
    required this.id,
    required this.action,
    required this.title,
    this.description = '',
    required this.occurredAt,
    this.studentId,
    this.entityType,
    this.entityId,
  });

  @override
  List<Object?> get props => [
    id,
    action,
    title,
    description,
    occurredAt,
    studentId,
    entityType,
    entityId,
  ];
}

/// Today's attendance position for the class.
///
/// [isSubmitted] is what separates "nobody is absent" from "nobody has taken
/// the register yet" - two very different things for a dashboard to show, and
/// the reason the counts are not simply zero-defaulted.
class ClassAttendanceToday extends Equatable {
  final bool hasSession;
  final bool isSubmitted;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final DateTime? submittedAt;

  const ClassAttendanceToday({
    this.hasSession = false,
    this.isSubmitted = false,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
    this.submittedAt,
  });

  int get markedCount => presentCount + absentCount + lateCount + excusedCount;

  @override
  List<Object?> get props => [
    hasSession,
    isSubmitted,
    presentCount,
    absentCount,
    lateCount,
    excusedCount,
    submittedAt,
  ];
}

/// Everything the Class Teacher home tab renders, resolved in one pass.
///
/// Composed rather than fetched: the roster comes from the Student service,
/// attendance from the Attendance engine, the schedule from the timetable and
/// the activity feed from the audit trail. The dashboard does not recompute
/// any of it - it is the same data those modules already own, narrowed to the
/// one class this teacher was assigned.
class ClassDashboardSummary extends Equatable {
  final int totalStudents;
  final ClassAttendanceToday attendance;

  /// Homework and class assignments published to this class that are still
  /// open - the "Assignments / Pending" figure.
  final int pendingAssignments;

  /// Reports for this class still needing the teacher's sections.
  final int pendingReports;

  /// Behaviour records the teacher marked for follow-up and has not closed.
  final int pendingBehaviourFollowUps;

  final int unreadMessages;

  /// Every period on the class timetable today, across all subjects - not
  /// only the ones this teacher personally takes.
  final List<Lesson> todaysSchedule;

  final List<ClassActivityEntry> recentActivities;

  /// True when this came from the offline cache, so the UI can say so instead
  /// of presenting stale figures as live ones.
  final bool isFromCache;

  const ClassDashboardSummary({
    this.totalStudents = 0,
    this.attendance = const ClassAttendanceToday(),
    this.pendingAssignments = 0,
    this.pendingReports = 0,
    this.pendingBehaviourFollowUps = 0,
    this.unreadMessages = 0,
    this.todaysSchedule = const [],
    this.recentActivities = const [],
    this.isFromCache = false,
  });

  /// Students not accounted for present today. Only meaningful once the
  /// register exists, which is why callers check [ClassAttendanceToday
  /// .isSubmitted] before showing it as a figure.
  int get absentToday => attendance.absentCount;

  int get presentToday => attendance.presentCount;

  ClassDashboardSummary copyWith({
    int? totalStudents,
    ClassAttendanceToday? attendance,
    int? pendingAssignments,
    int? pendingReports,
    int? pendingBehaviourFollowUps,
    int? unreadMessages,
    List<Lesson>? todaysSchedule,
    List<ClassActivityEntry>? recentActivities,
    bool? isFromCache,
  }) {
    return ClassDashboardSummary(
      totalStudents: totalStudents ?? this.totalStudents,
      attendance: attendance ?? this.attendance,
      pendingAssignments: pendingAssignments ?? this.pendingAssignments,
      pendingReports: pendingReports ?? this.pendingReports,
      pendingBehaviourFollowUps:
          pendingBehaviourFollowUps ?? this.pendingBehaviourFollowUps,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      todaysSchedule: todaysSchedule ?? this.todaysSchedule,
      recentActivities: recentActivities ?? this.recentActivities,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    totalStudents,
    attendance,
    pendingAssignments,
    pendingReports,
    pendingBehaviourFollowUps,
    unreadMessages,
    todaysSchedule,
    recentActivities,
    isFromCache,
  ];
}
