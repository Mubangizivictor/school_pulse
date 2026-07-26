import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'bloc/exams_bloc.dart';
import 'bloc/exams_event.dart';
import 'bloc/exams_state.dart';

class ExamsDashboardScreen extends StatelessWidget {
  const ExamsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ExamsBloc>()..add(ExamsDashboardRequested()),
      child: const _ExamsDashboardView(),
    );
  }
}

class _ExamsDashboardView extends StatelessWidget {
  const _ExamsDashboardView();

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams Portal'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<ExamsBloc, ExamsState>(
        builder: (context, state) {
          if (state is ExamsLoading) {
            return const _ExamsSkeleton();
          }

          if (state is ExamsError) {
            return Center(child: Text(state.message));
          }

          if (state is ExamsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ExamsBloc>().add(ExamsDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      "Examination Management",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      FadeInSlide(
                        delay: const Duration(milliseconds: 100),
                        child: DashboardStatCard(
                          title: 'Pending Results',
                          value: state.pendingResults.toDouble(),
                          icon: Icons.pending_actions,
                          color: semanticColors.warning,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Completion',
                          value: (state.completionRate * 100),
                          suffix: '%',
                          icon: Icons.fact_check_outlined,
                          color: semanticColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Upcoming Sessions'),
                  ),
                  ...state.upcomingExams.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exam = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInSlide(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: AppCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(Icons.quiz_outlined, color: Theme.of(context).colorScheme.primary),
                            ),
                            title: Text(exam.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${exam.className} • ${exam.session}'),
                            trailing: Text(exam.date, style: Theme.of(context).textTheme.bodySmall),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 700),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/staff/marks'),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Marks'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ExamsSkeleton extends StatelessWidget {
  const _ExamsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: List.generate(2, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Skeleton(height: 72, borderRadius: 12),
        )),
      ],
    );
  }
}
