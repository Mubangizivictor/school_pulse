import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/health/domain/entities/medical_inventory.dart';
import 'package:school_pulse/features/health/domain/entities/medical_supply_request.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  State<MedicineInventoryScreen> createState() =>
      _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  AuthAuthenticated? get _auth {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state : null;
  }

  String get _schoolId => _auth?.user.schoolId ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
    context.read<HealthBloc>().add(FetchInventory(_schoolId));
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 0) {
      context.read<HealthBloc>().add(FetchInventory(_schoolId));
    } else {
      context.read<HealthBloc>().add(FetchSupplyRequests(_schoolId));
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealthBloc, HealthState>(
      listener: (context, state) {
        if (state is HealthActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          if (_tabController.index == 0) {
            context.read<HealthBloc>().add(FetchInventory(_schoolId));
          } else {
            context.read<HealthBloc>().add(FetchSupplyRequests(_schoolId));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Inventory'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Current Stock', icon: Icon(Icons.inventory_2)),
              Tab(
                text: 'Supply Requests',
                icon: Icon(Icons.assignment_outlined),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Item',
              onPressed: () => _showAddItemDialog(context),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildStockTab(), _buildRequestsTab()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showRequestSupplyDialog(context),
          label: const Text('Request Supplies'),
          icon: const Icon(Icons.add_shopping_cart),
        ),
      ),
    );
  }

  Widget _buildStockTab() {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        if (state is HealthLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is InventoryLoaded) {
          if (state.items.isEmpty) {
            return _RefreshableEmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'Inventory is empty',
              message: 'Add the first medication or medical supply item.',
              onRefresh: () async =>
                  context.read<HealthBloc>().add(FetchInventory(_schoolId)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<HealthBloc>().add(FetchInventory(_schoolId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                final isLow = item.quantity <= item.reorderLevel;
                final isExpired =
                    item.expiryDate != null &&
                    item.expiryDate!.isBefore(DateTime.now());

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          (isExpired
                                  ? Colors.red
                                  : (isLow ? Colors.orange : Colors.green))
                              .withValues(alpha: 0.1),
                      child: Icon(
                        item.type == MedicalItemType.medication
                            ? Icons.medication
                            : Icons.medical_services,
                        color: isExpired
                            ? Colors.red
                            : (isLow ? Colors.orange : Colors.green),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.category} • Batch: ${item.batchNumber ?? "N/A"}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isLow)
                          const Text(
                            'LOW STOCK',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (isExpired)
                          const Text(
                            'EXPIRED',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    onTap: () => _showUpdateStockDialog(context, item),
                  ),
                );
              },
            ),
          );
        }
        if (state is HealthError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<HealthBloc>().add(FetchInventory(_schoolId)),
          );
        }
        return const Center(child: SchoolPulseLoader());
      },
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        if (state is HealthLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is SupplyRequestsLoaded) {
          if (state.requests.isEmpty) {
            return _RefreshableEmptyView(
              icon: Icons.assignment_outlined,
              title: 'No supply requests',
              message: 'New requests sent to Store will appear here.',
              onRefresh: () async => context.read<HealthBloc>().add(
                FetchSupplyRequests(_schoolId),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.requests.length,
            itemBuilder: (context, index) {
              final request = state.requests[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    request.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    request.rejectionReason?.trim().isNotEmpty == true
                        ? 'Requested: ${DateFormat('MMM dd').format(request.requestDate)} • Qty: ${request.quantity} ${request.unit}\nReason: ${request.rejectionReason}'
                        : 'Requested: ${DateFormat('MMM dd').format(request.requestDate)} • Qty: ${request.quantity} ${request.unit}',
                  ),
                  trailing: StatusBadge(
                    label: request.status.name.toUpperCase(),
                    color: _getStatusColor(request.status),
                  ),
                ),
              );
            },
          );
        }
        if (state is HealthError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<HealthBloc>().add(FetchSupplyRequests(_schoolId)),
          );
        }
        return const Center(child: SchoolPulseLoader());
      },
    );
  }

  Color _getStatusColor(SupplyRequestStatus status) {
    switch (status) {
      case SupplyRequestStatus.pending:
        return Colors.orange;
      case SupplyRequestStatus.approved:
        return Colors.green;
      case SupplyRequestStatus.purchased:
        return Colors.blue;
      case SupplyRequestStatus.delivered:
        return Colors.teal;
      case SupplyRequestStatus.rejected:
        return Colors.red;
    }
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');
    final quantityController = TextEditingController(text: '0');
    final unitController = TextEditingController(text: 'Units');
    final reorderController = TextEditingController(text: '5');
    var type = MedicalItemType.medication;
    String? validationError;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add medical inventory item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('inventory-item-name-field'),
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Item name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MedicalItemType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: MedicalItemType.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => type = value ?? type),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reorderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reorder level'),
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    validationError!,
                    key: const Key('inventory-item-validation-error'),
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('add-inventory-item-button'),
              onPressed: () {
                final quantity = int.tryParse(quantityController.text.trim());
                final reorder = int.tryParse(reorderController.text.trim());
                if (nameController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty ||
                    unitController.text.trim().isEmpty ||
                    quantity == null ||
                    quantity < 0 ||
                    reorder == null ||
                    reorder < 0) {
                  setDialogState(
                    () => validationError =
                        'Enter an item name, category, unit, and valid non-negative quantities.',
                  );
                  return;
                }
                if (_schoolId.isEmpty) {
                  setDialogState(
                    () => validationError =
                        'Your account is not assigned to a school.',
                  );
                  return;
                }
                context.read<HealthBloc>().add(
                  UpdateInventoryItemEvent(
                    MedicalInventoryItem(
                      id: '',
                      schoolId: _schoolId,
                      name: nameController.text.trim(),
                      type: type,
                      category: categoryController.text.trim(),
                      quantity: quantity,
                      unit: unitController.text.trim(),
                      reorderLevel: reorder,
                      purchaseDate: DateTime.now(),
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Add item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, MedicalInventoryItem item) {
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    String? validationError;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Update Stock: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Current Quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              if (validationError != null) ...[
                const SizedBox(height: 12),
                Text(
                  validationError!,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final newQty = int.tryParse(quantityController.text.trim());
                if (newQty == null || newQty < 0) {
                  setDialogState(
                    () => validationError =
                        'Enter a valid non-negative quantity.',
                  );
                  return;
                }
                context.read<HealthBloc>().add(
                  UpdateInventoryItemEvent(
                    MedicalInventoryItem(
                      id: item.id,
                      name: item.name,
                      type: item.type,
                      category: item.category,
                      quantity: newQty,
                      unit: item.unit,
                      reorderLevel: item.reorderLevel,
                      supplier: item.supplier,
                      purchaseDate: item.purchaseDate,
                      expiryDate: item.expiryDate,
                      batchNumber: item.batchNumber,
                      schoolId: item.schoolId,
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestSupplyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final unitController = TextEditingController(text: 'Units');
    String? validationError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Request Medical Supplies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (e.g. Boxes, Bottles)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (validationError != null) ...[
                Text(
                  validationError!,
                  key: const Key('supply-request-validation-error'),
                  style: TextStyle(
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                key: const Key('submit-supply-request-button'),
                onPressed: () {
                  final quantity = int.tryParse(qtyController.text.trim());
                  if (nameController.text.trim().isEmpty ||
                      quantity == null ||
                      quantity <= 0 ||
                      unitController.text.trim().isEmpty) {
                    setSheetState(
                      () => validationError =
                          'Enter an item name, a quantity above zero, and a unit.',
                    );
                    return;
                  }
                  if (_schoolId.isEmpty || (_auth?.user.id ?? '').isEmpty) {
                    setSheetState(
                      () => validationError =
                          'Your account is not assigned to a school.',
                    );
                    return;
                  }
                  context.read<HealthBloc>().add(
                    CreateNewSupplyRequest(
                      MedicalSupplyRequest(
                        id: '',
                        itemName: nameController.text.trim(),
                        quantity: quantity,
                        unit: unitController.text.trim(),
                        requestedBy: _auth?.user.id ?? '',
                        requestDate: DateTime.now(),
                        status: SupplyRequestStatus.pending,
                        schoolId: _schoolId,
                      ),
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
                child: const Text('Submit Request'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

class _RefreshableEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function() onRefresh;

  const _RefreshableEmptyView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(icon: icon, title: title, message: message),
        ),
      ],
    ),
  );
}
