import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class UploadResourceScreen extends StatelessWidget {
  const UploadResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Upload Resource')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Dropzone
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 40),
              borderColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Drag and drop files here\nor tap to browse',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const Text(
              'Resource Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: _TypeSelector(
                    icon: Icons.description,
                    label: 'Document',
                    isSelected: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeSelector(icon: Icons.play_circle, label: 'Video'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeSelector(icon: Icons.image, label: 'Image'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeSelector(icon: Icons.link, label: 'Link'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3l),

            const Text(
              'Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.l),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter resource title',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Add a short description',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Class *'),
              value: 'Primary 4 - Emerald',
              items: [
                'Primary 4 - Emerald',
                'Primary 4 - Ruby',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Folder'),
              hint: const Text('Select folder (Optional)'),
              items: [
                'Mathematics',
                'Science',
                'English',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Upload Resource',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _TypeSelector({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : null,
      borderColor: isSelected ? Theme.of(context).colorScheme.primary : null,
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).hintColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
