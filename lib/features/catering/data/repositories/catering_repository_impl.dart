import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/catering_repository.dart';
import '../../presentation/bloc/catering_state.dart';
import '../datasources/catering_remote_data_source.dart';

class CateringRepositoryImpl implements CateringRepository {
  final CateringRemoteDataSource remoteDataSource;

  CateringRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CateringLoaded>> getDashboardData() async {
    try {
      final meals = await remoteDataSource.getTodayMeals();
      final stats = await remoteDataSource.getCateringStats();
      
      return Right(CateringLoaded(
        todayMeals: meals,
        totalStudents: stats['totalStudents'] ?? 0,
        specialDiets: stats['specialDiets'] ?? 0,
        stockLevel: (stats['stockLevel'] ?? 0).toDouble(),
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
