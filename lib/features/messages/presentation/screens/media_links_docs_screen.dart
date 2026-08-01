import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class MediaLinksDocsScreen extends StatelessWidget {
  final String chatId;
  const MediaLinksDocsScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Media, Links & Docs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Media'),
              Tab(text: 'Links'),
              Tab(text: 'Docs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMediaGrid(context),
            _buildLinksList(context),
            _buildDocsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        _buildSectionHeader(context, 'This Month'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => Container(
            color: Colors.grey[300],
            child: Icon(Icons.image, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _buildSectionHeader(context, 'May'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            color: Colors.grey[300],
            child: Icon(Icons.image, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.link, color: Colors.blue),
        ),
        title: const Text('https://school.edu/exam-timetable'),
        subtitle: const Text('Exam Timetable for Term 2'),
        onTap: () {},
      ),
    );
  }

  Widget _buildDocsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: 4,
      itemBuilder: (context, index) => ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red),
        ),
        title: Text('Newsletter_June_2024.pdf'),
        subtitle: Text('2.4 MB • 12/06/24'),
        onTap: () {},
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Text(title, style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted(context))),
    );
  }
}
