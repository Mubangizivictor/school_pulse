import '../entities/visitor.dart';
import '../repositories/gate_ops_repository.dart';

class WatchVisitors {
  final GateOpsRepository repository;
  WatchVisitors(this.repository);
  Stream<List<Visitor>> call(String schoolId) =>
      repository.watchVisitors(schoolId);
}
