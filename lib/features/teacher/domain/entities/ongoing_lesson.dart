import 'package:equatable/equatable.dart';

class OngoingLesson extends Equatable {
  final String id;
  final String subjectName;
  final String className;
  final String topic;
  final String startTime;
  final String endTime;
  final String room;

  const OngoingLesson({
    required this.id,
    required this.subjectName,
    required this.className,
    required this.topic,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  @override
  List<Object?> get props => [
    id,
    subjectName,
    className,
    topic,
    startTime,
    endTime,
    room,
  ];
}
