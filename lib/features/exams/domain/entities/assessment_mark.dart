import 'package:equatable/equatable.dart';

enum MarkStatus {
  draft,
  submitted,
  moderated,
  approved,
  published,
}

class AssessmentMark extends Equatable {
  final String id;
  final String studentId;
  final String assessmentTypeId;
  final String subjectId;
  final String teacherId;
  final double? score;
  final String? competencyLevel; // For competency-based assessments
  final String? teacherComment;
  final MarkStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? moderatedBy;
  final String? approvedBy;

  const AssessmentMark({
    required this.id,
    required this.studentId,
    required this.assessmentTypeId,
    required this.subjectId,
    required this.teacherId,
    this.score,
    this.competencyLevel,
    this.teacherComment,
    this.status = MarkStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    this.moderatedBy,
    this.approvedBy,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        assessmentTypeId,
        subjectId,
        teacherId,
        score,
        competencyLevel,
        teacherComment,
        status,
        createdAt,
        updatedAt,
        moderatedBy,
        approvedBy,
      ];

  AssessmentMark copyWith({
    double? score,
    MarkStatus? status,
    String? moderatedBy,
    String? approvedBy,
    DateTime? updatedAt,
  }) {
    return AssessmentMark(
      id: id,
      studentId: studentId,
      assessmentTypeId: assessmentTypeId,
      subjectId: subjectId,
      teacherId: teacherId,
      createdAt: createdAt,
      score: score ?? this.score,
      status: status ?? this.status,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      competencyLevel: competencyLevel,
      teacherComment: teacherComment,
    );
  }
}
