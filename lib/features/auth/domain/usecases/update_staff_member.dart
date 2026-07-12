import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateStaffMember {
  final AuthRepository repository;
  UpdateStaffMember(this.repository);

  Future<Either<Failure, void>> call(UserEntity user) async {
    return await repository.updateStaffMember(user);
  }
}
