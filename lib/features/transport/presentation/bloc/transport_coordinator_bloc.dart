import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transport_coordinator_repository.dart';
import 'transport_coordinator_event.dart';
import 'transport_coordinator_state.dart';

class TransportCoordinatorBloc extends Bloc<TransportCoordinatorEvent, TransportCoordinatorState> {
  final TransportCoordinatorRepository repository;

  TransportCoordinatorBloc({required this.repository}) : super(TransportCoordinatorInitial()) {
    on<TransportCoordinatorDashboardRequested>((event, emit) async {
      emit(TransportCoordinatorLoading());
      final result = await repository.getDashboardData();
      result.fold(
        (failure) => emit(TransportCoordinatorError(failure.message)),
        (data) => emit(data),
      );
    });
  }
}
