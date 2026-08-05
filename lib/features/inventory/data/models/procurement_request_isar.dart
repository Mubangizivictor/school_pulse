import 'package:isar/isar.dart';
import '../../domain/entities/procurement_request.dart';

part 'procurement_request_isar.g.dart';

@collection
class ProcurementRequestIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String requestId;
  late String requesterId;
  late String requesterName;
  late String itemName;
  late int quantity;
  late String reason;
  @enumerated
  late ProcurementStatus status;
  late DateTime date;
  String? directorNote;
  bool isSynced = true;

  ProcurementRequestIsar();

  factory ProcurementRequestIsar.fromEntity(
    ProcurementRequest entity, {
    bool isSynced = true,
  }) {
    return ProcurementRequestIsar()
      ..requestId = entity.id
      ..requesterId = entity.requesterId
      ..requesterName = entity.requesterName
      ..itemName = entity.itemName
      ..quantity = entity.quantity
      ..reason = entity.reason
      ..status = entity.status
      ..date = entity.date
      ..directorNote = entity.directorNote
      ..isSynced = isSynced;
  }

  ProcurementRequest toEntity() {
    return ProcurementRequest(
      id: requestId,
      requesterId: requesterId,
      requesterName: requesterName,
      itemName: itemName,
      quantity: quantity,
      reason: reason,
      status: status,
      date: date,
      directorNote: directorNote,
    );
  }
}
