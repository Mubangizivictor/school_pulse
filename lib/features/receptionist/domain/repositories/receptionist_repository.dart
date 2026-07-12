import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/receptionist_state.dart';

abstract class ReceptionistRepository {
  Future<Either<Failure, ReceptionistLoaded>> getDashboardData();
  Future<Either<Failure, void>> scheduleAppointment(Appointment appointment);
}
