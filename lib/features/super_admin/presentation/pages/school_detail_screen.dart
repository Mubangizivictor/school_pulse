import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(school.name),
        actions: [
          if (school.status == SchoolStatus.active)
            TextButton.icon(
              onPressed: () => _confirmAction(context, 'Suspend', Colors.red, () {
                context.read<SuperAdminBloc>().add(
                  UpdateSchoolStatusEvent(schoolId: school.id, status: SchoolStatus.suspended, reason: 'Suspended by Owner'),
                );
              }),
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text('Suspend School', style: TextStyle(color: Colors.red)),
            )
          else if (school.status == SchoolStatus.suspended)
            TextButton.icon(
              onPressed: () => _confirmAction(context, 'Activate', Colors.green, () {
                context.read<SuperAdminBloc>().add(
                  UpdateSchoolStatusEvent(schoolId: school.id, status: SchoolStatus.active),
                );
              }),
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Activate School', style: TextStyle(color: Colors.green)),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            if (isSuperAdminWide(context))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSchoolInfo(theme)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildSubscriptionCard(theme, context)),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSchoolInfo(theme),
                  const SizedBox(height: 32),
                  _buildSubscriptionCard(theme, context),
                ],
              ),
            const SizedBox(height: 32),
            _buildFeatureControl(theme, context),
            const SizedBox(height: 32),
            _buildSupportModeAction(theme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                school.name.substring(0, 1).toUpperCase(),
                style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(school.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Tenant ID: ${school.tenantId} • Created ${DateFormat('MMM dd, yyyy').format(school.createdAt)}'),
                ],
              ),
            ),
            _SupportBadge(status: school.status),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Information', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(school.contactEmail),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone'),
                subtitle: Text(school.contactPhone),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Address'),
                subtitle: Text(school.address),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subscription', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.subscriptionPlanId.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Expires on ${DateFormat('MMM dd, yyyy').format(school.subscriptionExpiry)}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showPlanSelector(context),
                  child: const Text('Change Plan'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureControl(ThemeData theme, BuildContext context) {
    final allFeatures = [
      {'id': 'attendance', 'name': 'Attendance Management', 'icon': Icons.calendar_today},
      {'id': 'finance', 'name': 'Financial Records', 'icon': Icons.payments},
      {'id': 'exams', 'name': 'Examination System', 'icon': Icons.assignment},
      {'id': 'transport', 'name': 'Transport/Bus Tracking', 'icon': Icons.directions_bus},
      {'id': 'library', 'name': 'Library Management', 'icon': Icons.book},
      {'id': 'qr_scanner', 'name': 'QR Attendance Integration', 'icon': Icons.qr_code},
      {'id': 'parent_portal', 'name': 'Parent Engagement', 'icon': Icons.family_restroom},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enabled Features', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allFeatures.length,
            separatorBuilder: (_, _) => const Divider(),
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
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.support_agent, color: Colors.orange, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Owner Support Mode', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('Temporarily access this school\'s dashboard to assist the administrator.'),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () => _promptSupportModeReason(context, school),
              child: const Text('Enter Support Mode'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String action, Color color, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action School?'),
        content: Text('Are you sure you want to $action ${school.name}? This action will be logged.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _showPlanSelector(BuildContext context) {
    // Show a dialog with plan options
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              context.read<SuperAdminBloc>().add(
                EnterSupportModeEvent(schoolId: school.id, reason: reason),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Entering Support Mode for ${school.name}... (Logged)')),
              );
            },
            child: const Text('Enter Support Mode'),
          ),
        ],
      ),
    );
  }
}

class _SupportBadge extends StatelessWidget {
  final SchoolStatus status;
  const _SupportBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == SchoolStatus.active) color = Colors.green;
    if (status == SchoolStatus.suspended) color = Colors.red;
    if (status == SchoolStatus.trial) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
