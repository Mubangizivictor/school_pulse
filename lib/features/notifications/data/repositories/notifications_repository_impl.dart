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
    List<String> studentIds,
  ) async {
    try {
      final alerts = await remoteDataSource.getAlerts(studentIds);
      return Right(alerts);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
