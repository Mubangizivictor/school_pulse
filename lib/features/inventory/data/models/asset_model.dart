import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/asset.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.schoolId,
    required super.assetNumber,
    required super.qrCode,
    required super.name,
    required super.category,
    super.brand,
    super.model,
    super.serialNumber,
    required super.purchaseDate,
    required super.purchasePrice,
    super.supplierId,
    super.warrantyExpiry,
    super.assignedDepartment,
    super.assignedStaffId,
    super.assignedRoom,
    required super.condition,
    required super.status,
    super.photoUrl,
    super.documentUrls,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      assetNumber: data['assetNumber'] ?? '',
      qrCode: data['qrCode'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'],
      model: data['model'],
      serialNumber: data['serialNumber'],
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      purchasePrice: (data['purchasePrice'] as num).toDouble(),
      supplierId: data['supplierId'],
      warrantyExpiry: data['warrantyExpiry'] != null
          ? (data['warrantyExpiry'] as Timestamp).toDate()
          : null,
      assignedDepartment: data['assignedDepartment'],
      assignedStaffId: data['assignedStaffId'],
      assignedRoom: data['assignedRoom'],
      condition: data['condition'] ?? '',
      status: AssetStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AssetStatus.active,
      ),
      photoUrl: data['photoUrl'],
      documentUrls: List<String>.from(data['documentUrls'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'assetNumber': assetNumber,
      'qrCode': qrCode,
      'name': name,
      'category': category,
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'purchasePrice': purchasePrice,
      'supplierId': supplierId,
      'warrantyExpiry': warrantyExpiry != null ? Timestamp.fromDate(warrantyExpiry!) : null,
      'assignedDepartment': assignedDepartment,
      'assignedStaffId': assignedStaffId,
      'assignedRoom': assignedRoom,
      'condition': condition,
      'status': status.name,
      'photoUrl': photoUrl,
      'documentUrls': documentUrls,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AssetModel.fromEntity(Asset asset) {
    return AssetModel(
      id: asset.id,
      schoolId: asset.schoolId,
      assetNumber: asset.assetNumber,
      qrCode: asset.qrCode,
      name: asset.name,
      category: asset.category,
      brand: asset.brand,
      model: asset.model,
      serialNumber: asset.serialNumber,
      purchaseDate: asset.purchaseDate,
      purchasePrice: asset.purchasePrice,
      supplierId: asset.supplierId,
      warrantyExpiry: asset.warrantyExpiry,
      assignedDepartment: asset.assignedDepartment,
      assignedStaffId: asset.assignedStaffId,
      assignedRoom: asset.assignedRoom,
      condition: asset.condition,
      status: asset.status,
      photoUrl: asset.photoUrl,
      documentUrls: asset.documentUrls,
      notes: asset.notes,
      createdAt: asset.createdAt,
      updatedAt: asset.updatedAt,
    );
  }
}
