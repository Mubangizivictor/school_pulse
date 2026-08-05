import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/exams_repository.dart';
import '../../presentation/bloc/exams_state.dart';
import '../datasources/exams_remote_data_source.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  final ExamsRemoteDataSource remoteDataSource;

  ExamsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExamsLoaded>> getDashboardData() async {
    try {
      final exams = await remoteDataSource.getUpcomingExams();
      final stats = await remoteDataSource.getExamsStats();

      return Right(
        ExamsLoaded(
          totalStudents: stats['totalStudents'] ?? 0,
          pendingResults: stats['pendingResults'] ?? 0,
          completionRate: (stats['completionRate'] ?? 0).toDouble(),
          upcomingExams: exams,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
