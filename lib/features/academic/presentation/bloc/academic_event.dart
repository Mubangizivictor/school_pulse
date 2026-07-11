part of 'academic_bloc.dart';

abstract class AcademicEvent extends Equatable {
  const AcademicEvent();

  @override
  List<Object?> get props => [];
}

class GetAcademicRecordsRequested extends AcademicEvent {
  final String studentId;
  final String? term;
  final String? year;

  const GetAcademicRecordsRequested({
    required this.studentId,
    this.term,
    this.year,
  });

  @override
  List<Object?> get props => [studentId, term, year];
}

class GetAttendanceRecordsRequested extends AcademicEvent {
  final String studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAttendanceRecordsRequested({
    required this.studentId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [studentId, startDate, endDate];
}
