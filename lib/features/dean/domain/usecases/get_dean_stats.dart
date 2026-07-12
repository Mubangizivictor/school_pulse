import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dean_stats.dart';
import '../repositories/dean_repository.dart';

class GetDeanStats implements UseCase<DeanStats, NoParams> {
  final DeanRepository repository;

  GetDeanStats(this.repository);

  @override
  Future<Either<Failure, DeanStats>> call(NoParams params) async {
    return await repository.getDeanStats();
  }
}
