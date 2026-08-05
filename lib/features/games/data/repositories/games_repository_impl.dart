import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/games_entities.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_remote_data_source.dart';
import '../models/games_models.dart';

class GamesRepositoryImpl implements GamesRepository {
  final GamesRemoteDataSource remoteDataSource;

  GamesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SportsHouse>>> getSportsHouses() async {
    try {
      final houses = await remoteDataSource.getSportsHouses();
      return Right(houses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportsCompetition>>>
  getRecentCompetitions() async {
    try {
      final competitions = await remoteDataSource.getRecentCompetitions();
      return Right(competitions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateHousePoints(
    String houseId,
    int points,
  ) async {
    try {
      await remoteDataSource.updateHousePoints(houseId, points);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCompetition(
    SportsCompetition competition,
  ) async {
    try {
      final model = SportsCompetitionModel(
        id: competition.id,
        title: competition.title,
        date: competition.date,
        venue: competition.venue,
        status: competition.status,
      );
      await remoteDataSource.createCompetition(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
