import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/asset.dart';

class ScheduleMaintenanceDialog extends StatefulWidget {
  final Asset? asset;
  const ScheduleMaintenanceDialog({super.key, this.asset});

  @override
  State<ScheduleMaintenanceDialog> createState() => _ScheduleMaintenanceDialogState();
}

class _ScheduleMaintenanceDialogState extends State<ScheduleMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  MaintenanceType _type = MaintenanceType.preventive;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule Maintenance ${widget.asset != null ? "for ${widget.asset!.name}" : ""}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.asset == null)
                const Text('Please select an asset first (UI for selection to be added)'),
              DropdownButtonFormField<MaintenanceType>(
                initialValue: _type,
                items: MaintenanceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _type = val!),
                decoration: const InputDecoration(labelText: 'Maintenance Type'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description / Task'),
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Scheduled Date'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
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
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final maintenance = MaintenanceRecord(
        id: const Uuid().v4(),
        assetId: widget.asset!.id,
        assetName: widget.asset!.name,
        type: _type,
        description: _descriptionController.text,
        scheduledDate: _selectedDate,
        status: MaintenanceStatus.scheduled,
      );

      context.read<StoresAssetsBloc>().add(ScheduleMaintenanceRequested(maintenance));
      Navigator.pop(context);
    }
  }
}
