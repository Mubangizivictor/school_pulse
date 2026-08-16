import '../../domain/entities/academic_record.dart';

class AcademicRecordModel extends AcademicRecord {
  const AcademicRecordModel({
    required super.studentId,
    required super.subject,
    required super.score,
    required super.grade,
    super.gradeLabel,
    super.gradeColorHex,
    super.isPassing,
    required super.term,
    required super.year,
    super.teacherRemark,
    super.trend,
  });

  factory AcademicRecordModel.fromFirestore(Map<String, dynamic> json) {
    return AcademicRecordModel(
      studentId: json['studentId'] as String,
      subject: json['subject'] as String,
      score: (json['score'] as num).toDouble(),
      grade: json['grade'] as String?,
      gradeLabel: json['gradeLabel'] as String?,
      gradeColorHex: json['gradeColorHex'] as String?,
      isPassing: json['isPassing'] as bool?,
      term: json['term'] as String,
      year: json['year'] as String,
      teacherRemark: json['teacherRemark'] as String? ?? '',
      trend: (json['trend'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'subject': subject,
      'score': score,
      'grade': grade,
      'gradeLabel': gradeLabel,
      'gradeColorHex': gradeColorHex,
      'isPassing': isPassing,
      'term': term,
      'year': year,
      'teacherRemark': teacherRemark,
      'trend': trend,
    };
  }
}
