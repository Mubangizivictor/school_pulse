import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/assessment_mark.dart';

class AssessmentMarkModel extends AssessmentMark {
  const AssessmentMarkModel({
    required super.id,
    required super.studentId,
    required super.assessmentTypeId,
    required super.subjectId,
    required super.teacherId,
    super.score,
    super.competencyLevel,
    super.teacherComment,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.moderatedBy,
    super.approvedBy,
  });

  factory AssessmentMarkModel.fromMap(Map<String, dynamic> map, String id) {
    return AssessmentMarkModel(
      id: id,
      studentId: map['studentId'] ?? '',
      assessmentTypeId: map['assessmentTypeId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      score: (map['score'] as num?)?.toDouble(),
      competencyLevel: map['competencyLevel'],
      teacherComment: map['teacherComment'],
      status: MarkStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MarkStatus.draft,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moderatedBy: map['moderatedBy'],
      approvedBy: map['approvedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'assessmentTypeId': assessmentTypeId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'score': score,
      'competencyLevel': competencyLevel,
      'teacherComment': teacherComment,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'moderatedBy': moderatedBy,
      'approvedBy': approvedBy,
    };
  }
}
