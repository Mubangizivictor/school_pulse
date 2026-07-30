import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../../domain/entities/asset.dart';

class AddAssetDialog extends StatefulWidget {
  const AddAssetDialog({super.key});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _assetNumberController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _conditionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _assetNumberController.dispose();
    _purchasePriceController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Asset'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Asset Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _assetNumberController,
                decoration: const InputDecoration(labelText: 'Asset Number / Tag'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(labelText: 'Purchase Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid' : null,
              ),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(labelText: 'Condition (e.g., New, Good)'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final asset = Asset(
        id: const Uuid().v4(),
        schoolId: 'current-school-id', // Should be fetched from Auth
        assetNumber: _assetNumberController.text,
        qrCode: 'QR-${_assetNumberController.text}',
        name: _nameController.text,
        category: _categoryController.text,
        purchaseDate: now,
        purchasePrice: double.parse(_purchasePriceController.text),
        condition: _conditionController.text,
        status: AssetStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      context.read<StoresAssetsBloc>().add(AddAssetRequested(asset));
      Navigator.pop(context);
    }
  }
}
