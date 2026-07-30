import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ToggleStaffStatus {
  final AuthRepository repository;
  ToggleStaffStatus(this.repository);

  Future<Either<Failure, void>> call(String userId, bool isActive, {String? reason}) async {
    return await repository.toggleStaffActiveStatus(userId, isActive, reason: reason);
  }
}
