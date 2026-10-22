import 'package:isar/isar.dart';
import '../../domain/entities/clinic_visit.dart';
import '../models/clinic_visit_isar.dart';
import 'health_local_data_source.dart';

HealthLocalDataSource create({dynamic isar}) =>
    HealthLocalDataSourceImpl(isar: isar as Isar);

class HealthLocalDataSourceImpl implements HealthLocalDataSource {
  final Isar isar;

  HealthLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheClinicVisit(ClinicVisit visit) async {
    final row = ClinicVisitIsar.fromEntity(visit);
    await isar.writeTxn(() => isar.clinicVisitIsars.put(row));
  }

  @override
  Future<List<ClinicVisit>> getPendingClinicVisits(String schoolId) async {
    final rows = await isar.clinicVisitIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .syncStatusEqualTo(HealthSyncStatus.pending.name)
        .findAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> markClinicVisitSynced(String visitId) async {
    await isar.writeTxn(() async {
      final row = await isar.clinicVisitIsars
          .filter()
          .visitIdEqualTo(visitId)
          .findFirst();
      if (row == null) return;
      row.syncStatus = HealthSyncStatus.synced.name;
      await isar.clinicVisitIsars.put(row);
    });
  }
}
