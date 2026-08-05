import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class RecentActivityScreen extends StatelessWidget {
  const RecentActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Recent Activity')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: const [
          _ActivityItem(
            icon: Icons.upload_file_outlined,
            iconColor: Colors.red,
            title: 'You uploaded a resource',
            subtitle: 'P4_Math_Workbook.pdf',
            time: '2 hours ago',
          ),
          _ActivityItem(
            icon: Icons.share_outlined,
            iconColor: Colors.green,
            title: 'You shared a resource with the class',
            subtitle: 'Water Cycle Animation.mp4',
            time: '2 hours ago',
          ),
          _ActivityItem(
            icon: Icons.file_download_outlined,
            iconColor: Colors.blue,
            title: 'Aguti Brian downloaded a resource',
            subtitle: 'Science_Notes_Term2.docx',
            time: '1 day ago',
          ),
          _ActivityItem(
            icon: Icons.create_new_folder_outlined,
            iconColor: Colors.orange,
            title: 'You created a folder',
            subtitle: 'Mathematics',
            time: '2 days ago',
          ),
          _ActivityItem(
            icon: Icons.link_outlined,
            iconColor: Colors.purple,
            title: 'You added a link',
            subtitle: 'Math Practice Link',
            time: '3 days ago',
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: PrimaryButton(label: 'View All Activity', onPressed: () {}),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
