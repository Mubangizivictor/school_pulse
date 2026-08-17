import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';

class CurriculumAssignmentRepositoryImpl
    implements CurriculumAssignmentRepository {
  final FirebaseFirestore firestore;
  final StructureTenantResolver tenantResolver;

  CurriculumAssignmentRepositoryImpl({
    required this.firestore,
    required this.tenantResolver,
  });

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('structure_curriculum_assignments');

  @override
  Stream<List<CurriculumAssignment>> watchAssignments() async* {
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
  Future<void> saveAssignment(CurriculumAssignment assignment) async {
    final schoolId = await tenantResolver.resolve();
    if (assignment.academicYearId.isEmpty ||
        assignment.levelId.isEmpty ||
        assignment.classId.isEmpty ||
        assignment.subjectId.isEmpty) {
      throw StateError(
        'Academic year, level, class and subject are required for curriculum allocation.',
      );
    }
    if (assignment.periodsPerWeek < 0) {
      throw StateError('Periods per week cannot be negative.');
    }

    final duplicates = await _collection
        .where('schoolId', isEqualTo: schoolId)
        .where('academicYearId', isEqualTo: assignment.academicYearId)
        .where('classId', isEqualTo: assignment.classId)
        .where('streamId', isEqualTo: assignment.streamId)
        .where('subjectId', isEqualTo: assignment.subjectId)
        .where('isActive', isEqualTo: true)
        .get();
    if (duplicates.docs.any((doc) => doc.id != assignment.id)) {
      throw StateError(
        'This subject is already allocated to the selected class/stream for this academic year.',
      );
    }

    await _collection.doc(assignment.id).set({
      'schoolId': schoolId,
      'academicYearId': assignment.academicYearId,
      'levelId': assignment.levelId,
      'classId': assignment.classId,
      'streamId': assignment.streamId,
      'subjectId': assignment.subjectId,
      'isCompulsory': assignment.isCompulsory,
      'periodsPerWeek': assignment.periodsPerWeek,
      'displayOrder': assignment.displayOrder,
      'isActive': assignment.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deactivateAssignment(String assignmentId) async {
    final schoolId = await tenantResolver.resolve();
    final ref = _collection.doc(assignmentId);
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data()?['schoolId'] != schoolId) {
      throw StateError('Curriculum assignment not found in the active school.');
    }
    await ref.update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  CurriculumAssignment _fromMap(String id, Map<String, dynamic> map) =>
      CurriculumAssignment(
        id: id,
        schoolId: map['schoolId']?.toString() ?? '',
        academicYearId: map['academicYearId']?.toString() ?? '',
        levelId: map['levelId']?.toString() ?? '',
        classId: map['classId']?.toString() ?? '',
        streamId: map['streamId']?.toString() ?? '',
        subjectId: map['subjectId']?.toString() ?? '',
        isCompulsory: map['isCompulsory'] != false,
        periodsPerWeek: (map['periodsPerWeek'] as num?)?.toInt() ?? 0,
        displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
        isActive: map['isActive'] != false,
      );
}
