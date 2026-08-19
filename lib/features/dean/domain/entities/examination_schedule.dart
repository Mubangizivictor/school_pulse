import 'package:equatable/equatable.dart';

enum ExaminationStatus {
  scheduled,
  inProgress,
  completed,
  marksPending,
  published,
}

class ExaminationSchedule extends Equatable {
  final String id;
  final String examName;
  final String subjectId;
  final String subjectName;
  final String className;
  final DateTime date;
  final String startTime;
  final String durationLabel;
  final String venue;
  final ExaminationStatus status;

  const ExaminationSchedule({
    required this.id,
    required this.examName,
    required this.subjectId,
    required this.subjectName,
    required this.className,
    required this.date,
    required this.startTime,
    required this.durationLabel,
    required this.venue,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    examName,
    subjectId,
    subjectName,
    className,
    date,
    startTime,
    durationLabel,
    venue,
    status,
  ];
}
