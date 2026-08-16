import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
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

  /// The saved event's id, populated only for a save (not a delete), so
  /// the caller can upload staged attachments to its Storage path.
  final String? savedEventId;

  const SchoolCalendarActionSuccess(this.message, {this.savedEventId});

  @override
  List<Object?> get props => [message, savedEventId];
}
