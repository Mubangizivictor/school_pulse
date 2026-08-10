import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../responsive.dart';

class SchoolDetailScreen extends StatelessWidget {
  final School school;

  const SchoolDetailScreen({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final daysRemaining = school.subscriptionExpiry
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(school.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (school.status == SchoolStatus.active)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.m),
              child: OutlinedButton.icon(
                onPressed: () => _confirmStatusChange(
                  context,
                  action: 'Suspend',
                  color: theme.colorScheme.error,
                  onConfirm: () => context.read<SuperAdminBloc>().add(
                    UpdateSchoolStatusEvent(
                      schoolId: school.id,
                      status: SchoolStatus.suspended,
                      reason: 'Suspended by Owner',
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                icon: const Icon(Icons.block_rounded, size: 18),
                label: const Text('Suspend'),
              ),
            )
          else if (school.status == SchoolStatus.suspended)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.m),
              child: FilledButton.icon(
                onPressed: () => _confirmStatusChange(
                  context,
                  action: 'Reactivate',
                  color: AppColors.success(context),
                  onConfirm: () => context.read<SuperAdminBloc>().add(
                    UpdateSchoolStatusEvent(
                      schoolId: school.id,
                      status: SchoolStatus.active,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success(context),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Reactivate'),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: AppSpacing.x4l),
            if (isSuperAdminWide(context))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildOverview(theme)),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: _buildSubscription(theme, dateFormat, daysRemaining),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverview(theme),
                  const SizedBox(height: AppSpacing.x4l),
                  _buildSubscription(theme, dateFormat, daysRemaining),
                ],
              ),
            const SizedBox(height: AppSpacing.x4l),
            _buildFeatureControl(theme, context),
            const SizedBox(height: AppSpacing.x4l),
            _buildSupportModeAction(theme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary(context).withValues(alpha: 0.1),
            child: Text(
              school.name.isEmpty
                  ? '?'
                  : school.name.substring(0, 1).toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tenant ID: ${school.tenantId} • Created ${DateFormat('MMM dd, yyyy').format(school.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          _statusBadge(school.status, context),
        ],
      ),
    );
  }

  Widget _buildOverview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Overview'),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Category'),
                subtitle: Text(
                  school.classificationOther?.isNotEmpty == true
                      ? school.classificationOther!
                      : school.classification.name,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Contact email'),
                subtitle: Text(
                  school.contactEmail.isEmpty ? '—' : school.contactEmail,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Contact phone'),
                subtitle: Text(
                  school.contactPhone.isEmpty ? '—' : school.contactPhone,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Address'),
                subtitle: Text(school.address.isEmpty ? '—' : school.address),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscription(
    ThemeData theme,
    DateFormat dateFormat,
    int daysRemaining,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Subscription'),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.subscriptionPlanId.isEmpty
                    ? 'No plan assigned'
                    : school.subscriptionPlanId.toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expires on ${dateFormat.format(school.subscriptionExpiry)}',
              ),
              const SizedBox(height: 4),
              Text(
                daysRemaining >= 0
                    ? '$daysRemaining days remaining'
                    : 'Expired ${-daysRemaining} days ago',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: daysRemaining < 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureControl(ThemeData theme, BuildContext context) {
    const allFeatures = [
      {
        'id': 'attendance',
        'name': 'Attendance Management',
        'icon': Icons.calendar_today,
      },
      {'id': 'finance', 'name': 'Financial Records', 'icon': Icons.payments},
      {'id': 'exams', 'name': 'Examination System', 'icon': Icons.assignment},
      {
        'id': 'transport',
        'name': 'Transport/Bus Tracking',
        'icon': Icons.directions_bus,
      },
      {'id': 'library', 'name': 'Library Management', 'icon': Icons.book},
      {
        'id': 'qr_scanner',
        'name': 'QR Attendance Integration',
        'icon': Icons.qr_code,
      },
      {
        'id': 'parent_portal',
        'name': 'Parent Engagement',
        'icon': Icons.family_restroom,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Features & Modules'),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allFeatures.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final feature = allFeatures[index];
              final isEnabled = school.enabledFeatures.contains(feature['id']);
              return SwitchListTile(
                secondary: Icon(feature['icon'] as IconData),
                title: Text(feature['name'] as String),
                value: isEnabled,
                onChanged: (value) {
                  context.read<SuperAdminBloc>().add(
                    ToggleFeatureEvent(
                      schoolId: school.id,
                      feature: feature['id'] as String,
                      enabled: value,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportModeAction(ThemeData theme, BuildContext context) {
    return AppCard(
      color: AppColors.warning(context).withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(
            Icons.support_agent,
            color: AppColors.warning(context),
            size: 32,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner Support Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Temporarily access this school's dashboard to assist the administrator.",
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning(context),
              foregroundColor: Colors.white,
            ),
            onPressed: () => _promptSupportModeReason(context, school),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Enter'),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(
    BuildContext context, {
    required String action,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$action School?'),
        content: Text(
          'Are you sure you want to $action ${school.name}? This action will be logged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogContext);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _promptSupportModeReason(BuildContext context, School school) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Support Mode'),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Reason for accessing this school',
            hintText: 'e.g. Investigating a parent-reported billing issue',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning(context),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              context.read<SuperAdminBloc>().add(
                EnterSupportModeEvent(schoolId: school.id, reason: reason),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Entering Support Mode for ${school.name}… (Logged)',
                  ),
                ),
              );
            },
            child: const Text('Enter Support Mode'),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(SchoolStatus status, BuildContext context) {
    final (label, color) = switch (status) {
      SchoolStatus.active => ('Active', AppColors.success(context)),
      SchoolStatus.suspended => ('Suspended', AppColors.danger(context)),
      SchoolStatus.trial => ('Trial', AppColors.warning(context)),
      SchoolStatus.archived => ('Archived', AppColors.textSecondary(context)),
    };
    return StatusBadge(label: label, color: color);
  }
}
