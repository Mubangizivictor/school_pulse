import 'package:equatable/equatable.dart';

/// One subject's aggregated result on a report card, produced by the
/// CalculationEngine from a student's approved AssessmentMarks.
class SubjectResult extends Equatable {
  final String subjectId;
  final String subjectName;
  final Map<String, double> assessmentScores; // assessmentTypeId -> score
  final double totalMark;
  final double percentage;
  final String grade;
  final double? gradePoint;
  final String remarks;
  final int? subjectPosition;
  final String teacherName;
  final String? teacherSignatureUrl;

  const SubjectResult({
    required this.subjectId,
    required this.subjectName,
    required this.assessmentScores,
    required this.totalMark,
    required this.percentage,
    required this.grade,
    this.gradePoint,
    required this.remarks,
    this.subjectPosition,
    required this.teacherName,
    this.teacherSignatureUrl,
  });

  SubjectResult copyWith({
    String? subjectId,
    String? subjectName,
    Map<String, double>? assessmentScores,
    double? totalMark,
    double? percentage,
    String? grade,
    double? gradePoint,
    String? remarks,
    int? subjectPosition,
    String? teacherName,
    String? teacherSignatureUrl,
  }) {
    return SubjectResult(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      assessmentScores: assessmentScores ?? this.assessmentScores,
      totalMark: totalMark ?? this.totalMark,
      percentage: percentage ?? this.percentage,
      grade: grade ?? this.grade,
      gradePoint: gradePoint ?? this.gradePoint,
      remarks: remarks ?? this.remarks,
      subjectPosition: subjectPosition ?? this.subjectPosition,
      teacherName: teacherName ?? this.teacherName,
      teacherSignatureUrl: teacherSignatureUrl ?? this.teacherSignatureUrl,
    );
  }

  @override
  List<Object?> get props => [
    subjectId,
    subjectName,
    assessmentScores,
    totalMark,
    percentage,
    grade,
    gradePoint,
    remarks,
    subjectPosition,
    teacherName,
    teacherSignatureUrl,
  ];
}
