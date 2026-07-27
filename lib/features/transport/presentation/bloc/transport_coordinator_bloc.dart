import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transport_coordinator_repository.dart';
import 'transport_coordinator_event.dart';
import 'transport_coordinator_state.dart';

class TransportCoordinatorBloc extends Bloc<TransportCoordinatorEvent, TransportCoordinatorState> {
  final TransportCoordinatorRepository repository;

  TransportCoordinatorBloc({required this.repository}) : super(TransportCoordinatorInitial()) {
    on<TransportCoordinatorDashboardRequested>(_onDashboardRequested);
    on<StartTripRequested>(_onStartTripRequested);
    on<EndTripRequested>(_onEndTripRequested);
    on<LogStudentPickupRequested>(_onLogStudentPickupRequested);
  }

  Future<void> _onDashboardRequested(
    TransportCoordinatorDashboardRequested event,
    Emitter<TransportCoordinatorState> emit,
  ) async {
    emit(TransportCoordinatorLoading());
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(TransportCoordinatorError(failure.message)),
      (data) => emit(data),
    );
  }

  Future<void> _onStartTripRequested(
    StartTripRequested event,
    Emitter<TransportCoordinatorState> emit,
  ) async {
    final result = await repository.startTrip(event.routeId);
    result.fold(
      (failure) => emit(TransportCoordinatorError(failure.message)),
      (_) {
        emit(const TripActionSuccess('Trip started successfully'));
        add(TransportCoordinatorDashboardRequested());
      },
    );
  }

  Future<void> _onEndTripRequested(
    EndTripRequested event,
    Emitter<TransportCoordinatorState> emit,
  ) async {
    final result = await repository.endTrip(event.routeId);
    result.fold(
      (failure) => emit(TransportCoordinatorError(failure.message)),
      (_) {
        emit(const TripActionSuccess('Trip ended successfully'));
        add(TransportCoordinatorDashboardRequested());
      },
    );
  }

  Future<void> _onLogStudentPickupRequested(
    LogStudentPickupRequested event,
    Emitter<TransportCoordinatorState> emit,
  ) async {
    final result = await repository.logStudentPickup(event.routeId, event.studentId);
    result.fold(
      (failure) => emit(TransportCoordinatorError(failure.message)),
      (_) => emit(const TripActionSuccess('Student pickup logged')),
    );
  }
}
