import 'package:equatable/equatable.dart';

class ClassObservation extends Equatable {
  final String id;
  final String teacherId;
  final String teacherName;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String observerId;
  final DateTime date;
  final String strengths;
  final String areasForImprovement;
  final String recommendations;
  final DateTime? followUpDate;

  const ClassObservation({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.observerId,
    required this.date,
    required this.strengths,
    required this.areasForImprovement,
    required this.recommendations,
    this.followUpDate,
  });

  @override
  List<Object?> get props => [
        id,
        teacherId,
        teacherName,
        subjectId,
        subjectName,
        classId,
        className,
        observerId,
        date,
        strengths,
        areasForImprovement,
        recommendations,
        followUpDate,
      ];
}
