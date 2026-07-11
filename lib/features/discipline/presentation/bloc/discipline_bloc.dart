import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_discipline_incidents.dart';
import '../../domain/usecases/get_recent_discipline_incidents.dart';
import 'discipline_event.dart';
import 'discipline_state.dart';

class DisciplineBloc extends Bloc<DisciplineEvent, DisciplineState> {
  final GetDisciplineIncidents getDisciplineIncidents;
  final GetRecentDisciplineIncidents getRecentDisciplineIncidents;

  DisciplineBloc({
    required this.getDisciplineIncidents,
    required this.getRecentDisciplineIncidents,
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
  }
}
