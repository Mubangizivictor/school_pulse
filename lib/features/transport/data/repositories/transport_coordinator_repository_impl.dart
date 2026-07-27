import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/transport_coordinator_repository.dart';
import '../../presentation/bloc/transport_coordinator_state.dart';
import '../datasources/transport_remote_data_source.dart';

class TransportCoordinatorRepositoryImpl implements TransportCoordinatorRepository {
  final TransportRemoteDataSource remoteDataSource;

  TransportCoordinatorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TransportCoordinatorLoaded>> getDashboardData() async {
    try {
      final routes = await remoteDataSource.getActiveRoutes();
      final stats = await remoteDataSource.getTransportStats();
      
      return Right(TransportCoordinatorLoaded(
        activeBuses: stats['activeBuses'] ?? 0,
        totalStudents: stats['totalStudents'] ?? 0,
        studentsInTransit: stats['studentsInTransit'] ?? 0,
        routes: routes,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> startTrip(String routeId) async {
    try {
      await remoteDataSource.startTrip(routeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endTrip(String routeId) async {
    try {
      await remoteDataSource.endTrip(routeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logStudentPickup(String routeId, String studentId) async {
    try {
      await remoteDataSource.logStudentPickup(routeId, studentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
