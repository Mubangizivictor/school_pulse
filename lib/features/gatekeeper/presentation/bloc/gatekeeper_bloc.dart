import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/gatekeeper_repository.dart';
import 'gatekeeper_event.dart';
import 'gatekeeper_state.dart';

class GatekeeperBloc extends Bloc<GatekeeperEvent, GatekeeperState> {
  final GatekeeperRepository repository;

  GatekeeperBloc({required this.repository}) : super(GatekeeperInitial()) {
    on<GatekeeperDashboardRequested>(_onGatekeeperDashboardRequested);
  }

  Future<void> _onGatekeeperDashboardRequested(
    GatekeeperDashboardRequested event,
    Emitter<GatekeeperState> emit,
  ) async {
    emit(GatekeeperLoading());
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(GatekeeperError(failure.message)),
      (data) => emit(data),
    );
  }
}
