import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/transport_coordinator_state.dart';

abstract class TransportCoordinatorRepository {
  Future<Either<Failure, TransportCoordinatorLoaded>> getDashboardData();
  Future<Either<Failure, void>> startTrip(String routeId);
  Future<Either<Failure, void>> endTrip(String routeId);
  Future<Either<Failure, void>> logStudentPickup(String routeId, String studentId);
}
