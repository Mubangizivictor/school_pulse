import 'package:equatable/equatable.dart';

enum LessonStatus { planned, completed, missed, rescheduled, substituted }

class LessonRecord extends Equatable {
  final String id;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String teacherId;
  final String teacherName;
  final DateTime scheduledAt;
  final LessonStatus status;
  final String? topicCovered;
  final String? remarks;

  const LessonRecord({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.scheduledAt,
    required this.status,
    this.topicCovered,
    this.remarks,
  });

  @override
  List<Object?> get props => [
    id,
    subjectId,
    subjectName,
    classId,
    className,
    teacherId,
    teacherName,
    scheduledAt,
    status,
    topicCovered,
    remarks,
  ];
}
