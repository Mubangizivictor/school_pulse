import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/staff_role_assignment.dart';
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
}

class SubjectTeacherRemoteDataSourceImpl implements SubjectTeacherRemoteDataSource {
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
        .where('status', whereIn: [
          AssignmentStatus.active.name,
          AssignmentStatus.suspended.name,
        ])
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
        .where('status', whereIn: [
          AssignmentStatus.active.name,
          AssignmentStatus.suspended.name,
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => _assignmentFromDoc(d.id, schoolId, d.data()))
            .toList());
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
        .doc(enrollment.id.isEmpty ? _enrollmentDocId(enrollment) : enrollment.id)
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
        admissionNumber: data['admissionNumber'] as String? ??
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

  static String _enrollmentDocId(SubjectEnrollment e) =>
      '${e.studentId}_${e.subjectId}_${e.academicYearId}';

  StaffRoleAssignment _assignmentFromDoc(
    String id,
    String schoolId,
    Map<String, dynamic> data,
  ) {
    final scope = (data['permissionScope'] as Map<String, dynamic>?) ?? const {};
    return StaffRoleAssignment(
      id: id,
      schoolId: schoolId,
      campusId: data['campusId'] as String? ?? '',
      staffId: data['staffId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
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
      assignedBy: data['assignedBy'] as String? ?? '',
      assignedAt: _toDate(data['assignedAt']) ?? DateTime(1970),
      updatedBy: data['updatedBy'] as String?,
      updatedAt: _toDate(data['updatedAt']),
    );
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
      if (e.effectiveFrom != null) 'effectiveFrom': Timestamp.fromDate(e.effectiveFrom!),
      if (e.effectiveTo != null) 'effectiveTo': Timestamp.fromDate(e.effectiveTo!),
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
