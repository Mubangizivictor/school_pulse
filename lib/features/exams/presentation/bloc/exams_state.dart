import 'package:equatable/equatable.dart';

abstract class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

class ExamsInitial extends ExamsState {}

class ExamsLoading extends ExamsState {}

class ExamsLoaded extends ExamsState {
  final int totalStudents;
  final int pendingResults;
  final double completionRate;
  final List<ExamSchedule> upcomingExams;

  const ExamsLoaded({
    required this.totalStudents,
    required this.pendingResults,
    required this.completionRate,
    required this.upcomingExams,
  });

  @override
  List<Object?> get props => [
    totalStudents,
    pendingResults,
    completionRate,
    upcomingExams,
  ];
}

class ExamsError extends ExamsState {
  final String message;
  const ExamsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExamSchedule extends Equatable {
  final String subject;
  final String className;
  final String date;
  final String session;

  const ExamSchedule({
    required this.subject,
    required this.className,
    required this.date,
    required this.session,
  });

  @override
  List<Object?> get props => [subject, className, date, session];
}
