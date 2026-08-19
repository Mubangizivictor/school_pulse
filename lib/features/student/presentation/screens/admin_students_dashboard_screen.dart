import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/responsive/responsive_builder.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_radius.dart';
import '../../../../design_system/theme/app_spacing.dart';
import '../../../../design_system/theme/app_typography.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../structure/presentation/bloc/structure_bloc.dart';
import '../../../structure/presentation/bloc/structure_state.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/student_enums.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';

/// Admin Students Dashboard.
///
/// School-scoped data sourcing: `getAllStudents(schoolId: ...)` already
/// supports school scoping end-to-end (repository -> remote data source
/// applies a Firestore `where('schoolId', ...)` filter), so this screen adds
/// a minimal `LoadSchoolStudents(schoolId)` bloc event (see students_event/
/// students_bloc.dart) rather than reusing the query-filtering
/// `SearchStudents` event, which never threaded a schoolId through at all.
///
/// "Recent Admissions" uses real `AdmissionApplication.appliedAt` timestamps
/// via the existing `AdmissionBloc` (same pattern as AdmissionsListScreen) -
/// wiring it in was trivial, so no proxy data was needed for that card.
class AdminStudentsDashboardScreen extends StatelessWidget {
  const AdminStudentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated ? authState.user.schoolId : '';

    // StructureBloc is already provided app-wide (see main.dart) and loaded
    // at sign-in - creating a second instance here would duplicate its
    // listeners and re-fetch data that's already loading/loaded.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<StudentsBloc>()..add(LoadSchoolStudents(schoolId)),
        ),
        BlocProvider(
          create: (_) => di.sl<AdmissionBloc>()..add(LoadApplicationsRequested(schoolId)),
        ),
      ],
      child: const _AdminStudentsDashboardView(),
    );
  }
}

class _AdminStudentsDashboardView extends StatelessWidget {
  const _AdminStudentsDashboardView();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.name : '';
    final schoolName = authState is AuthAuthenticated ? (authState.user.schoolName ?? '') : '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          onPressed: () {},
        ),
        title: Text(
          'Students',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, studentsState) {
            final students = studentsState is StudentsLoaded ? studentsState.students : <Student>[];
            final isLoading = studentsState is StudentsLoading || studentsState is StudentsInitial;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingHeader(greeting: _greeting(), userName: userName, schoolName: schoolName),
                  const SizedBox(height: AppSpacing.x3l),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.x6l),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _StatTilesSection(students: students),
                    const SizedBox(height: AppSpacing.x3l),
                    ResponsiveBuilder(
                      builder: (context, layout) {
                        final classCard = _StudentsByClassCard(students: students);
                        final admissionsCard = const _RecentAdmissionsCard();
                        if (layout == ResponsiveLayout.desktop) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: classCard),
                                const SizedBox(width: AppSpacing.xl),
                                Expanded(child: admissionsCard),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            classCard,
                            const SizedBox(height: AppSpacing.xl),
                            admissionsCard,
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String schoolName;

  const _GreetingHeader({required this.greeting, required this.userName, required this.schoolName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySoft(context),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.school_rounded, color: AppColors.primary(context)),
        ),
        const SizedBox(width: AppSpacing.l),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              if (schoolName.isNotEmpty)
                Text(
                  schoolName,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTilesSection extends StatelessWidget {
  final List<Student> students;
  const _StatTilesSection({required this.students});

  @override
  Widget build(BuildContext context) {
    final total = students.length;
    final male = students.where((s) => s.gender == Gender.male).length;
    final female = students.where((s) => s.gender == Gender.female).length;
    // Fourth tile: "New this term" was ruled out (Student has no createdAt/
    // admittedAt field), so this uses the real StudentStatus.active count as
    // a defensible, honestly-labelled metric instead of a fabricated proxy.
    final active = students.where((s) => s.status == StudentStatus.active).length;

    final tiles = [
      _StatTile(label: 'Total Students', value: total, icon: Icons.groups_rounded, color: AppColors.primary(context)),
      _StatTile(label: 'Male Students', value: male, icon: Icons.male_rounded, color: AppColors.information(context)),
      _StatTile(label: 'Female Students', value: female, icon: Icons.female_rounded, color: AppColors.secondary(context)),
      _StatTile(label: 'Active Students', value: active, icon: Icons.verified_rounded, color: AppColors.success(context)),
    ];

    return ResponsiveBuilder(
      builder: (context, layout) {
        final crossAxisCount = layout == ResponsiveLayout.desktop ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.l,
          mainAxisSpacing: AppSpacing.l,
          childAspectRatio: layout == ResponsiveLayout.desktop ? 1.5 : 1.3,
          children: tiles,
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.medium,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            '$value',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentsByClassCard extends StatelessWidget {
  final List<Student> students;
  const _StudentsByClassCard({required this.students});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, structureState) {
        final classes = structureState.classes;
        final Map<String, int> counts = {};
        for (final s in students) {
          counts[s.classId] = (counts[s.classId] ?? 0) + 1;
        }
        final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        String classLabel(String classId) {
          final match = classes.where((c) => c.id == classId);
          if (match.isEmpty) return classId.isEmpty ? 'Unassigned' : classId;
          return match.first.name;
        }

        final palette = [
          AppColors.primary(context),
          AppColors.secondary(context),
          AppColors.success(context),
          AppColors.information(context),
          AppColors.warning(context),
          AppColors.danger(context),
        ];

        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.medium,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students by Class',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (entries.isEmpty)
                Text(
                  'No students yet',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                )
              else ...[
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              for (var i = 0; i < entries.length; i++)
                                PieChartSectionData(
                                  value: entries[i].value.toDouble(),
                                  color: palette[i % palette.length],
                                  title: '',
                                  radius: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Wrap(
                  spacing: AppSpacing.l,
                  runSpacing: AppSpacing.m,
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      _LegendRow(
                        color: palette[i % palette.length],
                        label: classLabel(entries[i].key),
                        count: entries[i].value,
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendRow({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.s),
        Text(
          '$label ($count)',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _RecentAdmissionsCard extends StatelessWidget {
  const _RecentAdmissionsCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, structureState) {
        final classes = structureState.classes;
        String classLabel(String classId) {
          final match = classes.where((c) => c.id == classId);
          if (match.isEmpty) return classId.isEmpty ? 'Unassigned' : classId;
          return match.first.name;
        }

        return BlocBuilder<AdmissionBloc, AdmissionState>(
          builder: (context, admissionState) {
            List<AdmissionApplication> applications = [];
            if (admissionState is AdmissionApplicationsLoaded) {
              applications = List.of(admissionState.applications)
                ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
            }
            final recent = applications.take(4).toList();

            return Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppRadius.medium,
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Admissions',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/staff/admin/students/list'),
                        child: Text(
                          'View All',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  if (recent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Text(
                        'No recent admissions',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    )
                  else
                    ...recent.map(
                      (app) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primarySoft(context),
                              child: Text(
                                _initials(app.studentName),
                                style: AppTypography.labelSmall.copyWith(color: AppColors.primary(context)),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.l),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.studentName,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    classLabel(app.targetClassId),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatDate(app.appliedAt),
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
