import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/health_visit.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';
import '../models/health_visit_model.dart';

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

  @override
  Future<Either<Failure, List<HealthVisit>>> getAllHealthVisits() async {
    try {
      final remoteVisits = await remoteDataSource.getAllHealthVisits();
      return Right(remoteVisits);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logHealthVisit(HealthVisit visit) async {
    try {
      final model = HealthVisitModel(
        id: visit.id,
        studentId: visit.studentId,
        date: visit.date,
        reason: visit.reason,
        treatment: visit.treatment,
        medication: visit.medication,
      );
      await remoteDataSource.logHealthVisit(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
