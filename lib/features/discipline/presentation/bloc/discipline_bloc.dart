import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/discipline_incident.dart';
import '../../domain/entities/counseling_session.dart';
import '../../domain/usecases/get_discipline_incidents.dart';
import '../../domain/usecases/get_recent_discipline_incidents.dart';
import '../../domain/usecases/log_discipline_incident.dart';
import '../../domain/usecases/get_counseling_sessions.dart';
import '../../domain/usecases/log_counseling_session.dart';
import 'discipline_event.dart';
import 'discipline_state.dart';

class DisciplineBloc extends Bloc<DisciplineEvent, DisciplineState> {
  final GetDisciplineIncidents getDisciplineIncidents;
  final GetRecentDisciplineIncidents getRecentDisciplineIncidents;
  final LogDisciplineIncident logDisciplineIncident;
  final GetCounselingSessions getCounselingSessions;
  final LogCounselingSession logCounselingSession;

  DisciplineBloc({
    required this.getDisciplineIncidents,
    required this.getRecentDisciplineIncidents,
    required this.logDisciplineIncident,
    required this.getCounselingSessions,
    required this.logCounselingSession,
  }) : super(DisciplineInitial()) {
    on<LoadDisciplineIncidents>((event, emit) async {
      emit(DisciplineLoading());
      final result = await getDisciplineIncidents(event.studentId);
      result.fold(
        (failure) => emit(const DisciplineError('Failed to fetch discipline incidents')),
        (incidents) => emit(DisciplineLoaded(incidents: incidents)),
      );
    });

    on<LoadRecentIncidents>((event, emit) async {
      emit(DisciplineLoading());
      final incidentsResult = await getRecentDisciplineIncidents();
      final sessionsResult = await getCounselingSessions();

      incidentsResult.fold(
        (failure) => emit(const DisciplineError('Failed to fetch recent incidents')),
        (incidents) {
          sessionsResult.fold(
            (failure) => emit(DisciplineLoaded(incidents: incidents)),
            (sessions) => emit(DisciplineLoaded(incidents: incidents, sessions: sessions)),
          );
        },
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
          add(LoadRecentIncidents());
        },
      );
    });

    on<LoadCounselingSessions>((event, emit) async {
      emit(DisciplineLoading());
      final result = await getCounselingSessions();
      result.fold(
        (failure) => emit(const DisciplineError('Failed to fetch counseling sessions')),
        (sessions) => emit(DisciplineLoaded(sessions: sessions)),
      );
    });

    on<LogCounselingSessionRequested>((event, emit) async {
      final session = CounselingSession(
        id: '',
        studentId: event.studentId,
        counselorId: 'current_user_id', // Should be replaced with actual user ID
        date: DateTime.now(),
        reason: event.reason,
        notes: event.notes,
        recommendations: event.recommendations,
      );
      final result = await logCounselingSession(session);
      await result.fold(
        (failure) async => emit(const DisciplineError('Failed to log counseling session')),
        (_) async {
          add(LoadRecentIncidents());
        },
      );
    });
  }
}
