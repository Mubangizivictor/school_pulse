import '../../domain/entities/clinic_visit.dart';
import 'health_local_data_source.dart';

HealthLocalDataSource create({dynamic isar}) =>
    const HealthLocalDataSourceWeb();

/// No local database on web - every write goes straight to Firestore via
/// HealthRepositoryImpl's network branch (WebNetworkInfo always reports
/// connected, so nothing is ever queued as pending here).
class HealthLocalDataSourceWeb implements HealthLocalDataSource {
  const HealthLocalDataSourceWeb();

  @override
  Future<void> cacheClinicVisit(ClinicVisit visit) async {}

  @override
  Future<List<ClinicVisit>> getPendingClinicVisits(String schoolId) async =>
      [];

  @override
  Future<void> markClinicVisitSynced(String visitId) async {}
}
