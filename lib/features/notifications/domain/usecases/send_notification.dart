import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class SendNotificationUseCase {
  final NotificationsRepository repository;

  SendNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String title,
    required String body,
    required List<String> targetGroups,
    String? imageUrl,
  }) {
    return repository.sendNotification(
      title: title,
      body: body,
      targetGroups: targetGroups,
      imageUrl: imageUrl,
    );
  }
}
