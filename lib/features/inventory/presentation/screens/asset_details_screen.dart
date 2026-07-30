import 'package:flutter/material.dart';
import 'package:school_pulse/core/utils.dart';
import '../../domain/entities/asset.dart';
import '../widgets/request_repair_dialog.dart';
import '../widgets/schedule_maintenance_dialog.dart';

class AssetDetailsScreen extends StatelessWidget {
  final Asset asset;

  const AssetDetailsScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement Edit Asset
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (asset.photoUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    asset.photoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildSectionTitle('General Information'),
            _buildInfoRow('Asset Number', asset.assetNumber),
            _buildInfoRow('Category', asset.category),
            _buildInfoRow('Condition', asset.condition),
            _buildInfoRow('Status', asset.status.name.toUpperCase()),
            const Divider(height: 32),
            _buildSectionTitle('Technical Details'),
            _buildInfoRow('Brand', asset.brand ?? 'N/A'),
            _buildInfoRow('Model', asset.model ?? 'N/A'),
            _buildInfoRow('Serial Number', asset.serialNumber ?? 'N/A'),
            const Divider(height: 32),
            _buildSectionTitle('Purchase Information'),
            _buildInfoRow('Purchase Date', DateFormatter.format(asset.purchaseDate)),
            _buildInfoRow('Purchase Price', 'UGX ${asset.purchasePrice.toStringAsFixed(0)}'),
            if (asset.warrantyExpiry != null)
              _buildInfoRow('Warranty Expiry', DateFormatter.format(asset.warrantyExpiry!)),
            const Divider(height: 32),
            _buildSectionTitle('Assignment'),
            _buildInfoRow('Department', asset.assignedDepartment ?? 'Unassigned'),
            _buildInfoRow('Staff', asset.assignedStaffId ?? 'Unassigned'),
            _buildInfoRow('Room', asset.assignedRoom ?? 'Unassigned'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => RequestRepairDialog(asset: asset),
                      );
                    },
                    icon: const Icon(Icons.build),
                    label: const Text('Report Issue'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ScheduleMaintenanceDialog(asset: asset),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Schedule Maint.'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
