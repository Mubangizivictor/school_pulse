import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/entities/calendar_event.dart';

abstract class SchoolCalendarEvent extends Equatable {
  const SchoolCalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarRequested extends SchoolCalendarEvent {
  final String schoolId;
  final UserEntity operatorUser;

  const LoadCalendarRequested({
    required this.schoolId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, operatorUser];
}

class SaveCalendarEventRequested extends SchoolCalendarEvent {
  final CalendarEvent event;
  final UserEntity operatorUser;

  const SaveCalendarEventRequested({
    required this.event,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [event, operatorUser];
}

class DeleteCalendarEventRequested extends SchoolCalendarEvent {
  final String schoolId;
  final String eventId;
  final UserEntity operatorUser;

  const DeleteCalendarEventRequested({
    required this.schoolId,
    required this.eventId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, eventId, operatorUser];
}
