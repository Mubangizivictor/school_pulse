import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/class_announcement.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/entities/class_behaviour.dart';
import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/class_homework.dart';
import '../../domain/entities/class_performance.dart';
import '../../domain/entities/class_report_entry.dart';
import '../../domain/entities/class_task.dart';
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

  /// The teacher's own task list. Scoped by ownership rather than class -
  /// see [ClassTask] for why.
  Future<List<ClassTask>> getTasks({
    required String schoolId,
    required String ownerUserId,
  });

  Future<void> saveTask(ClassTask task);

  Future<void> deleteTask({required String schoolId, required String taskId});

  /// The class teacher's report sections for every student in the class.
  Future<List<ClassReportEntry>> getReportEntries({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
  });

  Future<void> saveReportEntry(ClassReportEntry entry);

  /// The school's report configuration - which sections apply and what the
  /// competency and conduct scales are called. Null when none is configured.
  Future<ReportProfile?> getReportProfile({
    required String schoolId,
    required String academicYearId,
  });

  /// Approved marks for every subject the class sits, for one term.
  ///
  /// Only marks the Assessment engine has approved: draft and submitted-but-
  /// unapproved marks are excluded, because an average over marks a subject
  /// teacher is still editing is a number nobody should act on.
  Future<List<ClassMarkRow>> getApprovedClassMarks({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    String? streamId,
  });

  /// One student's individual approved marks in one subject - the rows
  /// [getApprovedClassMarks] collapses into a subject average, resolved
  /// against the assessment each mark belongs to for its display name.
  Future<List<StudentAssessmentResult>> getStudentAssessmentResults({
    required String schoolId,
    required String studentId,
    required String subjectId,
    required String academicYearId,
    required String termId,
  });

  /// Announcements posted to this class, newest first.
  Future<List<ClassAnnouncement>> getAnnouncements({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<void> saveAnnouncement(ClassAnnouncement announcement);

  /// Class work set for this class, newest due date first.
  Future<List<ClassHomework>> getHomework({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<void> saveHomework(ClassHomework homework);

  /// Behaviour and achievement records for the class, newest first.
  /// [studentId] narrows to one student's file.
  Future<List<ClassBehaviourRecord>> getBehaviourRecords({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? studentId,
    int limit = 100,
  });

  Future<void> saveBehaviourRecord(ClassBehaviourRecord record);

  /// The behaviour categories the school configured, or empty when it has
  /// configured none and the shared defaults should stand.
  Future<List<({String id, String name, String colorHex, bool isActive})>>
  getBehaviourCategories({required String schoolId});

  /// One class register, or null when it has not been started.
  Future<ClassAttendanceSession?> getAttendanceSession({
    required String schoolId,
    required String sessionId,
  });

  /// Writes the register. Keyed on the deterministic session id, so a second
  /// submission for the same class and day overwrites rather than creating a
  /// duplicate the school would have to reconcile.
  Future<void> saveAttendanceSession(ClassAttendanceSession session);

  /// Submitted registers between two dates, newest first - the history and
  /// term-summary views.
  Future<List<ClassAttendanceSession>> getAttendanceSessions({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required DateTime from,
    required DateTime to,
    String? streamId,
  });

  /// Raises a correction request for a register the teacher may no longer
  /// edit directly. Only the academic office decides one.
  Future<void> createCorrectionRequest(AttendanceCorrectionRequest request);

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

/// One approved mark, flattened to what the class view needs.
class ClassMarkRow {
  final String studentId;
  final String subjectId;
  final String subjectName;
  final double percentage;

  const ClassMarkRow({
    required this.studentId,
    required this.subjectId,
    this.subjectName = '',
    required this.percentage,
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

  CollectionReference<Map<String, dynamic>> _attendanceSessions(
    String schoolId,
  ) => _school(schoolId).collection('class_attendance_sessions');

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

  CollectionReference<Map<String, dynamic>> _announcements(String schoolId) =>
      _school(schoolId).collection('class_announcements');

  CollectionReference<Map<String, dynamic>> _assessments(String schoolId) =>
      _school(schoolId).collection('subject_assessments');

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

    return _sorted(
      snapshot.docs
          .map(
            (d) => _studentFromDoc(
              d.id,
              schoolId,
              classId,
              academicYearId,
              d.data(),
            ),
          )
          .toList(),
    );
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
    ).snapshots().map(
      (snapshot) => _sorted(
        snapshot.docs
            .map(
              (d) => _studentFromDoc(
                d.id,
                schoolId,
                classId,
                academicYearId,
                d.data(),
              ),
            )
            .toList(),
      ),
    );
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
        .doc(classSessionId(classId: classId, streamId: streamId, date: date))
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

  CollectionReference<Map<String, dynamic>> _tasks(String schoolId) =>
      _school(schoolId).collection('class_tasks');

  @override
  Future<List<ClassTask>> getTasks({
    required String schoolId,
    required String ownerUserId,
  }) async {
    final snapshot = await _tasks(
      schoolId,
    ).where('ownerUserId', isEqualTo: ownerUserId).orderBy('dueAt').get();

    return snapshot.docs
        .map((d) => _taskFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> saveTask(ClassTask task) async {
    await _tasks(task.schoolId).doc(task.id).set({
      'schoolId': task.schoolId,
      'campusId': task.campusId,
      'classId': task.classId,
      'academicYearId': task.academicYearId,
      'termId': task.termId,
      'title': task.title,
      'description': task.description,
      'category': task.category,
      'priority': task.priority.name,
      'status': task.status.name,
      'dueAt': Timestamp.fromDate(task.dueAt),
      'studentId': task.studentId,
      'subjectName': task.subjectName,
      'checklist': task.checklist
          .map(
            (c) => {'id': c.id, 'title': c.title, 'isCompleted': c.isCompleted},
          )
          .toList(),
      'attachments': task.attachments,
      'recurrence': {
        ...task.recurrence.toMap(),
        'endDate': task.recurrence.endDate == null
            ? null
            : Timestamp.fromDate(task.recurrence.endDate!),
      },
      'remindAt': task.remindAt == null
          ? null
          : Timestamp.fromDate(task.remindAt!),
      'ownerUserId': task.ownerUserId,
      'collaboratorUserIds': task.collaboratorUserIds,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'completedAt': task.completedAt == null
          ? null
          : Timestamp.fromDate(task.completedAt!),
      'completedBy': task.completedBy,
      'roleAssignmentId': task.roleAssignmentId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteTask({
    required String schoolId,
    required String taskId,
  }) async {
    await _tasks(schoolId).doc(taskId).delete();
  }

  ClassTask _taskFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    final recurrence =
        (data['recurrence'] as Map<String, dynamic>?) ?? const {};

    return ClassTask(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String?,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      priority: ClassTaskPriority.fromId(data['priority'] as String?),
      status: ClassTaskStatus.fromId(data['status'] as String?),
      dueAt: _toDate(data['dueAt']) ?? DateTime(1970),
      studentId: data['studentId'] as String?,
      subjectName: data['subjectName'] as String?,
      checklist: ((data['checklist'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => ClassTaskChecklistItem(
              id: e['id'] as String? ?? '',
              title: e['title'] as String? ?? '',
              isCompleted: e['isCompleted'] as bool? ?? false,
            ),
          )
          .toList(),
      attachments:
          (data['attachments'] as List?)?.whereType<String>().toList() ??
          const [],
      recurrence: TaskRecurrence.fromMap({
        ...recurrence,
        'endDate': _toDate(recurrence['endDate']),
      }),
      remindAt: _toDate(data['remindAt']),
      ownerUserId: data['ownerUserId'] as String? ?? '',
      collaboratorUserIds:
          (data['collaboratorUserIds'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      createdAt: _toDate(data['createdAt']) ?? DateTime(1970),
      completedAt: _toDate(data['completedAt']),
      completedBy: data['completedBy'] as String?,
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
    );
  }

  @override
  Future<List<ClassReportEntry>> getReportEntries({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
  }) async {
    final snapshot = await _reportEntries(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('termId', isEqualTo: termId)
        .get();

    return snapshot.docs
        .map((d) => _reportEntryFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> saveReportEntry(ClassReportEntry entry) async {
    await _reportEntries(entry.schoolId).doc(entry.id).set({
      'schoolId': entry.schoolId,
      'campusId': entry.campusId,
      'classId': entry.classId,
      'streamId': entry.streamId,
      'academicYearId': entry.academicYearId,
      'termId': entry.termId,
      'studentId': entry.studentId,
      'studentName': entry.studentName,
      'status': entry.status.storageId,
      'competencies': entry.competencies
          .map(
            (c) => {
              'domainId': c.domainId,
              'domainLabel': c.domainLabel,
              'levelCode': c.levelCode,
              'evidenceNote': c.evidenceNote,
            },
          )
          .toList(),
      'conduct': entry.conduct
          .map(
            (c) => {
              'criterionId': c.criterionId,
              'criterionLabel': c.criterionLabel,
              'ratingCode': c.ratingCode,
            },
          )
          .toList(),
      'overallConductCode': entry.overallConductCode,
      'teacherComment': entry.teacherComment,
      'recommendations': entry.recommendations,
      'attendanceVerified': entry.attendanceVerified,
      'returnReason': entry.returnReason,
      'updatedBy': entry.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'submittedAt': entry.submittedAt == null
          ? null
          : Timestamp.fromDate(entry.submittedAt!),
      'roleAssignmentId': entry.roleAssignmentId,
    }, SetOptions(merge: true));
  }

  @override
  Future<ReportProfile?> getReportProfile({
    required String schoolId,
    required String academicYearId,
  }) async {
    final doc = await _school(
      schoolId,
    ).collection('configs').doc('classReportProfile').get();

    final data = doc.data();
    if (!doc.exists || data == null) return null;

    List<({String id, String label})> pairs(String key) {
      return ((data[key] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => (
              id: e['id'] as String? ?? '',
              label: e['label'] as String? ?? '',
            ),
          )
          .where((e) => e.id.isNotEmpty)
          .toList();
    }

    List<({String code, String label})> codes(String key) {
      return ((data[key] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => (
              code: e['code'] as String? ?? '',
              label: e['label'] as String? ?? '',
            ),
          )
          .where((e) => e.code.isNotEmpty)
          .toList();
    }

    return ReportProfile(
      id: doc.id,
      name: data['name'] as String? ?? '',
      enabledSections: ((data['enabledSections'] as List?) ?? const [])
          .whereType<String>()
          .map(ReportSection.fromId)
          .whereType<ReportSection>()
          .toSet(),
      competencyDomains: pairs('competencyDomains'),
      competencyLevels: codes('competencyLevels'),
      conductCriteria: pairs('conductCriteria'),
      conductRatings: codes('conductRatings'),
      commentMinLength: (data['commentMinLength'] as num?)?.toInt() ?? 20,
      requiresCompleteness: data['requiresCompleteness'] as bool? ?? true,
    );
  }

  ClassReportEntry _reportEntryFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return ClassReportEntry(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      status: ReportEntryStatus.fromId(data['status'] as String?),
      competencies: ((data['competencies'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => CompetencyEntry(
              domainId: e['domainId'] as String? ?? '',
              domainLabel: e['domainLabel'] as String? ?? '',
              levelCode: e['levelCode'] as String?,
              evidenceNote: e['evidenceNote'] as String?,
            ),
          )
          .toList(),
      conduct: ((data['conduct'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => ConductEntry(
              criterionId: e['criterionId'] as String? ?? '',
              criterionLabel: e['criterionLabel'] as String? ?? '',
              ratingCode: e['ratingCode'] as String?,
            ),
          )
          .toList(),
      overallConductCode: data['overallConductCode'] as String?,
      teacherComment: data['teacherComment'] as String?,
      recommendations:
          (data['recommendations'] as List?)?.whereType<String>().toList() ??
          const [],
      attendanceVerified: data['attendanceVerified'] as bool? ?? false,
      returnReason: data['returnReason'] as String?,
      updatedBy: data['updatedBy'] as String?,
      updatedAt: _toDate(data['updatedAt']),
      submittedAt: _toDate(data['submittedAt']),
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
    );
  }

  @override
  Future<List<ClassMarkRow>> getApprovedClassMarks({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required String termId,
    String? streamId,
  }) async {
    Query<Map<String, dynamic>> query = _school(schoolId)
        .collection('student_marks')
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('termId', isEqualTo: termId)
        .where('markStatus', isEqualTo: 'approved');

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.get();
    final rows = <ClassMarkRow>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final score = (data['score'] as num?)?.toDouble();
      final maximum = (data['maximumMark'] as num?)?.toDouble();
      if (score == null) continue;

      // Percentage is derived here rather than trusted from the document:
      // components carry different maxima, and a raw score compared across
      // them would be meaningless.
      final percentage = (maximum != null && maximum > 0)
          ? (score / maximum) * 100
          : score;

      rows.add(
        ClassMarkRow(
          studentId: data['studentId'] as String? ?? '',
          subjectId: data['subjectId'] as String? ?? '',
          subjectName: data['subjectName'] as String? ?? '',
          percentage: percentage,
        ),
      );
    }

    return rows;
  }

  @override
  Future<List<StudentAssessmentResult>> getStudentAssessmentResults({
    required String schoolId,
    required String studentId,
    required String subjectId,
    required String academicYearId,
    required String termId,
  }) async {
    final snapshot = await _school(schoolId)
        .collection('student_marks')
        .where('studentId', isEqualTo: studentId)
        .where('subjectId', isEqualTo: subjectId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('termId', isEqualTo: termId)
        .where('markStatus', isEqualTo: 'approved')
        .get();

    if (snapshot.docs.isEmpty) return const [];

    // Assessment titles/dates live on the parent assessment, not the mark -
    // resolved by id rather than duplicated onto every mark document.
    final assessmentIds = snapshot.docs
        .map((d) => d.data()['assessmentId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final assessmentDocs = await Future.wait(
      assessmentIds.map((id) => _assessments(schoolId).doc(id).get()),
    );
    final assessmentById = {
      for (final doc in assessmentDocs)
        if (doc.exists) doc.id: doc.data()!,
    };

    final results = <StudentAssessmentResult>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final score = (data['score'] as num?)?.toDouble();
      final maximumMark = (data['maximumMark'] as num?)?.toDouble();
      if (score == null || maximumMark == null) continue;

      final assessmentId = data['assessmentId'] as String? ?? '';
      final assessment = assessmentById[assessmentId];

      results.add(
        StudentAssessmentResult(
          assessmentId: assessmentId,
          componentId: data['componentId'] as String? ?? '',
          assessmentTitle: assessment?['title'] as String? ?? '',
          componentName:
              assessment?['assessmentTypeName'] as String? ??
              data['componentId'] as String? ??
              '',
          score: score,
          maximumMark: maximumMark,
          assessmentDate: _toDate(assessment?['assessmentDate']),
        ),
      );
    }

    results.sort((a, b) {
      final aDate = a.assessmentDate;
      final bDate = b.assessmentDate;
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    return results;
  }

  @override
  Future<List<ClassAnnouncement>> getAnnouncements({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    Query<Map<String, dynamic>> query = _announcements(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId);

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((d) => _announcementFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> saveAnnouncement(ClassAnnouncement announcement) async {
    await _announcements(announcement.schoolId).doc(announcement.id).set({
      'schoolId': announcement.schoolId,
      'campusId': announcement.campusId,
      'classId': announcement.classId,
      'className': announcement.className,
      'streamId': announcement.streamId,
      'academicYearId': announcement.academicYearId,
      'termId': announcement.termId,
      'title': announcement.title,
      'body': announcement.body,
      'status': announcement.status.name,
      'audience': announcement.audience.name,
      'attachments': announcement.attachments,
      'scheduledFor': announcement.scheduledFor == null
          ? null
          : Timestamp.fromDate(announcement.scheduledFor!),
      'expiresAt': announcement.expiresAt == null
          ? null
          : Timestamp.fromDate(announcement.expiresAt!),
      'publishedAt': announcement.publishedAt == null
          ? null
          : Timestamp.fromDate(announcement.publishedAt!),
      'recipientCount': announcement.recipientCount,
      'createdBy': announcement.createdBy,
      'createdAt': Timestamp.fromDate(announcement.createdAt),
      'updatedBy': announcement.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'roleAssignmentId': announcement.roleAssignmentId,
    }, SetOptions(merge: true));
  }

  ClassAnnouncement _announcementFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return ClassAnnouncement(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      className: data['className'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      status: ClassAnnouncementStatus.fromId(data['status'] as String?),
      audience: ClassAnnouncementAudience.fromId(data['audience'] as String?),
      attachments:
          (data['attachments'] as List?)?.whereType<String>().toList() ??
          const [],
      scheduledFor: _toDate(data['scheduledFor']),
      expiresAt: _toDate(data['expiresAt']),
      publishedAt: _toDate(data['publishedAt']),
      recipientCount: (data['recipientCount'] as num?)?.toInt() ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDate(data['createdAt']) ?? DateTime(1970),
      updatedBy: data['updatedBy'] as String?,
      updatedAt: _toDate(data['updatedAt']),
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
    );
  }

  @override
  Future<List<ClassHomework>> getHomework({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    Query<Map<String, dynamic>> query = _homework(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId);

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.orderBy('dueDate', descending: true).get();
    return snapshot.docs
        .map((d) => _homeworkFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> saveHomework(ClassHomework homework) async {
    await _homework(homework.schoolId).doc(homework.id).set({
      'schoolId': homework.schoolId,
      'campusId': homework.campusId,
      'classId': homework.classId,
      'className': homework.className,
      'streamId': homework.streamId,
      'academicYearId': homework.academicYearId,
      'termId': homework.termId,
      'title': homework.title,
      'description': homework.description,
      'instructions': homework.instructions,
      'subjectName': homework.subjectName,
      'dueDate': Timestamp.fromDate(homework.dueDate),
      'status': homework.status.name,
      'priority': homework.priority.name,
      'attachments': homework.attachments,
      'createdBy': homework.createdBy,
      'createdAt': Timestamp.fromDate(homework.createdAt),
      'updatedBy': homework.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'publishedAt': homework.publishedAt == null
          ? null
          : Timestamp.fromDate(homework.publishedAt!),
      'roleAssignmentId': homework.roleAssignmentId,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<ClassBehaviourRecord>> getBehaviourRecords({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? studentId,
    int limit = 100,
  }) async {
    Query<Map<String, dynamic>> query = _behaviour(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId);

    if (studentId != null && studentId.isNotEmpty) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    final snapshot = await query
        .orderBy('recordedAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((d) => _behaviourFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> saveBehaviourRecord(ClassBehaviourRecord record) async {
    await _behaviour(record.schoolId).doc(record.id).set({
      'schoolId': record.schoolId,
      'campusId': record.campusId,
      'classId': record.classId,
      'streamId': record.streamId,
      'academicYearId': record.academicYearId,
      'termId': record.termId,
      'studentId': record.studentId,
      'studentName': record.studentName,
      'category': record.categoryCode,
      'note': record.note,
      'recommendation': record.recommendation,
      'followUpRequired': record.followUpRequired,
      'followUpClosed': record.followUpClosed,
      'followUpNote': record.followUpNote,
      'recordedBy': record.recordedBy,
      'recordedAt': Timestamp.fromDate(record.recordedAt),
      'updatedBy': record.updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'roleAssignmentId': record.roleAssignmentId,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<({String id, String name, String colorHex, bool isActive})>>
  getBehaviourCategories({required String schoolId}) async {
    final snapshot = await _school(
      schoolId,
    ).collection('class_behaviour_categories').get();
    return snapshot.docs.map((d) {
      final data = d.data();
      return (
        id: d.id,
        name: data['name'] as String? ?? d.id,
        colorHex: data['colorHex'] as String? ?? '',
        isActive: data['isActive'] as bool? ?? true,
      );
    }).toList();
  }

  ClassHomework _homeworkFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return ClassHomework(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      className: data['className'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      instructions: data['instructions'] as String?,
      subjectName: data['subjectName'] as String?,
      dueDate: _toDate(data['dueDate']) ?? DateTime(1970),
      status: ClassHomeworkStatus.fromId(data['status'] as String?),
      priority: ClassHomeworkPriority.fromId(data['priority'] as String?),
      attachments:
          (data['attachments'] as List?)?.whereType<String>().toList() ??
          const [],
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDate(data['createdAt']) ?? DateTime(1970),
      updatedBy: data['updatedBy'] as String?,
      updatedAt: _toDate(data['updatedAt']),
      publishedAt: _toDate(data['publishedAt']),
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
    );
  }

  ClassBehaviourRecord _behaviourFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return ClassBehaviourRecord(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      categoryCode: data['category'] as String? ?? '',
      note: data['note'] as String? ?? '',
      recommendation: data['recommendation'] as String?,
      followUpRequired: data['followUpRequired'] as bool? ?? false,
      followUpClosed: data['followUpClosed'] as bool? ?? false,
      followUpNote: data['followUpNote'] as String?,
      disciplineCaseId: data['disciplineCaseId'] as String?,
      disciplineStatus: data['disciplineStatus'] as String?,
      recordedBy: data['recordedBy'] as String? ?? '',
      recordedAt: _toDate(data['recordedAt']) ?? DateTime(1970),
      updatedBy: data['updatedBy'] as String?,
      updatedAt: _toDate(data['updatedAt']),
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
    );
  }

  @override
  Future<ClassAttendanceSession?> getAttendanceSession({
    required String schoolId,
    required String sessionId,
  }) async {
    final doc = await _attendanceSessions(schoolId).doc(sessionId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return _sessionFromDoc(doc.id, schoolId, data);
  }

  @override
  Future<void> saveAttendanceSession(ClassAttendanceSession session) async {
    await _attendanceSessions(session.schoolId).doc(session.id).set({
      'schoolId': session.schoolId,
      'campusId': session.campusId,
      'classId': session.classId,
      'className': session.className,
      'streamId': session.streamId,
      'academicYearId': session.academicYearId,
      'termId': session.termId,
      'sessionType': session.sessionType,
      'date': Timestamp.fromDate(session.date),
      'status': session.status.name,
      'entries': session.entries
          .map(
            (e) => {
              'studentId': e.studentId,
              'status': e.statusCode,
              'note': e.note,
              'markedAt': e.markedAt == null
                  ? null
                  : Timestamp.fromDate(e.markedAt!),
            },
          )
          .toList(),
      // Denormalised so the dashboard reads one document instead of counting
      // an entries array on every refresh.
      'counts': _countsFor(session),
      'submittedAt': session.submittedAt == null
          ? null
          : Timestamp.fromDate(session.submittedAt!),
      'submittedBy': session.submittedBy,
      'roleAssignmentId': session.roleAssignmentId,
      'deviceId': session.deviceId,
      'lastCorrectedAt': session.lastCorrectedAt == null
          ? null
          : Timestamp.fromDate(session.lastCorrectedAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<ClassAttendanceSession>> getAttendanceSessions({
    required String schoolId,
    required String classId,
    required String academicYearId,
    required DateTime from,
    required DateTime to,
    String? streamId,
  }) async {
    Query<Map<String, dynamic>> query = _attendanceSessions(schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((d) => _sessionFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> createCorrectionRequest(
    AttendanceCorrectionRequest request,
  ) async {
    await _school(
      request.schoolId,
    ).collection('class_attendance_corrections').doc(request.id).set({
      'schoolId': request.schoolId,
      'sessionId': request.sessionId,
      'classId': request.classId,
      'academicYearId': request.academicYearId,
      'studentId': request.studentId,
      'previousStatusCode': request.previousStatusCode,
      'requestedStatusCode': request.requestedStatusCode,
      'reason': request.reason,
      'requestedByUserId': request.requestedByUserId,
      'requestedByStaffId': request.requestedByStaffId,
      'roleAssignmentId': request.roleAssignmentId,
      'requestedAt': Timestamp.fromDate(request.requestedAt),
      // The rules pin this to 'pending' on create: a teacher cannot raise a
      // request that is already approved.
      'status': 'pending',
    });
  }

  static Map<String, int> _countsFor(ClassAttendanceSession session) {
    final counts = <String, int>{};
    for (final entry in session.entries) {
      if (!entry.isMarked) continue;
      counts[entry.statusCode] = (counts[entry.statusCode] ?? 0) + 1;
    }
    // The dashboard reads these four names, so they are always present even
    // at zero rather than missing and read as null.
    for (final key in ['present', 'absent', 'late', 'excused']) {
      counts.putIfAbsent(key, () => 0);
    }
    return counts;
  }

  ClassAttendanceSession _sessionFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    final rawEntries = (data['entries'] as List?) ?? const [];
    return ClassAttendanceSession(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      className: data['className'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      sessionType: data['sessionType'] as String? ?? 'daily',
      date: _toDate(data['date']) ?? DateTime(1970),
      status: ClassAttendanceSessionStatus.fromId(data['status'] as String?),
      entries: rawEntries.whereType<Map<String, dynamic>>().map((e) {
        return ClassAttendanceEntry(
          studentId: e['studentId'] as String? ?? '',
          statusCode: e['status'] as String? ?? '',
          note: e['note'] as String?,
          markedAt: _toDate(e['markedAt']),
        );
      }).toList(),
      submittedAt: _toDate(data['submittedAt']),
      submittedBy: data['submittedBy'] as String?,
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
      deviceId: data['deviceId'] as String? ?? '',
      lastCorrectedAt: _toDate(data['lastCorrectedAt']),
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
          entry['studentId'] as String:
              entry['status'] as String? ?? 'notMarked',
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
        .where(
          'scheduledStart',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
        )
        .where('scheduledStart', isLessThan: Timestamp.fromDate(dayEnd));

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.orderBy('scheduledStart').get();
    return snapshot.docs
        .map((d) => _lessonFromDoc(d.id, schoolId, d.data()))
        .toList();
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
      _countOrZero(
        _homework(schoolId)
            .where('classId', isEqualTo: classId)
            .where('academicYearId', isEqualTo: academicYearId)
            .where(
              'status',
              whereIn: ['published', 'active', 'due_soon', 'overdue'],
            ),
      ),
      _countOrZero(
        _reportEntries(schoolId)
            .where('classId', isEqualTo: classId)
            .where('academicYearId', isEqualTo: academicYearId)
            .where('termId', isEqualTo: termId)
            .where('status', whereIn: ['draft', 'in_progress', 'returned']),
      ),
      _countOrZero(
        _behaviour(schoolId)
            .where('classId', isEqualTo: classId)
            .where('academicYearId', isEqualTo: academicYearId)
            .where('followUpRequired', isEqualTo: true)
            .where('followUpClosed', isEqualTo: false),
      ),
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
    students.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
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
      admissionNumber:
          data['admissionNumber'] as String? ??
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
      // `isBoarder` is the older field several modules still write; falling
      // back to it keeps the roster filter working on students who predate
      // the explicit `residency` value.
      residency: ResidencyType.fromId(
        data['residency'] as String? ??
            switch (data['isBoarder']) {
              true => 'boarding',
              false => 'day',
              _ => null,
            },
      ),
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
  final day =
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
  final stream = (streamId == null || streamId.isEmpty) ? 'all' : streamId;
  return '${classId}_${stream}_${sessionType}_$day';
}
