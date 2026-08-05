import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class AdminResetStaffPassword {
  final AuthRepository repository;
  AdminResetStaffPassword(this.repository);

  Future<Either<Failure, String>> call(String userId) async {
    return await repository.adminResetStaffPassword(userId);
  }
}
