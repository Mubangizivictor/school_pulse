import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/movement_event.dart';
import '../repositories/gate_ops_repository.dart';

class RecordMovementEvent {
  final GateOpsRepository repository;
  RecordMovementEvent(this.repository);
  Future<Either<Failure, void>> call(MovementEvent event) =>
      repository.recordMovementEvent(event);
}
