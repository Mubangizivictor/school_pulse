import 'package:cloud_firestore/cloud_firestore.dart';

/// Cheap, single-collection reference counts used to decide whether a
/// Structure record (Level, Class, Department, Campus) is safe to delete
/// outright or should be archived instead. Deliberately shallow - no
/// cross-collection graph traversal, no recursive dependency resolution.
/// Counts of 0 are only ever a real "unused" signal, never a false
/// positive standing in for "not implemented yet" (see the Department/
/// Campus stubs below, which are honestly documented as always-0 until a
/// later phase adds the field they'd need to query on).
class StructureDependencyService {
  final FirebaseFirestore firestore;

  StructureDependencyService({required this.firestore});

  Future<int> countStudentsInClass(String schoolId, String classId) async {
    final snap = await firestore
        .collection('students')
        .where('schoolId', isEqualTo: schoolId)
        .where('classId', isEqualTo: classId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<int> countClassesInLevel(String schoolId, String levelId) async {
    final snap = await firestore
        .collection('classes')
        .where('schoolId', isEqualTo: schoolId)
        .where('levelId', isEqualTo: levelId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Students don't carry a levelId directly (only classId) - so "students
  /// in this level" is the sum of students in each class under it, not a
  /// single indexed query. Cheap enough at Structure-module scale (a
  /// handful of classes per level), so this stays a client-side fan-out
  /// rather than a denormalized levelId field on Student for this phase.
  Future<int> countStudentsInLevel(String schoolId, String levelId) async {
    final classesSnap = await firestore
        .collection('classes')
        .where('schoolId', isEqualTo: schoolId)
        .where('levelId', isEqualTo: levelId)
        .get();
    if (classesSnap.docs.isEmpty) return 0;
    var total = 0;
    for (final classDoc in classesSnap.docs) {
      total += await countStudentsInClass(schoolId, classDoc.id);
    }
    return total;
  }

  /// Staff profiles carry their Structure department ID. Count the actual
  /// tenant-scoped references before allowing a department to be deleted.
  Future<int> countStaffInDepartment(
    String schoolId,
    String departmentId,
  ) async {
    final snap = await firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('departmentId', isEqualTo: departmentId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Staff profiles also carry their assigned campus. This guards campus
  /// deletion against removing a live reference; other campus-aware modules
  /// can add their own checks here as they become canonical.
  Future<int> countCampusReferences(String schoolId, String campusId) async {
    final snap = await firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .where('campusId', isEqualTo: campusId)
        .count()
        .get();
    return snap.count ?? 0;
  }
}
