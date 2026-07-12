import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/security_repository.dart';
import '../../presentation/bloc/security_state.dart';
import '../datasources/security_remote_data_source.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityRemoteDataSource remoteDataSource;

  SecurityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SecurityLoaded>> getDashboardData() async {
    try {
      final stats = await remoteDataSource.getSecurityStats();
      final alerts = await remoteDataSource.getRecentAlerts();
      
      return Right(SecurityLoaded(
        guardsOnDuty: stats['guardsOnDuty'] ?? 0,
        activeIncidents: stats['activeIncidents'] ?? 0,
        visitorsIn: stats['visitorsIn'] ?? 0,
        recentAlerts: alerts,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
