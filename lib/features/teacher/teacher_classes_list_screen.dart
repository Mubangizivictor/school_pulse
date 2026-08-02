import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';

class TeacherClassesListScreen extends StatelessWidget {
  const TeacherClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textPrimary(context)),
          onPressed: () {},
        ),
        title: Text(
          'Classes',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: AppColors.primary(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildMyClassesHeader(context),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: PulseTextField(
                  hint: 'Search classes...',
                  prefixIcon: Icons.search,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(AppSpacing.m),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Icon(Icons.filter_list, color: AppColors.textPrimary(context)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildClassCard(
            context,
            classId: 'p5_east',
            className: 'P5 East',
            studentCount: 32,
          ),
          _buildClassCard(
            context,
            classId: 'p4_west',
            className: 'P4 West',
            studentCount: 28,
          ),
          _buildClassCard(
            context,
            classId: 'p4_blue',
            className: 'P4 Blue',
            studentCount: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildMyClassesHeader(BuildContext context) {
    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundColor: AppColors.surfaceElevated(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Classes',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Classes Assigned',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.school, color: AppColors.primary(context), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String classId,
    required String className,
    required int studentCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: PulseCard(
        onTap: () => context.push('/staff/classes/$classId'),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.m),
              ),
              child: Icon(Icons.groups, color: AppColors.primary(context), size: 24),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$studentCount Students',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Active',
                style: AppTypography.labelSmall.copyWith(color: AppColors.success(context), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }

}
