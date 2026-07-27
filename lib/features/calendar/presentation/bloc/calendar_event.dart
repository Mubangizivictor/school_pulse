import 'package:equatable/equatable.dart';
import '../../domain/entities/school_event.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {}

class AddCalendarEvent extends CalendarEvent {
  final SchoolEvent event;
  const AddCalendarEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteCalendarEvent extends CalendarEvent {
  final String eventId;
  const DeleteCalendarEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
