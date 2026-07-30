import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkAlertRead {
  final NotificationsRepository repository;

  MarkAlertRead(this.repository);

  Future<Either<Failure, void>> call(String alertId, String uid) async {
    return await repository.markAlertRead(alertId, uid);
  }
}
