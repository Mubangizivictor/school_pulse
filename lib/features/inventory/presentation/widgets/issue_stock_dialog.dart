import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_issue.dart';

class IssueStockDialog extends StatefulWidget {
  final InventoryItem item;
  const IssueStockDialog({super.key, required this.item});

  @override
  State<IssueStockDialog> createState() => _IssueStockDialogState();
}

class _IssueStockDialogState extends State<IssueStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _issuedToController = TextEditingController();
  final _departmentController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _issuedToController.dispose();
    _departmentController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Issue ${widget.item.name}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available: ${widget.item.quantity} ${widget.item.unit}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Issue',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null)
                    return 'Invalid';
                  final qty = int.parse(value);
                  if (qty <= 0) return 'Must be > 0';
                  if (qty > widget.item.quantity) return 'Insufficient stock';
                  return null;
                },
              ),
              TextFormField(
                controller: _issuedToController,
                decoration: const InputDecoration(
                  labelText: 'Issued To (Staff/Student)',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose/Description',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Issue Stock')),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final issue = StockIssue(
        id: const Uuid().v4(),
        itemId: widget.item.id,
        itemName: widget.item.name,
        issuedToId: 'USER_ID', // Should be dynamic
        issuedToName: _issuedToController.text,
        department: _departmentController.text,
        purpose: _purposeController.text,
        quantity: int.parse(_quantityController.text),
        date: DateTime.now(),
        approvedBy: 'Current User', // Should be dynamic
      );

      context.read<StoresAssetsBloc>().add(IssueStockRequested(issue));
      Navigator.pop(context);
    }
  }
}
