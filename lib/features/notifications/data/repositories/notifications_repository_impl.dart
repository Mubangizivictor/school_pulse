import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Alert>>> getAlerts(
    List<String> studentIds, {
    List<String> groups = const [],
  }) async {
    try {
      final alerts = await remoteDataSource.getAlerts(studentIds, groups: groups);
      return Right(alerts);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAlertRead(String alertId, String uid) async {
    try {
      await remoteDataSource.markAlertRead(alertId, uid);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
