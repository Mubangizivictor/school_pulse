import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/alert.dart';
import '../repositories/notifications_repository.dart';

class GetAlerts {
  final NotificationsRepository repository;

  GetAlerts(this.repository);

  Future<Either<Failure, List<Alert>>> call(List<String> studentIds, {List<String> groups = const []}) async {
    return await repository.getAlerts(studentIds, groups: groups);
  }
}
