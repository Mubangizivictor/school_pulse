import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/pickup_authorization.dart';
import '../repositories/gate_ops_repository.dart';

class AddPickupAuthorization {
  final GateOpsRepository repository;
  AddPickupAuthorization(this.repository);
  Future<Either<Failure, void>> call(PickupAuthorization authorization) =>
      repository.addPickupAuthorization(authorization);
}
