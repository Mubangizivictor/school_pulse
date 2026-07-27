import 'package:equatable/equatable.dart';

class MedicineStock extends Equatable {
  final String id;
  final String name;
  final String category; // e.g., Painkiller, Antibiotic
  final int quantity;
  final String unit; // e.g., Tablets, Bottles, Strips
  final DateTime expiryDate;
  final int lowStockThreshold;

  const MedicineStock({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.lowStockThreshold,
  });

  bool get isLowStock => quantity <= lowStockThreshold;
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, name, category, quantity, unit, expiryDate, lowStockThreshold];
}
