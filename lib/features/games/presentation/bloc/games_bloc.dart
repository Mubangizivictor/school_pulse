import 'package:flutter_bloc/flutter_bloc.dart';
import 'games_event.dart';
import 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc() : super(GamesInitial()) {
    on<GamesDashboardRequested>((event, emit) async {
      emit(GamesLoading());
      // Mocking delay and data
      await Future.delayed(const Duration(seconds: 1));
      emit(const GamesLoaded(
        upcomingFixtures: [
          SportsFixture(
            sport: 'Football',
            opponent: 'St. Mary\'s College',
            date: 'Oct 24, 2023',
            venue: 'Home Ground',
          ),
          SportsFixture(
            sport: 'Basketball',
            opponent: 'Kings College Buddo',
            date: 'Oct 27, 2023',
            venue: 'Away',
          ),
        ],
        totalEquipment: 145,
        activeTeams: 8,
        nextEvent: 'Inter-House Athletics',
      ));
    });
  }
}
