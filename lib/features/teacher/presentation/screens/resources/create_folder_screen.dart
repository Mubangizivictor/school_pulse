import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class CreateFolderScreen extends StatelessWidget {
  const CreateFolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Create Folder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Folder Name *',
                hintText: 'Enter folder name',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add folder description',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Parent Folder',
              ),
              initialValue: 'General Resources',
              items: [
                'General Resources',
                'Mathematics',
                'Science',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Folder Color',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ColorOption(color: Colors.orange, isSelected: true),
                _ColorOption(color: Colors.red),
                _ColorOption(color: Colors.blue),
                _ColorOption(color: Colors.green),
                _ColorOption(color: Colors.purple),
                _ColorOption(color: Colors.pink),
              ],
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Create Folder',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;

  const _ColorOption({required this.color, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: isSelected
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
            : null,
      ),
    );
  }
}
