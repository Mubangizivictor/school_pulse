import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_health_visits.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final GetHealthVisits getHealthVisits;

  HealthBloc({required this.getHealthVisits}) : super(HealthInitial()) {
    on<FetchHealthVisits>(_onFetchHealthVisits);
  }

  Future<void> _onFetchHealthVisits(FetchHealthVisits event, Emitter<HealthState> emit) async {
    emit(HealthLoading());
    final result = await getHealthVisits(event.studentId);
    result.fold(
      (failure) => emit(const HealthError('Server Failure')),
      (visits) => emit(HealthLoaded(visits)),
    );
  }
}
