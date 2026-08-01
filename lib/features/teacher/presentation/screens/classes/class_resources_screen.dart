import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';

class ClassResourcesScreen extends StatelessWidget {
  final String classId;
  const ClassResourcesScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Resources',
              style: AppTypography.titleLarge.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            Text(
              'P5 East',
              style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildCategoryHeader('Study Materials', Icons.auto_stories, isDark),
          _buildResourceItem('Math_Algebra_Notes.pdf', '1.2 MB • 2 days ago', Icons.picture_as_pdf, Colors.red, isDark),
          _buildResourceItem('English_Grammar_Guide.docx', '850 KB • 1 week ago', Icons.description, Colors.blue, isDark),
          const SizedBox(height: AppSpacing.xl),
          _buildCategoryHeader('Shared Media', Icons.collections, isDark),
          _buildResourceItem('Class_Project_Photo.jpg', '4.5 MB • 3 days ago', Icons.image, Colors.green, isDark),
          _buildResourceItem('Science_Experiment_Video.mp4', '15.8 MB • Yesterday', Icons.videocam, Colors.purple, isDark),
          const SizedBox(height: AppSpacing.xl),
          _buildCategoryHeader('Documents', Icons.folder, isDark),
          _buildResourceItem('Term_2_Syllabus.pdf', '2.4 MB • 1 month ago', Icons.picture_as_pdf, Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.royalBlue),
          const SizedBox(width: AppSpacing.s),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String name, String meta, IconData icon, Color iconColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: PulseCard(
        onTap: () {},
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.s),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    meta,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert, size: 20, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ],
        ),
      ),
    );
  }
}
