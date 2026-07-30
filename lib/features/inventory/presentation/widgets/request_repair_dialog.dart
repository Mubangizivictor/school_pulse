import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/asset.dart';

class RequestRepairDialog extends StatefulWidget {
  final Asset? asset;
  const RequestRepairDialog({super.key, this.asset});

  @override
  State<RequestRepairDialog> createState() => _RequestRepairDialogState();
}

class _RequestRepairDialogState extends State<RequestRepairDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Repair ${widget.asset != null ? "for ${widget.asset!.name}" : ""}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Issue Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _estimatedCostController,
                decoration: const InputDecoration(labelText: 'Estimated Cost (Optional)'),
                keyboardType: TextInputType.number,
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
        ElevatedButton(
          onPressed: widget.asset != null ? _submit : null,
          child: const Text('Submit Request'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final repair = RepairRecord(
        id: const Uuid().v4(),
        assetId: widget.asset!.id,
        assetName: widget.asset!.name,
        description: _descriptionController.text,
        estimatedCost: double.tryParse(_estimatedCostController.text) ?? 0.0,
        status: RepairStatus.pending,
        requestDate: DateTime.now(),
      );

      context.read<StoresAssetsBloc>().add(RequestRepairRequested(repair));
      Navigator.pop(context);
    }
  }
}
