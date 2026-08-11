import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/tab_button.dart';

class TeacherStudentCommunicationsScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentCommunicationsScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Communications',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _MessageTile(
                  name: 'Okello Lucy (Mother)',
                  message: 'Thank you teacher.',
                  time: '10:15 AM',
                  isDark: isDark,
                ),
                _MessageTile(
                  name: 'Ochieng Denis (You)',
                  message: 'Please ensure Peter brings...',
                  time: '9:40 AM',
                  isDark: isDark,
                  isSelf: true,
                ),
                _MessageTile(
                  name: 'Okello Lucy (Mother)',
                  message: 'Noted, thank you.',
                  time: 'Yesterday',
                  isDark: isDark,
                ),
                _MessageTile(
                  name: 'Ochieng Denis (You)',
                  message: 'Peter has been doing well.',
                  time: 'Yesterday',
                  isDark: isDark,
                  isSelf: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'New Message',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.m),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.m),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabButton(
              label: 'Messages',
              isSelected: true,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: TabButton(
              label: 'Announcements',
              isSelected: false,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isDark;
  final bool isSelf;

  const _MessageTile({
    required this.name,
    required this.message,
    required this.time,
    required this.isDark,
    this.isSelf = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              isSelf
                  ? 'https://i.pravatar.cc/150?u=me'
                  : 'https://i.pravatar.cc/150?u=mother',
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
