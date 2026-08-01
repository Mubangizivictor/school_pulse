import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class MediaLinksDocsScreen extends StatelessWidget {
  final String chatId;
  const MediaLinksDocsScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Media, Links & Docs', style: AppTypography.titleLarge),
          bottom: TabBar(
            labelColor: AppColors.electricBlue,
            unselectedLabelColor: AppColors.textMuted(context),
            indicatorColor: AppColors.electricBlue,
            indicatorWeight: 3,
            labelStyle: AppTypography.titleSmall,
            tabs: const [
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
        _buildSectionHeader(context, 'THIS MONTH'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/200/200?random=$index'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _buildSectionHeader(context, 'MAY'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/200/200?random=${index + 10}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: 5,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.electricBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.link, color: AppColors.electricBlue),
            ),
            title: Text('https://school.edu/exam-timetable', 
              style: AppTypography.bodyMedium.copyWith(color: AppColors.electricBlue, decoration: TextDecoration.underline)),
            subtitle: Text('Exam Timetable for Term 2 • 10:30 AM', style: AppTypography.labelSmall),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildDocsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
            ),
            title: Text('Newsletter_June_2024.pdf', style: AppTypography.titleSmall),
            subtitle: Text('2.4 MB • 12/06/24 • 09:15 AM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
            trailing: const Icon(Icons.file_download_outlined, size: 20),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s, left: 4),
      child: Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context), letterSpacing: 1.2)),
    );
  }
}
