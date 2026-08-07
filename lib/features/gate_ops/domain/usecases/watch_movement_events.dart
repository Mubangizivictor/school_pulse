import '../entities/movement_event.dart';
import '../repositories/gate_ops_repository.dart';

class WatchMovementEvents {
  final GateOpsRepository repository;
  WatchMovementEvents(this.repository);
  Stream<List<MovementEvent>> call(
    String schoolId, {
    PersonType? personType,
    String? personId,
    String? gateId,
    DateTime? date,
  }) => repository.watchMovementEvents(
    schoolId,
    personType: personType,
    personId: personId,
    gateId: gateId,
    date: date,
  );
}
