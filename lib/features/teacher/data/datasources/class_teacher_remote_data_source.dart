import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/entities/lesson.dart';

/// The Class Teacher panel's reads and writes against Firestore.
///
/// Everything the panel owns lives under `schools/{schoolId}/...`, so tenant
/// isolation is structural: a query rooted at one school cannot return another
/// school's rows however the arguments are tampered with. The one exception is
/// `students`, a top-level collection the Student Information System owns and
/// which every module filters by `schoolId` - matching what the Subject
/// Teacher panel already does rather than inventing a second convention.
abstract class ClassTeacherRemoteDataSource {
  /// The active roster of one class and stream. Narrow by design - see
  /// [ClassStudentSummary] for why fees, clinical notes and admission
  /// paperwork are absent.
  Future<List<ClassStudentSummary>> getClassRoster({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Stream<List<ClassStudentSummary>> watchClassRoster({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  /// One student's roster row, or null when they are not on this class's
  /// register for this year.
  Future<ClassStudentSummary?> getClassStudent({
    required String schoolId,
    required String studentId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  /// Today's class register as the Attendance engine holds it. Null when no
  /// session exists yet, which the dashboard shows as "not taken" rather than
  /// as nobody being absent.
  Future<ClassAttendanceToday?> getTodaysAttendance({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required DateTime date,
    String? streamId,
  });

  /// How each student was marked in today's register, keyed by student id.
  /// Empty when no register exists - which the roster shows as "not marked"
  /// rather than defaulting anybody to absent.
  Future<Map<String, String>> getSessionStatuses({
    required String schoolId,
    required String classId,
    required DateTime date,
    String? streamId,
  });

  /// Every period on the class timetable for [date], across all subjects -
  /// the Class Teacher sees the whole class day, not only their own lessons.
  Future<List<Lesson>> getClassSchedule({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required DateTime date,
    String? streamId,
  });

  /// The class's recent audit rows, rendered as the dashboard activity feed.
  Future<List<ClassActivityEntry>> getRecentActivity({
    required String schoolId,
    required String classId,
    required String academicYearId,
    int limit = 20,
  });

  /// Counts the home tab shows as pending work. Grouped into one call because
  /// they are four small aggregate reads that always render together.
  Future<ClassPendingCounts> getPendingCounts({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    required String staffId,
    String? streamId,
  });
}

/// The four "pending" figures on the home tab.
class ClassPendingCounts {
  final int openAssignments;
  final int pendingReports;
  final int behaviourFollowUps;
  final int unreadMessages;

  const ClassPendingCounts({
    this.openAssignments = 0,
    this.pendingReports = 0,
    this.behaviourFollowUps = 0,
    this.unreadMessages = 0,
  });
}

class ClassTeacherRemoteDataSourceImpl implements ClassTeacherRemoteDataSource {
  final FirebaseFirestore firestore;

  ClassTeacherRemoteDataSourceImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> _school(String schoolId) =>
      firestore.collection('schools').doc(schoolId);

  CollectionReference<Map<String, dynamic>> _attendanceSessions(String schoolId) =>
      _school(schoolId).collection('class_attendance_sessions');

  CollectionReference<Map<String, dynamic>> _lessons(String schoolId) =>
      _school(schoolId).collection('lessons');

  CollectionReference<Map<String, dynamic>> _auditLogs(String schoolId) =>
      _school(schoolId).collection('subject_audit_logs');

  CollectionReference<Map<String, dynamic>> _homework(String schoolId) =>
      _school(schoolId).collection('class_homework');

  CollectionReference<Map<String, dynamic>> _reportEntries(String schoolId) =>
      _school(schoolId).collection('class_report_entries');

  CollectionReference<Map<String, dynamic>> _behaviour(String schoolId) =>
      _school(schoolId).collection('class_behaviour_records');

  Query<Map<String, dynamic>> _rosterQuery({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) {
    Query<Map<String, dynamic>> query = firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        // Transferred, withdrawn, graduated and suspended students must not
        // appear on a class register.
        .where('status', isEqualTo: 'active');

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }
    return query;
  }

  @override
  Future<List<ClassStudentSummary>> getClassRoster({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    final snapshot = await _rosterQuery(
      schoolId: schoolId,
      classId: classId,
      academicYearId: academicYearId,
      streamId: streamId,
    ).get();

    return _sorted(snapshot.docs
        .map((d) => _studentFromDoc(d.id, schoolId, classId, academicYearId, d.data()))
        .toList());
  }

  @override
  Stream<List<ClassStudentSummary>> watchClassRoster({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) {
    return _rosterQuery(
      schoolId: schoolId,
      classId: classId,
      academicYearId: academicYearId,
      streamId: streamId,
    ).snapshots().map((snapshot) => _sorted(snapshot.docs
        .map((d) => _studentFromDoc(d.id, schoolId, classId, academicYearId, d.data()))
        .toList()));
  }

  @override
  Future<ClassStudentSummary?> getClassStudent({
    required String schoolId,
    required String studentId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    final doc = await firestore.collection('students').doc(studentId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;

    // Membership is re-checked against the document rather than trusted from
    // the caller: a student id is guessable, so being asked for one is not
    // evidence the asker is entitled to it.
    if (data['schoolId'] != schoolId) return null;
    if (data['classId'] != classId) return null;
    if (data['academicYearId'] != academicYearId) return null;
    if (streamId != null &&
        streamId.isNotEmpty &&
        (data['streamId'] as String? ?? '').isNotEmpty &&
        data['streamId'] != streamId) {
      return null;
    }

    return _studentFromDoc(doc.id, schoolId, classId, academicYearId, data);
  }

  @override
  Future<ClassAttendanceToday?> getTodaysAttendance({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required DateTime date,
    String? streamId,
  }) async {
    final doc = await _attendanceSessions(schoolId)
        .doc(classSessionId(
          classId: classId,
          streamId: streamId,
          date: date,
        ))
        .get();

    final data = doc.data();
    if (!doc.exists || data == null) return null;
    if (data['academicYearId'] != academicYearId) return null;

    final counts = (data['counts'] as Map<String, dynamic>?) ?? const {};
    return ClassAttendanceToday(
      hasSession: true,
      isSubmitted: (data['status'] as String?) == 'submitted',
      presentCount: (counts['present'] as num?)?.toInt() ?? 0,
      absentCount: (counts['absent'] as num?)?.toInt() ?? 0,
      lateCount: (counts['late'] as num?)?.toInt() ?? 0,
      excusedCount: (counts['excused'] as num?)?.toInt() ?? 0,
      submittedAt: _toDate(data['submittedAt']),
    );
  }

  @override
  Future<Map<String, String>> getSessionStatuses({
    required String schoolId,
    required String classId,
    required DateTime date,
    String? streamId,
  }) async {
    final doc = await _attendanceSessions(schoolId)
        .doc(classSessionId(classId: classId, streamId: streamId, date: date))
        .get();

    final data = doc.data();
    if (!doc.exists || data == null) return const {};

    final entries = (data['entries'] as List?) ?? const [];
    return {
      for (final entry in entries.whereType<Map<String, dynamic>>())
        if ((entry['studentId'] as String? ?? '').isNotEmpty)
          entry['studentId'] as String: entry['status'] as String? ?? 'notMarked',
    };
  }

  @override
  Future<List<Lesson>> getClassSchedule({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required DateTime date,
    String? streamId,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    Query<Map<String, dynamic>> query = _lessons(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('scheduledStart',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('scheduledStart', isLessThan: Timestamp.fromDate(dayEnd));

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.orderBy('scheduledStart').get();
    return snapshot.docs.map((d) => _lessonFromDoc(d.id, schoolId, d.data())).toList();
  }

  @override
  Future<List<ClassActivityEntry>> getRecentActivity({
    required String schoolId,
    required String classId,
    required String academicYearId,
    int limit = 20,
  }) async {
    final snapshot = await _auditLogs(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((d) {
      final data = d.data();
      final action = data['action'] as String? ?? '';
      return ClassActivityEntry(
        id: d.id,
        action: action,
        title: _activityTitle(action),
        description: data['reason'] as String? ?? '',
        occurredAt: _toDate(data['timestamp']) ?? DateTime.now(),
        studentId: data['studentId'] as String?,
        entityType: data['entityType'] as String?,
        entityId: data['entityId'] as String?,
      );
    }).toList();
  }

  @override
  Future<ClassPendingCounts> getPendingCounts({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    required String staffId,
    String? streamId,
  }) async {
    // Four independent aggregate reads. `count()` keeps them server-side -
    // downloading a class's homework just to length it would be a wasted
    // round trip on every dashboard refresh.
    final results = await Future.wait([
      _countOrZero(_homework(schoolId)
          .where('classId', isEqualTo: classId)
          .where('academicYearId', isEqualTo: academicYearId)
          .where('status', whereIn: ['published', 'active', 'due_soon', 'overdue'])),
      _countOrZero(_reportEntries(schoolId)
          .where('classId', isEqualTo: classId)
          .where('academicYearId', isEqualTo: academicYearId)
          .where('termId', isEqualTo: termId)
          .where('status', whereIn: ['draft', 'in_progress', 'returned'])),
      _countOrZero(_behaviour(schoolId)
          .where('classId', isEqualTo: classId)
          .where('academicYearId', isEqualTo: academicYearId)
          .where('followUpRequired', isEqualTo: true)
          .where('followUpClosed', isEqualTo: false)),
    ]);

    return ClassPendingCounts(
      openAssignments: results[0],
      pendingReports: results[1],
      behaviourFollowUps: results[2],
    );
  }

  /// A count that degrades to zero rather than failing the whole dashboard.
  /// A missing composite index on one aggregate must not blank the other
  /// three figures the teacher came to see.
  Future<int> _countOrZero(Query<Map<String, dynamic>> query) async {
    try {
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  List<ClassStudentSummary> _sorted(List<ClassStudentSummary> students) {
    students.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return students;
  }

  ClassStudentSummary _studentFromDoc(
    String id,
    String schoolId,
    String classId,
    String academicYearId,
    Map<String, dynamic> data,
  ) {
    return ClassStudentSummary(
      studentId: id,
      schoolId: schoolId,
      name: data['name'] as String? ?? '',
      admissionNumber: data['admissionNumber'] as String? ??
          data['studentCode'] as String? ??
          '',
      photoUrl: data['photoUrl'] as String?,
      classId: data['classId'] as String? ?? classId,
      className: data['className'] as String? ?? '',
      streamId: data['streamId'] as String?,
      streamName: data['streamName'] as String?,
      academicYearId: data['academicYearId'] as String? ?? academicYearId,
      status: ClassStudentStatus.fromId(data['status'] as String?),
      gender: data['gender'] as String?,
      residency: ResidencyType.fromId(data['residency'] as String?),
      houseId: data['houseId'] as String?,
      houseName: data['houseName'] as String?,
      hasHealthAlert: data['hasHealthAlert'] as bool? ?? false,
    );
  }

  Lesson _lessonFromDoc(String id, String schoolId, Map<String, dynamic> data) {
    return Lesson(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      subjectName: data['subjectName'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      className: data['className'] as String? ?? '',
      streamId: data['streamId'] as String?,
      streamName: data['streamName'] as String?,
      timetableSlotId: data['timetableSlotId'] as String? ?? '',
      teacherStaffId: data['teacherStaffId'] as String? ?? '',
      substituteStaffId: data['substituteStaffId'] as String?,
      title: data['title'] as String? ?? '',
      topic: data['topic'] as String?,
      subtopic: data['subtopic'] as String?,
      scheduledStart: _toDate(data['scheduledStart']) ?? DateTime(1970),
      scheduledEnd: _toDate(data['scheduledEnd']) ?? DateTime(1970),
      actualStart: _toDate(data['actualStart']),
      actualEnd: _toDate(data['actualEnd']),
      room: data['room'] as String?,
      status: LessonStatus.fromId(data['status'] as String?),
      statusReason: data['statusReason'] as String?,
      enrolledCount: (data['enrolledCount'] as num?)?.toInt() ?? 0,
      attendanceSubmitted: data['attendanceSubmitted'] as bool? ?? false,
      lessonNoteCount: (data['lessonNoteCount'] as num?)?.toInt() ?? 0,
      resourceCount: (data['resourceCount'] as num?)?.toInt() ?? 0,
      relatedAssessmentId: data['relatedAssessmentId'] as String?,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Human label for an audit action, so the activity feed reads as English
  /// rather than as dotted action ids.
  static String _activityTitle(String action) => switch (action) {
        'attendance.saved' => 'Attendance Draft Saved',
        'attendance.submitted' => 'Attendance Logged',
        'attendance.edited' => 'Attendance Corrected',
        'homework.created' => 'Homework Created',
        'homework.published' => 'Homework Published',
        'behaviour.recorded' => 'Behaviour Recorded',
        'achievement.recorded' => 'Achievement Recorded',
        'announcement.created' => 'Announcement Created',
        'announcement.published' => 'Announcement Published',
        'message.sent' => 'Message Sent',
        'report.draft_saved' => 'Report Draft Saved',
        'report.submitted' => 'Report Submitted',
        'report.generated' => 'Reports Generated',
        'competency.entered' => 'Competencies Entered',
        'conduct.entered' => 'Conduct Ratings Entered',
        'comment.added' => 'Teacher Comment Added',
        'task.created' => 'Task Created',
        'task.completed' => 'Task Completed',
        'resource.uploaded' => 'Resource Uploaded',
        'resource.shared' => 'Resource Shared',
        _ => 'Class Activity',
      };
}

/// The deterministic id of one class's register for one day.
///
/// Derived rather than random so a second submission for the same class and
/// day collides with the first instead of creating a duplicate register -
/// which is the whole defence against double-marking a class.
String classSessionId({
  required String classId,
  String? streamId,
  required DateTime date,
  String sessionType = 'daily',
}) {
  final day = '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
  final stream = (streamId == null || streamId.isEmpty) ? 'all' : streamId;
  return '${classId}_${stream}_${sessionType}_$day';
}
