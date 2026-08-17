import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/repositories/teaching_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';

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
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> saveAssignment(TeachingAssignment assignment) async {
    final schoolId = await tenantResolver.resolve();
    if (assignment.staffId.trim().isEmpty ||
        assignment.academicYearId.trim().isEmpty) {
      throw StateError('Staff member and academic year are required.');
    }

    final staffDoc =
        await firestore.collection('users').doc(assignment.staffId).get();
    final staffData = staffDoc.data();
    if (!staffDoc.exists || staffData?['schoolId']?.toString() != schoolId) {
      throw StateError('The selected staff member does not belong to this school.');
    }
    if (staffData?['isActive'] == false) {
      throw StateError('The selected staff account is inactive.');
    }

    switch (assignment.responsibilityType) {
      case TeachingResponsibilityType.subjectTeacher:
        if (assignment.classId.isEmpty || assignment.subjectId.isEmpty) {
          throw StateError('Subject Teacher requires a class and subject.');
        }
        await _validateSubjectTeacherCurriculum(assignment, schoolId);
        break;
      case TeachingResponsibilityType.classTeacher:
        if (assignment.classId.isEmpty) {
          throw StateError('Class Teacher requires a class.');
        }
        break;
      case TeachingResponsibilityType.headOfDepartment:
        if (assignment.departmentId.isEmpty) {
          throw StateError('Head of Department requires a department.');
        }
        break;
    }

    final exact = await _collection
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: assignment.academicYearId)
        .where('staffId', isEqualTo: assignment.staffId)
        .where(
          'responsibilityType',
          isEqualTo: assignment.responsibilityType.name,
        )
        .where('classId', isEqualTo: assignment.classId)
        .where('streamId', isEqualTo: assignment.streamId)
        .where('subjectId', isEqualTo: assignment.subjectId)
        .where('departmentId', isEqualTo: assignment.departmentId)
        .where('isActive', isEqualTo: true)
        .get();
    if (exact.docs.any((doc) => doc.id != assignment.id)) {
      throw StateError('This staff responsibility is already assigned.');
    }

    if (assignment.responsibilityType ==
        TeachingResponsibilityType.classTeacher) {
      final target = await _collection
          .where('schoolId', isEqualTo: schoolId)
          .where('academicYearId', isEqualTo: assignment.academicYearId)
          .where(
            'responsibilityType',
            isEqualTo: TeachingResponsibilityType.classTeacher.name,
          )
          .where('classId', isEqualTo: assignment.classId)
          .where('streamId', isEqualTo: assignment.streamId)
          .where('isActive', isEqualTo: true)
          .get();
      if (target.docs.any((doc) => doc.id != assignment.id)) {
        throw StateError(
          'This class/stream already has an active Class Teacher.',
        );
      }

      final staffPrimary = await _collection
          .where('schoolId', isEqualTo: schoolId)
          .where('academicYearId', isEqualTo: assignment.academicYearId)
          .where(
            'responsibilityType',
            isEqualTo: TeachingResponsibilityType.classTeacher.name,
          )
          .where('staffId', isEqualTo: assignment.staffId)
          .where('isActive', isEqualTo: true)
          .get();
      if (staffPrimary.docs.any((doc) => doc.id != assignment.id)) {
        throw StateError(
          'This staff member is already an active Class Teacher for another class/stream in this academic year.',
        );
      }
    }

    await _collection.doc(assignment.id).set({
      'schoolId': schoolId,
      'staffId': assignment.staffId,
      'academicYearId': assignment.academicYearId,
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _validateSubjectTeacherCurriculum(
    TeachingAssignment assignment,
    String schoolId,
  ) async {
    final snapshot = await _curriculum
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: assignment.academicYearId)
        .where('classId', isEqualTo: assignment.classId)
        .where('subjectId', isEqualTo: assignment.subjectId)
        .where('isActive', isEqualTo: true)
        .get();
    final valid = snapshot.docs.any((doc) {
      final curriculumStream = doc.data()['streamId']?.toString() ?? '';
      return curriculumStream.isEmpty ||
          curriculumStream == assignment.streamId;
    });
    if (!valid) {
      throw StateError(
        'Allocate this subject to the class/stream curriculum before assigning a Subject Teacher.',
      );
    }
  }

  @override
  Future<void> endAssignment(String assignmentId, {DateTime? endDate}) async {
    final schoolId = await tenantResolver.resolve();
    final ref = _collection.doc(assignmentId);
    final snapshot = await ref.get();
    if (!snapshot.exists ||
        snapshot.data()?['schoolId']?.toString() != schoolId) {
      throw StateError('Teaching assignment not found in the active school.');
    }
    await ref.update({
      'isActive': false,
      'endDate': Timestamp.fromDate(endDate ?? DateTime.now()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  TeachingAssignment _fromMap(String id, Map<String, dynamic> map) {
    final typeName = map['responsibilityType']?.toString() ??
        TeachingResponsibilityType.subjectTeacher.name;
    final type = TeachingResponsibilityType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => TeachingResponsibilityType.subjectTeacher,
    );
    return TeachingAssignment(
      id: id,
      schoolId: map['schoolId']?.toString() ?? '',
      staffId: map['staffId']?.toString() ?? '',
      academicYearId: map['academicYearId']?.toString() ?? '',
      responsibilityType: type,
      departmentId: map['departmentId']?.toString() ?? '',
      classId: map['classId']?.toString() ?? '',
      streamId: map['streamId']?.toString() ?? '',
      subjectId: map['subjectId']?.toString() ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      isPrimary: map['isPrimary'] == true,
      isActive: map['isActive'] != false,
    );
  }
}
