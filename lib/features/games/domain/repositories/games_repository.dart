import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/games_state.dart';

abstract class GamesRepository {
  Future<Either<Failure, GamesLoaded>> getDashboardData();
}
