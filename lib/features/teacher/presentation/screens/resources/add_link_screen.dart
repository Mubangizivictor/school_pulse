import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class AddLinkScreen extends StatelessWidget {
  const AddLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Add Link')),
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
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Link Title *',
                hintText: 'Enter link title',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Enter URL *',
                hintText: 'https://',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add description',
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
              label: 'Add Link',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
