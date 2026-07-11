import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/core/utils.dart';
import '../models/student_model.dart';
import '../models/parent_access_code_model.dart';

abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getStudentsByIds(List<String> ids);
  Future<List<StudentModel>> getAllStudents();

  /// Looks up a family access code (e.g. "KHA1234"). Returns null if the
  /// code doesn't exist. This is called before the parent has signed in, so
  /// it relies only on the denormalized fields on the code doc itself
  /// (never touches the students collection, which requires auth).
  Future<ParentAccessCodeModel?> resolveAccessCode(String code);

  Future<List<ParentAccessCodeModel>> getAllAccessCodes();
  Future<String> createAccessCode({required List<String> studentIds, String? parentName});
  Future<String> regenerateAccessCode(String oldCode);
  Future<void> toggleAccessCodeStatus(String code, bool isActive);
  Future<void> createStudent(StudentModel student);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final FirebaseFirestore firestore;

  StudentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createStudent(StudentModel student) async {
    await firestore.collection('students').doc(student.id).set(student.toFirestore());
  }

  @override
  Future<List<StudentModel>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final docs = await Future.wait(
      ids.map((id) => firestore.collection('students').doc(id).get()),
    );
    return docs
        .where((doc) => doc.exists)
        .map((doc) => StudentModel.fromFirestore(doc.data()!, doc.id))
        .toList();
  }

  @override
  Future<List<StudentModel>> getAllStudents() async {
    final snapshot = await firestore.collection('students').get();
    return snapshot.docs.map((doc) => StudentModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<ParentAccessCodeModel?> resolveAccessCode(String code) async {
    final doc = await firestore.collection('parent_access_codes').doc(code).get();
    if (!doc.exists) return null;
    return ParentAccessCodeModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<List<ParentAccessCodeModel>> getAllAccessCodes() async {
    final snapshot = await firestore.collection('parent_access_codes').get();
    return snapshot.docs.map((doc) => ParentAccessCodeModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<String> createAccessCode({required List<String> studentIds, String? parentName}) async {
    final students = await getStudentsByIds(studentIds);
    final studentNames = students.map((s) => s.name).toList();
    return _writeNewCode(studentIds: studentIds, studentNames: studentNames, parentName: parentName);
  }

  @override
  Future<String> regenerateAccessCode(String oldCode) async {
    final oldDoc = await firestore.collection('parent_access_codes').doc(oldCode).get();
    if (!oldDoc.exists) {
      throw Exception('Access code not found');
    }
    final existing = ParentAccessCodeModel.fromFirestore(oldDoc.data()!, oldDoc.id);
    // Reuse the already-denormalized names instead of re-fetching every
    // student doc - they were only just read when the old code was created.
    final newCode = await _writeNewCode(
      studentIds: existing.studentIds,
      studentNames: existing.studentNames,
      parentName: existing.parentName,
    );
    await firestore.collection('parent_access_codes').doc(oldCode).delete();
    return newCode;
  }

  @override
  Future<void> toggleAccessCodeStatus(String code, bool isActive) async {
    await firestore.collection('parent_access_codes').doc(code).update({'isActive': isActive});
  }

  Future<String> _writeNewCode({
    required List<String> studentIds,
    required List<String> studentNames,
    String? parentName,
  }) async {
    String code;
    DocumentSnapshot<Map<String, dynamic>> existing;
    do {
      code = AccessCodeGenerator.generate();
      existing = await firestore.collection('parent_access_codes').doc(code).get();
    } while (existing.exists);

    final model = ParentAccessCodeModel(
      code: code,
      studentIds: studentIds,
      studentNames: studentNames,
      parentName: parentName,
    );
    await firestore.collection('parent_access_codes').doc(code).set(model.toFirestore());
    return code;
  }
}
