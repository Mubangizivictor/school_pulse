import 'package:equatable/equatable.dart';
import '../../domain/entities/games_entities.dart';

abstract class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class GamesLoaded extends GamesState {
  final List<SportsHouse> houses;
  final List<SportsCompetition> competitions;
  final int activeTeams;
  final int totalEquipment;
  final String? nextEvent;
  final List<dynamic> upcomingFixtures;

  const GamesLoaded({
    required this.houses,
    required this.competitions,
    this.activeTeams = 0,
    this.totalEquipment = 0,
    this.nextEvent,
    this.upcomingFixtures = const [],
  });

  @override
  List<Object?> get props => [houses, competitions, activeTeams, totalEquipment, nextEvent, upcomingFixtures];
}

class GamesError extends GamesState {
  final String message;

  const GamesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ActionSuccess extends GamesState {
  final String message;

  const ActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
