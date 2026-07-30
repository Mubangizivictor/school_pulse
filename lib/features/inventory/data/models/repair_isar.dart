import 'package:isar/isar.dart';
import '../../domain/entities/repair.dart';

part 'repair_isar.g.dart';

@collection
class RepairIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String repairId;

  late String assetId;
  late String assetName;
  late String description;
  String? technicianName;
  late double estimatedCost;
  late double actualCost;

  @enumerated
  late RepairStatus status;

  late List<String> partsUsed;
  late DateTime requestDate;
  DateTime? completionDate;
  String? notes;
  String? beforePhotoUrl;
  String? afterPhotoUrl;
  late bool isSynced;

  RepairIsar();

  RepairRecord toEntity() {
    return RepairRecord(
      id: repairId,
      assetId: assetId,
      assetName: assetName,
      description: description,
      technicianName: technicianName,
      estimatedCost: estimatedCost,
      actualCost: actualCost,
      status: status,
      partsUsed: partsUsed,
      requestDate: requestDate,
      completionDate: completionDate,
      notes: notes,
      beforePhotoUrl: beforePhotoUrl,
      afterPhotoUrl: afterPhotoUrl,
    );
  }

  factory RepairIsar.fromEntity(RepairRecord entity, {bool isSynced = true}) {
    return RepairIsar()
      ..repairId = entity.id
      ..assetId = entity.assetId
      ..assetName = entity.assetName
      ..description = entity.description
      ..technicianName = entity.technicianName
      ..estimatedCost = entity.estimatedCost
      ..actualCost = entity.actualCost
      ..status = entity.status
      ..partsUsed = entity.partsUsed
      ..requestDate = entity.requestDate
      ..completionDate = entity.completionDate
      ..notes = entity.notes
      ..beforePhotoUrl = entity.beforePhotoUrl
      ..afterPhotoUrl = entity.afterPhotoUrl
      ..isSynced = isSynced;
  }
}
