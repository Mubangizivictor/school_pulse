import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/app_components.dart';
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
              onPressed: () => context.read<SuperAdminBloc>().add(
                    LoadSuperAdminDashboard(),
                  ),
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
            ),
            Padding(
              padding: EdgeInsets.only(right: isWide ? 24 : 8),
              child: isWide
                  ? ElevatedButton.icon(
                      onPressed: () => _showCreateSchoolDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add School Manually'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(190, 46),
                      ),
                    )
                  : IconButton.filled(
                      onPressed: () => _showCreateSchoolDialog(context),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add School Manually',
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: AppSearchField(
                hintText: 'Search schools, applicants, email or school ID…',
                onChanged: (value) => setState(() => _searchQuery = value),
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
                        school.contactEmail.toLowerCase().contains(query);
                  }

                  bool applicationMatches(SchoolApplication application) {
                    if (query.isEmpty) return true;
                    return application.schoolName.toLowerCase().contains(query) ||
                        application.prefix.toLowerCase().contains(query) ||
                        application.administratorName.toLowerCase().contains(query) ||
                        application.administratorEmail.toLowerCase().contains(query) ||
                        application.schoolEmail.toLowerCase().contains(query);
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
                  final applications = state.applications
                      .where(applicationMatches)
                      .toList()
                    ..sort((a, b) {
                      final aPending = a.status ==
                          SchoolApplicationStatus.pendingReview;
                      final bPending = b.status ==
                          SchoolApplicationStatus.pendingReview;
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
      return _EmptyState(
        icon: Icons.school_outlined,
        title: emptyTitle,
        copy: emptyCopy,
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: schools.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _SchoolListTile(school: schools[index]),
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
      return const _EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No school applications',
        copy:
            'Applications submitted from schoolpulse.victorbee.com will appear here automatically.',
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: applications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    final statusColor = _applicationStatusColor(application.status, theme);
    final initial = application.schoolName.trim().isEmpty
        ? 'S'
        : application.schoolName.trim()[0].toUpperCase();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<SuperAdminBloc>(),
              child: SchoolApplicationReviewScreen(application: application),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 14),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            application.status.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${application.plan.isEmpty ? 'Plan pending' : '${application.plan} plan'} • ${application.district.isEmpty ? application.region : application.district}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${application.administratorName.isEmpty ? 'Administrator' : application.administratorName} • ${application.administratorEmail}',
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
                        if (application.createdAt != null)
                          _MiniLabel(
                            icon: Icons.schedule_outlined,
                            label: DateFormat('dd MMM, h:mm a')
                                .format(application.createdAt!.toLocal()),
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
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
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

class _SchoolListTile extends StatelessWidget {
  final School school;

  const _SchoolListTile({required this.school});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(school.status);
    final initial = school.name.trim().isEmpty
        ? 'S'
        : school.name.trim()[0].toUpperCase();

    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchoolDetailScreen(school: school),
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              initial,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(school.name, style: theme.textTheme.titleMedium),
            StatusBadge(label: school.status.name, color: statusColor),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 18,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('ID: ${school.tenantId}'),
              Text(
                'Expiry: ${DateFormat('MMM dd, yyyy').format(school.subscriptionExpiry)}',
              ),
              Text('${school.metadata['studentCount'] ?? 0} Students'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _getStatusColor(SchoolStatus status) {
    switch (status) {
      case SchoolStatus.active:
        return Colors.green;
      case SchoolStatus.suspended:
        return Colors.red;
      case SchoolStatus.trial:
        return Colors.orange;
      case SchoolStatus.archived:
        return Colors.grey;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String copy;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.copy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: theme.colorScheme.outline),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Text(
                copy,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
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
  SchoolApplicationStatus status,
  ThemeData theme,
) {
  switch (status) {
    case SchoolApplicationStatus.pendingReview:
      return Colors.orange.shade800;
    case SchoolApplicationStatus.approved:
      return Colors.green.shade700;
    case SchoolApplicationStatus.rejected:
      return theme.colorScheme.error;
    case SchoolApplicationStatus.emailVerified:
      return Colors.blue.shade700;
    case SchoolApplicationStatus.emailVerificationPending:
      return Colors.amber.shade900;
    case SchoolApplicationStatus.unknown:
      return theme.colorScheme.outline;
  }
}
