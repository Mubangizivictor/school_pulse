import 'package:equatable/equatable.dart';

enum ModerationStatus { pending, approved, rejected }

class AssessmentModeration extends Equatable {
  final String id;
  final String assessmentId;
  final String title;
  final String className;
  final String subjectName;
  final String teacherName;
  final int submissionCount;
  final int totalStudents;
  final double averageScore;
  final ModerationStatus status;
  final String? rejectionReason;
  final DateTime createdAt;

  const AssessmentModeration({
    required this.id,
    required this.assessmentId,
    required this.title,
    required this.className,
    required this.subjectName,
    required this.teacherName,
    required this.submissionCount,
    required this.totalStudents,
    required this.averageScore,
    this.status = ModerationStatus.pending,
    this.rejectionReason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        assessmentId,
        title,
        className,
        subjectName,
        teacherName,
        submissionCount,
        totalStudents,
        averageScore,
        status,
        rejectionReason,
        createdAt,
      ];

  AssessmentModeration copyWith({
    ModerationStatus? status,
    String? rejectionReason,
  }) {
    return AssessmentModeration(
      id: id,
      assessmentId: assessmentId,
      title: title,
      className: className,
      subjectName: subjectName,
      teacherName: teacherName,
      submissionCount: submissionCount,
      totalStudents: totalStudents,
      averageScore: averageScore,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
    );
  }
}
