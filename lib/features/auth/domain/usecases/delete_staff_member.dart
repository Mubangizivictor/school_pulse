import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class DeleteStaffMember {
  final AuthRepository repository;
  DeleteStaffMember(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.deleteStaffMember(userId);
  }
}
