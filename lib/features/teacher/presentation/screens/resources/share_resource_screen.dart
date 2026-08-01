import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class ShareResourceScreen extends StatelessWidget {
  const ShareResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Share Resource'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'P4_Math_Workbook.pdf',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'PDF • 2.4 MB',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const Text(
              'Share With',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.l),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ShareOption(icon: Icons.people_outline, label: 'Primary 4 - Emerald', subtitle: 'All Students'),
                  _ShareOption(icon: Icons.school_outlined, label: 'Teachers', subtitle: 'All Teachers'),
                  _ShareOption(icon: Icons.person_outline, label: 'Specific Students', subtitle: 'Select from list'),
                  _ShareOption(icon: Icons.family_restroom_outlined, label: 'Parents', subtitle: 'All Parents'),
                  _ShareOption(icon: Icons.other_houses_outlined, label: 'Other Classes', subtitle: 'Select classes', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const Text(
              'Additional Options',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.l),
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Allow Download', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch.adaptive(value: true, onChanged: (v) {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Add Message (Optional)',
                      hintText: 'Write a message...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Share Resource',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isLast;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: () {},
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
