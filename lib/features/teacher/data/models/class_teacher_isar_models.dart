import 'package:isar/isar.dart';

import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/class_student_summary.dart';

part 'class_teacher_isar_models.g.dart';

/// The cached class register.
///
/// Kept so a teacher can open the roster and mark attendance in a classroom
/// with no signal - the single most common offline moment in the panel. Every
/// row carries [schoolId] because the cache is wiped per-tenant on school
/// switch, and a roster surviving into another school would be a tenancy leak
/// rather than a stale read.
@collection
class ClassStudentIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String studentId;

  @Index()
  late String schoolId;

  @Index()
  late String classId;

  String? streamId;

  @Index()
  late String academicYearId;

  late String name;
  late String admissionNumber;
  String? photoUrl;
  late String className;
  String? streamName;
  late String status;
  String? gender;
  late String residency;
  String? houseId;
  String? houseName;
  late bool hasHealthAlert;

  /// When this row was last read from the server, so the UI can say how old
  /// the offline roster is instead of implying it is live.
  late DateTime cachedAt;

  ClassStudentSummary toEntity() => ClassStudentSummary(
        studentId: studentId,
        schoolId: schoolId,
        name: name,
        admissionNumber: admissionNumber,
        photoUrl: photoUrl,
        classId: classId,
        className: className,
        streamId: streamId,
        streamName: streamName,
        academicYearId: academicYearId,
        status: ClassStudentStatus.fromId(status),
        gender: gender,
        residency: ResidencyType.fromId(residency),
        houseId: houseId,
        houseName: houseName,
        hasHealthAlert: hasHealthAlert,
      );

  static ClassStudentIsar fromEntity(ClassStudentSummary student) {
    return ClassStudentIsar()
      ..studentId = student.studentId
      ..schoolId = student.schoolId
      ..classId = student.classId
      ..streamId = student.streamId
      ..academicYearId = student.academicYearId
      ..name = student.name
      ..admissionNumber = student.admissionNumber
      ..photoUrl = student.photoUrl
      ..className = student.className
      ..streamName = student.streamName
      ..status = student.status.name
      ..gender = student.gender
      ..residency = student.residency.name
      ..houseId = student.houseId
      ..houseName = student.houseName
      ..hasHealthAlert = student.hasHealthAlert
      ..cachedAt = DateTime.now();
  }
}

/// The last dashboard figures seen for one class.
///
/// Only the counts are cached, never the schedule or the activity feed: those
/// are read-only context a teacher can do without offline, whereas opening the
/// panel to a blank set of figures makes it look broken.
@collection
class ClassDashboardCacheIsar {
  Id get isarId => Isar.autoIncrement;

  /// class + stream + year, so two classes under a school's multi-class
  /// override do not overwrite each other's figures.
  @Index(unique: true, replace: true)
  late String cacheKey;

  @Index()
  late String schoolId;

  late String classId;
  String? streamId;
  late String academicYearId;

  late int totalStudents;
  late bool hasSession;
  late bool isSubmitted;
  late int presentCount;
  late int absentCount;
  late int lateCount;
  late int excusedCount;
  DateTime? submittedAt;
  late int pendingAssignments;
  late int pendingReports;
  late int pendingBehaviourFollowUps;
  late int unreadMessages;
  late DateTime cachedAt;

  ClassDashboardSummary toEntity() => ClassDashboardSummary(
        totalStudents: totalStudents,
        attendance: ClassAttendanceToday(
          hasSession: hasSession,
          isSubmitted: isSubmitted,
          presentCount: presentCount,
          absentCount: absentCount,
          lateCount: lateCount,
          excusedCount: excusedCount,
          submittedAt: submittedAt,
        ),
        pendingAssignments: pendingAssignments,
        pendingReports: pendingReports,
        pendingBehaviourFollowUps: pendingBehaviourFollowUps,
        unreadMessages: unreadMessages,
        // Never presented as live - the dashboard says where this came from.
        isFromCache: true,
      );

  static ClassDashboardCacheIsar fromEntity(
    ClassDashboardSummary summary, {
    required String schoolId,
    required String classId,
    String? streamId,
    required String academicYearId,
  }) {
    return ClassDashboardCacheIsar()
      ..cacheKey = dashboardCacheKey(
        classId: classId,
        streamId: streamId,
        academicYearId: academicYearId,
      )
      ..schoolId = schoolId
      ..classId = classId
      ..streamId = streamId
      ..academicYearId = academicYearId
      ..totalStudents = summary.totalStudents
      ..hasSession = summary.attendance.hasSession
      ..isSubmitted = summary.attendance.isSubmitted
      ..presentCount = summary.attendance.presentCount
      ..absentCount = summary.attendance.absentCount
      ..lateCount = summary.attendance.lateCount
      ..excusedCount = summary.attendance.excusedCount
      ..submittedAt = summary.attendance.submittedAt
      ..pendingAssignments = summary.pendingAssignments
      ..pendingReports = summary.pendingReports
      ..pendingBehaviourFollowUps = summary.pendingBehaviourFollowUps
      ..unreadMessages = summary.unreadMessages
      ..cachedAt = DateTime.now();
  }
}

String dashboardCacheKey({
  required String classId,
  String? streamId,
  required String academicYearId,
}) {
  final stream = (streamId == null || streamId.isEmpty) ? 'all' : streamId;
  return '${classId}_${stream}_$academicYearId';
}
