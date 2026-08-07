import '../entities/emergency_event.dart';
import '../repositories/gate_ops_repository.dart';

class WatchActiveEmergencies {
  final GateOpsRepository repository;
  WatchActiveEmergencies(this.repository);
  Stream<List<EmergencyEvent>> call(String schoolId) =>
      repository.watchActiveEmergencies(schoolId);
}
