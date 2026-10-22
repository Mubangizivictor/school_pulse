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
  // Internal ids kept off the UI but needed to target the real
  // subject_assessments/student_marks documents on write.
  final String subjectId;
  final String classId;
  final String teacherStaffId;
  final String academicYearId;
  final String termId;
  final String type;
  final String rawStatus;
  final String? streamId;
  final String? description;
  final DateTime? dueDate;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final int markedCount;
  final int missingMarksCount;
  final List<String> attachments;

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
    this.subjectId = '',
    this.classId = '',
    this.teacherStaffId = '',
    this.academicYearId = '',
    this.termId = '',
    this.type = 'Other',
    this.rawStatus = 'draft',
    this.streamId,
    this.description,
    this.dueDate,
    this.publishedAt,
    this.updatedAt,
    this.markedCount = 0,
    this.missingMarksCount = 0,
    this.attachments = const [],
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
    subjectId,
    classId,
    teacherStaffId,
    academicYearId,
    termId,
    type,
    rawStatus,
    streamId,
    description,
    dueDate,
    publishedAt,
    updatedAt,
    markedCount,
    missingMarksCount,
    attachments,
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
      subjectId: subjectId,
      classId: classId,
      teacherStaffId: teacherStaffId,
      academicYearId: academicYearId,
      termId: termId,
      type: type,
      rawStatus: rawStatus,
      streamId: streamId,
      description: description,
      dueDate: dueDate,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
      markedCount: markedCount,
      missingMarksCount: missingMarksCount,
      attachments: attachments,
    );
  }
}
