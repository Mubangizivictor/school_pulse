import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/app_components.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_radius.dart';
import '../../../../design_system/theme/app_spacing.dart';
import '../../../../design_system/theme/app_typography.dart';
import 'package:school_pulse/features/institution/domain/entities/access_mode.dart';
import '../../domain/entities/school.dart';
import '../../domain/entities/school_application.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_tab_navigator.dart';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _SchoolsHeader(
                onRefresh: () => context.read<SuperAdminBloc>().add(
                  LoadSuperAdminDashboard(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
                child: _SchoolsSegmentedTabs(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2l,
                  AppSpacing.xl,
                  AppSpacing.x2l,
                  AppSpacing.l,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.health_and_safety_outlined,
                            color: AppColors.electricBlue,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Manage every institution using School Pulse.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SchoolSearchField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
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
                        message:
                            state.errorMessage ?? 'Unable to load schools.',
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
                          application.schoolEmail.toLowerCase().contains(
                            query,
                          ) ||
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
                                a.status ==
                                SchoolApplicationStatus.pendingReview;
                            final bPending =
                                b.status ==
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
      ),
    );
  }
}

class _SchoolsHeader extends StatelessWidget {
  const _SchoolsHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -38,
            top: -95,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x294D8BFF), Color(0x004D8BFF)],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 160,
            height: 64,
            child: IgnorePointer(
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Schools',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textPrimary(context),
                      fontSize: 26,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                Material(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: AppRadius.medium,
                  elevation: 0,
                  child: InkWell(
                    onTap: onRefresh,
                    borderRadius: AppRadius.medium,
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary(context),
                        size: 19,
                      ),
                    ),
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

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1A4D8BFF);
    const spacing = 14.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}

class _SchoolsSegmentedTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        splashBorderRadius: AppRadius.medium,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.surfaceContainerHigh(context),
          borderRadius: AppRadius.medium,
          border: const Border(
            bottom: BorderSide(color: AppColors.electricBlue, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppColors.primary(context),
        unselectedLabelColor: AppColors.textSecondary(context),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            height: 56,
            icon: Icon(Icons.account_balance_outlined, size: 18),
            text: 'Active Schools',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            height: 56,
            icon: Icon(Icons.description_outlined, size: 18),
            text: 'Applications',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            height: 56,
            icon: Icon(Icons.block_outlined, size: 18),
            text: 'Suspended',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }
}

class _SchoolSearchField extends StatelessWidget {
  const _SchoolSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        hintText: 'Search by name, prefix, email, district or tenant ID...',
        hintStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textMuted(context),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary(context),
          size: 20,
        ),
        suffixIcon: Icon(
          Icons.tune_rounded,
          color: AppColors.textSecondary(context),
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.surfaceElevated(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: AppColors.border(context), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: AppColors.primary(context), width: 1.4),
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: schools.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
      onTap: () => pushSuperAdminDetail(
        context: context,
        sectionPath: 'schools',
        detailPath: 'applications/${application.id}',
        detail: BlocProvider.value(
          value: context.read<SuperAdminBloc>(),
          child: SchoolApplicationReviewScreen(application: application),
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
    final initial = school.name.trim().isEmpty
        ? 'S'
        : school.name.trim()[0].toUpperCase();

    return Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: AppRadius.large,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => pushSuperAdminDetail(
          context: context,
          sectionPath: 'schools',
          detailPath: school.id,
          detail: SchoolDetailScreen(school: school),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.l,
            AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.large,
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SchoolInitialAvatar(initial: initial, name: school.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              school.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _SchoolStatusPill(status: school.status),
                        if (AccessMode.fromRaw(school.accessMode) !=
                            AccessMode.full) ...[
                          const SizedBox(width: 6),
                          _AccessModePill(accessMode: school.accessMode),
                        ],
                      ],
                    ),
                    const SizedBox(height: 9),
                    _SchoolMetaRow(
                      icon: Icons.badge_outlined,
                      text: 'ID: ${school.tenantId}',
                    ),
                    const SizedBox(height: 6),
                    _SchoolMetaRow(
                      icon: Icons.calendar_today_outlined,
                      text:
                          'Expiry: ${DateFormat('MMM dd, yyyy').format(school.subscriptionExpiry)}',
                    ),
                    const SizedBox(height: 6),
                    _SchoolMetaRow(
                      icon: Icons.mail_outline_rounded,
                      text: school.contactEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _SchoolQuickActions(school: school),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchoolInitialAvatar extends StatelessWidget {
  const _SchoolInitialAvatar({required this.initial, required this.name});

  final String initial;
  final String name;

  @override
  Widget build(BuildContext context) {
    const palettes = [
      (Color(0xFFBED0FF), Color(0xFFE8EEFF), Color(0xFF1549B8)),
      (Color(0xFFBCEFD7), Color(0xFFE7FAEF), Color(0xFF087342)),
      (Color(0xFFE0C8FF), Color(0xFFF2E9FF), Color(0xFF4E149D)),
      (Color(0xFFFFD1B5), Color(0xFFFFEEE3), Color(0xFFB3430B)),
    ];
    final palette =
        palettes[name.codeUnits.fold<int>(0, (a, b) => a + b) %
            palettes.length];
    return Container(
      width: 56,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.$1, palette.$2],
        ),
        border: Border.all(color: palette.$1.withValues(alpha: .75)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: palette.$3,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _SchoolMetaRow extends StatelessWidget {
  const _SchoolMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.textSecondary(context)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ),
    ],
  );
}

/// Billing state, deliberately separate from _SchoolStatusPill's operational
/// status (active/suspended/etc) - an expired subscription and an
/// owner-suspended school are different concepts and must never share one
/// badge. Only rendered when accessMode isn't 'full', so a normal paying
/// school shows no extra pill.
class _AccessModePill extends StatelessWidget {
  const _AccessModePill({required this.accessMode});

  final String? accessMode;

  @override
  Widget build(BuildContext context) {
    final mode = AccessMode.fromRaw(accessMode);
    final (label, color) = switch (mode) {
      AccessMode.readOnly => ('READ-ONLY', Colors.amber.shade800),
      AccessMode.blocked => ('BLOCKED', Theme.of(context).colorScheme.error),
      AccessMode.full => ('', Colors.transparent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: AppRadius.full,
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _SchoolStatusPill extends StatelessWidget {
  const _SchoolStatusPill({required this.status});

  final SchoolStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive =
        status == SchoolStatus.active || status == SchoolStatus.trial;
    final color = isActive
        ? AppColors.success(context)
        : _schoolStatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.successSurface(context)
            : color.withValues(alpha: .12),
        borderRadius: AppRadius.full,
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
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
      onTap: () => pushSuperAdminDetail(
        context: context,
        sectionPath: 'schools',
        detailPath: school.id,
        detail: SchoolDetailScreen(school: school),
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
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge(label: school.status.name, color: statusColor),
                  if (AccessMode.fromRaw(school.accessMode) != AccessMode.full)
                    _AccessModePill(accessMode: school.accessMode),
                ],
              ),
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
            _SchoolQuickActions(school: school, compact: true),
          ],
        ),
      ),
    );
  }
}

/// Suspend/Reactivate shortcut menu shown on each Schools list row, so
/// lifecycle actions don't require opening School Details first. Reuses
/// the exact same confirmation dialogs and Firestore-backed events as the
/// School Details screen. Deleting a school lives only in the More page.
class _SchoolQuickActions extends StatelessWidget {
  const _SchoolQuickActions({required this.school, this.compact = false});

  final School school;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: 'Quick actions',
      icon: Icon(
        Icons.more_vert_rounded,
        size: compact ? 18 : 22,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onSelected: (value) {
        switch (value) {
          case 'suspend':
            confirmSchoolStatusChange(
              context,
              action: 'Suspend',
              message:
                  'Are you sure you want to suspend ${school.name}? Staff '
                  'and admins will immediately lose access to the '
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
            );
          case 'reactivate':
            confirmSchoolStatusChange(
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
            );
        }
      },
      itemBuilder: (menuContext) => [
        PopupMenuItem(
          value: 'view',
          onTap: () => pushSuperAdminDetail(
            context: context,
            sectionPath: 'schools',
            detailPath: school.id,
            detail: SchoolDetailScreen(school: school),
          ),
          child: const Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18),
              SizedBox(width: AppSpacing.m),
              Text('View Details'),
            ],
          ),
        ),
        if (school.status == SchoolStatus.active)
          PopupMenuItem(
            value: 'suspend',
            child: Row(
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 18,
                  color: Theme.of(menuContext).colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.m),
                Text(
                  'Suspend',
                  style: TextStyle(
                    color: Theme.of(menuContext).colorScheme.error,
                  ),
                ),
              ],
            ),
          )
        else if (school.status == SchoolStatus.suspended ||
            school.status == SchoolStatus.archived)
          PopupMenuItem(
            value: 'reactivate',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AppColors.success(menuContext),
                ),
                const SizedBox(width: AppSpacing.m),
                Text(
                  'Reactivate',
                  style: TextStyle(color: AppColors.success(menuContext)),
                ),
              ],
            ),
          ),
      ],
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
