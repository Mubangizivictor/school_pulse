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
          IconButton(
            tooltip: 'Edit school info',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editSchoolInfo(context, school),
          ),
          if (school.status == SchoolStatus.active)
            IconButton(
              tooltip: 'Suspend school',
              icon: Icon(Icons.block_rounded, color: theme.colorScheme.error),
              onPressed: () => _confirmStatusChange(
                context,
                action: 'Suspend',
                message:
                    'Are you sure you want to suspend ${school.name}? '
                    'Staff and admins will immediately lose access to the '
                    'dashboard. You can reactivate at any time. This action '
                    'will be logged.',
                color: theme.colorScheme.error,
                onConfirm: () => context.read<SuperAdminBloc>().add(
                  UpdateSchoolStatusEvent(
                    schoolId: school.id,
                    status: SchoolStatus.suspended,
                    reason: 'Suspended by Owner',
                  ),
                ),
              ),
            )
          else if (school.status == SchoolStatus.suspended ||
              school.status == SchoolStatus.archived)
            IconButton(
              tooltip: 'Reactivate school',
              icon: Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success(context),
              ),
              onPressed: () => _confirmStatusChange(
                context,
                action: 'Reactivate',
                message:
                    'Are you sure you want to reactivate ${school.name}? '
                    'Staff and admins will regain access immediately. This '
                    'action will be logged.',
                color: AppColors.success(context),
                onConfirm: () => context.read<SuperAdminBloc>().add(
                  UpdateSchoolStatusEvent(
                    schoolId: school.id,
                    status: SchoolStatus.active,
                  ),
                ),
              ),
            ),
          if (school.status != SchoolStatus.archived)
            PopupMenuButton<String>(
              tooltip: 'More actions',
              onSelected: (value) {
                if (value == 'archive') _archiveSchool(context, school);
              },
              itemBuilder: (menuContext) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 18,
                        color: Theme.of(menuContext).colorScheme.error,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Text(
                        'Archive School',
                        style: TextStyle(
                          color: Theme.of(menuContext).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      color: AppColors.textSecondary(context).withValues(alpha: 0.06),
      child: Row(
        children: [
          Icon(
            Icons.support_agent,
            color: AppColors.textSecondary(context),
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
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  'Not available yet — impersonating a school admin '
                  'session requires a dedicated, audited access model that '
                  "hasn't been built. This card is a placeholder for that "
                  'future capability.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editSchoolInfo(BuildContext context, School school) {
    final bloc = context.read<SuperAdminBloc>();
    final nameController = TextEditingController(text: school.name);
    final emailController = TextEditingController(text: school.contactEmail);
    final phoneController = TextEditingController(text: school.contactPhone);
    final addressController = TextEditingController(text: school.address);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit School Info'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'School name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'School name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Contact email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              bloc.add(
                UpdateSchoolInfoEvent(
                  school.copyWith(
                    name: nameController.text.trim(),
                    contactEmail: emailController.text.trim(),
                    contactPhone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('School info updated.')),
              );
            },
            child: const Text('Save Changes'),
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
    required String message,
  }) {
    confirmSchoolStatusChange(
      context,
      action: action,
      message: message,
      color: color,
      onConfirm: onConfirm,
    );
  }

  void _archiveSchool(BuildContext context, School school) {
    archiveSchoolDialog(context, school);
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

/// Shared suspend/reactivate confirmation dialog. Reused by both
/// [SchoolDetailScreen]'s app bar actions and the Schools list's quick
/// actions so the wording and behavior stay in one place.
void confirmSchoolStatusChange(
  BuildContext context, {
  required String action,
  required String message,
  required Color color,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('$action School?'),
      content: Text(message),
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

/// Shared archive confirmation dialog — reused by [SchoolDetailScreen] and
/// the Schools list quick actions. Archiving reuses the same Firestore
/// write and access-lockout logic as suspending; it never deletes data.
void archiveSchoolDialog(BuildContext context, School school) {
  final bloc = context.read<SuperAdminBloc>();
  final reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        Icons.archive_outlined,
        color: Theme.of(dialogContext).colorScheme.error,
      ),
      title: const Text('Archive School?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Archiving ${school.name} immediately blocks all staff and '
            'admin access, the same as suspending. This does NOT delete '
            'any school data — it stays fully recoverable. Use this for '
            'schools that are permanently leaving the platform.',
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: reasonController,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'e.g. School closed, moved to another provider',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () {
            final reason = reasonController.text.trim();
            if (reason.length < 3) return;
            bloc.add(
              UpdateSchoolStatusEvent(
                schoolId: school.id,
                status: SchoolStatus.archived,
                reason: reason,
              ),
            );
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${school.name} has been archived.')),
            );
          },
          child: const Text('Archive School'),
        ),
      ],
    ),
  );
}
