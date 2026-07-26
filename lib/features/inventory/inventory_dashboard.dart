import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/inventory/domain/entities/inventory_item.dart';
import 'package:school_pulse/features/inventory/domain/entities/stock_movement.dart';
import 'package:school_pulse/features/inventory/domain/usecases/get_inventory_items.dart';
import 'package:school_pulse/features/inventory/domain/usecases/get_recent_movements.dart';
import 'package:school_pulse/features/inventory/domain/usecases/add_stock.dart';
import 'package:school_pulse/features/inventory/domain/usecases/issue_item.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class _InventorySnapshot {
  final List<InventoryItem> items;
  final List<StockMovement> movements;

  const _InventorySnapshot({required this.items, required this.movements});
}

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() => _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  late Future<_InventorySnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  void _reload() {
    setState(() => _snapshotFuture = _loadSnapshot());
  }

  Future<_InventorySnapshot> _loadSnapshot() async {
    final results = await Future.wait([
      di.sl<GetInventoryItems>()().then((r) => r.getOrElse(() => const <InventoryItem>[])),
      di.sl<GetRecentMovements>()().then((r) => r.getOrElse(() => const <StockMovement>[])),
    ]);
    return _InventorySnapshot(
      items: results[0] as List<InventoryItem>,
      movements: results[1] as List<StockMovement>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store & Inventory'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: FutureBuilder<_InventorySnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final items = data?.items ?? const <InventoryItem>[];
          final movements = data?.movements ?? const <StockMovement>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Stock Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Row(
                  children: [
                    Expanded(child: Skeleton(height: 100)),
                    SizedBox(width: 12),
                    Expanded(child: Skeleton(height: 100)),
                  ],
                )
              else
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
                      value: items.where((i) => i.isLowStock).length.toDouble(),
                      icon: Icons.warning_amber_rounded,
                      color: semanticColors.error,
                    ),
                    DashboardStatCard(
                      title: 'Total Items',
                      value: items.length.toDouble(),
                      icon: Icons.inventory_2_outlined,
                      color: semanticColors.info,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent Stock Movements'),
              const SizedBox(height: 12),
              if (isLoading)
                ...List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Skeleton(height: 72),
                ))
              else if (movements.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No stock movements recorded yet.'),
                )
              else
                ...movements.take(5).map((m) => _InventoryItemTile(
                      name: m.itemName,
                      status: m.type == StockMovementType.restock ? 'Restocked' : 'Issued',
                      quantity: m.type == StockMovementType.restock ? '+${m.quantity}' : '-${m.quantity}',
                      date: DateFormatter.relative(m.date),
                      color: m.type == StockMovementType.restock ? semanticColors.success : semanticColors.warning,
                    )),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickAction(
                    label: 'Add Stock',
                    icon: Icons.add_box_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => _showAddStockDialog(context, items),
                  ),
                  _QuickAction(
                    label: 'Issue Item',
                    icon: Icons.outbox_outlined,
                    color: semanticColors.info,
                    onTap: () => _showIssueItemDialog(context, items),
                  ),
                  _QuickAction(
                    label: 'Inventory Audit',
                    icon: Icons.assignment_turned_in_outlined,
                    color: semanticColors.success,
                    onTap: () => _showAuditSheet(context, items),
                  ),
                ],
              ),
            ],
          );
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
                    onChanged: (value) => setDialogState(() => isNewItem = value),
                  ),
                if (!isNewItem && items.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: selectedItemId,
                    decoration: const InputDecoration(labelText: 'Item'),
                    items: items.map((i) => DropdownMenuItem(value: i.id, child: Text(i.name))).toList(),
                    onChanged: (value) => setDialogState(() => selectedItemId = value),
                  )
                else ...[
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
                  const SizedBox(height: 16),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                  const SizedBox(height: 16),
                  TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (e.g. Reams, Boxes)')),
                  const SizedBox(height: 16),
                  TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Low Stock Threshold'),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity to Add'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text.trim());
                if (quantity == null || quantity <= 0) return;

                if (isNewItem) {
                  if (nameController.text.trim().isEmpty) return;
                  await di.sl<AddStock>()(
                    itemId: '',
                    itemName: nameController.text.trim(),
                    category: categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim(),
                    unit: unitController.text.trim().isEmpty ? 'Units' : unitController.text.trim(),
                    lowStockThreshold: int.tryParse(thresholdController.text.trim()) ?? 5,
                    quantity: quantity,
                  );
                } else {
                  if (selectedItemId == null) return;
                  final item = items.firstWhere((i) => i.id == selectedItemId);
                  await di.sl<AddStock>()(
                    itemId: item.id,
                    itemName: item.name,
                    category: item.category,
                    unit: item.unit,
                    lowStockThreshold: item.lowStockThreshold,
                    quantity: quantity,
                  );
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _reload();
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
        const SnackBar(content: Text('No items in stock yet. Add stock first.')),
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
                items: items.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} (${i.quantity} ${i.unit})'))).toList(),
                onChanged: (value) => setDialogState(() => selectedItemId = value ?? selectedItemId),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity to Issue'),
              ),
              const SizedBox(height: 16),
              TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Issued To / Note')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text.trim());
                final item = items.firstWhere((i) => i.id == selectedItemId);
                if (quantity == null || quantity <= 0 || quantity > item.quantity) return;
                await di.sl<IssueItem>()(itemId: selectedItemId, quantity: quantity, note: noteController.text.trim());
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _reload();
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
                    color: item.isLowStock ? Theme.of(context).colorScheme.error : null,
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
                Text('$status • $date', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            quantity,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
