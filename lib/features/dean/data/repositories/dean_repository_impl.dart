import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/dean_stats.dart';
import '../../domain/repositories/dean_repository.dart';
import '../datasources/dean_remote_data_source.dart';

class DeanRepositoryImpl implements DeanRepository {
  final DeanRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DeanRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DeanStats>> getDeanStats() async {
    if (await networkInfo.isConnected) {
      try {
        final stats = await remoteDataSource.getDeanStats();
        return Right(stats);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
