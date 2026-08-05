import 'package:equatable/equatable.dart';

enum AssetStatus {
  active,
  underRepair,
  maintenanceDue,
  disposed,
  lost,
  writtenOff,
}

class Asset extends Equatable {
  final String id;
  final String schoolId;
  final String assetNumber;
  final String qrCode;
  final String name;
  final String category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final DateTime purchaseDate;
  final double purchasePrice;
  final String? supplierId;
  final DateTime? warrantyExpiry;
  final String? assignedDepartment;
  final String? assignedStaffId;
  final String? assignedRoom;
  final String condition;
  final AssetStatus status;
  final String? photoUrl;
  final List<String> documentUrls;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.schoolId,
    required this.assetNumber,
    required this.qrCode,
    required this.name,
    required this.category,
    this.brand,
    this.model,
    this.serialNumber,
    required this.purchaseDate,
    required this.purchasePrice,
    this.supplierId,
    this.warrantyExpiry,
    this.assignedDepartment,
    this.assignedStaffId,
    this.assignedRoom,
    required this.condition,
    required this.status,
    this.photoUrl,
    this.documentUrls = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    assetNumber,
    qrCode,
    name,
    category,
    brand,
    model,
    serialNumber,
    purchaseDate,
    purchasePrice,
    supplierId,
    warrantyExpiry,
    assignedDepartment,
    assignedStaffId,
    assignedRoom,
    condition,
    status,
    photoUrl,
    documentUrls,
    notes,
    createdAt,
    updatedAt,
  ];
}
