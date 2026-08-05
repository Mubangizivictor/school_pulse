import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class ResourceCategoriesScreen extends StatelessWidget {
  const ResourceCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Resource Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppSearchField(hintText: 'Search categories...'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                _CategoryItem(
                  icon: Icons.grid_view_outlined,
                  label: 'All Resources',
                  count: 124,
                  color: Colors.blue,
                ),
                _CategoryItem(
                  icon: Icons.description_outlined,
                  label: 'Documents',
                  count: 68,
                  color: Colors.red,
                ),
                _CategoryItem(
                  icon: Icons.play_circle_outline,
                  label: 'Videos',
                  count: 24,
                  color: Colors.purple,
                ),
                _CategoryItem(
                  icon: Icons.image_outlined,
                  label: 'Images',
                  count: 16,
                  color: Colors.green,
                ),
                _CategoryItem(
                  icon: Icons.link_outlined,
                  label: 'Links',
                  count: 18,
                  color: Colors.orange,
                ),
                _CategoryItem(
                  icon: Icons.audiotrack_outlined,
                  label: 'Audio',
                  count: 5,
                  color: Colors.teal,
                ),
                _CategoryItem(
                  icon: Icons.more_horiz_outlined,
                  label: 'Others',
                  count: 0,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}
