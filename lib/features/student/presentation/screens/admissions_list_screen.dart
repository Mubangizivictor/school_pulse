import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';

String admissionStatusLabel(AdmissionStatus status) {
  switch (status) {
    case AdmissionStatus.application:
      return 'Submitted';
    case AdmissionStatus.review:
      return 'Under Review';
    case AdmissionStatus.approved:
      return 'Approved';
    case AdmissionStatus.admitted:
      return 'Enrolled';
    case AdmissionStatus.rejected:
      return 'Rejected';
  }
}

class AdmissionsListScreen extends StatelessWidget {
  const AdmissionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    return BlocProvider(
      create: (_) =>
          sl<AdmissionBloc>()..add(LoadApplicationsRequested(schoolId)),
      child: _AdmissionsListView(schoolId: schoolId),
    );
  }
}

class _AdmissionsListView extends StatefulWidget {
  final String schoolId;
  const _AdmissionsListView({required this.schoolId});

  @override
  State<_AdmissionsListView> createState() => _AdmissionsListViewState();
}

class _AdmissionsListViewState extends State<_AdmissionsListView> {
  AdmissionStatus? _filter;

  void _reload() {
    context.read<AdmissionBloc>().add(
      LoadApplicationsRequested(widget.schoolId),
    );
  }

  Future<void> _openReview(AdmissionApplication application) async {
    final changed = await context.push<bool>(
      '/staff/admin/admissions/review',
      extra: application,
    );
    if (changed == true && mounted) _reload();
  }

  Future<void> _openNewApplication() async {
    final created = await context.push<bool>(
      '/staff/admin/admissions/new',
      extra: widget.schoolId,
    );
    if (created == true && mounted) _reload();
  }

  Color _statusColor(BuildContext context, AdmissionStatus status) {
    switch (status) {
      case AdmissionStatus.application:
        return AppColors.information(context);
      case AdmissionStatus.review:
        return AppColors.warning(context);
      case AdmissionStatus.approved:
      case AdmissionStatus.admitted:
        return AppColors.success(context);
      case AdmissionStatus.rejected:
        return AppColors.danger(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admissions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewApplication,
        icon: const Icon(Icons.add),
        label: const Text('New Application'),
      ),
      body: BlocConsumer<AdmissionBloc, AdmissionState>(
        listenWhen: (previous, current) =>
            current is AdmissionError || current is AdmissionActionDenied,
        listener: (context, state) {
          final message = state is AdmissionError
              ? state.message
              : state is AdmissionActionDenied
              ? state.message
              : null;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.black),
            );
          }
        },
        builder: (context, state) {
          if (state is AdmissionLoading || state is AdmissionInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          final applications = state is AdmissionApplicationsLoaded
              ? state.applications
              : const <AdmissionApplication>[];
          final visible = _filter == null
              ? applications
              : applications.where((a) => a.status == _filter).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    for (final status in AdmissionStatus.values)
                      ChoiceChip(
                        label: Text(admissionStatusLabel(status)),
                        selected: _filter == status,
                        onSelected: (_) => setState(() => _filter = status),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No applications',
                        message: _filter == null
                            ? 'New admission applications will appear here.'
                            : 'No applications match "${admissionStatusLabel(_filter!)}".',
                        ctaLabel: 'New Application',
                        onCtaPressed: _openNewApplication,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final application = visible[index];
                          return AppCard(
                            onTap: () => _openReview(application),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        application.studentName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary(context),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      StreamBuilder<List<SchoolClass>>(
                                        stream: sl<StructureRepository>()
                                            .watchClasses(widget.schoolId),
                                        builder: (context, snap) {
                                          final classes =
                                              snap.data ??
                                              const <SchoolClass>[];
                                          final match = classes
                                              .where(
                                                (c) =>
                                                    c.id ==
                                                    application.targetClassId,
                                              )
                                              .toList();
                                          final className = match.isNotEmpty
                                              ? match.first.name
                                              : (classes.isEmpty
                                                    ? 'Loading…'
                                                    : 'Unknown class');
                                          return Text(
                                            'Class $className · Applied '
                                            '${application.appliedAt.toLocal().toString().split(' ').first}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary(
                                                context,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: admissionStatusLabel(
                                    application.status,
                                  ),
                                  color: _statusColor(
                                    context,
                                    application.status,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
