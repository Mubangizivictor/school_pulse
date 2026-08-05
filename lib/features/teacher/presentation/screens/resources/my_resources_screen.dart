import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class MyResourcesScreen extends StatelessWidget {
  const MyResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('My Resources'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppSearchField(hintText: 'Search resources...'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                _FilterChip(label: 'All', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Documents'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Videos'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Images'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Links'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _ResourceItem(
                  title: 'P4_Math_Workbook.pdf',
                  subtitle: 'PDF • 2.4 MB',
                  date: '15 May 2025',
                  icon: Icons.picture_as_pdf,
                  iconColor: Colors.red,
                  onTap: () => context.push('/staff/resources/details'),
                ),
                _ResourceItem(
                  title: 'Science_Notes_Term2.docx',
                  subtitle: 'DOCX • 1.1 MB',
                  date: '12 May 2025',
                  icon: Icons.description,
                  iconColor: Colors.blue,
                ),
                _ResourceItem(
                  title: 'Water Cycle Animation.mp4',
                  subtitle: 'MP4 • 12.8 MB',
                  date: '10 May 2025',
                  icon: Icons.play_circle_outline,
                  iconColor: Colors.purple,
                ),
                _ResourceItem(
                  title: 'P4_Reading_Passage.pdf',
                  subtitle: 'PDF • 850 KB',
                  date: '08 May 2025',
                  icon: Icons.picture_as_pdf,
                  iconColor: Colors.red,
                ),
                _ResourceItem(
                  title: 'Fractions_Explained.mp4',
                  subtitle: 'MP4 • 6.2 MB',
                  date: '05 May 2025',
                  icon: Icons.play_circle_outline,
                  iconColor: Colors.purple,
                ),
                _ResourceItem(
                  title: 'Human_Skeleton.jpg',
                  subtitle: 'JPG • 1.4 MB',
                  date: '02 May 2025',
                  icon: Icons.image_outlined,
                  iconColor: Colors.green,
                ),
                _ResourceItem(
                  title: 'Math_Practice_Link',
                  subtitle: 'Link • Google Drive',
                  date: '01 May 2025',
                  icon: Icons.link_outlined,
                  iconColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ResourceItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
