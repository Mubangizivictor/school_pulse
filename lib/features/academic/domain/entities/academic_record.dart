import 'package:equatable/equatable.dart';

class AcademicRecord extends Equatable {
  final String studentId;
  final String subject;
  final double score;
  final String grade;
  final String term;
  final String year;
  final String teacherRemark;
  final double trend;

  const AcademicRecord({
    required this.studentId,
    required this.subject,
    required this.score,
    required this.grade,
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
        term,
        year,
        teacherRemark,
        trend,
      ];
}
