import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../presentation/bloc/transport_coordinator_state.dart';

abstract class TransportCoordinatorRepository {
  Future<Either<Failure, TransportCoordinatorLoaded>> getDashboardData();
}
