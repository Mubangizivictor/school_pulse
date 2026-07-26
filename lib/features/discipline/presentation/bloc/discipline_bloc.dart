import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/discipline_incident.dart';
import '../../domain/usecases/get_discipline_incidents.dart';
import '../../domain/usecases/get_recent_discipline_incidents.dart';
import '../../domain/usecases/log_discipline_incident.dart';
import 'discipline_event.dart';
import 'discipline_state.dart';

class DisciplineBloc extends Bloc<DisciplineEvent, DisciplineState> {
  final GetDisciplineIncidents getDisciplineIncidents;
  final GetRecentDisciplineIncidents getRecentDisciplineIncidents;
  final LogDisciplineIncident logDisciplineIncident;

  DisciplineBloc({
    required this.getDisciplineIncidents,
    required this.getRecentDisciplineIncidents,
    required this.logDisciplineIncident,
  }) : super(DisciplineInitial()) {
    on<LoadDisciplineIncidents>((event, emit) async {
      emit(DisciplineLoading());
      final result = await getDisciplineIncidents(event.studentId);
      result.fold(
        (failure) => emit(const DisciplineError('Failed to fetch discipline incidents')),
        (incidents) => emit(DisciplineLoaded(incidents)),
      );
    });

    on<LoadRecentIncidents>((event, emit) async {
      emit(DisciplineLoading());
      final result = await getRecentDisciplineIncidents();
      result.fold(
        (failure) => emit(const DisciplineError('Failed to fetch recent incidents')),
        (incidents) => emit(DisciplineLoaded(incidents)),
      );
    });

    on<LogIncidentRequested>((event, emit) async {
      final incident = DisciplineIncident(
        id: '',
        studentId: event.studentId,
        date: DateTime.now(),
        description: event.description,
        severity: event.severity,
        resolution: '',
        counselingNotes: '',
      );
      final result = await logDisciplineIncident(incident);
      await result.fold(
        (failure) async => emit(const DisciplineError('Failed to log incident')),
        (_) async {
          emit(DisciplineLoading());
          final refreshed = await getRecentDisciplineIncidents();
          refreshed.fold(
            (failure) => emit(const DisciplineError('Failed to fetch recent incidents')),
            (incidents) => emit(DisciplineLoaded(incidents)),
          );
        },
      );
    });
  }
}
