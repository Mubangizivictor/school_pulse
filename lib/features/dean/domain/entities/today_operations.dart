import 'package:equatable/equatable.dart';

class TodaysOperations extends Equatable {
  final int lessonsScheduled;
  final int lessonsCompleted;
  final int lessonsInProgress;
  final int lessonsMissed;
  final int assessmentsToday;
  final int awaitingConfirmation;
  final int teacherAbsences;
  final int substituteLessons;
  final int examinationsToday;
  final int meetingsToday;

  const TodaysOperations({
    required this.lessonsScheduled,
    required this.lessonsCompleted,
    required this.lessonsInProgress,
    required this.lessonsMissed,
    required this.assessmentsToday,
    required this.awaitingConfirmation,
    required this.teacherAbsences,
    required this.substituteLessons,
    required this.examinationsToday,
    required this.meetingsToday,
  });

  @override
  List<Object?> get props => [
    lessonsScheduled,
    lessonsCompleted,
    lessonsInProgress,
    lessonsMissed,
    assessmentsToday,
    awaitingConfirmation,
    teacherAbsences,
    substituteLessons,
    examinationsToday,
    meetingsToday,
  ];
}
