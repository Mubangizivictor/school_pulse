import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discipline_incident.dart';
import '../repositories/discipline_repository.dart';

class GetDisciplineIncidents {
  final DisciplineRepository repository;

  GetDisciplineIncidents(this.repository);

  Future<Either<Failure, List<DisciplineIncident>>> call(
    String studentId,
  ) async {
    return await repository.getDisciplineIncidents(studentId);
  }
}
