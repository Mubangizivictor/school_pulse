import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: [
          _Header(user: user),
          const SizedBox(height: 18),
          const _SetupCard(),
          const SizedBox(height: 22),
          _Group(
            title: 'Manage school',
            rows: [
              _Row(
                icon: Icons.people_outline,
                title: 'Learners & admissions',
                subtitle: 'Enrolment, admissions and student records',
                onTap: () => context.push('/staff/admin/students'),
              ),
              _Row(
                icon: Icons.badge_outlined,
                title: 'People',
                subtitle: 'Staff, roles and assignments',
                onTap: () => context.push('/staff/admin/users'),
              ),
              _Row(
                icon: Icons.menu_book_outlined,
                title: 'Academic programme',
                subtitle: 'Structure & calendar, subjects and curriculum',
                onTap: () => context.push('/staff/admin/structure'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Group(
            title: 'Operations',
            rows: [
              _Row(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Fees & finance',
                subtitle: 'Collections, invoices and reports',
                onTap: () => context.push('/staff/bursar'),
              ),
              _Row(
                icon: Icons.schedule_outlined,
                title: 'School day & timetables',
                subtitle: 'Periods, sessions and class timetables',
                onTap: () => context.push('/staff/admin/structure/operations'),
              ),
              _Row(
                icon: Icons.holiday_village_outlined,
                title: 'Facilities',
                subtitle: 'Campuses, rooms and physical spaces',
                onTap: () => context.push('/staff/admin/structure/campus'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Group(
            title: 'Administration',
            rows: [
              _Row(
                icon: Icons.apartment_outlined,
                title: 'Institution profile',
                subtitle: 'Identity, branding and registration',
                onTap: () => context.push('/staff/admin/structure/institution'),
              ),
              _Row(
                icon: Icons.tune_outlined,
                title: 'Modules & access',
                subtitle: 'Feature toggles and role permissions',
                onTap: () =>
                    context.push('/staff/admin/structure/feature-toggles'),
              ),
              _Row(
                icon: Icons.storage_outlined,
                title: 'Data management',
                subtitle: 'Import, export and records maintenance',
                onTap: () => context.push('/staff/admin/data-management'),
              ),
            ],
          ),
        ],
      ),
    ),
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
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: _ink(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'School setup',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${progress.percentage}% complete · ${progress.pendingCount} step${progress.pendingCount == 1 ? '' : 's'} remaining',
                    style: TextStyle(fontSize: 12, color: _ink(context)),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.push('/staff/admin/structure'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink(context),
                side: BorderSide(color: _ink(context)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('View setup'),
            ),
          ],
        ),
      );
    },
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title.toUpperCase(),
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
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: _ink(context)),
              rows[i],
            ],
          ],
        ),
      ),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _ink(context)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

Color _ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;
