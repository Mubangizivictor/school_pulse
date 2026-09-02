import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../data/services/school_counts_service.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../widgets/super_admin_tab_navigator.dart';
import 'school_subscription_screen.dart';
import 'school_modules_screen.dart';
import 'school_admin_actions_screen.dart';

/// Screen A - School Overview. Compact identity card, editable profile
/// summary, real metrics grid, and action rows into Subscription/Payments
/// (Screen B), Modules (Screen C), and School admins (Screen D). Those
/// sub-screens are pushed onto this section's nested Navigator via
/// [pushSuperAdminDetail] so back/swipe-back and the URL stay in sync with
/// the existing SuperAdminTabNavigator pattern.
class SchoolDetailScreen extends StatefulWidget {
  final School school;

  const SchoolDetailScreen({super.key, required this.school});

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen> {
  School get school => widget.school;
  final _metricsKey = GlobalKey<_MetricsGridState>();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final daysRemaining = school.subscriptionExpiry
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(school.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Edit school info',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editSchoolInfo(context, school),
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            onSelected: (value) {
              if (value == 'admin_actions') {
                pushSuperAdminDetail(
                  context: context,
                  sectionPath: 'schools',
                  detailPath: '${school.id}/admins',
                  detail: BlocProvider.value(
                    value: context.read<SuperAdminBloc>(),
                    child: SchoolAdminActionsScreen(school: school),
                  ),
                );
              }
            },
            itemBuilder: (menuContext) => [
              const PopupMenuItem(
                value: 'admin_actions',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined, size: 18),
                    SizedBox(width: AppSpacing.m),
                    Text('School admins & actions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
          await _metricsKey.currentState?.refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IdentityCard(school: school),
              const SizedBox(height: AppSpacing.l),
              _ProfileSummaryCard(school: school),
              const SizedBox(height: AppSpacing.l),
              _MetricsGrid(
                key: _metricsKey,
                school: school,
                dateFormat: dateFormat,
              ),
              const SizedBox(height: AppSpacing.l),
              _ActionRow(
                icon: Icons.workspace_premium_rounded,
                color: AppColors.primary(context),
                title: 'Subscription',
                subtitle: 'Plan, renewal & billing',
                summary: daysRemaining >= 0
                    ? '$daysRemaining days left'
                    : 'Expired',
                onTap: () => pushSuperAdminDetail(
                  context: context,
                  sectionPath: 'schools',
                  detailPath: '${school.id}/subscription',
                  detail: BlocProvider.value(
                    value: context.read<SuperAdminBloc>(),
                    child: SchoolSubscriptionScreen(school: school),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _ActionRow(
                icon: Icons.credit_card_rounded,
                color: AppColors.primary(context),
                title: 'Payments',
                subtitle: 'Payment history & manual reviews',
                summary: '',
                onTap: () => pushSuperAdminDetail(
                  context: context,
                  sectionPath: 'schools',
                  detailPath: '${school.id}/subscription',
                  detail: BlocProvider.value(
                    value: context.read<SuperAdminBloc>(),
                    child: SchoolSubscriptionScreen(school: school),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _ActionRow(
                icon: Icons.extension_rounded,
                color: AppColors.primary(context),
                title: 'Modules',
                subtitle: 'Enabled entitlements and history',
                summary: '',
                onTap: () => pushSuperAdminDetail(
                  context: context,
                  sectionPath: 'schools',
                  detailPath: '${school.id}/modules',
                  detail: BlocProvider.value(
                    value: context.read<SuperAdminBloc>(),
                    child: SchoolModulesScreen(school: school),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _ActionRow(
                icon: Icons.groups_rounded,
                color: AppColors.primary(context),
                title: 'School admins',
                subtitle: 'Administrators, access & support session',
                summary: '',
                onTap: () => pushSuperAdminDetail(
                  context: context,
                  sectionPath: 'schools',
                  detailPath: '${school.id}/admins',
                  detail: BlocProvider.value(
                    value: context.read<SuperAdminBloc>(),
                    child: SchoolAdminActionsScreen(school: school),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.l,
            right: AppSpacing.l,
            top: AppSpacing.l,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit school information',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(sheetContext),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
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
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: saving
                              ? null
                              : () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: FilledButton(
                          onPressed: saving
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  }
                                  setSheetState(() => saving = true);
                                  bloc.add(
                                    UpdateSchoolInfoEvent(
                                      school.copyWith(
                                        name: nameController.text.trim(),
                                        contactEmail: emailController.text
                                            .trim(),
                                        contactPhone: phoneController.text
                                            .trim(),
                                        address: addressController.text
                                            .trim(),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(sheetContext);
                                },
                          child: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.school});
  final School school;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final portalUrl = _portalUrl(school);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary(context).withValues(alpha: .14),
            child: Text(
              school.name.isEmpty ? '?' : school.name.substring(0, 1).toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        school.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _statusBadge(school.status, context),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tenant ID  ${school.tenantId}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _location(school),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Created ${DateFormat('MMM d, yyyy').format(school.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                  ),
                ),
                if (portalUrl != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View portal',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _portalUrl(School school) {
    if (school.domainStatus != 'active') return null;
    if (school.portalSubdomain.isEmpty) return null;
    return 'https://${school.portalSubdomain}';
  }

  static String _location(School school) {
    final district = school.metadata['district']?.toString().trim();
    if (district?.isNotEmpty == true) return district!;
    return school.address.trim().isEmpty ? 'Location unavailable' : school.address;
  }

  Widget _statusBadge(SchoolStatus status, BuildContext context) {
    final (label, color) = switch (status) {
      SchoolStatus.active => ('Active', AppColors.success(context)),
      SchoolStatus.suspended => ('Suspended', AppColors.danger(context)),
      SchoolStatus.trial => ('Pending', AppColors.warning(context)),
      SchoolStatus.archived => ('Archived', AppColors.textSecondary(context)),
    };
    return StatusBadge(label: label, color: color);
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.school});
  final School school;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _row(
            context,
            icon: Icons.email_outlined,
            label: 'Contact email',
            value: school.contactEmail.isEmpty ? '—' : school.contactEmail,
          ),
          const Divider(height: 1),
          _row(
            context,
            icon: Icons.phone_outlined,
            label: 'Contact phone',
            value: school.contactPhone.isEmpty ? '—' : school.contactPhone,
          ),
          const Divider(height: 1),
          _row(
            context,
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: school.address.isEmpty ? '—' : school.address,
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary(context)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatefulWidget {
  const _MetricsGrid({super.key, required this.school, required this.dateFormat});
  final School school;
  final DateFormat dateFormat;

  @override
  State<_MetricsGrid> createState() => _MetricsGridState();
}

enum _CountsLoadState { loading, loaded, unavailable }

class _MetricsGridState extends State<_MetricsGrid> {
  _CountsLoadState _state = _CountsLoadState.loading;
  SchoolCounts? _counts;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => _state = _CountsLoadState.loading);
    try {
      // Constructed inside the try, not as a field initializer: creating
      // FirebaseFunctions.instanceFor throws synchronously if no Firebase
      // app is initialized yet at the point this widget builds (e.g. a
      // widget test with no Firebase.initializeApp) - this keeps that a
      // normal "unavailable" state instead of an uncaught build-time crash.
      final counts = await SchoolCountsService().fetch(widget.school.id);
      if (!mounted) return;
      setState(() {
        _counts = counts;
        _state = _CountsLoadState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _CountsLoadState.unavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentValue = switch (_state) {
      _CountsLoadState.loading => null,
      _CountsLoadState.loaded => _counts!.studentCount.toString(),
      _CountsLoadState.unavailable => '—',
    };
    final staffValue = switch (_state) {
      _CountsLoadState.loading => null,
      _CountsLoadState.loaded => _counts!.staffCount.toString(),
      _CountsLoadState.unavailable => '—',
    };
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s,
      crossAxisSpacing: AppSpacing.s,
      childAspectRatio: 2.4,
      children: [
        _metricTile(
          context,
          icon: Icons.groups_2_outlined,
          label: 'Students',
          value: studentValue,
          onRetry: _state == _CountsLoadState.unavailable ? refresh : null,
        ),
        _metricTile(
          context,
          icon: Icons.badge_outlined,
          label: 'Staff',
          value: staffValue,
          onRetry: _state == _CountsLoadState.unavailable ? refresh : null,
        ),
        _metricTile(
          context,
          icon: Icons.workspace_premium_outlined,
          label: 'Current plan',
          value: widget.school.subscriptionPlanId.isEmpty
              ? 'Unassigned'
              : widget.school.subscriptionPlanId,
        ),
        _metricTile(
          context,
          icon: Icons.event_available_outlined,
          label: 'Renewal',
          value: widget.dateFormat.format(widget.school.subscriptionExpiry),
        ),
      ],
    );
  }

  Widget _metricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onRetry,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      onTap: onRetry,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary(context)),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value == null)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  onRetry != null ? '$label · tap to retry' : label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 11,
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          if (summary.isNotEmpty) ...[
            Text(
              summary,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted(context),
          ),
        ],
      ),
    );
  }
}
