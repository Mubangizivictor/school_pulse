import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/receptionist_repository.dart';
import '../../presentation/bloc/receptionist_state.dart';
import '../datasources/receptionist_remote_data_source.dart';

class ReceptionistRepositoryImpl implements ReceptionistRepository {
  final ReceptionistRemoteDataSource remoteDataSource;

  ReceptionistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReceptionistLoaded>> getDashboardData() async {
    try {
      final appointments = await remoteDataSource.getUpcomingAppointments();
      final totalVisitors = await remoteDataSource.getTotalVisitorsToday();
      
      return Right(ReceptionistLoaded(
        upcomingAppointments: appointments.length,
        totalVisitorsToday: totalVisitors,
        appointments: appointments,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleAppointment(Appointment appointment) async {
    try {
      await remoteDataSource.scheduleAppointment(appointment);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
