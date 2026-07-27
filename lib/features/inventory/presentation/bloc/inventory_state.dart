import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/inventory/domain/entities/inventory_item.dart';
import 'package:school_pulse/features/inventory/domain/entities/stock_movement.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  final List<StockMovement> movements;

  const InventoryLoaded({required this.items, required this.movements});

  @override
  List<Object?> get props => [items, movements];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
