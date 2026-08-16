import 'package:equatable/equatable.dart';

class AcademicRecord extends Equatable {
  final String studentId;
  final String subject;
  final double score;

  /// Null when the school has no grading system configured at all -
  /// deliberately never a fabricated fallback grade. Populated by
  /// GradeResolver against the school's default GradingSystemDef/GradeBand
  /// (see TeacherRemoteDataSourceImpl.submitMarks).
  final String? grade;
  final String? gradeLabel;

  /// The resolved band's presentation color, so display code never needs to
  /// pattern-match on the grade string to pick a color. Null for legacy
  /// records written before this field existed, or when [grade] is null.
  final String? gradeColorHex;
  final bool? isPassing;

  final String term;
  final String year;
  final String teacherRemark;
  final double trend;

  const AcademicRecord({
    required this.studentId,
    required this.subject,
    required this.score,
    required this.grade,
    this.gradeLabel,
    this.gradeColorHex,
    this.isPassing,
    required this.term,
    required this.year,
    this.teacherRemark = '',
    this.trend = 0,
  });

  @override
  List<Object?> get props => [
    studentId,
    subject,
    score,
    grade,
    gradeLabel,
    gradeColorHex,
    isPassing,
    term,
    year,
    teacherRemark,
    trend,
  ];
}
