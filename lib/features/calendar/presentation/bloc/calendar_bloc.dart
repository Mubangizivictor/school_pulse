import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_upcoming_events.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetUpcomingEvents getUpcomingEvents;
  final AddEvent addEvent;
  final DeleteEvent deleteEvent;

  CalendarBloc({
    required this.getUpcomingEvents,
    required this.addEvent,
    required this.deleteEvent,
  }) : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<AddCalendarEvent>(_onAddCalendarEvent);
    on<DeleteCalendarEvent>(_onDeleteCalendarEvent);
  }

  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    final result = await getUpcomingEvents();
    result.fold(
      (failure) => emit(const CalendarError('Failed to load events')),
      (events) => emit(CalendarLoaded(events)),
    );
  }

  Future<void> _onAddCalendarEvent(
    AddCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final result = await addEvent(event.event);
    result.fold(
      (failure) => emit(const CalendarError('Failed to add event')),
      (_) => add(LoadCalendarEvents()),
    );
  }

  Future<void> _onDeleteCalendarEvent(
    DeleteCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final result = await deleteEvent(event.eventId);
    result.fold(
      (failure) => emit(const CalendarError('Failed to delete event')),
      (_) => add(LoadCalendarEvents()),
    );
  }
}
