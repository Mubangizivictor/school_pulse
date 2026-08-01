import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class OfflineResourcesScreen extends StatelessWidget {
  const OfflineResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Offline Resources'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Offline',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Switch.adaptive(value: true, onChanged: (v) {}),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: AppSearchField(hintText: 'Search offline resources...'),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: const [
                _OfflineItem(
                  title: 'P4_Math_Workbook.pdf',
                  subtitle: '2.4 MB',
                  icon: Icons.picture_as_pdf,
                  iconColor: Colors.red,
                ),
                _OfflineItem(
                  title: 'Science_Notes_Term2.docx',
                  subtitle: '1.1 MB',
                  icon: Icons.description,
                  iconColor: Colors.blue,
                ),
                _OfflineItem(
                  title: 'Fractions_Explained.mp4',
                  subtitle: '6.2 MB',
                  icon: Icons.play_circle_outline,
                  iconColor: Colors.purple,
                ),
                _OfflineItem(
                  title: 'Human_Skeleton.jpg',
                  subtitle: '1.4 MB',
                  icon: Icons.image_outlined,
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SecondaryButton(
              label: 'Download More',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _OfflineItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
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
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
