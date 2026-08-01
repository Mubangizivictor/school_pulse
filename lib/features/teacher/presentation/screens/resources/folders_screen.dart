import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppSearchField(hintText: 'Search folders...'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: const [
                _FolderItem(title: 'Mathematics', count: 12, color: Colors.orange),
                _FolderItem(title: 'Science', count: 8, color: Colors.red),
                _FolderItem(title: 'English Language', count: 15, color: Colors.blue),
                _FolderItem(title: 'Social Studies', count: 6, color: Colors.green),
                _FolderItem(title: 'Worksheets', count: 24, color: Colors.purple),
                _FolderItem(title: 'Exams & Past Papers', count: 10, color: Colors.teal),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FolderItem extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _FolderItem({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.folder, color: color, size: 32),
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
                  '$count resources',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}
