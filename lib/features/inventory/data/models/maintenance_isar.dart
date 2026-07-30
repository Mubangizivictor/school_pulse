import 'package:isar/isar.dart';
import '../../domain/entities/maintenance.dart';

part 'maintenance_isar.g.dart';

@collection
class MaintenanceIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String maintenanceId;

  late String assetId;
  late String assetName;

  @enumerated
  late MaintenanceType type;

  late String description;
  late DateTime scheduledDate;
  DateTime? completionDate;

  @enumerated
  late MaintenanceStatus status;

  String? performedBy;
  late double cost;
  String? notes;
  late bool isSynced;

  MaintenanceIsar();

  MaintenanceRecord toEntity() {
    return MaintenanceRecord(
      id: maintenanceId,
      assetId: assetId,
      assetName: assetName,
      type: type,
      description: description,
      scheduledDate: scheduledDate,
      completionDate: completionDate,
      status: status,
      performedBy: performedBy,
      cost: cost,
      notes: notes,
    );
  }

  factory MaintenanceIsar.fromEntity(MaintenanceRecord entity, {bool isSynced = true}) {
    return MaintenanceIsar()
      ..maintenanceId = entity.id
      ..assetId = entity.assetId
      ..assetName = entity.assetName
      ..type = entity.type
      ..description = entity.description
      ..scheduledDate = entity.scheduledDate
      ..completionDate = entity.completionDate
      ..status = entity.status
      ..performedBy = entity.performedBy
      ..cost = entity.cost
      ..notes = entity.notes
      ..isSynced = isSynced;
  }
}
