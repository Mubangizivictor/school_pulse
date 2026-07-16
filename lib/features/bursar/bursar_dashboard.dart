import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class BursarDashboardScreen extends StatelessWidget {
  const BursarDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bursar Portal'),
        actions: const [
          IconButton(icon: Icon(Icons.search), onPressed: null),
          NotificationBellButton(),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const [])),
        builder: (context, studentsSnapshot) {
          final studentsById = {for (final s in studentsSnapshot.data ?? const <Student>[]) s.id: s};
          return BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFinancialSummary(context, semanticColors, state),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Quick Actions'),
              QuickActionGrid(
                items: [
                  QuickActionItem(
                    label: 'Collect',
                    icon: Icons.add_card,
                    color: semanticColors.info,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Receipt',
                    icon: Icons.receipt_long,
                    color: semanticColors.success,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Debtors',
                    icon: Icons.person_off_outlined,
                    color: semanticColors.error,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Reports',
                    icon: Icons.assessment_outlined,
                    color: semanticColors.warning,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (state is FinanceLoading)
                const Skeleton(height: 80)
              else
                ProgressCard(
                  title: 'Fee Collection Target',
                  progress: 124.5 / 180,
                  subtitle: 'UGX 124.5M of 180M collected (69%)',
                  color: semanticColors.success,
                ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent Transactions', actionLabel: 'View All'),
              if (state is FinanceLoading)
                ...List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Skeleton(height: 60),
                ))
              else if (state is FinanceLoaded)
                ...state.paymentHistory.take(3).map((record) {
                  final studentName = studentsById[record.studentId]?.name ?? 'Unknown Student';
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: semanticColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_downward, color: semanticColors.success, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(record.method, style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.ugx(record.amount),
                          style: TextStyle(fontWeight: FontWeight.bold, color: semanticColors.success),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
            },
          );
        },
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, SemanticColors colors, FinanceState state) {
    if (state is FinanceLoading) {
      return const Skeleton(height: 180);
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Total Collections (This Term)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.ugx(124500000), // Mock total
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Target',
                  value: '180M',
                  color: colors.info,
                ),
              ),
              Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
              Expanded(
                child: _SummaryItem(
                  label: 'Outstanding',
                  value: '55.5M',
                  color: colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18),
        ),
      ],
    );
  }
}
