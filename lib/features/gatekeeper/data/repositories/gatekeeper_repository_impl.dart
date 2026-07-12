import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/gatekeeper_repository.dart';
import '../../presentation/bloc/gatekeeper_state.dart';
import '../datasources/gatekeeper_remote_data_source.dart';

class GatekeeperRepositoryImpl implements GatekeeperRepository {
  final GatekeeperRemoteDataSource remoteDataSource;

  GatekeeperRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GatekeeperLoaded>> getDashboardData() async {
    try {
      final visitors = await remoteDataSource.getRecentVisitors();
      final studentsIn = await remoteDataSource.getStudentsInCount();
      final studentsOut = await remoteDataSource.getStudentsOutCount();
      
      // Calculate active visitors (those without exitTime)
      final activeVisitors = visitors.where((v) => v.exitTime == null).length;

      return Right(GatekeeperLoaded(
        recentVisitors: visitors,
        studentsIn: studentsIn,
        studentsOut: studentsOut,
        activeVisitors: activeVisitors,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logVisitor(VisitorLog visitor) async {
    try {
      await remoteDataSource.logVisitor(visitor);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signExit(String visitorId) async {
    try {
      await remoteDataSource.signExit(visitorId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
