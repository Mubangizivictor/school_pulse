import 'package:equatable/equatable.dart';

class LessonPlan extends Equatable {
  final String id;
  final String teacherId;
  final String subject;
  final String className;
  final DateTime date;
  final String content;

  const LessonPlan({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.className,
    required this.date,
    required this.content,
  });

  @override
  List<Object?> get props => [id, teacherId, subject, className, date, content];
}
