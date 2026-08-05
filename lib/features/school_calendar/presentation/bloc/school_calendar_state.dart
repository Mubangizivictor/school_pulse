import 'package:equatable/equatable.dart';
import '../../domain/entities/academic_year.dart';
import '../../domain/entities/calendar_event.dart';

abstract class SchoolCalendarState extends Equatable {
  const SchoolCalendarState();

  @override
  List<Object?> get props => [];
}

class SchoolCalendarInitial extends SchoolCalendarState {}

class SchoolCalendarLoading extends SchoolCalendarState {}

class SchoolCalendarLoaded extends SchoolCalendarState {
  final AcademicYear? academicYear;
  final List<CalendarEvent> events;
  final bool canManage;

  const SchoolCalendarLoaded({
    required this.academicYear,
    required this.events,
    required this.canManage,
  });

  @override
  List<Object?> get props => [academicYear, events, canManage];
}

class SchoolCalendarError extends SchoolCalendarState {
  final String message;
  const SchoolCalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

class SchoolCalendarActionDenied extends SchoolCalendarState {
  final String message;
  const SchoolCalendarActionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class SchoolCalendarActionSuccess extends SchoolCalendarState {
  final String message;
  const SchoolCalendarActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
