import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class StorageUsageScreen extends StatelessWidget {
  const StorageUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Storage Usage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: 1.28 / 5,
                          strokeWidth: 12,
                          backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          color: Theme.of(context).colorScheme.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Storage Used',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                          const Text(
                            '1.28 GB',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'of 5 GB',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _StorageItem(label: 'Documents', size: '620 MB', color: Colors.blue),
                  _StorageItem(label: 'Videos', size: '480 MB', color: Colors.purple),
                  _StorageItem(label: 'Images', size: '130 MB', color: Colors.green),
                  _StorageItem(label: 'Others', size: '60 MB', color: Colors.orange, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Manage Storage',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageItem extends StatelessWidget {
  final String label;
  final String size;
  final Color color;
  final bool isLast;

  const _StorageItem({
    required this.label,
    required this.size,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
              Text(size, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 44,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
