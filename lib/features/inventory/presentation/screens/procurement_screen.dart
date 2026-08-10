import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/core/utils/reporting_engine.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/inventory/domain/entities/procurement_request.dart';
import 'package:school_pulse/features/inventory/domain/entities/purchase_order.dart';
import 'package:school_pulse/features/inventory/domain/entities/supplier.dart';
import 'package:uuid/uuid.dart';

import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../bloc/stores_assets_state.dart';

class ProcurementScreen extends StatefulWidget {
  final bool isAdminView;
  const ProcurementScreen({super.key, this.isAdminView = false});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool get _canManageProcurement {
    if (widget.isAdminView) return true;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return false;
    const managers = {
      UserRole.director,
      UserRole.headTeacher,
      UserRole.deputyHead,
      UserRole.schoolAdmin,
      UserRole.bursar,
      UserRole.storeInventory,
    };
    return auth.user.roles.any(managers.contains);
  }

  bool get _canApproveProcurement {
    if (widget.isAdminView) return true;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return false;
    const approvers = {
      UserRole.director,
      UserRole.headTeacher,
      UserRole.deputyHead,
      UserRole.schoolAdmin,
      UserRole.bursar,
    };
    return auth.user.roles.any(approvers.contains);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final bloc = context.read<StoresAssetsBloc>();
    bloc
      ..add(LoadProcurementRequests())
      ..add(LoadPurchaseOrders())
      ..add(LoadSuppliers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdminView ? 'Procurement & Orders' : 'Procurement',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Purchase Orders'),
          ],
        ),
        actions: [
          if (_canManageProcurement)
            IconButton(
              tooltip: 'Add supplier',
              onPressed: () => _showSupplierDialog(context),
              icon: const Icon(Icons.business_outlined),
            ),
          IconButton(
            tooltip: 'New request',
            onPressed: () => _showRequestDialog(context),
            icon: const Icon(Icons.add_shopping_cart),
          ),
          if (_canManageProcurement)
            IconButton(
              tooltip: 'Create purchase order',
              onPressed: () => _showPurchaseOrderDialog(context),
              icon: const Icon(Icons.note_add_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<StoresAssetsBloc, StoresAssetsState>(
        listener: (context, state) {
          if (state is StoresAssetsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is StoresAssetsLoading || state is StoresAssetsInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state is StoresAssetsError) {
            return Center(
              child: FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }

          final loaded = state as StoresAssetsLoaded;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(loaded.procurementRequests),
                _buildOrdersList(loaded.purchaseOrders),
              ],
            ),
          );
        },
      ),
    );
  }

  void _reload() => context.read<StoresAssetsBloc>().add(LoadDashboardData());

  Widget _buildRequestsList(List<ProcurementRequest> requests) {
    if (requests.isEmpty) {
      return const _EmptyProcurementView(
        icon: Icons.playlist_add_outlined,
        message: 'No procurement requests yet.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) => _RequestTile(
        request: requests[index],
        isAdmin: _canApproveProcurement,
        onStatusChanged: (status) => context.read<StoresAssetsBloc>().add(
          UpdateProcurementRequestStatusRequested(requests[index].id, status),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<PurchaseOrder> orders) {
    if (orders.isEmpty) {
      return const _EmptyProcurementView(
        icon: Icons.receipt_long_outlined,
        message: 'No purchase orders yet.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _OrderTile(
        order: orders[index],
        canManage: _canApproveProcurement,
        onStatusChanged: (status) => context.read<StoresAssetsBloc>().add(
          UpdatePurchaseOrderStatusRequested(orders[index].id, status),
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before submitting a request.'),
        ),
      );
      return;
    }
    final item = TextEditingController();
    final quantity = TextEditingController();
    final reason = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Procurement Request'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(item, 'Item name'),
              const SizedBox(height: 12),
              _field(quantity, 'Quantity', number: true),
              const SizedBox(height: 12),
              _field(reason, 'Reason', required: false),
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
              if (!(formKey.currentState?.validate() ?? false)) return;
              context.read<StoresAssetsBloc>().add(
                CreateProcurementRequestRequested(
                  ProcurementRequest(
                    id: const Uuid().v4(),
                    requesterId: auth.user.id,
                    requesterName: auth.user.name,
                    itemName: item.text.trim(),
                    quantity: int.parse(quantity.text.trim()),
                    reason: reason.text.trim(),
                    status: ProcurementStatus.pending,
                    date: DateTime.now(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Submit request'),
          ),
        ],
      ),
    );
  }

  void _showSupplierDialog(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final name = TextEditingController();
    final category = TextEditingController();
    final contact = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Supplier'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(name, 'Supplier name'),
                const SizedBox(height: 12),
                _field(category, 'Category'),
                const SizedBox(height: 12),
                _field(contact, 'Contact person', required: false),
                const SizedBox(height: 12),
                _field(phone, 'Phone', required: false),
                const SizedBox(height: 12),
                _field(email, 'Email', required: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              context.read<StoresAssetsBloc>().add(
                AddSupplierRequested(
                  Supplier(
                    id: const Uuid().v4(),
                    schoolId: auth.user.schoolId,
                    name: name.text.trim(),
                    category: category.text.trim(),
                    contactPerson: contact.text.trim(),
                    phone: phone.text.trim(),
                    email: email.text.trim(),
                    createdAt: DateTime.now(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Add supplier'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseOrderDialog(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final state = context.read<StoresAssetsBloc>().state;
    if (auth is! AuthAuthenticated || state is! StoresAssetsLoaded) return;
    final suppliers = state.suppliers
        .where((s) => s.schoolId == auth.user.schoolId)
        .toList();
    if (suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a supplier before creating an order.'),
        ),
      );
      return;
    }
    Supplier supplier = suppliers.first;
    final item = TextEditingController();
    final quantity = TextEditingController();
    final unitPrice = TextEditingController();
    final notes = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Purchase Order'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Supplier>(
                    initialValue: supplier,
                    decoration: const InputDecoration(labelText: 'Supplier'),
                    items: suppliers
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => supplier = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _field(item, 'Item name'),
                  const SizedBox(height: 12),
                  _field(quantity, 'Quantity', number: true),
                  const SizedBox(height: 12),
                  _field(unitPrice, 'Unit price (UGX)', decimal: true),
                  const SizedBox(height: 12),
                  _field(notes, 'Notes', required: false),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final orderItem = OrderItem(
                  itemName: item.text.trim(),
                  quantity: int.parse(quantity.text.trim()),
                  unitPrice: double.parse(unitPrice.text.trim()),
                );
                context.read<StoresAssetsBloc>().add(
                  CreatePurchaseOrderRequested(
                    PurchaseOrder(
                      id: const Uuid().v4(),
                      schoolId: auth.user.schoolId,
                      orderNumber:
                          'PO-${DateTime.now().millisecondsSinceEpoch}',
                      supplierId: supplier.id,
                      supplierName: supplier.name,
                      items: [orderItem],
                      totalAmount: orderItem.totalPrice,
                      status: PurchaseOrderStatus.pending,
                      date: DateTime.now(),
                      notes: notes.text.trim().isEmpty
                          ? null
                          : notes.text.trim(),
                      createdBy: auth.user.id,
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Create order'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _field(
    TextEditingController controller,
    String label, {
    bool number = false,
    bool decimal = false,
    bool required = true,
  }) => TextFormField(
    controller: controller,
    keyboardType: number || decimal
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      final text = value?.trim() ?? '';
      if (required && text.isEmpty) {
        return '$label is required';
      }
      if (text.isNotEmpty &&
          number &&
          (int.tryParse(text) == null || int.parse(text) <= 0)) {
        return 'Enter a whole number greater than zero';
      }
      if (text.isNotEmpty &&
          decimal &&
          (double.tryParse(text) == null || double.parse(text) < 0)) {
        return 'Enter a valid amount';
      }
      return null;
    },
  );
}

class _EmptyProcurementView extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyProcurementView({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message),
          ],
        ),
      ),
    ],
  );
}

class _RequestTile extends StatelessWidget {
  final ProcurementRequest request;
  final bool isAdmin;
  final ValueChanged<ProcurementStatus> onStatusChanged;
  const _RequestTile({
    required this.request,
    required this.isAdmin,
    required this.onStatusChanged,
  });
  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                request.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            StatusBadge(
              label: request.status.name,
              color: _requestColor(request.status),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Quantity: ${request.quantity}'),
        Text('Requested by: ${request.requesterName}'),
        if (request.reason.isNotEmpty)
          Text(
            'Reason: ${request.reason}',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        if (request.directorNote?.isNotEmpty ?? false)
          Text(
            'Decision note: ${request.directorNote}',
            style: const TextStyle(fontSize: 12),
          ),
        const SizedBox(height: 12),
        Text(
          DateFormatter.format(request.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (isAdmin && request.status == ProcurementStatus.pending) ...[
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => onStatusChanged(ProcurementStatus.rejected),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => onStatusChanged(ProcurementStatus.approved),
                child: const Text('Approve'),
              ),
            ],
          ),
        ],
      ],
    ),
  );
  Color _requestColor(ProcurementStatus status) => switch (status) {
    ProcurementStatus.pending => Colors.orange,
    ProcurementStatus.approved => Colors.green,
    ProcurementStatus.rejected => Colors.red,
    ProcurementStatus.completed => Colors.blue,
  };
}

class _OrderTile extends StatelessWidget {
  final PurchaseOrder order;
  final bool canManage;
  final ValueChanged<PurchaseOrderStatus> onStatusChanged;
  const _OrderTile({
    required this.order,
    required this.canManage,
    required this.onStatusChanged,
  });
  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                order.orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            StatusBadge(
              label: order.status.name,
              color: _orderColor(order.status),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Supplier: ${order.supplierName}'),
        Text('Items: ${order.items.length}'),
        Text(
          'Total: UGX ${order.totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormatter.format(order.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton.icon(
              onPressed: () => ReportingEngine.exportPurchaseOrderToPdf(order),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Export PDF'),
            ),
            if (canManage && _nextStatuses.isNotEmpty)
              PopupMenuButton<PurchaseOrderStatus>(
                tooltip: 'Update order status',
                onSelected: onStatusChanged,
                itemBuilder: (_) => _nextStatuses
                    .map(
                      (status) => PopupMenuItem(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ],
    ),
  );
  List<PurchaseOrderStatus> get _nextStatuses => switch (order.status) {
    PurchaseOrderStatus.pending => [
      PurchaseOrderStatus.approved,
      PurchaseOrderStatus.cancelled,
    ],
    PurchaseOrderStatus.approved => [
      PurchaseOrderStatus.ordered,
      PurchaseOrderStatus.cancelled,
    ],
    PurchaseOrderStatus.ordered => [
      PurchaseOrderStatus.received,
      PurchaseOrderStatus.cancelled,
    ],
    PurchaseOrderStatus.received || PurchaseOrderStatus.cancelled => const [],
  };
  Color _orderColor(PurchaseOrderStatus status) => switch (status) {
    PurchaseOrderStatus.pending => Colors.orange,
    PurchaseOrderStatus.approved => Colors.blue,
    PurchaseOrderStatus.ordered => Colors.indigo,
    PurchaseOrderStatus.received => Colors.green,
    PurchaseOrderStatus.cancelled => Colors.red,
  };
  String _statusLabel(PurchaseOrderStatus status) =>
      status.name[0].toUpperCase() + status.name.substring(1);
}
