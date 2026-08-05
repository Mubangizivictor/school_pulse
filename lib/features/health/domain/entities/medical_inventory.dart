import 'package:equatable/equatable.dart';

enum MedicalItemType {
  medication,
  supply, // Gloves, masks, etc.
  equipment, // Thermometers, etc.
}

class MedicalInventoryItem extends Equatable {
  final String id;
  final String name;
  final MedicalItemType type;
  final String category;
  final int quantity;
  final String unit; // e.g., tablets, bottles, pieces
  final int reorderLevel;
  final String? supplier;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? schoolId;

  const MedicalInventoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    this.supplier,
    this.purchaseDate,
    this.expiryDate,
    this.batchNumber,
    this.schoolId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    category,
    quantity,
    unit,
    reorderLevel,
    supplier,
    purchaseDate,
    expiryDate,
    batchNumber,
    schoolId,
  ];
}
