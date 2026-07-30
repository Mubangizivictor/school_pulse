import 'package:equatable/equatable.dart';

class TeacherWorkload extends Equatable {
  final String teacherId;
  final String teacherName;
  final List<AssignedSubject> assignedSubjects;
  final int weeklyLessonsCount;
  final int lessonsDelivered;
  final int lessonsMissed;
  final int assessmentsCreated;
  final int marksPending;

  const TeacherWorkload({
    required this.teacherId,
    required this.teacherName,
    required this.assignedSubjects,
    required this.weeklyLessonsCount,
    required this.lessonsDelivered,
    required this.lessonsMissed,
    required this.assessmentsCreated,
    required this.marksPending,
  });

  @override
  List<Object?> get props => [
        teacherId,
        teacherName,
        assignedSubjects,
        weeklyLessonsCount,
        lessonsDelivered,
        lessonsMissed,
        assessmentsCreated,
        marksPending,
      ];
}

class AssignedSubject extends Equatable {
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final int weeklyLessons;

  const AssignedSubject({
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.weeklyLessons,
  });

  @override
  List<Object?> get props => [subjectId, subjectName, classId, className, weeklyLessons];
}
