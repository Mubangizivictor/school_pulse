import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dean_stats.dart';
import 'dean_event.dart';
import 'dean_state.dart';

class DeanBloc extends Bloc<DeanEvent, DeanState> {
  final GetDeanStats getDeanStats;

  DeanBloc({
    required this.getDeanStats,
  }) : super(DeanInitial()) {
    on<DeanStatsRequested>(_onDeanStatsRequested);
  }

  Future<void> _onDeanStatsRequested(
    DeanStatsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await getDeanStats(NoParams());
    
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (stats) => emit(DeanLoaded(stats)),
    );
  }
}
