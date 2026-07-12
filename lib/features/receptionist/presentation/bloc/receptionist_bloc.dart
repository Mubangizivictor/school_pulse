import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/receptionist_repository.dart';
import 'receptionist_event.dart';
import 'receptionist_state.dart';

class ReceptionistBloc extends Bloc<ReceptionistEvent, ReceptionistState> {
  final ReceptionistRepository repository;

  ReceptionistBloc({required this.repository}) : super(ReceptionistInitial()) {
    on<ReceptionistDashboardRequested>(_onReceptionistDashboardRequested);
  }

  Future<void> _onReceptionistDashboardRequested(
    ReceptionistDashboardRequested event,
    Emitter<ReceptionistState> emit,
  ) async {
    emit(ReceptionistLoading());
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(ReceptionistError(failure.message)),
      (data) => emit(data),
    );
  }
}
