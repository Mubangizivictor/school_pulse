import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/matron_repository.dart';
import 'matron_event.dart';
import 'matron_state.dart';

class MatronBloc extends Bloc<MatronEvent, MatronState> {
  final MatronRepository repository;

  MatronBloc({required this.repository}) : super(MatronInitial()) {
    on<MatronDashboardRequested>(_onMatronDashboardRequested);
  }

  Future<void> _onMatronDashboardRequested(
    MatronDashboardRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (data) => emit(data),
    );
  }
}
