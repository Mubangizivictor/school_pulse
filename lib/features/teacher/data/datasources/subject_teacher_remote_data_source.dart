import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/class_subject.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/entities/subject_assessment.dart';
import '../../domain/entities/subject_audit_log.dart';
import '../../domain/entities/subject_enrollment.dart';

/// Firestore access for staff responsibilities, subject enrollment and the
/// audit trail.
///
/// Everything lives under `schools/{schoolId}/...` rather than in top-level
/// collections, so tenant isolation is structural: a query rooted at one
/// school physically cannot return another school's documents, and the
/// security rules only need to check the path segment.
abstract class SubjectTeacherRemoteDataSource {
  Future<List<StaffRoleAssignment>> getAssignmentsForUser({
    required String schoolId,
    required String userId,
  });

  /// Live view of the signed-in teacher's responsibilities. The panel listens
  /// to this so an admin suspending an assignment takes effect on the device
  /// immediately, without waiting for the teacher to restart the app.
  Stream<List<StaffRoleAssignment>> watchAssignmentsForUser({
    required String schoolId,
    required String userId,
  });

  Future<StaffRoleAssignment?> getAssignment({
    required String schoolId,
    required String assignmentId,
  });

  /// Every assignment currently pointing at [roleDefinitionId], across all
  /// staff. Backs the Role Details "Assignments" tab and the role-deletion
  /// usage guard. Only assignments created after `roleDefinitionId` started
  /// being populated are found this way — see the field's doc comment.
  Future<List<StaffRoleAssignment>> getAssignmentsForRole({
    required String schoolId,
    required String roleDefinitionId,
  });

  /// Admin-only. Writes a new responsibility row. `assignment.id` may be
  /// empty, in which case a Firestore doc id is generated and returned on
  /// the result so the caller can navigate to it immediately.
  Future<StaffRoleAssignment> createAssignment(StaffRoleAssignment assignment);

  /// Admin-only. Full-record update - status changes, scope edits, and
  /// end-date edits all go through this rather than bespoke partial-update
  /// methods, keeping the write surface small and matching the read model.
  Future<StaffRoleAssignment> updateAssignment(StaffRoleAssignment assignment);

  Future<List<SubjectEnrollment>> getEnrollments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<List<SubjectEnrollment>> getEnrollmentsForStudent({
    required String schoolId,
    required String studentId,
    required String academicYearId,
  });

  Future<void> createEnrollments(List<SubjectEnrollment> enrollments);

  Future<void> updateEnrollment(SubjectEnrollment enrollment);

  Future<void> writeAuditLog(SubjectAuditLog log);

  Future<void> writeAuditLogs(List<SubjectAuditLog> logs);

  /// The active students of one class, as a deliberately narrow projection.
  ///
  /// The Subject Teacher panel has no business reading a student's fee
  /// balance, clinical notes or discipline file, so the projection carries
  /// name, photo, admission number and placement and nothing else. Fetching
  /// the class in one query rather than looking up enrolled ids individually
  /// keeps this to a single read per class.
  Future<List<EligibleStudent>> getClassRoster({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  });

  Future<List<Lesson>> getLessons({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    DateTime? from,
    DateTime? to,
  });

  Future<Lesson?> getLesson({
    required String schoolId,
    required String lessonId,
  });

  /// Records what happened during a lesson. [roleAssignmentId] is written so
  /// the rules can prove the writer held a responsibility covering it.
  Future<void> updateLesson(Lesson lesson, {required String roleAssignmentId});

  Future<LessonAttendance?> getLessonAttendance({
    required String schoolId,
    required String lessonId,
  });

  Future<void> saveLessonAttendance(LessonAttendance attendance);

  Future<List<SubjectAssessment>> getAssessments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? termId,
  });

  /// Creates a new assessment, open for entry immediately. `maximumMark` is
  /// also the maximum of its single initial component - a teacher who needs
  /// more components edits them afterwards, this call just gets them
  /// unblocked from "no assessments yet".
  Future<SubjectAssessment> createAssessment({
    required String schoolId,
    required String campusId,
    required String subjectId,
    required String classId,
    String? streamId,
    required String academicYearId,
    required String termId,
    required String title,
    required String assessmentType,
    required double maximumMark,
    required String createdByStaffId,
    required String roleAssignmentId,
  });

  Future<List<StudentMarkEntry>> getMarks({
    required String schoolId,
    required String assessmentId,
    required String componentId,
  });

  /// Every subject the curriculum teaches in one class, for the Class
  /// Teacher marks-entry subject picker.
  Future<List<ClassSubject>> getClassSubjects({
    required String schoolId,
    required String classId,
    required String academicYearId,
  });

  /// One document per student/component, so a re-save corrects rather than
  /// duplicates, and an approved mark can be recognised and refused by the
  /// rules on the way in.
  Future<void> saveMarks({
    required String schoolId,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
    required String roleAssignmentId,
    required String staffId,
    required String markStatus,
  });
}

class SubjectTeacherRemoteDataSourceImpl
    implements SubjectTeacherRemoteDataSource {
  final FirebaseFirestore firestore;

  SubjectTeacherRemoteDataSourceImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> _school(String schoolId) =>
      firestore.collection('schools').doc(schoolId);

  CollectionReference<Map<String, dynamic>> _assignments(String schoolId) =>
      _school(schoolId).collection('staff_role_assignments');

  CollectionReference<Map<String, dynamic>> _enrollments(String schoolId) =>
      _school(schoolId).collection('subject_enrollments');

  CollectionReference<Map<String, dynamic>> _auditLogs(String schoolId) =>
      _school(schoolId).collection('subject_audit_logs');

  @override
  Future<List<StaffRoleAssignment>> getAssignmentsForUser({
    required String schoolId,
    required String userId,
  }) async {
    final snapshot = await _assignments(schoolId)
        .where('userId', isEqualTo: userId)
        .where(
          'status',
          whereIn: [
            AssignmentStatus.active.name,
            AssignmentStatus.suspended.name,
          ],
        )
        .get();

    return snapshot.docs
        .map((d) => _assignmentFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Stream<List<StaffRoleAssignment>> watchAssignmentsForUser({
    required String schoolId,
    required String userId,
  }) {
    return _assignments(schoolId)
        .where('userId', isEqualTo: userId)
        .where(
          'status',
          whereIn: [
            AssignmentStatus.active.name,
            AssignmentStatus.suspended.name,
          ],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => _assignmentFromDoc(d.id, schoolId, d.data()))
              .toList(),
        );
  }

  @override
  Future<StaffRoleAssignment?> getAssignment({
    required String schoolId,
    required String assignmentId,
  }) async {
    final doc = await _assignments(schoolId).doc(assignmentId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return _assignmentFromDoc(doc.id, schoolId, data);
  }

  @override
  Future<List<StaffRoleAssignment>> getAssignmentsForRole({
    required String schoolId,
    required String roleDefinitionId,
  }) async {
    final snapshot = await _assignments(
      schoolId,
    ).where('roleDefinitionId', isEqualTo: roleDefinitionId).get();
    return snapshot.docs
        .map((d) => _assignmentFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<StaffRoleAssignment> createAssignment(
    StaffRoleAssignment assignment,
  ) async {
    final ref = assignment.id.isEmpty
        ? _assignments(assignment.schoolId).doc()
        : _assignments(assignment.schoolId).doc(assignment.id);
    final withId = assignment.id.isEmpty
        ? assignment.copyWith(id: ref.id)
        : assignment;
    await ref.set(_assignmentToMap(withId));
    return withId;
  }

  @override
  Future<StaffRoleAssignment> updateAssignment(
    StaffRoleAssignment assignment,
  ) async {
    await _assignments(assignment.schoolId)
        .doc(assignment.id)
        .set(_assignmentToMap(assignment), SetOptions(merge: true));
    return assignment;
  }

  @override
  Future<List<SubjectEnrollment>> getEnrollments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    Query<Map<String, dynamic>> query = _enrollments(schoolId)
        .where('subjectId', isEqualTo: subjectId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId);

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((d) => _enrollmentFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<List<SubjectEnrollment>> getEnrollmentsForStudent({
    required String schoolId,
    required String studentId,
    required String academicYearId,
  }) async {
    final snapshot = await _enrollments(schoolId)
        .where('studentId', isEqualTo: studentId)
        .where('academicYearId', isEqualTo: academicYearId)
        .get();

    return snapshot.docs
        .map((d) => _enrollmentFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<void> createEnrollments(List<SubjectEnrollment> enrollments) async {
    if (enrollments.isEmpty) return;
    final schoolId = enrollments.first.schoolId;
    final batch = firestore.batch();

    for (final enrollment in enrollments) {
      // Deterministic id: one student can hold exactly one enrollment per
      // subject per year, so a double-tap or an offline replay overwrites
      // the same document instead of creating a duplicate row.
      final docId = _enrollmentDocId(enrollment);
      batch.set(
        _enrollments(schoolId).doc(docId),
        _enrollmentToMap(enrollment),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  @override
  Future<void> updateEnrollment(SubjectEnrollment enrollment) async {
    await _enrollments(enrollment.schoolId)
        .doc(
          enrollment.id.isEmpty ? _enrollmentDocId(enrollment) : enrollment.id,
        )
        .set(_enrollmentToMap(enrollment), SetOptions(merge: true));
  }

  @override
  Future<void> writeAuditLog(SubjectAuditLog log) async {
    await _auditLogs(log.schoolId).doc(log.auditId).set(_auditToMap(log));
  }

  @override
  Future<void> writeAuditLogs(List<SubjectAuditLog> logs) async {
    if (logs.isEmpty) return;
    final batch = firestore.batch();
    for (final log in logs) {
      batch.set(_auditLogs(log.schoolId).doc(log.auditId), _auditToMap(log));
    }
    await batch.commit();
  }

  @override
  Future<List<EligibleStudent>> getClassRoster({
    required String schoolId,
    required String classId,
    required String academicYearId,
    String? streamId,
  }) async {
    Query<Map<String, dynamic>> query = firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        // Transferred, withdrawn, graduated and suspended students must not
        // appear in a teaching register.
        .where('status', isEqualTo: 'active');

    if (streamId != null && streamId.isNotEmpty) {
      query = query.where('streamId', isEqualTo: streamId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((d) {
      final data = d.data();
      return EligibleStudent(
        studentId: d.id,
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
      );
    }).toList();
  }

  CollectionReference<Map<String, dynamic>> _lessons(String schoolId) =>
      _school(schoolId).collection('lessons');

  CollectionReference<Map<String, dynamic>> _attendance(String schoolId) =>
      _school(schoolId).collection('lesson_attendance');

  @override
  Future<List<Lesson>> getLessons({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    DateTime? from,
    DateTime? to,
  }) async {
    Query<Map<String, dynamic>> query = _lessons(schoolId)
        .where('subjectId', isEqualTo: subjectId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId);

    if (from != null) {
      query = query.where(
        'scheduledStart',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (to != null) {
      query = query.where(
        'scheduledStart',
        isLessThanOrEqualTo: Timestamp.fromDate(to),
      );
    }

    final snapshot = await query.orderBy('scheduledStart').get();
    return snapshot.docs
        .map((d) => _lessonFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<Lesson?> getLesson({
    required String schoolId,
    required String lessonId,
  }) async {
    final doc = await _lessons(schoolId).doc(lessonId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return _lessonFromDoc(doc.id, schoolId, data);
  }

  @override
  Future<void> updateLesson(
    Lesson lesson, {
    required String roleAssignmentId,
  }) async {
    // Only the fields the panel owns. The timetable owns the schedule, the
    // room and who is assigned - a merge write of the whole entity would let
    // a teacher quietly move their own lesson.
    await _lessons(lesson.schoolId).doc(lesson.id).set({
      'status': lesson.status.name,
      'statusReason': lesson.statusReason,
      if (lesson.actualStart != null)
        'actualStart': Timestamp.fromDate(lesson.actualStart!),
      if (lesson.actualEnd != null)
        'actualEnd': Timestamp.fromDate(lesson.actualEnd!),
      'topic': lesson.topic,
      'subtopic': lesson.subtopic,
      'attendanceSubmitted': lesson.attendanceSubmitted,
      'roleAssignmentId': roleAssignmentId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<LessonAttendance?> getLessonAttendance({
    required String schoolId,
    required String lessonId,
  }) async {
    // Keyed on the lesson id, so there is exactly one register per period.
    final doc = await _attendance(schoolId).doc(lessonId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return _attendanceFromDoc(schoolId, lessonId, data);
  }

  @override
  Future<void> saveLessonAttendance(LessonAttendance attendance) async {
    await _attendance(attendance.schoolId).doc(attendance.lessonId).set({
      'attendanceId': attendance.id,
      'schoolId': attendance.schoolId,
      'campusId': attendance.campusId,
      'lessonId': attendance.lessonId,
      'academicYearId': attendance.academicYearId,
      'termId': attendance.termId,
      'subjectId': attendance.subjectId,
      'classId': attendance.classId,
      'streamId': attendance.streamId,
      'staffId': attendance.staffId,
      'roleAssignmentId': attendance.roleAssignmentId,
      'entries': attendance.entries
          .map(
            (e) => {
              'studentId': e.studentId,
              'status': e.status.name,
              'note': e.note,
              if (e.markedAt != null)
                'markedAt': Timestamp.fromDate(e.markedAt!),
            },
          )
          .toList(),
      'status': attendance.status.name,
      if (attendance.submittedAt != null)
        'submittedAt': Timestamp.fromDate(attendance.submittedAt!),
      'deviceId': attendance.deviceId,
      'presentCount': attendance.presentCount,
      'absentCount': attendance.absentCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

  LessonAttendance _attendanceFromDoc(
    String schoolId,
    String lessonId,
    Map<String, dynamic> data,
  ) {
    final rawEntries = (data['entries'] as List?) ?? const [];
    return LessonAttendance(
      id: data['attendanceId'] as String? ?? lessonId,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      lessonId: lessonId,
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      staffId: data['staffId'] as String? ?? '',
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
      entries: rawEntries.whereType<Map<String, dynamic>>().map((e) {
        return LessonAttendanceEntry(
          studentId: e['studentId'] as String? ?? '',
          status: LessonAttendanceStatus.fromId(e['status'] as String?),
          note: e['note'] as String?,
          markedAt: _toDate(e['markedAt']),
        );
      }).toList(),
      status: AttendanceRegisterStatus.fromId(data['status'] as String?),
      submittedAt: _toDate(data['submittedAt']),
      deviceId: data['deviceId'] as String?,
      updatedAt: _toDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  CollectionReference<Map<String, dynamic>> _assessments(String schoolId) =>
      _school(schoolId).collection('subject_assessments');

  CollectionReference<Map<String, dynamic>> _marks(String schoolId) =>
      _school(schoolId).collection('student_marks');

  @override
  Future<List<SubjectAssessment>> getAssessments({
    required String schoolId,
    required String subjectId,
    required String classId,
    required String academicYearId,
    String? termId,
  }) async {
    Query<Map<String, dynamic>> query = _assessments(schoolId)
        .where('subjectId', isEqualTo: subjectId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId);
    if (termId != null && termId.isNotEmpty) {
      query = query.where('termId', isEqualTo: termId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((d) => _assessmentFromDoc(d.id, schoolId, d.data()))
        .toList();
  }

  @override
  Future<SubjectAssessment> createAssessment({
    required String schoolId,
    required String campusId,
    required String subjectId,
    required String classId,
    String? streamId,
    required String academicYearId,
    required String termId,
    required String title,
    required String assessmentType,
    required double maximumMark,
    required String createdByStaffId,
    required String roleAssignmentId,
  }) async {
    final ref = _assessments(schoolId).doc();
    final componentId = _assessments(schoolId).doc().id;
    final component = {
      'id': componentId,
      'name': title,
      'maximumMark': maximumMark,
      'weight': 100.0,
      'isRequired': true,
      'entryStatus': AssessmentAvailability.open.name,
    };
    await ref.set({
      'schoolId': schoolId,
      'campusId': campusId,
      'subjectId': subjectId,
      'classId': classId,
      'streamId': streamId,
      'academicYearId': academicYearId,
      'termId': termId,
      'assessmentTypeId': assessmentType.toLowerCase().replaceAll(' ', '_'),
      'assessmentTypeName': assessmentType,
      'title': title,
      'maximumMark': maximumMark,
      'status': AssessmentAvailability.open.name,
      'requiresApproval': true,
      'components': [component],
      'roleAssignmentId': roleAssignmentId,
      'createdByStaffId': createdByStaffId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return _assessmentFromDoc(ref.id, schoolId, {
      'schoolId': schoolId,
      'campusId': campusId,
      'subjectId': subjectId,
      'classId': classId,
      'streamId': streamId,
      'academicYearId': academicYearId,
      'termId': termId,
      'assessmentTypeId': assessmentType.toLowerCase().replaceAll(' ', '_'),
      'assessmentTypeName': assessmentType,
      'title': title,
      'maximumMark': maximumMark,
      'status': AssessmentAvailability.open.name,
      'requiresApproval': true,
      'components': [component],
    });
  }

  @override
  Future<List<StudentMarkEntry>> getMarks({
    required String schoolId,
    required String assessmentId,
    required String componentId,
  }) async {
    final snapshot = await _marks(schoolId)
        .where('assessmentId', isEqualTo: assessmentId)
        .where('componentId', isEqualTo: componentId)
        .get();

    return snapshot.docs.map((d) {
      final data = d.data();
      return StudentMarkEntry(
        studentId: data['studentId'] as String? ?? '',
        componentId: data['componentId'] as String? ?? componentId,
        score: (data['score'] as num?)?.toDouble(),
        status: MarkEntryStatus.fromId(data['entryStatus'] as String?),
        remark: data['remark'] as String?,
        enteredAt: _toDate(data['enteredAt']),
      );
    }).toList();
  }

  @override
  Future<List<ClassSubject>> getClassSubjects({
    required String schoolId,
    required String classId,
    required String academicYearId,
  }) async {
    final assignments = await firestore
        .collection('structure_curriculum_assignments')
        .where('schoolId', isEqualTo: schoolId)
        .where('classId', isEqualTo: classId)
        .where('academicYearId', isEqualTo: academicYearId)
        .where('isActive', isEqualTo: true)
        .get();

    final subjectIds = assignments.docs
        .map((d) => d.data()['subjectId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (subjectIds.isEmpty) return const [];

    // Firestore whereIn caps at 30 values - a class's subject list is
    // nowhere near that, so one query covers every real curriculum.
    final subjectsSnapshot = await firestore
        .collection('subjects')
        .where('schoolId', isEqualTo: schoolId)
        .where(FieldPath.documentId, whereIn: subjectIds.toList())
        .get();

    return subjectsSnapshot.docs
        .map(
          (d) =>
              ClassSubject(id: d.id, name: d.data()['name'] as String? ?? d.id),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> saveMarks({
    required String schoolId,
    required SubjectAssessment assessment,
    required AssessmentComponent component,
    required List<StudentMarkEntry> entries,
    required String roleAssignmentId,
    required String staffId,
    required String markStatus,
  }) async {
    if (entries.isEmpty) return;
    final batch = firestore.batch();

    for (final entry in entries) {
      // Deterministic id per student/component: a re-save corrects the same
      // row rather than adding a second mark for the same paper.
      final docId = '${assessment.id}_${component.id}_${entry.studentId}';
      batch.set(_marks(schoolId).doc(docId), {
        'schoolId': schoolId,
        'assessmentId': assessment.id,
        'componentId': component.id,
        'studentId': entry.studentId,
        'subjectId': assessment.subjectId,
        'classId': assessment.classId,
        'streamId': assessment.streamId,
        'academicYearId': assessment.academicYearId,
        'termId': assessment.termId,
        'score': entry.score,
        'entryStatus': entry.status.name,
        'remark': entry.remark,
        'maximumMark': component.maximumMark,
        // Read back by the rules to refuse a teacher overwriting an
        // approved or published mark.
        'markStatus': markStatus,
        'roleAssignmentId': roleAssignmentId,
        'staffId': staffId,
        'enteredAt': Timestamp.fromDate(entry.enteredAt ?? DateTime.now()),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  SubjectAssessment _assessmentFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    final rawComponents = (data['components'] as List?) ?? const [];
    return SubjectAssessment(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      assessmentTypeId: data['assessmentTypeId'] as String? ?? '',
      assessmentTypeName: data['assessmentTypeName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      maximumMark: (data['maximumMark'] as num?)?.toDouble() ?? 100,
      passMark: (data['passMark'] as num?)?.toDouble(),
      gradingSystemId: data['gradingSystemId'] as String?,
      status: AssessmentAvailability.fromId(data['status'] as String?),
      assessmentDate: _toDate(data['assessmentDate']),
      entryOpensAt: _toDate(data['entryOpensAt']),
      submissionDeadline: _toDate(data['submissionDeadline']),
      requiresApproval: data['requiresApproval'] as bool? ?? true,
      components: rawComponents.whereType<Map<String, dynamic>>().map((c) {
        return AssessmentComponent(
          id: c['id'] as String? ?? '',
          assessmentId: id,
          name: c['name'] as String? ?? '',
          maximumMark: (c['maximumMark'] as num?)?.toDouble() ?? 0,
          weight: (c['weight'] as num?)?.toDouble() ?? 0,
          isRequired: c['isRequired'] as bool? ?? true,
          entryStatus: AssessmentAvailability.fromId(
            c['entryStatus'] as String?,
          ),
          deadline: _toDate(c['deadline']),
        );
      }).toList(),
    );
  }

  static String _enrollmentDocId(SubjectEnrollment e) =>
      '${e.studentId}_${e.subjectId}_${e.academicYearId}';

  StaffRoleAssignment _assignmentFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    final scope =
        (data['permissionScope'] as Map<String, dynamic>?) ?? const {};
    return StaffRoleAssignment(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      staffId: data['staffId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      roleDefinitionId: data['roleDefinitionId'] as String? ?? '',
      isPrimary: data['isPrimary'] as bool? ?? false,
      roleType: StaffResponsibilityType.fromId(data['roleType'] as String?),
      academicYearId: data['academicYearId'] as String? ?? '',
      termId: data['termId'] as String?,
      subjectId: data['subjectId'] as String?,
      subjectName: data['subjectName'] as String?,
      classId: data['classId'] as String?,
      className: data['className'] as String?,
      streamId: data['streamId'] as String?,
      streamName: data['streamName'] as String?,
      departmentId: data['departmentId'] as String?,
      houseId: data['houseId'] as String?,
      startDate: _toDate(data['startDate']) ?? DateTime(1970),
      endDate: _toDate(data['endDate']),
      status: AssignmentStatus.fromId(data['status'] as String?),
      permissionScope: PermissionScope(
        permissions: _toStringSet(scope['permissions']),
        subjectId: data['subjectId'] as String?,
        classId: data['classId'] as String?,
        streamId: data['streamId'] as String?,
        departmentId: data['departmentId'] as String?,
        academicYearId: data['academicYearId'] as String? ?? '',
        termIds: _toStringSet(scope['termIds']),
      ),
      substituteForStaffId: data['substituteForStaffId'] as String?,
      extraScope:
          (data['extraScope'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
      assignedBy: data['assignedBy'] as String? ?? '',
      assignedAt: _toDate(data['assignedAt']) ?? DateTime(1970),
      updatedBy: data['updatedBy'] as String?,
      updatedAt: _toDate(data['updatedAt']),
      monthlyBonusAmount: (data['monthlyBonusAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _assignmentToMap(StaffRoleAssignment a) {
    return {
      'schoolId': a.schoolId,
      'campusId': a.campusId,
      'staffId': a.staffId,
      'userId': a.userId,
      'roleDefinitionId': a.roleDefinitionId,
      'isPrimary': a.isPrimary,
      'roleType': a.roleType.name,
      'academicYearId': a.academicYearId,
      'termId': a.termId,
      'subjectId': a.subjectId,
      'subjectName': a.subjectName,
      'classId': a.classId,
      'className': a.className,
      'streamId': a.streamId,
      'streamName': a.streamName,
      'departmentId': a.departmentId,
      'houseId': a.houseId,
      'startDate': Timestamp.fromDate(a.startDate),
      if (a.endDate != null) 'endDate': Timestamp.fromDate(a.endDate!),
      'status': a.status.name,
      'permissionScope': {
        'permissions': a.permissionScope.permissions.toList(),
        'termIds': a.permissionScope.termIds.toList(),
      },
      if (a.substituteForStaffId != null)
        'substituteForStaffId': a.substituteForStaffId,
      'extraScope': a.extraScope,
      'assignedBy': a.assignedBy,
      'assignedAt': Timestamp.fromDate(a.assignedAt),
      if (a.updatedBy != null) 'updatedBy': a.updatedBy,
      'updatedAt': Timestamp.now(),
      if (a.monthlyBonusAmount != null)
        'monthlyBonusAmount': a.monthlyBonusAmount,
    };
  }

  SubjectEnrollment _enrollmentFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    return SubjectEnrollment(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      classId: data['classId'] as String? ?? '',
      streamId: data['streamId'] as String?,
      academicYearId: data['academicYearId'] as String? ?? '',
      status: SubjectEnrollmentStatus.fromId(data['status'] as String?),
      roleAssignmentId: data['roleAssignmentId'] as String? ?? '',
      isMandatory: data['isMandatory'] as bool? ?? false,
      enrolledAt: _toDate(data['enrolledAt']) ?? DateTime(1970),
      enrolledBy: data['enrolledBy'] as String? ?? '',
      removedAt: _toDate(data['removedAt']),
      removedBy: data['removedBy'] as String?,
      removalReason: data['removalReason'] as String?,
      effectiveFrom: _toDate(data['effectiveFrom']),
      effectiveTo: _toDate(data['effectiveTo']),
    );
  }

  Map<String, dynamic> _enrollmentToMap(SubjectEnrollment e) {
    return {
      'schoolId': e.schoolId,
      'campusId': e.campusId,
      'studentId': e.studentId,
      'subjectId': e.subjectId,
      'classId': e.classId,
      'streamId': e.streamId,
      'academicYearId': e.academicYearId,
      'status': e.status.name,
      // The rules read this back to confirm the writer held an assignment
      // covering this subject and class.
      'roleAssignmentId': e.roleAssignmentId,
      'isMandatory': e.isMandatory,
      'enrolledAt': Timestamp.fromDate(e.enrolledAt),
      'enrolledBy': e.enrolledBy,
      if (e.removedAt != null) 'removedAt': Timestamp.fromDate(e.removedAt!),
      if (e.removedBy != null) 'removedBy': e.removedBy,
      if (e.removalReason != null) 'removalReason': e.removalReason,
      if (e.effectiveFrom != null)
        'effectiveFrom': Timestamp.fromDate(e.effectiveFrom!),
      if (e.effectiveTo != null)
        'effectiveTo': Timestamp.fromDate(e.effectiveTo!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _auditToMap(SubjectAuditLog log) {
    return {
      'schoolId': log.schoolId,
      'campusId': log.campusId,
      'userId': log.userId,
      'staffId': log.staffId,
      'roleAssignmentId': log.roleAssignmentId,
      'activeRole': log.activeRole.name,
      'subjectId': log.subjectId,
      'classId': log.classId,
      'streamId': log.streamId,
      'academicYearId': log.academicYearId,
      'termId': log.termId,
      'action': log.action,
      'entityType': log.entityType,
      'entityId': log.entityId,
      'previousValue': log.previousValue,
      'newValue': log.newValue,
      'reason': log.reason,
      // The client clock is recorded too, because an offline action replayed
      // hours later would otherwise be stamped with the replay time and look
      // like it happened then.
      'clientTimestamp': Timestamp.fromDate(log.timestamp),
      'timestamp': FieldValue.serverTimestamp(),
      'deviceId': log.deviceId,
      'platform': log.platform,
      'offlineOperationId': log.offlineOperationId,
    };
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Set<String> _toStringSet(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toSet();
    return const {};
  }
}
