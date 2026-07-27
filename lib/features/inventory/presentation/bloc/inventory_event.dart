import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddStockRequested extends InventoryEvent {
  final String itemId;
  final String itemName;
  final String category;
  final String unit;
  final int lowStockThreshold;
  final int quantity;

  const AddStockRequested({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.unit,
    required this.lowStockThreshold,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemId, itemName, category, unit, lowStockThreshold, quantity];
}

class IssueItemRequested extends InventoryEvent {
  final String itemId;
  final int quantity;
  final String note;

  const IssueItemRequested({
    required this.itemId,
    required this.quantity,
    required this.note,
  });

  @override
  List<Object?> get props => [itemId, quantity, note];
}
