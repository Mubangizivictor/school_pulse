import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_visit.dart';
import '../repositories/health_repository.dart';

class GetHealthVisits {
  final HealthRepository repository;

  GetHealthVisits(this.repository);

  Future<Either<Failure, List<HealthVisit>>> call(String studentId) async {
    return await repository.getHealthVisits(studentId);
  }
}
