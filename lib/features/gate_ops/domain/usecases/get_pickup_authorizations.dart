import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/pickup_authorization.dart';
import '../repositories/gate_ops_repository.dart';

class GetPickupAuthorizations {
  final GateOpsRepository repository;
  GetPickupAuthorizations(this.repository);
  Future<Either<Failure, List<PickupAuthorization>>> call(
    String schoolId,
    String studentId,
  ) => repository.getPickupAuthorizations(schoolId, studentId);
}
