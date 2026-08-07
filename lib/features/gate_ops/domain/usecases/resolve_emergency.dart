import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../repositories/gate_ops_repository.dart';

class ResolveEmergency {
  final GateOpsRepository repository;
  ResolveEmergency(this.repository);
  Future<Either<Failure, void>> call(String emergencyId) =>
      repository.resolveEmergency(emergencyId);
}
