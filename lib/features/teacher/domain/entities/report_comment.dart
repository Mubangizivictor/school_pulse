import 'package:equatable/equatable.dart';

class ReportComment extends Equatable {
  final String id;
  final String studentId;
  final String className;
  final String term;
  final String year;
  final String comment;
  final String teacherId;
  final DateTime updatedAt;

  const ReportComment({
    required this.id,
    required this.studentId,
    required this.className,
    required this.term,
    required this.year,
    required this.comment,
    required this.teacherId,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        className,
        term,
        year,
        comment,
        teacherId,
        updatedAt,
      ];

  ReportComment copyWith({
    String? id,
    String? studentId,
    String? className,
    String? term,
    String? year,
    String? comment,
    String? teacherId,
    DateTime? updatedAt,
  }) {
    return ReportComment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      className: className ?? this.className,
      term: term ?? this.term,
      year: year ?? this.year,
      comment: comment ?? this.comment,
      teacherId: teacherId ?? this.teacherId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
