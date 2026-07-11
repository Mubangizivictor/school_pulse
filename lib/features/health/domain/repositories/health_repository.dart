import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_visit.dart';

abstract class HealthRepository {
  Future<Either<Failure, List<HealthVisit>>> getHealthVisits(String studentId);
}
