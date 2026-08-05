import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/discipline_incident.dart';
import '../entities/counseling_session.dart';

abstract class DisciplineRepository {
  Future<Either<Failure, List<DisciplineIncident>>> getDisciplineIncidents(
    String studentId,
  );
  Future<Either<Failure, List<DisciplineIncident>>>
  getRecentDisciplineIncidents();
  Future<Either<Failure, void>> logIncident(DisciplineIncident incident);

  Future<Either<Failure, List<CounselingSession>>> getCounselingSessions();
  Future<Either<Failure, void>> logCounselingSession(CounselingSession session);
}
