import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class ResourceDetailsScreen extends StatelessWidget {
  const ResourceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'P4_Math_Workbook.pdf',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'PDF Document • 2.4 MB',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const SectionHeader(title: 'Information'),
            const SizedBox(height: AppSpacing.l),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoTile(icon: Icons.person_outline, label: 'Uploaded By', value: 'Mrs. Grace W. Gikama'),
                  _InfoTile(icon: Icons.calendar_today_outlined, label: 'Uploaded On', value: '15 May 2025 • 08:30 AM'),
                  _InfoTile(icon: Icons.class_outlined, label: 'Class', value: 'Primary 4 - Emerald'),
                  _InfoTile(icon: Icons.folder_open_outlined, label: 'Folder', value: 'Mathematics'),
                  _InfoTile(icon: Icons.file_download_outlined, label: 'Downloads', value: '32'),
                  _InfoTile(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: 'Workbook with exercises and activities for term 2.',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const SectionHeader(title: 'Actions'),
            const SizedBox(height: AppSpacing.l),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _ActionButton(icon: Icons.remove_red_eye_outlined, label: 'Preview', color: Colors.blue),
                _ActionButton(icon: Icons.file_download_outlined, label: 'Download', color: Colors.green),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.orange,
                  onTap: () => context.push('/staff/resources/share'),
                ),
                _ActionButton(icon: Icons.drive_file_move_outlined, label: 'Move', color: Colors.purple),
                _ActionButton(icon: Icons.edit_outlined, label: 'Rename', color: Colors.teal),
                _ActionButton(icon: Icons.delete_outline, label: 'Delete', color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).hintColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 52,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
