import 'package:equatable/equatable.dart';
import '../../domain/entities/games_entities.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

class GamesDashboardRequested extends GamesEvent {}

class UpdateHousePointsRequested extends GamesEvent {
  final String houseId;
  final int points;

  const UpdateHousePointsRequested({required this.houseId, required this.points});

  @override
  List<Object?> get props => [houseId, points];
}

class CreateCompetitionRequested extends GamesEvent {
  final SportsCompetition competition;

  const CreateCompetitionRequested(this.competition);

  @override
  List<Object?> get props => [competition];
}
