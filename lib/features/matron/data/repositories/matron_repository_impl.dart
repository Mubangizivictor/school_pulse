import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/matron_repository.dart';
import '../../presentation/bloc/matron_state.dart';
import '../datasources/matron_remote_data_source.dart';

class MatronRepositoryImpl implements MatronRepository {
  final MatronRemoteDataSource remoteDataSource;

  MatronRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MatronLoaded>> getDashboardData() async {
    try {
      final dormitories = await remoteDataSource.getDormitoriesStatus();
      final stats = await remoteDataSource.getAttendanceStats();
      
      return Right(MatronLoaded(
        dormitories: dormitories,
        totalStudents: stats['totalStudents'] ?? 0,
        studentsPresent: stats['studentsPresent'] ?? 0,
        studentsOnLeave: stats['studentsOnLeave'] ?? 0,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
