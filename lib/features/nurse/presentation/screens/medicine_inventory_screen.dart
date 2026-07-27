import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/nurse/domain/entities/medicine_stock.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  State<MedicineInventoryScreen> createState() => _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen> {
  final List<MedicineStock> _inventory = [
    MedicineStock(
      id: '1',
      name: 'Paracetamol',
      category: 'Painkiller',
      quantity: 500,
      unit: 'Tablets',
      expiryDate: DateTime(2025, 12, 1),
      lowStockThreshold: 100,
    ),
    MedicineStock(
      id: '2',
      name: 'Amoxicillin',
      category: 'Antibiotic',
      quantity: 50,
      unit: 'Capsules',
      expiryDate: DateTime(2024, 6, 15),
      lowStockThreshold: 20,
    ),
    MedicineStock(
      id: '3',
      name: 'Cough Syrup',
      category: 'Syrup',
      quantity: 5,
      unit: 'Bottles',
      expiryDate: DateTime(2025, 1, 1),
      lowStockThreshold: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMedicineDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _inventory.length,
        itemBuilder: (context, index) {
          final item = _inventory[index];
          final bool isLow = item.isLowStock;
          final bool isExpired = item.isExpired;

          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isExpired ? Colors.red : (isLow ? Colors.orange : Colors.green)).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: isExpired ? Colors.red : (isLow ? Colors.orange : Colors.green),
                ),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item.category} • Expiry: ${DateFormat('MMM yyyy').format(item.expiryDate)}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.quantity} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (isLow)
                    const Text('LOW STOCK', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  if (isExpired)
                    const Text('EXPIRED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              onTap: () => _showUpdateStockDialog(item),
            ),
          );
        },
      ),
    );
  }

  void _showAddMedicineDialog() {
    // Implementation for adding new medicine
  }

  void _showUpdateStockDialog(MedicineStock item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${item.name}'),
        content: TextField(
          controller: quantityController,
          decoration: const InputDecoration(labelText: 'Current Quantity'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final newQty = int.tryParse(quantityController.text) ?? item.quantity;
              setState(() {
                final index = _inventory.indexWhere((element) => element.id == item.id);
                _inventory[index] = MedicineStock(
                  id: item.id,
                  name: item.name,
                  category: item.category,
                  quantity: newQty,
                  unit: item.unit,
                  expiryDate: item.expiryDate,
                  lowStockThreshold: item.lowStockThreshold,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
