import '../entities/gate.dart';
import '../repositories/gate_ops_repository.dart';

class WatchGates {
  final GateOpsRepository repository;
  WatchGates(this.repository);
  Stream<List<Gate>> call(String schoolId) => repository.watchGates(schoolId);
}
