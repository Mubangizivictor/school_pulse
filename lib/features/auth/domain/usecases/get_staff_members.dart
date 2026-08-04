import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';

class GetStaffMembers implements UseCase<List<UserEntity>, NoParams> {
  final AuthRepository repository;

  GetStaffMembers(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    final currentUserResult = await repository.getCurrentUser();
    Failure? failure;
    UserEntity? user;
    currentUserResult.fold((f) => failure = f, (u) => user = u);
    if (failure != null) return Left(failure!);
    if (user == null || user!.schoolId.isEmpty) {
      return const Left(ServerFailure('Not signed in to a school.'));
    }
    return await repository.getStaffMembers(user!.schoolId);
  }
}
