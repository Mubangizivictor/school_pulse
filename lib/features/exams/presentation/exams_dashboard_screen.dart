import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'package:school_pulse/features/qr_scanner/domain/entities/scanner_mode.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
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

  void _scanForExam(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(
          mode: ScannerMode.verification,
          onScan: (studentId) => _verifyExamEligibility(context, studentId),
        ),
      ),
    );
  }

  void _verifyExamEligibility(BuildContext context, String studentId) {
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;
    context.read<FinanceBloc>().add(
      CheckStudentEligibility(
        studentId: studentId,
        schoolId: authState.user.schoolId,
        serviceType: 'EXAM',
      ),
    );
  }

  void _showEligibilityResult(
    BuildContext context,
    bool isEligible,
    String? reason,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          isEligible ? Icons.check_circle : Icons.cancel,
          color: isEligible ? Colors.green : Colors.red,
          size: 64,
        ),
        title: Text(isEligible ? 'Clear for Exam' : 'Financial Hold'),
        content: Text(
          isEligible
              ? 'Student is cleared to sit for exams.'
              : reason ??
                    'Please refer student to the bursar\'s office for financial clearance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return MultiBlocListener(
      listeners: [
        BlocListener<FinanceBloc, FinanceState>(
          listener: (context, state) {
            if (state is EligibilityChecked && state.serviceType == 'EXAM') {
              _showEligibilityResult(context, state.isEligible, state.reason);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exams Portal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _scanForExam(context),
              tooltip: 'Verify Exam Eligibility',
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                  children: [
                    FadeInSlide(
                      child: Text(
                        "Examination Management",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 100),
                            child: DashboardStatCard(
                              title: 'Pending Results',
                              value: state.pendingResults.toDouble(),
                              icon: Icons.pending_actions,
                              color: semanticColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 200),
                            child: DashboardStatCard(
                              title: 'Completion',
                              value: (state.completionRate * 100),
                              suffix: '%',
                              icon: Icons.fact_check_outlined,
                              color: semanticColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const FadeInSlide(
                      delay: Duration(milliseconds: 300),
                      child: SectionHeader(title: 'Upcoming Sessions'),
                    ),
                    const SizedBox(height: 12),
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
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.quiz_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                exam.subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${exam.className} • ${exam.session}',
                              ),
                              trailing: Text(
                                exam.date,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
      ),
    );
  }
}

class _ExamsSkeleton extends StatelessWidget {
  const _ExamsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: const Skeleton(height: 48, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: const Skeleton(height: 48, borderRadius: 12)),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 72, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}
