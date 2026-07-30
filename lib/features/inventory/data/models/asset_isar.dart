import 'package:isar/isar.dart';
import '../../domain/entities/asset.dart';

part 'asset_isar.g.dart';

@collection
class AssetIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String assetId;

  late String schoolId;
  late String assetNumber;
  late String qrCode;
  late String name;
  late String category;
  String? brand;
  String? model;
  String? serialNumber;
  late DateTime purchaseDate;
  late double purchasePrice;
  String? supplierId;
  DateTime? warrantyExpiry;
  String? assignedDepartment;
  String? assignedStaffId;
  String? assignedRoom;
  late String condition;

  @enumerated
  late AssetStatus status;

  String? photoUrl;
  List<String> documentUrls = const [];
  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isSynced;

  AssetIsar();

  factory AssetIsar.fromEntity(Asset entity, {bool isSynced = true}) {
    return AssetIsar()
      ..assetId = entity.id
      ..schoolId = entity.schoolId
      ..assetNumber = entity.assetNumber
      ..qrCode = entity.qrCode
      ..name = entity.name
      ..category = entity.category
      ..brand = entity.brand
      ..model = entity.model
      ..serialNumber = entity.serialNumber
      ..purchaseDate = entity.purchaseDate
      ..purchasePrice = entity.purchasePrice
      ..supplierId = entity.supplierId
      ..warrantyExpiry = entity.warrantyExpiry
      ..assignedDepartment = entity.assignedDepartment
      ..assignedStaffId = entity.assignedStaffId
      ..assignedRoom = entity.assignedRoom
      ..condition = entity.condition
      ..status = entity.status
      ..photoUrl = entity.photoUrl
      ..documentUrls = entity.documentUrls
      ..notes = entity.notes
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isSynced = isSynced;
  }

  Asset toEntity() {
    return Asset(
      id: assetId,
      schoolId: schoolId,
      assetNumber: assetNumber,
      qrCode: qrCode,
      name: name,
      category: category,
      brand: brand,
      model: model,
      serialNumber: serialNumber,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      supplierId: supplierId,
      warrantyExpiry: warrantyExpiry,
      assignedDepartment: assignedDepartment,
      assignedStaffId: assignedStaffId,
      assignedRoom: assignedRoom,
      condition: condition,
      status: status,
      photoUrl: photoUrl,
      documentUrls: documentUrls,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
