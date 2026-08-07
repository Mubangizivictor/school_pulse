import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/emergency_event.dart';
import '../repositories/gate_ops_repository.dart';

class TriggerEmergency {
  final GateOpsRepository repository;
  TriggerEmergency(this.repository);
  Future<Either<Failure, void>> call(EmergencyEvent emergency) =>
      repository.triggerEmergency(emergency);
}
