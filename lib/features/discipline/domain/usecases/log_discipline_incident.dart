import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discipline_incident.dart';
import '../repositories/discipline_repository.dart';

class LogDisciplineIncident {
  final DisciplineRepository repository;

  LogDisciplineIncident(this.repository);

  Future<Either<Failure, void>> call(DisciplineIncident incident) async {
    return await repository.logIncident(incident);
  }
}
