import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_visit.dart';
import '../repositories/health_repository.dart';

class GetAllHealthVisits {
  final HealthRepository repository;

  GetAllHealthVisits(this.repository);

  Future<Either<Failure, List<HealthVisit>>> call() async {
    return await repository.getAllHealthVisits();
  }
}
