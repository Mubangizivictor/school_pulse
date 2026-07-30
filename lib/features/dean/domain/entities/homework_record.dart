import 'package:equatable/equatable.dart';

class HomeworkRecord extends Equatable {
  final String id;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String teacherId;
  final String teacherName;
  final String title;
  final DateTime assignedDate;
  final DateTime dueDate;
  final int totalStudents;
  final int submittedCount;
  final double averageScore;
  final String feedbackStatus; // e.g., "All Graded", "Pending Feedback"

  const HomeworkRecord({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.title,
    required this.assignedDate,
    required this.dueDate,
    required this.totalStudents,
    required this.submittedCount,
    this.averageScore = 0.0,
    required this.feedbackStatus,
  });

  double get submissionRate => totalStudents > 0 ? (submittedCount / totalStudents) * 100 : 0.0;

  @override
  List<Object?> get props => [
        id,
        subjectId,
        subjectName,
        classId,
        className,
        teacherId,
        teacherName,
        title,
        assignedDate,
        dueDate,
        totalStudents,
        submittedCount,
        averageScore,
        feedbackStatus,
      ];
}
