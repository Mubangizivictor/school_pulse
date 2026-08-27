import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/services/structure_setup_progress_calculator.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';

final _progressCalculator = StructureSetupProgressCalculator();

/// The School Admin's institution workspace: manage-school, operations and
/// administration entry points, plus the Structure & calendar editors.
/// Reached from the "School" bottom-nav destination. Daily approvals live in
/// Work; personal account settings live in More - neither belongs here.
class SchoolWorkspaceScreen extends StatelessWidget {
  const SchoolWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    return _SchoolWorkspace(user: auth.user);
  }
}

class _SchoolWorkspace extends StatelessWidget {
  const _SchoolWorkspace({required this.user});
  final UserEntity user;

  List<_Group> get _groups => [
    _Group(
      title: 'Manage school',
      rows: [
        _Row(
          icon: Icons.people_outline,
          title: 'Learners & admissions',
          subtitle: 'Enrolment, admissions and student records',
          route: '/staff/admin/students',
        ),
        _Row(
          icon: Icons.badge_outlined,
          title: 'People',
          subtitle: 'Staff, roles and assignments',
          route: '/staff/admin/users',
        ),
        _Row(
          icon: Icons.menu_book_outlined,
          title: 'Academic programme',
          subtitle: 'Structure & calendar, subjects and curriculum',
          route: '/staff/admin/structure',
        ),
      ],
    ),
    _Group(
      title: 'Operations',
      rows: [
        _Row(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Fees & finance',
          subtitle: 'Collections, invoices and reports',
          route: '/staff/bursar',
        ),
        _Row(
          icon: Icons.schedule_outlined,
          title: 'School day & timetables',
          subtitle: 'Periods, sessions and class timetables',
          route: '/staff/admin/structure/operations',
        ),
        _Row(
          icon: Icons.holiday_village_outlined,
          title: 'Facilities',
          subtitle: 'Campuses, rooms and physical spaces',
          route: '/staff/admin/structure/campus',
        ),
      ],
    ),
    _Group(
      title: 'Administration',
      rows: [
        _Row(
          icon: Icons.apartment_outlined,
          title: 'Institution profile',
          subtitle: 'Identity, branding and registration',
          route: '/staff/admin/structure/institution',
        ),
        _Row(
          icon: Icons.tune_outlined,
          title: 'Modules & access',
          subtitle: 'Feature toggles and role permissions',
          route: '/staff/admin/structure/feature-toggles',
        ),
        _Row(
          icon: Icons.storage_outlined,
          title: 'Data management',
          subtitle: 'Import, export and records maintenance',
          route: '/staff/admin/data-management',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ResponsiveBuilder(
        builder: (context, layout) => layout == ResponsiveLayout.mobile
            ? _MobileSchool(user: user, groups: _groups)
            : _WideSchool(user: user, groups: _groups, layout: layout),
      ),
    ),
  );
}

class _MobileSchool extends StatelessWidget {
  const _MobileSchool({required this.user, required this.groups});
  final UserEntity user;
  final List<_Group> groups;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
    children: [
      _Header(user: user),
      const SizedBox(height: 18),
      const _SetupCard(),
      for (final group in groups) ...[
        const SizedBox(height: 22),
        _GroupList(group: group),
      ],
    ],
  );
}

/// Desktop (>=1024) and tablet (600-1023) layout: same destinations/routes as
/// mobile, arranged as a bounded card grid instead of stacked full-width rows.
class _WideSchool extends StatelessWidget {
  const _WideSchool({
    required this.user,
    required this.groups,
    required this.layout,
  });
  final UserEntity user;
  final List<_Group> groups;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    final isDesktop = layout == ResponsiveLayout.desktop;
    final columns = isDesktop ? 3 : 2;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 32 : 20,
        24,
        isDesktop ? 32 : 20,
        48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WideHeader(user: user),
              const SizedBox(height: 24),
              const _SetupCard(),
              for (final group in groups) ...[
                const SizedBox(height: 28),
                _GroupGrid(group: group, columns: columns),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WideHeader extends StatelessWidget {
  const _WideHeader({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              user.schoolName?.isNotEmpty == true
                  ? user.schoolName!
                  : 'Your institution',
              style: TextStyle(fontSize: 14, color: _ink(context)),
            ),
          ],
        ),
      ),
      _TermChip(schoolId: user.schoolId),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              user.schoolName?.isNotEmpty == true
                  ? user.schoolName!
                  : 'Your institution',
              style: TextStyle(fontSize: 12, color: _ink(context)),
            ),
          ],
        ),
      ),
      _TermChip(schoolId: user.schoolId),
    ],
  );
}

class _TermChip extends StatelessWidget {
  const _TermChip({required this.schoolId});
  final String schoolId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final currentTerm = state.academicTerms
              .where((term) => term.isCurrent && !term.isArchived)
              .firstOrNull;
          final currentYear = state.academicYears
              .where((year) => year.isCurrent && !year.isArchived)
              .firstOrNull;
          final label = currentTerm != null
              ? '${currentTerm.name} · ${currentYear?.name ?? ''}'
              : (currentYear?.name ?? 'No term set');
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: _ink(context)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 15),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      );
}

class _SetupCard extends StatelessWidget {
  const _SetupCard();

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, state) {
      final progress = _progressCalculator.calculate(state);
      if (progress.pendingCount == 0) return const SizedBox.shrink();
      final isMobile = ResponsiveBuilder.isMobile(context);
      final subtitle =
          '${progress.percentage}% complete · ${progress.pendingCount} step${progress.pendingCount == 1 ? '' : 's'} remaining';
      final action = OutlinedButton(
        onPressed: () => context.push('/staff/admin/structure'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink(context),
          side: BorderSide(color: _ink(context)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: const Text('View setup'),
      );
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'School setup',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: _ink(context))),
          if (!isMobile) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.percentage / 100,
                minHeight: 8,
                backgroundColor: _ink(context).withValues(alpha: 0.15),
                color: _ink(context),
              ),
            ),
          ],
        ],
      );
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: _ink(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            const SizedBox(width: 12),
            action,
          ],
        ),
      );
    },
  );
}

class _Group {
  const _Group({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;
}

class _Row {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

class _GroupList extends StatelessWidget {
  const _GroupList({required this.group});
  final _Group group;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        group.title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          letterSpacing: .6,
          fontWeight: FontWeight.w500,
          color: _ink(context),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: _ink(context)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            for (var i = 0; i < group.rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: _ink(context)),
              _RowTile(row: group.rows[i]),
            ],
          ],
        ),
      ),
    ],
  );
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});
  final _Row row;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push(row.route),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(row.icon, size: 22, color: _ink(context)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  row.subtitle,
                  style: TextStyle(fontSize: 12, color: _ink(context)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    ),
  );
}

/// Wide-viewport rendering of a [_Group]: a section label followed by a
/// balanced card grid, one card per [_Row], instead of a stacked row list.
class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.group, required this.columns});
  final _Group group;
  final int columns;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        group.title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          letterSpacing: .6,
          fontWeight: FontWeight.w500,
          color: _ink(context),
        ),
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 16.0;
          final cardWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final row in group.rows)
                SizedBox(width: cardWidth, child: _RowCard(row: row)),
            ],
          );
        },
      ),
    ],
  );
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.row});
  final _Row row;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${row.title}. ${row.subtitle}',
    child: Tooltip(
      message: row.subtitle,
      child: InkWell(
        onTap: () => context.push(row.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _ink(context)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: _ink(context)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(row.icon, size: 20),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              const Spacer(),
              Text(
                row.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                row.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: _ink(context)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

Color _ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;
