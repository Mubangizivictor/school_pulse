import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discipline_incident.dart';

abstract class DisciplineRepository {
  Future<Either<Failure, List<DisciplineIncident>>> getDisciplineIncidents(String studentId);
  Future<Either<Failure, List<DisciplineIncident>>> getRecentDisciplineIncidents();
}
