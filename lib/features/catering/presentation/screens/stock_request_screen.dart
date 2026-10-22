import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../../domain/entities/stock_request.dart';
import '../../domain/entities/food_item.dart';
import '../bloc/catering_bloc.dart';
import '../bloc/catering_event.dart';
import '../bloc/catering_state.dart';

class StockRequestScreen extends StatefulWidget {
  const StockRequestScreen({super.key});

  @override
  State<StockRequestScreen> createState() => _StockRequestScreenState();
}

class _StockRequestScreenState extends State<StockRequestScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CateringBloc>().add(LoadStockRequests());
    context.read<CateringBloc>().add(LoadInventoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Requests')),
      body: BlocBuilder<CateringBloc, CateringState>(
        builder: (context, state) {
          if (state is CateringLoading && state is! StockRequestsLoaded) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is StockRequestsLoaded) {
            final requests = state.requests;
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 16),
                    const Text('No stock requests found'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showCreateRequestDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Request'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text('Request #${request.id.substring(0, 8)}'),
                    subtitle: Text(
                      'Status: ${request.status.name.toUpperCase()}',
                    ),
                    trailing: _getStatusChip(request.status, semanticColors),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Requested By: ${request.requestedBy}'),
                            Text(
                              'Date: ${request.requestedAt.toLocal().toString().split('.')[0]}',
                            ),
                            const Divider(),
                            ...request.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.foodItemName),
                                    Text('${item.quantity} ${item.unit}'),
                                  ],
                                ),
                              ),
                            ),
                            if (request.comments != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Comments: ${request.comments}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRequestDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getStatusChip(StockRequestStatus status, SemanticColors colors) {
    Color color;
    switch (status) {
      case StockRequestStatus.pending:
        color = Colors.black;
        break;
      case StockRequestStatus.approved:
        color = colors.success;
        break;
      case StockRequestStatus.issued:
        color = Colors.black;
        break;
      case StockRequestStatus.rejected:
        color = colors.error;
        break;
    }
    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _showCreateRequestDialog(BuildContext context) {
    // This would ideally be a separate full screen or a more complex dialog
    // For now, a placeholder logic to show how it connects
    final cateringState = context.read<CateringBloc>().state;
    List<FoodItem> inventory = [];
    if (cateringState is InventoryLoaded) {
      inventory = cateringState.items;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateStockRequestSheet(inventory: inventory),
    );
  }
}

class _CreateStockRequestSheet extends StatefulWidget {
  final List<FoodItem> inventory;
  const _CreateStockRequestSheet({required this.inventory});

  @override
  State<_CreateStockRequestSheet> createState() =>
      _CreateStockRequestSheetState();
}

class _CreateStockRequestSheetState extends State<_CreateStockRequestSheet> {
  final List<StockRequestItem> _selectedItems = [];
  FoodItem? _currentItem;
  final _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Stock Request',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<FoodItem>(
            items: widget.inventory
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (val) => setState(() => _currentItem = val),
            decoration: const InputDecoration(labelText: 'Select Food Item'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    suffixText: _currentItem?.unit ?? '',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () {
                  if (_currentItem != null &&
                      _quantityController.text.isNotEmpty) {
                    setState(() {
                      _selectedItems.add(
                        StockRequestItem(
                          foodItemId: _currentItem!.id,
                          foodItemName: _currentItem!.name,
                          quantity: double.parse(_quantityController.text),
                          unit: _currentItem!.unit,
                        ),
                      );
                      _quantityController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedItems.isNotEmpty) ...[
            const Text(
              'Items in Request:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._selectedItems.map(
              (item) => ListTile(
                title: Text(item.foodItemName),
                dense: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${item.quantity} ${item.unit}'),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.black,
                      ),
                      onPressed: () =>
                          setState(() => _selectedItems.remove(item)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedItems.isEmpty
                  ? null
                  : () {
                      final request = StockRequest(
                        id: '', // Generated by backend
                        requestedBy: 'Catering Manager', // Get from Auth
                        requestedAt: DateTime.now(),
                        items: _selectedItems,
                      );
                      context.read<CateringBloc>().add(
                        CreateStockRequestEvent(request),
                      );
                      Navigator.pop(context);
                    },
              child: const Text('Submit Request'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
