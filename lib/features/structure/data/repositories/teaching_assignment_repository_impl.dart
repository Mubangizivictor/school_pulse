// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/repositories/teaching_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';

/// Tenant-bound persistence for academic duties. Ended duties remain as audit
/// records; the repository never deletes or repurposes historical rows.
class TeachingAssignmentRepositoryImpl implements TeachingAssignmentRepository {
  final FirebaseFirestore firestore;
  final StructureTenantResolver tenantResolver;
  TeachingAssignmentRepositoryImpl({
    required this.firestore,
    required this.tenantResolver,
  });
  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('structure_teaching_assignments');
  CollectionReference<Map<String, dynamic>> get _curriculum =>
      firestore.collection('structure_curriculum_assignments');

  @override
  Stream<List<TeachingAssignment>> watchAssignments() async* {
    final schoolId = await tenantResolver.resolve();
    yield* _collection
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => _fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> saveAssignment(TeachingAssignment assignment) async {
    final schoolId = await tenantResolver.resolve();
    if (assignment.staffId.trim().isEmpty ||
        assignment.academicYearId.trim().isEmpty ||
        assignment.academicTermId.trim().isEmpty) {
      throw StateError('Staff member, academic year and term are required.');
    }
    final staffDoc = await firestore
        .collection('users')
        .doc(assignment.staffId)
        .get();
    final staff = staffDoc.data();
    if (!staffDoc.exists || staff?['schoolId']?.toString() != schoolId)
      throw StateError(
        'The selected staff member does not belong to this school.',
      );
    if (staff?['isActive'] == false)
      throw StateError('The selected staff account is inactive.');
    final existing = await _collection.doc(assignment.id).get();
    if (existing.exists &&
        existing.data()?['schoolId']?.toString() != schoolId) {
      throw StateError(
        'Academic responsibility not found in the active school.',
      );
    }
    // Responsibility rows are audit records. Scope changes must be modelled
    // as ending the old row and creating a new one, never by rewriting a
    // historical assignment that may be referenced by marks or timetables.
    if (existing.exists) {
      throw StateError(
        'Existing academic responsibilities cannot be overwritten. End it and create a new assignment instead.',
      );
    }
    await _validateScope(assignment, schoolId);

    final active = await _activeForTerm(
      schoolId,
      assignment.academicYearId,
      assignment.academicTermId,
    );
    final others = active.where((row) => row.id != assignment.id).toList();
    final duplicate = others.any(
      (row) =>
          row.staffId == assignment.staffId &&
          row.responsibilityType == assignment.responsibilityType &&
          row.departmentId == assignment.departmentId &&
          row.classId == assignment.classId &&
          row.streamId == assignment.streamId &&
          row.subjectId == assignment.subjectId,
    );
    if (duplicate)
      throw StateError(
        'This staff responsibility is already assigned for this term.',
      );
    if (assignment.responsibilityType ==
            TeachingResponsibilityType.classTeacher ||
        assignment.responsibilityType ==
            TeachingResponsibilityType.streamTeacher) {
      final conflicts = others
          .where(
            (row) => row.responsibilityType == assignment.responsibilityType,
          )
          .toList();
      if (conflicts.any(
        (row) =>
            row.classId == assignment.classId &&
            row.streamId == assignment.streamId,
      ))
        throw StateError(
          'This class/stream already has an active ${_label(assignment.responsibilityType)}.',
        );
      if (conflicts.any((row) => row.staffId == assignment.staffId))
        throw StateError(
          'This staff member is already an active ${_label(assignment.responsibilityType)} for another class/stream in this term.',
        );
    }
    await _collection.doc(assignment.id).set({
      'schoolId': schoolId,
      'staffId': assignment.staffId,
      'academicYearId': assignment.academicYearId,
      'academicTermId': assignment.academicTermId,
      'designationId': assignment.designationId,
      'responsibilityType': assignment.responsibilityType.name,
      'departmentId': assignment.departmentId,
      'classId': assignment.classId,
      'streamId': assignment.streamId,
      'subjectId': assignment.subjectId,
      'startDate': assignment.startDate == null
          ? null
          : Timestamp.fromDate(assignment.startDate!),
      'endDate': assignment.endDate == null
          ? null
          : Timestamp.fromDate(assignment.endDate!),
      'isPrimary': assignment.isPrimary,
      'isActive': assignment.isActive,
      'assignedBy': assignment.assignedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _validateScope(
    TeachingAssignment assignment,
    String schoolId,
  ) async {
    switch (assignment.responsibilityType) {
      case TeachingResponsibilityType.subjectTeacher:
        if (assignment.classId.isEmpty || assignment.subjectId.isEmpty)
          throw StateError('Subject Teacher requires a class and subject.');
        await _validateSubjectTeacherCurriculum(assignment, schoolId);
      case TeachingResponsibilityType.classTeacher:
      case TeachingResponsibilityType.streamTeacher:
        if (assignment.classId.isEmpty)
          throw StateError(
            '${_label(assignment.responsibilityType)} requires a class.',
          );
      case TeachingResponsibilityType.headOfDepartment:
        if (assignment.departmentId.isEmpty)
          throw StateError('Head of Department requires a department.');
      case TeachingResponsibilityType.directorOfStudies:
      case TeachingResponsibilityType.academicCoordinator:
      case TeachingResponsibilityType.examinationsOfficer:
      case TeachingResponsibilityType.timetableCoordinator:
      case TeachingResponsibilityType.assessmentReportsCoordinator:
        break;
    }
  }

  Future<List<TeachingAssignment>> _activeForTerm(
    String schoolId,
    String yearId,
    String termId,
  ) async {
    final rows = await _collection.where('schoolId', isEqualTo: schoolId).get();
    return rows.docs
        .map((doc) => _fromMap(doc.id, doc.data()))
        .where(
          (row) =>
              row.isActive &&
              row.academicYearId == yearId &&
              row.academicTermId == termId,
        )
        .toList(growable: false);
  }

  Future<void> _validateSubjectTeacherCurriculum(
    TeachingAssignment assignment,
    String schoolId,
  ) async {
    final snap = await _curriculum
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: assignment.academicYearId)
        .where('classId', isEqualTo: assignment.classId)
        .where('subjectId', isEqualTo: assignment.subjectId)
        .where('isActive', isEqualTo: true)
        .get();
    final valid = snap.docs.any((doc) {
      final stream = doc.data()['streamId']?.toString() ?? '';
      return stream.isEmpty || stream == assignment.streamId;
    });
    if (!valid)
      throw StateError(
        'Allocate this subject to the class/stream curriculum before assigning a Subject Teacher.',
      );
  }

  @override
  Future<void> endAssignment(String assignmentId, {DateTime? endDate}) async {
    final schoolId = await tenantResolver.resolve();
    final ref = _collection.doc(assignmentId);
    final snap = await ref.get();
    if (!snap.exists || snap.data()?['schoolId']?.toString() != schoolId)
      throw StateError(
        'Academic responsibility not found in the active school.',
      );
    await ref.update({
      'isActive': false,
      'endDate': Timestamp.fromDate(endDate ?? DateTime.now()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  TeachingAssignment _fromMap(String id, Map<String, dynamic> map) {
    final type = TeachingResponsibilityType.values.firstWhere(
      (item) => item.name == map['responsibilityType']?.toString(),
      orElse: () => TeachingResponsibilityType.subjectTeacher,
    );
    return TeachingAssignment(
      id: id,
      schoolId: map['schoolId']?.toString() ?? '',
      staffId: map['staffId']?.toString() ?? '',
      academicYearId: map['academicYearId']?.toString() ?? '',
      academicTermId: map['academicTermId']?.toString() ?? '',
      designationId: map['designationId']?.toString() ?? '',
      responsibilityType: type,
      departmentId: map['departmentId']?.toString() ?? '',
      classId: map['classId']?.toString() ?? '',
      streamId: map['streamId']?.toString() ?? '',
      subjectId: map['subjectId']?.toString() ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      isPrimary: map['isPrimary'] == true,
      isActive: map['isActive'] != false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      assignedBy: map['assignedBy']?.toString() ?? '',
    );
  }

  String _label(TeachingResponsibilityType type) => switch (type) {
    TeachingResponsibilityType.subjectTeacher => 'Subject Teacher',
    TeachingResponsibilityType.classTeacher => 'Class Teacher',
    TeachingResponsibilityType.streamTeacher => 'Stream Teacher',
    TeachingResponsibilityType.headOfDepartment => 'Head of Department',
    TeachingResponsibilityType.directorOfStudies => 'Director of Studies',
    TeachingResponsibilityType.academicCoordinator => 'Academic Coordinator',
    TeachingResponsibilityType.examinationsOfficer => 'Examinations Officer',
    TeachingResponsibilityType.timetableCoordinator => 'Timetable Coordinator',
    TeachingResponsibilityType.assessmentReportsCoordinator =>
      'Assessment & Reports Coordinator',
  };
}
