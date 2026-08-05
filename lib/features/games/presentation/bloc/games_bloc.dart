import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/games_repository.dart';
import 'games_event.dart';
import 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  final GamesRepository repository;

  GamesBloc({required this.repository}) : super(GamesInitial()) {
    on<GamesDashboardRequested>(_onGamesDashboardRequested);
    on<UpdateHousePointsRequested>(_onUpdateHousePointsRequested);
    on<CreateCompetitionRequested>(_onCreateCompetitionRequested);
  }

  Future<void> _onGamesDashboardRequested(
    GamesDashboardRequested event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final housesResult = await repository.getSportsHouses();
    final competitionsResult = await repository.getRecentCompetitions();

    housesResult.fold((failure) => emit(GamesError(failure.message)), (houses) {
      competitionsResult.fold(
        (failure) => emit(GamesError(failure.message)),
        (competitions) =>
            emit(GamesLoaded(houses: houses, competitions: competitions)),
      );
    });
  }

  Future<void> _onUpdateHousePointsRequested(
    UpdateHousePointsRequested event,
    Emitter<GamesState> emit,
  ) async {
    final result = await repository.updateHousePoints(
      event.houseId,
      event.points,
    );
    result.fold((failure) => emit(GamesError(failure.message)), (_) {
      emit(const ActionSuccess('Points updated successfully'));
      add(GamesDashboardRequested());
    });
  }

  Future<void> _onCreateCompetitionRequested(
    CreateCompetitionRequested event,
    Emitter<GamesState> emit,
  ) async {
    final result = await repository.createCompetition(event.competition);
    result.fold((failure) => emit(GamesError(failure.message)), (_) {
      emit(const ActionSuccess('Competition created successfully'));
      add(GamesDashboardRequested());
    });
  }
}
