import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/games_repository.dart';
import 'games_event.dart';
import 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  final GamesRepository repository;

  GamesBloc({required this.repository}) : super(GamesInitial()) {
    on<GamesDashboardRequested>((event, emit) async {
      emit(GamesLoading());
      final result = await repository.getDashboardData();
      result.fold(
        (failure) => emit(GamesError(failure.message)),
        (data) => emit(data),
      );
    });
  }
}
