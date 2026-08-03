import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_student_relationship_model.dart';
import '../models/people_policy_model.dart';
import '../models/student_enrolment_model.dart';

abstract class RelationshipRemoteDataSource {
  Future<List<ParentStudentRelationshipModel>> getRelationshipsForStudent(String schoolId, String studentId);
  Future<List<ParentStudentRelationshipModel>> getRelationshipsForParent(String schoolId, String userId);
  Future<ParentStudentRelationshipModel> createRelationship(Map<String, dynamic> data);
  Future<ParentStudentRelationshipModel> getRelationshipById(String id);
  Future<void> supersedeRelationship(String id, Map<String, dynamic> data);

  Future<PeoplePolicyModel> getPeoplePolicy(String schoolId);
  Future<void> updatePeoplePolicy(String schoolId, Map<String, dynamic> data);

  Future<void> createEnrolment(Map<String, dynamic> data);
  Future<void> endActiveEnrolment(String schoolId, String studentId);
  Future<List<StudentEnrolmentModel>> getEnrolmentHistory(String schoolId, String studentId);
}

class RelationshipRemoteDataSourceImpl implements RelationshipRemoteDataSource {
  final FirebaseFirestore firestore;

  RelationshipRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _relationships =>
      firestore.collection('parent_student_relationships');

  CollectionReference<Map<String, dynamic>> get _enrolments => firestore.collection('student_enrolments');

  DocumentReference<Map<String, dynamic>> _policyDoc(String schoolId) =>
      firestore.collection('people_policies').doc(schoolId);

  @override
  Future<List<ParentStudentRelationshipModel>> getRelationshipsForStudent(
    String schoolId,
    String studentId,
  ) async {
    final snapshot = await _relationships
        .where('schoolId', isEqualTo: schoolId)
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs.map((d) => ParentStudentRelationshipModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<List<ParentStudentRelationshipModel>> getRelationshipsForParent(
    String schoolId,
    String userId,
  ) async {
    final snapshot = await _relationships
        .where('schoolId', isEqualTo: schoolId)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((d) => ParentStudentRelationshipModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<ParentStudentRelationshipModel> createRelationship(Map<String, dynamic> data) async {
    final ref = await _relationships.add(data);
    final snapshot = await ref.get();
    return ParentStudentRelationshipModel.fromMap(snapshot.id, snapshot.data()!);
  }

  @override
  Future<ParentStudentRelationshipModel> getRelationshipById(String id) async {
    final snapshot = await _relationships.doc(id).get();
    return ParentStudentRelationshipModel.fromMap(snapshot.id, snapshot.data()!);
  }

  @override
  Future<void> supersedeRelationship(String id, Map<String, dynamic> data) {
    return _relationships.doc(id).update(data);
  }

  @override
  Future<PeoplePolicyModel> getPeoplePolicy(String schoolId) async {
    final snapshot = await _policyDoc(schoolId).get();
    if (!snapshot.exists) {
      return PeoplePolicyModel(schoolId: schoolId);
    }
    return PeoplePolicyModel.fromMap(schoolId, snapshot.data()!);
  }

  @override
  Future<void> updatePeoplePolicy(String schoolId, Map<String, dynamic> data) {
    return _policyDoc(schoolId).set(data, SetOptions(merge: true));
  }

  @override
  Future<void> createEnrolment(Map<String, dynamic> data) {
    return _enrolments.add(data);
  }

  @override
  Future<void> endActiveEnrolment(String schoolId, String studentId) async {
    final snapshot = await _enrolments
        .where('schoolId', isEqualTo: schoolId)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'active')
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'status': 'ended',
        'endDate': Timestamp.now(),
      });
    }
  }

  @override
  Future<List<StudentEnrolmentModel>> getEnrolmentHistory(String schoolId, String studentId) async {
    final snapshot = await _enrolments
        .where('schoolId', isEqualTo: schoolId)
        .where('studentId', isEqualTo: studentId)
        .get();
    final results = snapshot.docs.map((d) => StudentEnrolmentModel.fromMap(d.id, d.data())).toList();
    results.sort((a, b) => b.startDate.compareTo(a.startDate));
    return results;
  }
}
