import '../../domain/entities/clinic_visit.dart';

abstract class HealthLocalDataSource {
  /// Caches [visit] locally with a pending sync status. Safe to call
  /// repeatedly for the same [ClinicVisit.id] - the underlying Isar `put`
  /// replaces the existing row rather than duplicating it.
  Future<void> cacheClinicVisit(ClinicVisit visit);

  Future<List<ClinicVisit>> getPendingClinicVisits(String schoolId);

  Future<void> markClinicVisitSynced(String visitId);
}
