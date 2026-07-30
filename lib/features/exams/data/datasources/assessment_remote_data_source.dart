import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_type_model.dart';
import '../models/grading_system_model.dart';
import '../models/assessment_mark_model.dart';
import '../models/report_template_model.dart';
import '../models/report_release_policy_model.dart';
import '../../domain/entities/report_release_policy.dart';

abstract class AssessmentRemoteDataSource {
  Future<List<AssessmentTypeModel>> getAssessmentTypes(String schoolId);
  Future<void> createAssessmentType(String schoolId, AssessmentTypeModel assessmentType);
  
  Future<List<GradingSystemModel>> getGradingSystems(String schoolId);
  Future<void> createGradingSystem(GradingSystemModel gradingSystem);

  Future<List<AssessmentMarkModel>> getMarks({
    required String schoolId,
    String? assessmentTypeId,
    String? subjectId,
    String? classId,
    String? studentId,
  });
  Future<void> saveMarks(String schoolId, List<AssessmentMarkModel> marks);
  Future<void> updateMarkStatus(String schoolId, List<String> markIds, String status, {String? userId});

  Future<List<ReportTemplateModel>> getReportTemplates(String schoolId);
  Future<void> saveReportTemplate(ReportTemplateModel template);

  Future<ReportReleasePolicyModel> getReleasePolicy(String schoolId);
  Future<void> updateReleasePolicy(ReportReleasePolicyModel policy);
}

class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  final FirebaseFirestore firestore;

  AssessmentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AssessmentTypeModel>> getAssessmentTypes(String schoolId) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('assessment_types')
        .get();
    return snapshot.docs
        .map((doc) => AssessmentTypeModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> createAssessmentType(String schoolId, AssessmentTypeModel assessmentType) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('assessment_types')
        .doc(assessmentType.id.isEmpty ? null : assessmentType.id)
        .set(assessmentType.toMap());
  }

  @override
  Future<List<AssessmentMarkModel>> getMarks({
    required String schoolId,
    String? assessmentTypeId,
    String? subjectId,
    String? classId,
    String? studentId,
  }) async {
    Query query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('assessment_marks');

    if (assessmentTypeId != null) query = query.where('assessmentTypeId', isEqualTo: assessmentTypeId);
    if (subjectId != null) query = query.where('subjectId', isEqualTo: subjectId);
    if (studentId != null) query = query.where('studentId', isEqualTo: studentId);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AssessmentMarkModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<void> saveMarks(String schoolId, List<AssessmentMarkModel> marks) async {
    final batch = firestore.batch();
    final collection = firestore.collection('schools').doc(schoolId).collection('assessment_marks');
    
    for (var mark in marks) {
      final docRef = mark.id.isEmpty ? collection.doc() : collection.doc(mark.id);
      batch.set(docRef, mark.toMap());
    }
    await batch.commit();
  }

  @override
  Future<void> updateMarkStatus(String schoolId, List<String> markIds, String status, {String? userId}) async {
    final batch = firestore.batch();
    final collection = firestore.collection('schools').doc(schoolId).collection('assessment_marks');
    
    for (var id in markIds) {
      final data = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == 'moderated') data['moderatedBy'] = userId;
      if (status == 'approved') data['approvedBy'] = userId;
      
      batch.update(collection.doc(id), data);
    }
    await batch.commit();
  }

  @override
  Future<void> createGradingSystem(GradingSystemModel gradingSystem) async {
    await firestore
        .collection('schools')
        .doc(gradingSystem.schoolId)
        .collection('grading_systems')
        .doc(gradingSystem.id.isEmpty ? null : gradingSystem.id)
        .set(gradingSystem.toMap());
  }

  @override
  Future<List<GradingSystemModel>> getGradingSystems(String schoolId) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('grading_systems')
        .get();
    return snapshot.docs
        .map((doc) => GradingSystemModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ReportReleasePolicyModel> getReleasePolicy(String schoolId) async {
    final doc = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('configs')
        .doc('report_release_policy')
        .get();
    
    if (!doc.exists) {
      return ReportReleasePolicyModel(
        id: 'default',
        schoolId: schoolId,
        option: ReleaseOption.everyoneImmediate,
      );
    }
    return ReportReleasePolicyModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<ReportTemplateModel>> getReportTemplates(String schoolId) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('report_templates')
        .get();
    return snapshot.docs
        .map((doc) => ReportTemplateModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> saveReportTemplate(ReportTemplateModel template) async {
    await firestore
        .collection('schools')
        .doc(template.schoolId)
        .collection('report_templates')
        .doc(template.id.isEmpty ? null : template.id)
        .set(template.toMap());
  }

  @override
  Future<void> updateReleasePolicy(ReportReleasePolicyModel policy) async {
    await firestore
        .collection('schools')
        .doc(policy.schoolId)
        .collection('configs')
        .doc('report_release_policy')
        .set(policy.toMap());
  }
}
