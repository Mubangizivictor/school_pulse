import 'package:equatable/equatable.dart';

abstract class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class GamesLoaded extends GamesState {
  final List<SportsFixture> upcomingFixtures;
  final int totalEquipment;
  final int activeTeams;
  final String nextEvent;

  const GamesLoaded({
    required this.upcomingFixtures,
    required this.totalEquipment,
    required this.activeTeams,
    required this.nextEvent,
  });

  @override
  List<Object?> get props => [upcomingFixtures, totalEquipment, activeTeams, nextEvent];
}

class SportsFixture extends Equatable {
  final String sport;
  final String opponent;
  final String date;
  final String venue;

  const SportsFixture({
    required this.sport,
    required this.opponent,
    required this.date,
    required this.venue,
  });

  @override
  List<Object?> get props => [sport, opponent, date, venue];
}

class GamesError extends GamesState {
  final String message;
  const GamesError(this.message);

  @override
  List<Object?> get props => [message];
}
