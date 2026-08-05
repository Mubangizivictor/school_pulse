import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/games_entities.dart';

abstract class GamesRepository {
  Future<Either<Failure, List<SportsHouse>>> getSportsHouses();
  Future<Either<Failure, List<SportsCompetition>>> getRecentCompetitions();
  Future<Either<Failure, void>> updateHousePoints(String houseId, int points);
  Future<Either<Failure, void>> createCompetition(
    SportsCompetition competition,
  );
}
