import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_visit.dart';
import '../repositories/health_repository.dart';

class LogHealthVisit {
  final HealthRepository repository;

  LogHealthVisit(this.repository);

  Future<Either<Failure, void>> call(HealthVisit visit) async {
    return await repository.logHealthVisit(visit);
  }
}
