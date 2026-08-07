import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../repositories/gate_ops_repository.dart';

class GetGateOpsDashboardStats {
  final GateOpsRepository repository;
  GetGateOpsDashboardStats(this.repository);
  Future<Either<Failure, GateOpsDashboardStats>> call(String schoolId) =>
      repository.getGateOpsDashboardStats(schoolId);
}
