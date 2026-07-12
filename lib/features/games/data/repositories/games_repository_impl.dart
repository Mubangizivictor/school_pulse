import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/games_repository.dart';
import '../../presentation/bloc/games_state.dart';
import '../datasources/games_remote_data_source.dart';

class GamesRepositoryImpl implements GamesRepository {
  final GamesRemoteDataSource remoteDataSource;

  GamesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GamesLoaded>> getDashboardData() async {
    try {
      final fixtures = await remoteDataSource.getUpcomingFixtures();
      final stats = await remoteDataSource.getGamesStats();
      
      return Right(GamesLoaded(
        upcomingFixtures: fixtures,
        totalEquipment: stats['totalEquipment'] ?? 0,
        activeTeams: stats['activeTeams'] ?? 0,
        nextEvent: stats['nextEvent'] ?? 'None',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
