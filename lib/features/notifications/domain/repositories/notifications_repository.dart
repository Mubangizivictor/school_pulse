import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<Alert>>> getAlerts(List<String> studentIds, {List<String> groups = const []});
  Future<Either<Failure, void>> markAlertRead(String alertId, String uid);
}
