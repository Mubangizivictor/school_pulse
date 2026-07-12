import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_class.dart';

class SchoolStructureRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SchoolClass>> watchClasses() {
    return _firestore
        .collection('classes')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => SchoolClass.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addClass(SchoolClass schoolClass) {
    return _firestore.collection('classes').add(schoolClass.toMap());
  }

  Future<void> updateClass(SchoolClass schoolClass) {
    return _firestore.collection('classes').doc(schoolClass.id).update(schoolClass.toMap());
  }

  Stream<List<Department>> watchDepartments() {
    return _firestore
        .collection('departments')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => Department.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addDepartment(Department department) {
    return _firestore.collection('departments').add(department.toMap());
  }

  Future<void> updateDepartment(Department department) {
    return _firestore.collection('departments').doc(department.id).update(department.toMap());
  }
}
