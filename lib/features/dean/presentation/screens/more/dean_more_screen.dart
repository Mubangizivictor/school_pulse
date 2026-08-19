import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/curriculum_management_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/observations/class_observations_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/homework_monitoring_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/approvals/dean_approvals_screen.dart';

/// More menu — root of the More tab. A profile row header plus a vertical
/// nav list routing to existing dean sub-pages where a real screen exists;
/// rows with no backend surface yet push a "coming soon" [EmptyState].
class DeanMoreScreen extends StatelessWidget {
  const DeanMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        automaticallyImplyLeading: false,
        title: Text('More', style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _buildProfileHeader(context),
          const SectionHeader(title: 'Academic Management'),
          _MoreRow(
            icon: Icons.menu_book_outlined,
            label: 'Curriculum & Subjects',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CurriculumManagementScreen(),
              ),
            ),
          ),
          _MoreRow(
            icon: Icons.visibility_outlined,
            label: 'Class Observations',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ClassObservationsScreen(),
              ),
            ),
          ),
          _MoreRow(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Homework Monitoring',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HomeworkMonitoringScreen(),
              ),
            ),
          ),
          _MoreRow(
            icon: Icons.verified_user_outlined,
            label: 'Report Approvals',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DeanApprovalsScreen()),
            ),
          ),
          _MoreRow(
            icon: Icons.calendar_month_outlined,
            label: 'Academic Calendar',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.calendar_month_outlined,
              title: 'Academic Calendar',
            ),
          ),
          _MoreRow(
            icon: Icons.schema_outlined,
            label: 'Schemes of Work',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.schema_outlined,
              title: 'Schemes of Work',
            ),
          ),
          _MoreRow(
            icon: Icons.groups_2_outlined,
            label: 'Meetings',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.groups_2_outlined,
              title: 'Meetings',
            ),
          ),
          _MoreRow(
            icon: Icons.campaign_outlined,
            label: 'Announcements',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.campaign_outlined,
              title: 'Announcements',
            ),
          ),
          _MoreRow(
            icon: Icons.folder_outlined,
            label: 'Documents',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.folder_outlined,
              title: 'Documents',
            ),
          ),
          _MoreRow(
            icon: Icons.summarize_outlined,
            label: 'Academic Reports',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.summarize_outlined,
              title: 'Academic Reports',
            ),
          ),
          _MoreRow(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => _pushComingSoon(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = (state is AuthAuthenticated) ? state.user.name : 'Dean';
        final email = (state is AuthAuthenticated) ? state.user.email : '';
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.l),
          child: Row(
            children: [
              AvatarInitials(name: name, size: 48),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pushComingSoon(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: EmptyState(
            icon: icon,
            title: 'Coming soon',
            message: '$title is not available yet.',
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: EdgeInsets.zero,
      onTap: onTap,
      showShadow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: AppColors.primary(context), size: 20),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(child: Text(label, style: AppTypography.bodyMedium)),
            Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}
