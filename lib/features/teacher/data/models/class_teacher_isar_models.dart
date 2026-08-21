import 'dart:convert';

import 'package:isar/isar.dart';

import '../../domain/entities/class_announcement.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_behaviour.dart';
import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/class_homework.dart';
import '../../domain/entities/class_performance.dart';
import '../../domain/entities/class_resource.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/class_task.dart';

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

/// A class register held on the device.
///
/// This is the offline case the whole panel is built around: a teacher marks
/// the roll in a classroom with no signal, and the register has to survive
/// until the phone reaches the staffroom. Entries are stored as JSON rather
/// than a linked collection because a register is read and written whole -
/// there is no query that wants one student's mark across every day.
@collection
class ClassAttendanceDraftIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  @Index()
  late String schoolId;

  late String campusId;
  late String classId;
  late String className;
  String? streamId;
  late String academicYearId;
  late String termId;
  late String sessionType;
  late DateTime date;
  late String status;
  late String entriesJson;
  DateTime? submittedAt;
  String? submittedBy;
  late String roleAssignmentId;
  late String deviceId;
  DateTime? lastCorrectedAt;
  late DateTime cachedAt;

  ClassAttendanceSession toEntity() {
    final raw = jsonDecode(entriesJson);
    final entries = (raw is List ? raw : const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => ClassAttendanceEntry(
            studentId: e['studentId'] as String? ?? '',
            statusCode: e['status'] as String? ?? '',
            note: e['note'] as String?,
            markedAt: DateTime.tryParse(e['markedAt'] as String? ?? ''),
          ),
        )
        .toList();

    return ClassAttendanceSession(
      id: sessionId,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      className: className,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      sessionType: sessionType,
      date: date,
      status: ClassAttendanceSessionStatus.fromId(status),
      entries: entries,
      submittedAt: submittedAt,
      submittedBy: submittedBy,
      roleAssignmentId: roleAssignmentId,
      deviceId: deviceId,
      lastCorrectedAt: lastCorrectedAt,
    );
  }

  static ClassAttendanceDraftIsar fromEntity(ClassAttendanceSession session) {
    return ClassAttendanceDraftIsar()
      ..sessionId = session.id
      ..schoolId = session.schoolId
      ..campusId = session.campusId
      ..classId = session.classId
      ..className = session.className
      ..streamId = session.streamId
      ..academicYearId = session.academicYearId
      ..termId = session.termId
      ..sessionType = session.sessionType
      ..date = session.date
      ..status = session.status.name
      ..entriesJson = jsonEncode(
        session.entries
            .map(
              (e) => {
                'studentId': e.studentId,
                'status': e.statusCode,
                'note': e.note,
                'markedAt': e.markedAt?.toIso8601String(),
              },
            )
            .toList(),
      )
      ..submittedAt = session.submittedAt
      ..submittedBy = session.submittedBy
      ..roleAssignmentId = session.roleAssignmentId
      ..deviceId = session.deviceId
      ..lastCorrectedAt = session.lastCorrectedAt
      ..cachedAt = DateTime.now();
  }
}

/// A teacher's own task list, held on the device.
///
/// Entries are stored as JSON (checklist/attachments/recurrence) for the
/// same reason [ClassAttendanceDraftIsar] does it: these are read and
/// written whole with the task, never queried by their internal fields.
@collection
class ClassTaskIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String taskId;

  @Index()
  late String schoolId;

  @Index()
  late String ownerUserId;

  late String campusId;
  String? classId;
  late String academicYearId;
  String? termId;

  late String title;
  late String description;
  late String category;
  late String priority;
  late String status;
  late DateTime dueAt;
  String? studentId;
  String? subjectName;
  late String checklistJson;
  late String attachmentsJson;
  late String recurrenceJson;
  DateTime? remindAt;
  late String collaboratorUserIdsJson;
  late DateTime createdAt;
  DateTime? completedAt;
  String? completedBy;
  late String roleAssignmentId;
  late DateTime cachedAt;

  ClassTask toEntity() {
    final checklistRaw = jsonDecode(checklistJson);
    final checklist = (checklistRaw is List ? checklistRaw : const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (c) => ClassTaskChecklistItem(
            id: c['id'] as String? ?? '',
            title: c['title'] as String? ?? '',
            isCompleted: c['isCompleted'] as bool? ?? false,
          ),
        )
        .toList();

    final recurrenceRaw = jsonDecode(recurrenceJson);
    final recurrence = TaskRecurrence.fromMap(
      recurrenceRaw is Map<String, dynamic>
          ? {
              ...recurrenceRaw,
              'endDate': recurrenceRaw['endDate'] == null
                  ? null
                  : DateTime.tryParse(recurrenceRaw['endDate'] as String),
            }
          : null,
    );

    return ClassTask(
      id: taskId,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      academicYearId: academicYearId,
      termId: termId,
      title: title,
      description: description,
      category: category,
      priority: ClassTaskPriority.fromId(priority),
      status: ClassTaskStatus.fromId(status),
      dueAt: dueAt,
      studentId: studentId,
      subjectName: subjectName,
      checklist: checklist,
      attachments: (jsonDecode(attachmentsJson) as List)
          .whereType<String>()
          .toList(),
      recurrence: recurrence,
      remindAt: remindAt,
      ownerUserId: ownerUserId,
      collaboratorUserIds: (jsonDecode(collaboratorUserIdsJson) as List)
          .whereType<String>()
          .toList(),
      createdAt: createdAt,
      completedAt: completedAt,
      completedBy: completedBy,
      roleAssignmentId: roleAssignmentId,
    );
  }

  static ClassTaskIsar fromEntity(ClassTask task) {
    return ClassTaskIsar()
      ..taskId = task.id
      ..schoolId = task.schoolId
      ..ownerUserId = task.ownerUserId
      ..campusId = task.campusId
      ..classId = task.classId
      ..academicYearId = task.academicYearId
      ..termId = task.termId
      ..title = task.title
      ..description = task.description
      ..category = task.category
      ..priority = task.priority.name
      ..status = task.status.name
      ..dueAt = task.dueAt
      ..studentId = task.studentId
      ..subjectName = task.subjectName
      ..checklistJson = jsonEncode(
        task.checklist
            .map(
              (c) => {
                'id': c.id,
                'title': c.title,
                'isCompleted': c.isCompleted,
              },
            )
            .toList(),
      )
      ..attachmentsJson = jsonEncode(task.attachments)
      ..recurrenceJson = jsonEncode({
        ...task.recurrence.toMap(),
        'endDate': task.recurrence.endDate?.toIso8601String(),
      })
      ..remindAt = task.remindAt
      ..collaboratorUserIdsJson = jsonEncode(task.collaboratorUserIds)
      ..createdAt = task.createdAt
      ..completedAt = task.completedAt
      ..completedBy = task.completedBy
      ..roleAssignmentId = task.roleAssignmentId
      ..cachedAt = DateTime.now();
  }
}

/// Class-level homework set by the class teacher, held on the device.
///
/// Attachments are JSON for the same reason [ClassTaskIsar] stores its lists
/// that way: read and written whole with the assignment, never queried by
/// their own fields.
@collection
class ClassHomeworkIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String homeworkId;

  @Index()
  late String schoolId;

  @Index()
  late String classId;

  late String className;
  String? streamId;
  late String academicYearId;
  late String termId;

  late String title;
  late String description;
  String? instructions;
  String? subjectName;
  late DateTime dueDate;
  late String status;
  late String priority;
  late String attachmentsJson;

  late String createdBy;
  late DateTime createdAt;
  String? updatedBy;
  DateTime? updatedAt;
  DateTime? publishedAt;
  late String roleAssignmentId;
  late DateTime cachedAt;

  ClassHomework toEntity() => ClassHomework(
    id: homeworkId,
    schoolId: schoolId,
    classId: classId,
    className: className,
    streamId: streamId,
    academicYearId: academicYearId,
    termId: termId,
    title: title,
    description: description,
    instructions: instructions,
    subjectName: subjectName,
    dueDate: dueDate,
    status: ClassHomeworkStatus.fromId(status),
    priority: ClassHomeworkPriority.fromId(priority),
    attachments: (jsonDecode(attachmentsJson) as List)
        .whereType<String>()
        .toList(),
    createdBy: createdBy,
    createdAt: createdAt,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
    publishedAt: publishedAt,
    roleAssignmentId: roleAssignmentId,
  );

  static ClassHomeworkIsar fromEntity(ClassHomework homework) {
    return ClassHomeworkIsar()
      ..homeworkId = homework.id
      ..schoolId = homework.schoolId
      ..classId = homework.classId
      ..className = homework.className
      ..streamId = homework.streamId
      ..academicYearId = homework.academicYearId
      ..termId = homework.termId
      ..title = homework.title
      ..description = homework.description
      ..instructions = homework.instructions
      ..subjectName = homework.subjectName
      ..dueDate = homework.dueDate
      ..status = homework.status.name
      ..priority = homework.priority.name
      ..attachmentsJson = jsonEncode(homework.attachments)
      ..createdBy = homework.createdBy
      ..createdAt = homework.createdAt
      ..updatedBy = homework.updatedBy
      ..updatedAt = homework.updatedAt
      ..publishedAt = homework.publishedAt
      ..roleAssignmentId = homework.roleAssignmentId
      ..cachedAt = DateTime.now();
  }
}

/// A behaviour or achievement record against a student, held on the device.
@collection
class ClassBehaviourRecordIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String recordId;

  @Index()
  late String schoolId;

  @Index()
  late String classId;

  String? streamId;
  late String academicYearId;
  late String termId;

  late String studentId;
  late String studentName;
  late String categoryCode;
  late String note;
  String? recommendation;
  late bool followUpRequired;
  late bool followUpClosed;
  String? followUpNote;
  String? disciplineCaseId;
  String? disciplineStatus;

  late String recordedBy;
  late DateTime recordedAt;
  String? updatedBy;
  DateTime? updatedAt;
  late String roleAssignmentId;
  late DateTime cachedAt;

  ClassBehaviourRecord toEntity() => ClassBehaviourRecord(
    id: recordId,
    schoolId: schoolId,
    classId: classId,
    streamId: streamId,
    academicYearId: academicYearId,
    termId: termId,
    studentId: studentId,
    studentName: studentName,
    categoryCode: categoryCode,
    note: note,
    recommendation: recommendation,
    followUpRequired: followUpRequired,
    followUpClosed: followUpClosed,
    followUpNote: followUpNote,
    disciplineCaseId: disciplineCaseId,
    disciplineStatus: disciplineStatus,
    recordedBy: recordedBy,
    recordedAt: recordedAt,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
    roleAssignmentId: roleAssignmentId,
  );

  static ClassBehaviourRecordIsar fromEntity(ClassBehaviourRecord record) {
    return ClassBehaviourRecordIsar()
      ..recordId = record.id
      ..schoolId = record.schoolId
      ..classId = record.classId
      ..streamId = record.streamId
      ..academicYearId = record.academicYearId
      ..termId = record.termId
      ..studentId = record.studentId
      ..studentName = record.studentName
      ..categoryCode = record.categoryCode
      ..note = record.note
      ..recommendation = record.recommendation
      ..followUpRequired = record.followUpRequired
      ..followUpClosed = record.followUpClosed
      ..followUpNote = record.followUpNote
      ..disciplineCaseId = record.disciplineCaseId
      ..disciplineStatus = record.disciplineStatus
      ..recordedBy = record.recordedBy
      ..recordedAt = record.recordedAt
      ..updatedBy = record.updatedBy
      ..updatedAt = record.updatedAt
      ..roleAssignmentId = record.roleAssignmentId
      ..cachedAt = DateTime.now();
  }
}

/// An announcement posted to the class, held on the device.
@collection
class ClassAnnouncementIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String announcementId;

  @Index()
  late String schoolId;

  @Index()
  late String classId;

  late String className;
  String? streamId;
  late String academicYearId;
  late String termId;

  late String title;
  late String body;
  late String status;
  late String audience;
  late String attachmentsJson;
  DateTime? scheduledFor;
  DateTime? expiresAt;

  DateTime? publishedAt;
  late String createdBy;
  late DateTime createdAt;
  String? updatedBy;
  DateTime? updatedAt;
  late String roleAssignmentId;
  late int recipientCount;
  late DateTime cachedAt;

  ClassAnnouncement toEntity() => ClassAnnouncement(
    id: announcementId,
    schoolId: schoolId,
    classId: classId,
    className: className,
    streamId: streamId,
    academicYearId: academicYearId,
    termId: termId,
    title: title,
    body: body,
    status: ClassAnnouncementStatus.fromId(status),
    audience: ClassAnnouncementAudience.fromId(audience),
    attachments: (jsonDecode(attachmentsJson) as List)
        .whereType<String>()
        .toList(),
    scheduledFor: scheduledFor,
    expiresAt: expiresAt,
    publishedAt: publishedAt,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
    roleAssignmentId: roleAssignmentId,
    recipientCount: recipientCount,
  );

  static ClassAnnouncementIsar fromEntity(ClassAnnouncement announcement) {
    return ClassAnnouncementIsar()
      ..announcementId = announcement.id
      ..schoolId = announcement.schoolId
      ..classId = announcement.classId
      ..className = announcement.className
      ..streamId = announcement.streamId
      ..academicYearId = announcement.academicYearId
      ..termId = announcement.termId
      ..title = announcement.title
      ..body = announcement.body
      ..status = announcement.status.name
      ..audience = announcement.audience.name
      ..attachmentsJson = jsonEncode(announcement.attachments)
      ..scheduledFor = announcement.scheduledFor
      ..expiresAt = announcement.expiresAt
      ..publishedAt = announcement.publishedAt
      ..createdBy = announcement.createdBy
      ..createdAt = announcement.createdAt
      ..updatedBy = announcement.updatedBy
      ..updatedAt = announcement.updatedAt
      ..roleAssignmentId = announcement.roleAssignmentId
      ..recipientCount = announcement.recipientCount
      ..cachedAt = DateTime.now();
  }
}

/// The last computed class-performance summary, cached whole.
///
/// Mirrors [ClassDashboardCacheIsar]'s reasoning: performance is derived
/// from marks/attendance/behaviour the repository composes at read time, not
/// something a teacher edits, so there is no write queue - just the last
/// good computed result to show while offline. Stored as one JSON blob
/// because the summary is a nested tree (students, subjects, attention
/// reasons) with no query that wants to reach into it.
@collection
class ClassPerformanceCacheIsar {
  Id get isarId => Isar.autoIncrement;

  /// class + stream + year + term, so distinct classes/terms don't clobber
  /// each other's cached figures.
  @Index(unique: true, replace: true)
  late String cacheKey;

  @Index()
  late String schoolId;

  late String summaryJson;
  late DateTime cachedAt;

  ClassPerformanceSummary toEntity() {
    final raw = jsonDecode(summaryJson) as Map<String, dynamic>;

    final students = (raw['students'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (s) => StudentPerformanceSummary(
            studentId: s['studentId'] as String? ?? '',
            studentName: s['studentName'] as String? ?? '',
            subjectPercentages: (s['subjectPercentages'] as Map).map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ),
            missingSubjects: s['missingSubjects'] as int? ?? 0,
            attendanceRate: (s['attendanceRate'] as num?)?.toDouble(),
            openBehaviourFollowUps: s['openBehaviourFollowUps'] as int? ?? 0,
            previousAverage: (s['previousAverage'] as num?)?.toDouble(),
          ),
        )
        .toList();

    final subjects = (raw['subjects'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (s) => SubjectPerformanceSummary(
            subjectId: s['subjectId'] as String? ?? '',
            subjectName: s['subjectName'] as String? ?? '',
            average: (s['average'] as num?)?.toDouble(),
            studentsWithMarks: s['studentsWithMarks'] as int? ?? 0,
            studentsExpected: s['studentsExpected'] as int? ?? 0,
            highest: (s['highest'] as num?)?.toDouble(),
            lowest: (s['lowest'] as num?)?.toDouble(),
          ),
        )
        .toList();

    final studentsById = {for (final s in students) s.studentId: s};
    final needingAttention = (raw['needingAttention'] as List)
        .cast<Map<String, dynamic>>()
        .map((n) {
          final studentId = n['studentId'] as String? ?? '';
          final student = studentsById[studentId];
          if (student == null) return null;
          return StudentNeedingAttention(
            student: student,
            reasons: (n['reasons'] as List)
                .whereType<String>()
                .map(
                  (r) => AttentionReason.values.firstWhere(
                    (v) => v.name == r,
                    orElse: () => AttentionReason.missingMarks,
                  ),
                )
                .toList(),
          );
        })
        .whereType<StudentNeedingAttention>()
        .toList();

    return ClassPerformanceSummary(
      students: students,
      subjects: subjects,
      needingAttention: needingAttention,
      passMark: (raw['passMark'] as num?)?.toDouble() ?? 50,
    );
  }

  static ClassPerformanceCacheIsar fromEntity(
    ClassPerformanceSummary summary, {
    required String schoolId,
    required String cacheKey,
  }) {
    return ClassPerformanceCacheIsar()
      ..cacheKey = cacheKey
      ..schoolId = schoolId
      ..summaryJson = jsonEncode({
        'students': summary.students
            .map(
              (s) => {
                'studentId': s.studentId,
                'studentName': s.studentName,
                'subjectPercentages': s.subjectPercentages,
                'missingSubjects': s.missingSubjects,
                'attendanceRate': s.attendanceRate,
                'openBehaviourFollowUps': s.openBehaviourFollowUps,
                'previousAverage': s.previousAverage,
              },
            )
            .toList(),
        'subjects': summary.subjects
            .map(
              (s) => {
                'subjectId': s.subjectId,
                'subjectName': s.subjectName,
                'average': s.average,
                'studentsWithMarks': s.studentsWithMarks,
                'studentsExpected': s.studentsExpected,
                'highest': s.highest,
                'lowest': s.lowest,
              },
            )
            .toList(),
        'needingAttention': summary.needingAttention
            .map(
              (n) => {
                'studentId': n.student.studentId,
                'reasons': n.reasons.map((r) => r.name).toList(),
              },
            )
            .toList(),
        'passMark': summary.passMark,
      })
      ..cachedAt = DateTime.now();
  }
}

String performanceCacheKey({
  required String classId,
  String? streamId,
  required String academicYearId,
  required String termId,
}) {
  final stream = (streamId == null || streamId.isEmpty) ? 'all' : streamId;
  return '${classId}_${stream}_${academicYearId}_$termId';
}

/// The class's resource area, mirrored for offline browsing.
///
/// [localFilePath] is set only once a file has actually been downloaded for
/// offline use - the metadata row exists as soon as the class area is read
/// online, well before that. Bytes live on disk rather than in Isar because
/// a resource can be tens of megabytes; only the path is stored here.
@collection
class ClassResourceIsar {
  Id get isarId => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String resourceId;

  @Index()
  late String schoolId;

  @Index()
  late String classId;

  late String academicYearId;
  String? termId;
  late String campusId;

  late String name;
  String? description;
  late String kind;
  late String origin;
  late String audience;
  String? storagePath;
  String? downloadUrl;
  String? externalUrl;
  int? sizeBytes;
  String? mimeType;
  String? folderId;
  String? sourceResourceId;
  late bool availableOffline;
  late String uploadedByUserId;
  late DateTime uploadedAt;
  late String roleAssignmentId;
  late int downloadCount;

  /// Where the downloaded bytes live on this device, or null if this row is
  /// metadata only.
  String? localFilePath;

  late DateTime cachedAt;

  ClassResource toEntity() => ClassResource(
    id: resourceId,
    schoolId: schoolId,
    campusId: campusId,
    classId: classId,
    academicYearId: academicYearId,
    termId: termId,
    name: name,
    description: description,
    kind: ClassResourceKind.fromId(kind),
    origin: ClassResourceOrigin.fromId(origin),
    audience: ClassResourceAudience.fromId(audience),
    storagePath: storagePath,
    downloadUrl: downloadUrl,
    externalUrl: externalUrl,
    sizeBytes: sizeBytes,
    mimeType: mimeType,
    folderId: folderId,
    sourceResourceId: sourceResourceId,
    availableOffline: availableOffline,
    uploadedByUserId: uploadedByUserId,
    uploadedAt: uploadedAt,
    roleAssignmentId: roleAssignmentId,
    downloadCount: downloadCount,
  );

  static ClassResourceIsar fromEntity(
    ClassResource resource, {
    String? localFilePath,
  }) {
    return ClassResourceIsar()
      ..resourceId = resource.id
      ..schoolId = resource.schoolId
      ..classId = resource.classId
      ..academicYearId = resource.academicYearId
      ..termId = resource.termId
      ..campusId = resource.campusId
      ..name = resource.name
      ..description = resource.description
      ..kind = resource.kind.name
      ..origin = resource.origin.name
      ..audience = resource.audience.name
      ..storagePath = resource.storagePath
      ..downloadUrl = resource.downloadUrl
      ..externalUrl = resource.externalUrl
      ..sizeBytes = resource.sizeBytes
      ..mimeType = resource.mimeType
      ..folderId = resource.folderId
      ..sourceResourceId = resource.sourceResourceId
      ..availableOffline = resource.availableOffline
      ..uploadedByUserId = resource.uploadedByUserId
      ..uploadedAt = resource.uploadedAt
      ..roleAssignmentId = resource.roleAssignmentId
      ..downloadCount = resource.downloadCount
      ..localFilePath = localFilePath
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
