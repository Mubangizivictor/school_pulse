import 'package:equatable/equatable.dart';

class CompetencyRating extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String className;
  final String term;
  final String year;
  final String competency; // e.g., 'Communication Skills'
  final int level; // 1-4
  final String teacherId;
  final DateTime updatedAt;

  const CompetencyRating({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.className,
    required this.term,
    required this.year,
    required this.competency,
    required this.level,
    required this.teacherId,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    className,
    term,
    year,
    competency,
    level,
    teacherId,
    updatedAt,
  ];

  CompetencyRating copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    String? className,
    String? term,
    String? year,
    String? competency,
    int? level,
    String? teacherId,
    DateTime? updatedAt,
  }) {
    return CompetencyRating(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      term: term ?? this.term,
      year: year ?? this.year,
      competency: competency ?? this.competency,
      level: level ?? this.level,
      teacherId: teacherId ?? this.teacherId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
