import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../../domain/repositories/school_calendar_repository.dart';
import 'school_calendar_event.dart';
import 'school_calendar_state.dart';

class SchoolCalendarBloc
    extends Bloc<SchoolCalendarEvent, SchoolCalendarState> {
  final SchoolCalendarRepository repository;
  final PermissionEvaluator permissionEvaluator;

  SchoolCalendarBloc({
    required this.repository,
    required this.permissionEvaluator,
  }) : super(SchoolCalendarInitial()) {
    on<LoadCalendarRequested>(_onLoad);
    on<SaveCalendarEventRequested>(_onSave);
    on<DeleteCalendarEventRequested>(_onDelete);
  }

  Future<bool> _canManage(dynamic operatorUser) async {
    final result = await permissionEvaluator.can(
      Permission.calendarManage,
      operatorUser,
    );
    return result.fold((failure) => false, (allowed) => allowed);
  }

  Future<void> _onLoad(
    LoadCalendarRequested event,
    Emitter<SchoolCalendarState> emit,
  ) async {
    emit(SchoolCalendarLoading());

    final canManage = await _canManage(event.operatorUser);

    final yearResult = await repository.getCurrentAcademicYear(event.schoolId);
    final eventsResult = await repository.getEvents(event.schoolId);

    final academicYear = yearResult.fold((failure) => null, (year) => year);
    final events = eventsResult.fold((failure) => null, (events) => events);

    if (events == null) {
      final message = eventsResult.fold(
        (failure) => failure.message,
        (_) => 'Failed to load calendar',
      );
      emit(SchoolCalendarError(message));
      return;
    }

    emit(
      SchoolCalendarLoaded(
        academicYear: academicYear,
        events: events,
        canManage: canManage,
      ),
    );
  }

  Future<void> _onSave(
    SaveCalendarEventRequested event,
    Emitter<SchoolCalendarState> emit,
  ) async {
    final allowed = await _canManage(event.operatorUser);
    if (!allowed) {
      emit(
        const SchoolCalendarActionDenied(
          'You do not have permission to manage the school calendar.',
        ),
      );
      return;
    }

    final result = await repository.upsertEvent(event.event);
    result.fold(
      (failure) => emit(SchoolCalendarError(failure.message)),
      (id) =>
          emit(SchoolCalendarActionSuccess('Event saved', savedEventId: id)),
    );

    add(
      LoadCalendarRequested(
        schoolId: event.event.schoolId,
        operatorUser: event.operatorUser,
      ),
    );
  }

  Future<void> _onDelete(
    DeleteCalendarEventRequested event,
    Emitter<SchoolCalendarState> emit,
  ) async {
    final allowed = await _canManage(event.operatorUser);
    if (!allowed) {
      emit(
        const SchoolCalendarActionDenied(
          'You do not have permission to manage the school calendar.',
        ),
      );
      return;
    }

    final result = await repository.deleteEvent(
      event.schoolId,
      event.eventId,
      scope: event.scope,
    );
    result.fold(
      (failure) => emit(SchoolCalendarError(failure.message)),
      (_) => emit(const SchoolCalendarActionSuccess('Event removed')),
    );

    add(
      LoadCalendarRequested(
        schoolId: event.schoolId,
        operatorUser: event.operatorUser,
      ),
    );
  }
}
