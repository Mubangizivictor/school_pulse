import 'package:isar/isar.dart';
import '../../domain/entities/package_delivery.dart';

part 'package_delivery_isar.g.dart';

@collection
class PackageDeliveryIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String packageId;

  late String schoolId;
  late String recipientName;
  String? recipientId;
  late String courierName;
  String? courierPhone;
  String? trackingNumber;
  late DateTime arrivalTime;
  DateTime? collectedTime;
  String? collectedBy;
  late bool isCollected;

  PackageDeliveryIsar();

  factory PackageDeliveryIsar.fromEntity(PackageDelivery entity) {
    return PackageDeliveryIsar()
      ..packageId = entity.id
      ..schoolId = entity.schoolId
      ..recipientName = entity.recipientName
      ..recipientId = entity.recipientId
      ..courierName = entity.courierName
      ..courierPhone = entity.courierPhone
      ..trackingNumber = entity.trackingNumber
      ..arrivalTime = entity.arrivalTime
      ..collectedTime = entity.collectedTime
      ..collectedBy = entity.collectedBy
      ..isCollected = entity.isCollected;
  }

  PackageDelivery toEntity() {
    return PackageDelivery(
      id: packageId,
      schoolId: schoolId,
      recipientName: recipientName,
      recipientId: recipientId,
      courierName: courierName,
      courierPhone: courierPhone,
      trackingNumber: trackingNumber,
      arrivalTime: arrivalTime,
      collectedTime: collectedTime,
      collectedBy: collectedBy,
      isCollected: isCollected,
    );
  }
}
