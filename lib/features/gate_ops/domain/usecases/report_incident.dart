import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/security_incident.dart';
import '../repositories/gate_ops_repository.dart';

class ReportIncident {
  final GateOpsRepository repository;
  ReportIncident(this.repository);
  Future<Either<Failure, void>> call(SecurityIncident incident) =>
      repository.reportIncident(incident);
}
