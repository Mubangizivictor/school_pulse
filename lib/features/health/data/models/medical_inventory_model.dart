import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/medical_inventory.dart';

DateTime? _readOptionalInventoryDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class MedicalInventoryItemModel extends MedicalInventoryItem {
  const MedicalInventoryItemModel({
    required super.id,
    required super.name,
    required super.type,
    required super.category,
    required super.quantity,
    required super.unit,
    required super.reorderLevel,
    super.supplier,
    super.purchaseDate,
    super.expiryDate,
    super.batchNumber,
    super.schoolId,
  });

  factory MedicalInventoryItemModel.fromJson(Map<String, dynamic> json) {
    return MedicalInventoryItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      type: MedicalItemType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MedicalItemType.supply,
      ),
      category: json['category'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String,
      reorderLevel: (json['reorderLevel'] as num?)?.toInt() ?? 0,
      supplier: json['supplier'] as String?,
      purchaseDate: _readOptionalInventoryDate(json['purchaseDate']),
      expiryDate: _readOptionalInventoryDate(json['expiryDate']),
      batchNumber: json['batchNumber'] as String?,
      schoolId: json['schoolId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'reorderLevel': reorderLevel,
      'supplier': supplier,
      'purchaseDate': purchaseDate == null
          ? null
          : Timestamp.fromDate(purchaseDate!),
      'expiryDate': expiryDate == null ? null : Timestamp.fromDate(expiryDate!),
      'batchNumber': batchNumber,
      'schoolId': schoolId,
    };
  }
}
