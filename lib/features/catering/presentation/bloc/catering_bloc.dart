import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catering_repository.dart';
import 'catering_event.dart';
import 'catering_state.dart';

class CateringBloc extends Bloc<CateringEvent, CateringState> {
  final CateringRepository repository;

  CateringBloc({required this.repository}) : super(CateringInitial()) {
    on<CateringDashboardRequested>((event, emit) async {
      emit(CateringLoading());
      final result = await repository.getDashboardData();
      result.fold(
        (failure) => emit(CateringError(failure.message)),
        (data) => emit(data),
      );
    });
  }
}
