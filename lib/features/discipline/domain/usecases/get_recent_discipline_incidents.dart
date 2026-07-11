import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discipline_incident.dart';
import '../repositories/discipline_repository.dart';

class GetRecentDisciplineIncidents {
  final DisciplineRepository repository;

  GetRecentDisciplineIncidents(this.repository);

  Future<Either<Failure, List<DisciplineIncident>>> call() async {
    return await repository.getRecentDisciplineIncidents();
  }
}
