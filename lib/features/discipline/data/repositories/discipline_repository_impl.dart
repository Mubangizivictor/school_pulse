import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/discipline_incident.dart';
import '../../domain/entities/counseling_session.dart';
import '../../domain/repositories/discipline_repository.dart';
import '../datasources/discipline_remote_data_source.dart';
import '../models/discipline_incident_model.dart';
import '../models/counseling_session_model.dart';

class DisciplineRepositoryImpl implements DisciplineRepository {
  final DisciplineRemoteDataSource remoteDataSource;

  DisciplineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DisciplineIncident>>> getDisciplineIncidents(String studentId) async {
    try {
      final remoteIncidents = await remoteDataSource.getDisciplineIncidents(studentId);
      return Right(remoteIncidents);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DisciplineIncident>>> getRecentDisciplineIncidents() async {
    try {
      final remoteIncidents = await remoteDataSource.getRecentDisciplineIncidents();
      return Right(remoteIncidents);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logIncident(DisciplineIncident incident) async {
    try {
      final model = DisciplineIncidentModel(
        id: incident.id,
        studentId: incident.studentId,
        date: incident.date,
        description: incident.description,
        severity: incident.severity,
        resolution: incident.resolution,
        counselingNotes: incident.counselingNotes,
      );
      await remoteDataSource.logIncident(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CounselingSession>>> getCounselingSessions() async {
    try {
      final remoteSessions = await remoteDataSource.getCounselingSessions();
      return Right(remoteSessions);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logCounselingSession(CounselingSession session) async {
    try {
      final model = CounselingSessionModel(
        id: session.id,
        studentId: session.studentId,
        counselorId: session.counselorId,
        date: session.date,
        reason: session.reason,
        notes: session.notes,
        recommendations: session.recommendations,
      );
      await remoteDataSource.logCounselingSession(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
