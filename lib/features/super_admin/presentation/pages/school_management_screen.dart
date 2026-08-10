import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/app_components.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_spacing.dart';
import '../../../../design_system/theme/app_typography.dart';
import '../../domain/entities/school.dart';
import '../../domain/entities/school_application.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import 'create_school_dialog.dart';
import 'school_detail_screen.dart';
import 'school_application_review_screen.dart';

class SchoolManagementScreen extends StatefulWidget {
  const SchoolManagementScreen({super.key});

  @override
  State<SchoolManagementScreen> createState() => _SchoolManagementScreenState();
}

class _SchoolManagementScreenState extends State<SchoolManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isWide = isSuperAdminWide(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schools'),
          actions: [
            IconButton(
              onPressed: () =>
                  context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard()),
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: isWide ? AppSpacing.x3l : AppSpacing.m,
              ),
              child: isWide
                  ? FilledButton.icon(
                      onPressed: () => _showCreateSchoolDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add School'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(160, 44),
                      ),
                    )
                  : IconButton.filled(
                      onPressed: () => _showCreateSchoolDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Add School',
                    ),
            ),
            if (!isWide) const SuperAdminLogoutButton(),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Schools'),
              Tab(text: 'Applications'),
              Tab(text: 'Suspended'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2l,
                AppSpacing.xl,
                AppSpacing.x2l,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage every institution using School Pulse.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppSearchField(
                    hintText:
                        'Search by name, prefix, email, district or tenant ID…',
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SuperAdminBloc, SuperAdminState>(
                builder: (context, state) {
                  if (state.status == SuperAdminStatus.loading) {
                    return const Center(child: SchoolPulseLoader());
                  }
                  if (state.status == SuperAdminStatus.failure &&
                      state.schools.isEmpty &&
                      state.applications.isEmpty) {
                    return _ErrorState(
                      message: state.errorMessage ?? 'Unable to load schools.',
                      onRetry: () => context.read<SuperAdminBloc>().add(
                        LoadSuperAdminDashboard(),
                      ),
                    );
                  }

                  final query = _searchQuery.trim().toLowerCase();
                  bool schoolMatches(School school) {
                    if (query.isEmpty) return true;
                    return school.name.toLowerCase().contains(query) ||
                        school.tenantId.toLowerCase().contains(query) ||
                        school.contactEmail.toLowerCase().contains(query) ||
                        school.address.toLowerCase().contains(query);
                  }

                  bool applicationMatches(SchoolApplication application) {
                    if (query.isEmpty) return true;
                    return application.schoolName.toLowerCase().contains(
                          query,
                        ) ||
                        application.prefix.toLowerCase().contains(query) ||
                        application.administratorName.toLowerCase().contains(
                          query,
                        ) ||
                        application.administratorEmail.toLowerCase().contains(
                          query,
                        ) ||
                        application.schoolEmail.toLowerCase().contains(query) ||
                        application.district.toLowerCase().contains(query);
                  }

                  final activeSchools = state.schools
                      .where(
                        (school) =>
                            schoolMatches(school) &&
                            (school.status == SchoolStatus.active ||
                                school.status == SchoolStatus.trial),
                      )
                      .toList();
                  final suspendedSchools = state.schools
                      .where(
                        (school) =>
                            schoolMatches(school) &&
                            (school.status == SchoolStatus.suspended ||
                                school.status == SchoolStatus.archived),
                      )
                      .toList();
                  final applications =
                      state.applications.where(applicationMatches).toList()
                        ..sort((a, b) {
                          final aPending =
                              a.status == SchoolApplicationStatus.pendingReview;
                          final bPending =
                              b.status == SchoolApplicationStatus.pendingReview;
                          if (aPending != bPending) return aPending ? -1 : 1;
                          final aDate = a.createdAt ?? DateTime(1970);
                          final bDate = b.createdAt ?? DateTime(1970);
                          return bDate.compareTo(aDate);
                        });

                  return TabBarView(
                    children: [
                      _SchoolList(
                        schools: activeSchools,
                        emptyTitle: 'No active schools',
                        emptyCopy:
                            'Approved schools and manually provisioned schools appear here.',
                      ),
                      _ApplicationList(applications: applications),
                      _SchoolList(
                        schools: suspendedSchools,
                        emptyTitle: 'No suspended schools',
                        emptyCopy:
                            'Suspended and archived tenants will appear here.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSchoolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateSchoolDialog(),
    );
  }
}

class _SchoolList extends StatelessWidget {
  final List<School> schools;
  final String emptyTitle;
  final String emptyCopy;

  const _SchoolList({
    required this.schools,
    required this.emptyTitle,
    required this.emptyCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return EmptyState(
        icon: Icons.school_outlined,
        title: emptyTitle,
        message: emptyCopy,
      );
    }
    final wide = isSuperAdminWide(context);
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: wide ? _schoolTable(context) : _schoolCards(context),
    );
  }

  Widget _schoolCards(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2l,
        AppSpacing.s,
        AppSpacing.x2l,
        AppSpacing.x3l,
      ),
      itemCount: schools.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
      itemBuilder: (context, index) => _SchoolCard(school: schools[index]),
    );
  }

  Widget _schoolTable(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2l,
        AppSpacing.s,
        AppSpacing.x2l,
        AppSpacing.x3l,
      ),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.m,
                ),
                child: Row(
                  children: [
                    _headCell(context, 'School', flex: 3),
                    _headCell(context, 'Tenant ID', flex: 2),
                    _headCell(context, 'Plan', flex: 2),
                    _headCell(context, 'Status', flex: 2),
                    _headCell(context, 'Expiry', flex: 2),
                    _headCell(context, 'Contact', flex: 3),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              const Divider(height: 1),
              for (final school in schools) _SchoolTableRow(school: school),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headCell(BuildContext context, String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _ApplicationList extends StatelessWidget {
  final List<SchoolApplication> applications;

  const _ApplicationList({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No school applications',
        message:
            'Applications submitted from schoolpulse.victorbee.com will appear here automatically.',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x2l,
          AppSpacing.s,
          AppSpacing.x2l,
          AppSpacing.x3l,
        ),
        itemCount: applications.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) =>
            _ApplicationTile(application: applications[index]),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final SchoolApplication application;

  const _ApplicationTile({required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = application.status == SchoolApplicationStatus.pendingReview;
    final statusColor = _applicationStatusColor(context, application.status);
    final initial = application.schoolName.trim().isEmpty
        ? 'S'
        : application.schoolName.trim()[0].toUpperCase();

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<SuperAdminBloc>(),
            child: SchoolApplicationReviewScreen(application: application),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
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
                        application.schoolName.isEmpty
                            ? 'Unnamed school'
                            : application.schoolName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: application.status.label,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${application.prefix.isEmpty ? 'No prefix' : application.prefix} • '
                  '${application.category.isEmpty ? 'School type pending' : application.category} • '
                  '${application.district.isEmpty ? application.region : application.district}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${application.plan.isEmpty ? 'Plan pending' : '${application.plan} plan'} • '
                  '${application.administratorName.isEmpty ? 'Administrator' : application.administratorName} • '
                  '${application.administratorEmail}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniLabel(
                      icon: application.administratorEmailVerified
                          ? Icons.verified_outlined
                          : Icons.mark_email_unread_outlined,
                      label: application.administratorEmailVerified
                          ? 'Email verified'
                          : 'Email not verified',
                    ),
                    _MiniLabel(
                      icon: application.termsAccepted
                          ? Icons.task_alt_outlined
                          : Icons.remove_circle_outline,
                      label: application.termsAccepted
                          ? 'Terms accepted'
                          : 'Terms not accepted',
                    ),
                    if (application.createdAt != null)
                      _MiniLabel(
                        icon: Icons.schedule_outlined,
                        label:
                            'Submitted ${DateFormat('dd MMM, h:mm a').format(application.createdAt!.toLocal())}',
                      ),
                    if (pending)
                      const _MiniLabel(
                        icon: Icons.rate_review_outlined,
                        label: 'Needs your review',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final School school;

  const _SchoolCard({required this.school});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _schoolStatusColor(context, school.status);
    final initial = school.name.trim().isEmpty
        ? 'S'
        : school.name.trim()[0].toUpperCase();

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolDetailScreen(school: school),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initial,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    StatusBadge(label: school.status.name, color: statusColor),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  'ID: ${school.tenantId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Expiry: ${DateFormat('MMM dd, yyyy').format(school.subscriptionExpiry)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(school.contactEmail, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _SchoolTableRow extends StatelessWidget {
  final School school;

  const _SchoolTableRow({required this.school});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _schoolStatusColor(context, school.status);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolDetailScreen(school: school),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                school.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                school.tenantId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                school.subscriptionPlanId.isEmpty
                    ? '—'
                    : school.subscriptionPlanId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: StatusBadge(label: school.status.name, color: statusColor),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM dd, yyyy').format(school.subscriptionExpiry),
                style: theme.textTheme.bodySmall,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                school.contactEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(
              width: 32,
              child: Icon(Icons.chevron_right_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 54,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

Color _applicationStatusColor(
  BuildContext context,
  SchoolApplicationStatus status,
) {
  switch (status) {
    case SchoolApplicationStatus.pendingReview:
    case SchoolApplicationStatus.emailVerificationPending:
    case SchoolApplicationStatus.emailVerified:
      return AppColors.warning(context);
    case SchoolApplicationStatus.approved:
      return AppColors.success(context);
    case SchoolApplicationStatus.rejected:
      return AppColors.danger(context);
    case SchoolApplicationStatus.unknown:
      return AppColors.textSecondary(context);
  }
}

Color _schoolStatusColor(BuildContext context, SchoolStatus status) {
  switch (status) {
    case SchoolStatus.active:
      return AppColors.success(context);
    case SchoolStatus.suspended:
      return AppColors.danger(context);
    case SchoolStatus.trial:
      return AppColors.warning(context);
    case SchoolStatus.archived:
      return AppColors.textSecondary(context);
  }
}
