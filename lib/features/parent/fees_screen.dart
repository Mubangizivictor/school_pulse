import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<FinanceBloc>().add(FetchFees(studentState.student.id));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Fees'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          if (state is SelectedStudentLoaded) {
            context.read<FinanceBloc>().add(FetchFees(state.student.id));
          }
        },
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Skeleton(height: 160),
                  const SizedBox(height: 24),
                  const Skeleton(height: 24, width: 150),
                  const SizedBox(height: 12),
                  ...List.generate(3, (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Skeleton(height: 70),
                  )),
                ],
              );
            } else if (state is FinanceError) {
              return Center(child: Text(state.message));
            } else if (state is FinanceLoaded) {
              final feeItems = state.fees;
              final totalBalance = feeItems
                  .where((item) => item.status != FeeStatus.paid)
                  .fold(0.0, (sum, item) => sum + item.amount);

              final hasOverdue = feeItems.any((item) => item.status == FeeStatus.overdue);

              return FadeTransition(
                opacity: _fadeAnimation,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    FadeInSlide(
                      duration: const Duration(milliseconds: 600),
                      child: AppCard(
                        onTap: () {},
                        child: Column(
                          children: [
                            Text('Current Balance', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            AnimatedNumberText(
                              value: totalBalance,
                              prefix: 'UGX ',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: hasOverdue ? semanticColors.error : semanticColors.warning,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: 'Pay Now',
                              onPressed: () => context.push('/parent/fees/pay'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FadeInSlide(
                      delay: const Duration(milliseconds: 200),
                      child: SectionHeader(
                        title: 'Fee Breakdown',
                        actionLabel: 'History',
                        onActionPressed: () => context.push('/parent/fees/history'),
                      ),
                    ),
                    ...feeItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 300 + (index * 100)),
                        child: _buildFeeItemRow(context, item, semanticColors),
                      );
                    }),
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

  Widget _buildFeeItemRow(BuildContext context, FeeItem item, SemanticColors colors) {
    Color statusColor;
    String statusLabel;

    switch (item.status) {
      case FeeStatus.paid:
        statusColor = colors.success;
        statusLabel = 'Paid';
        break;
      case FeeStatus.due:
        statusColor = colors.warning;
        statusLabel = 'Due';
        break;
      case FeeStatus.overdue:
        statusColor = colors.error;
        statusLabel = 'Overdue';
        break;
    }

    return AppCard(
      onTap: () {},
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Due: ${DateFormatter.format(item.dueDate)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyFormatter.format(item.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
        ],
      ),
    );
  }
}
