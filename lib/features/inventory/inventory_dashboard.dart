import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/inventory/domain/entities/inventory_item.dart';
import 'package:school_pulse/features/inventory/domain/entities/stock_movement.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/inventory/presentation/screens/procurement_screen.dart';
import 'package:school_pulse/features/inventory/presentation/screens/medical_supply_requests_screen.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store & Inventory'),
        actions: const [NotificationBellButton()],
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading || state is InventoryInitial) {
            return const _LoadingView();
          }

          if (state is InventoryError) {
            return Center(child: Text(state.message));
          }

          if (state is InventoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<InventoryBloc>().add(LoadInventory()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Stock Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      DashboardStatCard(
                        title: 'Low Stock Items',
                        value: state.items
                            .where((i) => i.isLowStock)
                            .length
                            .toDouble(),
                        icon: Icons.warning_amber_rounded,
                        color: semanticColors.error,
                      ),
                      DashboardStatCard(
                        title: 'Total Items',
                        value: state.items.length.toDouble(),
                        icon: Icons.inventory_2_outlined,
                        color: semanticColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Recent Stock Movements'),
                  const SizedBox(height: 12),
                  if (state.movements.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No stock movements recorded yet.'),
                    )
                  else
                    ...state.movements
                        .take(5)
                        .map(
                          (m) => _InventoryItemTile(
                            name: m.itemName,
                            status: m.type == StockMovementType.restock
                                ? 'Restocked'
                                : 'Issued',
                            quantity: m.type == StockMovementType.restock
                                ? '+${m.quantity}'
                                : '-${m.quantity}',
                            date: DateFormatter.relative(m.date),
                            color: m.type == StockMovementType.restock
                                ? semanticColors.success
                                : semanticColors.warning,
                          ),
                        ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickAction(
                        label: 'Add Stock',
                        icon: Icons.add_box_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () => _showAddStockDialog(context, state.items),
                      ),
                      _QuickAction(
                        label: 'Issue Item',
                        icon: Icons.outbox_outlined,
                        color: semanticColors.info,
                        onTap: () => _showIssueItemDialog(context, state.items),
                      ),
                      _QuickAction(
                        label: 'Inventory Audit',
                        icon: Icons.assignment_turned_in_outlined,
                        color: semanticColors.success,
                        onTap: () => _showAuditSheet(context, state.items),
                      ),
                      _QuickAction(
                        label: 'Procurement',
                        icon: Icons.shopping_basket_outlined,
                        color: Colors.deepPurple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProcurementScreen(),
                          ),
                        ),
                      ),
                      _QuickAction(
                        label: 'Medical Requests',
                        icon: Icons.medical_services_outlined,
                        color: Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MedicalSupplyRequestsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, List<InventoryItem> items) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final unitController = TextEditingController(text: 'Units');
    final quantityController = TextEditingController();
    final thresholdController = TextEditingController(text: '5');
    String? selectedItemId = items.isNotEmpty ? items.first.id : null;
    bool isNewItem = items.isEmpty;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add Stock'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (items.isNotEmpty)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('New item'),
                    value: isNewItem,
                    onChanged: (value) =>
                        setDialogState(() => isNewItem = value),
                  ),
                if (!isNewItem && items.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: selectedItemId,
                    decoration: const InputDecoration(labelText: 'Item'),
                    items: items
                        .map(
                          (i) => DropdownMenuItem(
                            value: i.id,
                            child: Text(i.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedItemId = value),
                  )
                else ...[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit (e.g. Reams, Boxes)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Low Stock Threshold',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity to Add',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text.trim());
                if (quantity == null || quantity <= 0) return;

                if (isNewItem) {
                  if (nameController.text.trim().isEmpty) return;
                  context.read<InventoryBloc>().add(
                    AddStockRequested(
                      itemId: '',
                      itemName: nameController.text.trim(),
                      category: categoryController.text.trim().isEmpty
                          ? 'General'
                          : categoryController.text.trim(),
                      unit: unitController.text.trim().isEmpty
                          ? 'Units'
                          : unitController.text.trim(),
                      lowStockThreshold:
                          int.tryParse(thresholdController.text.trim()) ?? 5,
                      quantity: quantity,
                    ),
                  );
                } else {
                  if (selectedItemId == null) return;
                  final item = items.firstWhere((i) => i.id == selectedItemId);
                  context.read<InventoryBloc>().add(
                    AddStockRequested(
                      itemId: item.id,
                      itemName: item.name,
                      category: item.category,
                      unit: item.unit,
                      lowStockThreshold: item.lowStockThreshold,
                      quantity: quantity,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Add Stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIssueItemDialog(BuildContext context, List<InventoryItem> items) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No items in stock yet. Add stock first.'),
        ),
      );
      return;
    }

    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    String selectedItemId = items.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Issue Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedItemId,
                decoration: const InputDecoration(labelText: 'Item'),
                items: items
                    .map(
                      (i) => DropdownMenuItem(
                        value: i.id,
                        child: Text('${i.name} (${i.quantity} ${i.unit})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(
                  () => selectedItemId = value ?? selectedItemId,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Issue',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Issued To / Note',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text.trim());
                final item = items.firstWhere((i) => i.id == selectedItemId);
                if (quantity == null ||
                    quantity <= 0 ||
                    quantity > item.quantity) {
                  return;
                }
                context.read<InventoryBloc>().add(
                  IssueItemRequested(
                    itemId: selectedItemId,
                    quantity: quantity,
                    note: noteController.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Issue'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuditSheet(BuildContext context, List<InventoryItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) {
          if (items.isEmpty) {
            return const Center(child: Text('No inventory items yet.'));
          }
          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.category),
                trailing: Text(
                  '${item.quantity} ${item.unit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.isLowStock
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Skeleton(height: 30, width: 150),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(child: Skeleton(height: 100)),
            SizedBox(width: 12),
            Expanded(child: Skeleton(height: 100)),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(height: 20, width: 180),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 72),
          ),
        ),
      ],
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final String name;
  final String status;
  final String quantity;
  final String date;
  final Color color;

  const _InventoryItemTile({
    required this.name,
    required this.status,
    required this.quantity,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'Restocked' ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '$status • $date',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            quantity,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
