import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/inventory/domain/entities/procurement_request.dart';

class ProcurementScreen extends StatefulWidget {
  final bool isAdminView;
  const ProcurementScreen({super.key, this.isAdminView = false});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  final List<ProcurementRequest> _requests = [
    ProcurementRequest(
      id: '1',
      requesterId: 'T001',
      requesterName: 'Mr. Okello',
      itemName: 'Chalk Boxes',
      quantity: 50,
      reason: 'End of term supplies needed.',
      status: ProcurementStatus.pending,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdminView ? 'Procurement Approvals' : 'Procurement Requests'),
        actions: [
          if (!widget.isAdminView)
            IconButton(
              onPressed: _showRequestDialog,
              icon: const Icon(Icons.add_shopping_cart),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _requests.isEmpty
          ? const Center(child: Text('No procurement requests yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _RequestTile(
                  request: request,
                  isAdmin: widget.isAdminView,
                  onStatusChanged: (status) {
                    setState(() {
                      _requests[index] = request.copyWith(status: status);
                    });
                  },
                );
              },
            ),
    );
  }

  void _showRequestDialog() {
    final itemController = TextEditingController();
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Procurement Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemController, decoration: const InputDecoration(labelText: 'Item Name')),
            const SizedBox(height: 16),
            TextField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            const SizedBox(height: 16),
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Reason')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (itemController.text.isEmpty || quantityController.text.isEmpty) return;
              setState(() {
                _requests.insert(0, ProcurementRequest(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  requesterId: 'SELF',
                  requesterName: 'Me',
                  itemName: itemController.text,
                  quantity: int.tryParse(quantityController.text) ?? 1,
                  reason: reasonController.text,
                  status: ProcurementStatus.pending,
                  date: DateTime.now(),
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ProcurementRequest request;
  final bool isAdmin;
  final Function(ProcurementStatus) onStatusChanged;

  const _RequestTile({required this.request, required this.isAdmin, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(request.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Quantity: ${request.quantity}'),
          Text('Requested by: ${request.requesterName}'),
          Text('Reason: ${request.reason}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Text(DateFormatter.format(request.date), style: Theme.of(context).textTheme.bodySmall),
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
  }
}

class _StatusBadge extends StatelessWidget {
  final ProcurementStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ProcurementStatus.pending: color = Colors.orange; break;
      case ProcurementStatus.approved: color = Colors.green; break;
      case ProcurementStatus.rejected: color = Colors.red; break;
      case ProcurementStatus.completed: color = Colors.blue; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
