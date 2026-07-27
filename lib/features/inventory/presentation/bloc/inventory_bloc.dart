import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/inventory/domain/usecases/get_inventory_items.dart';
import 'package:school_pulse/features/inventory/domain/usecases/get_recent_movements.dart';
import 'package:school_pulse/features/inventory/domain/usecases/add_stock.dart';
import 'package:school_pulse/features/inventory/domain/usecases/issue_item.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItems getInventoryItems;
  final GetRecentMovements getRecentMovements;
  final AddStock addStock;
  final IssueItem issueItem;

  InventoryBloc({
    required this.getInventoryItems,
    required this.getRecentMovements,
    required this.addStock,
    required this.issueItem,
  }) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddStockRequested>(_onAddStock);
    on<IssueItemRequested>(_onIssueItem);
  }

  Future<void> _onLoadInventory(LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    final itemsResult = await getInventoryItems();
    final movementsResult = await getRecentMovements();

    itemsResult.fold(
      (failure) => emit(InventoryError('Failed to load inventory items')),
      (items) {
        movementsResult.fold(
          (failure) => emit(InventoryError('Failed to load stock movements')),
          (movements) => emit(InventoryLoaded(items: items, movements: movements)),
        );
      },
    );
  }

  Future<void> _onAddStock(AddStockRequested event, Emitter<InventoryState> emit) async {
    final result = await addStock(
      itemId: event.itemId,
      itemName: event.itemName,
      category: event.category,
      unit: event.unit,
      lowStockThreshold: event.lowStockThreshold,
      quantity: event.quantity,
    );

    result.fold(
      (failure) => emit(InventoryError('Failed to add stock')),
      (_) => add(LoadInventory()),
    );
  }

  Future<void> _onIssueItem(IssueItemRequested event, Emitter<InventoryState> emit) async {
    final result = await issueItem(
      itemId: event.itemId,
      quantity: event.quantity,
      note: event.note,
    );

    result.fold(
      (failure) => emit(InventoryError('Failed to issue item')),
      (_) => add(LoadInventory()),
    );
  }
}
