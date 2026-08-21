// Shared presentation primitives for the /staff/students/:id/* detail
// screens (profile, health, notes, documents, siblings, leave, etc). Every
// one of those screens repeats the same transparent back-arrow app bar and,
// where a feature has no backing data yet, the same "coming soon" body -
// this file gives them one implementation to share.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Transparent, elevation-0 app bar with a themed back arrow and title,
/// matching every screen under /staff/students/:id/*.
class TeacherStudentDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TeacherStudentDetailAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
      onPressed: () => context.pop(),
    ),
    title: Text(
      title,
      style: AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimary(context),
      ),
    ),
  );
}

/// Centered icon + title + description block used by student-detail screens
/// whose feature has no backing data model yet (an honest "not available",
/// not fabricated content) and by empty-list states such as Documents.
class TeacherStudentDetailEmptyState extends StatelessWidget {
  const TeacherStudentDetailEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted(context)),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Failure state with a retry, for student-detail screens that load from a
/// repository. Distinct from [TeacherStudentDetailEmptyState]: empty means
/// the read succeeded and there was nothing there, this means it failed.
class TeacherStudentDetailErrorState extends StatelessWidget {
  const TeacherStudentDetailErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

/// The bordered, rounded row tile used throughout student-detail screens
/// (More Options list, Documents list) for a tappable icon + label row.
class TeacherStudentDetailTile extends StatelessWidget {
  const TeacherStudentDetailTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(AppSpacing.l),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary(context)),
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      trailing: Icon(trailingIcon, color: AppColors.textMuted(context)),
    ),
  );
}
