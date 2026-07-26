import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/shared/domain/entities/school_asset.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final List<SchoolAsset> _assets = [
    SchoolAsset(
      id: '1',
      name: 'School Bus - UAB 123X',
      category: 'Transport',
      location: 'Garage',
      status: AssetStatus.operational,
      purchaseDate: DateTime(2022, 5, 10),
      value: 150000000,
    ),
    SchoolAsset(
      id: '2',
      name: 'Generator 50kVA',
      category: 'Utilities',
      location: 'Power House',
      status: AssetStatus.repairNeeded,
      purchaseDate: DateTime(2021, 3, 15),
      value: 25000000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Management'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assets.length,
        itemBuilder: (context, index) {
          final asset = _assets[index];
          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(asset.status).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory, color: _getStatusColor(asset.status)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${asset.category} • ${asset.location}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.ugx(asset.value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(asset.status.name.toUpperCase(), style: TextStyle(color: _getStatusColor(asset.status), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.operational: return Colors.green;
      case AssetStatus.repairNeeded: return Colors.orange;
      case AssetStatus.decommissioned: return Colors.red;
    }
  }
}
