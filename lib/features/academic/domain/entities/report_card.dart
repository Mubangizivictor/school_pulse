import 'package:equatable/equatable.dart';

enum ReportCardStatus {
  pending,
  deanSigned,
  fullySigned,
}

class ReportCard extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String term;
  final String year;
  final ReportCardStatus status;
  final String? deanId;
  final DateTime? deanSignedAt;
  final String? headTeacherId;
  final DateTime? headTeacherSignedAt;
  final String? classTeacherComment;
  final double averageScore;

  const ReportCard({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.term,
    required this.year,
    this.status = ReportCardStatus.pending,
    this.deanId,
    this.deanSignedAt,
    this.headTeacherId,
    this.headTeacherSignedAt,
    this.classTeacherComment,
    this.averageScore = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        className,
        term,
        year,
        status,
        deanId,
        deanSignedAt,
        headTeacherId,
        headTeacherSignedAt,
        classTeacherComment,
        averageScore,
      ];

  ReportCard copyWith({
    ReportCardStatus? status,
    String? deanId,
    DateTime? deanSignedAt,
    String? headTeacherId,
    DateTime? headTeacherSignedAt,
    String? classTeacherComment,
    double? averageScore,
  }) {
    return ReportCard(
      id: id,
      studentId: studentId,
      studentName: studentName,
      className: className,
      term: term,
      year: year,
      status: status ?? this.status,
      deanId: deanId ?? this.deanId,
      deanSignedAt: deanSignedAt ?? this.deanSignedAt,
      headTeacherId: headTeacherId ?? this.headTeacherId,
      headTeacherSignedAt: headTeacherSignedAt ?? this.headTeacherSignedAt,
      classTeacherComment: classTeacherComment ?? this.classTeacherComment,
      averageScore: averageScore ?? this.averageScore,
    );
  }
}
