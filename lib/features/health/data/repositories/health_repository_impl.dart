import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/health_visit.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HealthVisit>>> getHealthVisits(String studentId) async {
    try {
      final remoteVisits = await remoteDataSource.getHealthVisits(studentId);
      return Right(remoteVisits);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
