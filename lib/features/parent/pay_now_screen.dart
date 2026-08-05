import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

/// Mobile-money payment integration is not live yet, so this screen shows the
/// outstanding balance and how to pay through the channels that exist today
/// instead of simulating a payment that never happens.
class PayNowScreen extends StatefulWidget {
  const PayNowScreen({super.key});

  @override
  State<PayNowScreen> createState() => _PayNowScreenState();
}

class _PayNowScreenState extends State<PayNowScreen> {
  @override
  void initState() {
    super.initState();
    final financeState = context.read<FinanceBloc>().state;
    if (financeState is! FinanceLoaded) {
      final studentState = context.read<SelectedStudentBloc>().state;
      if (studentState is SelectedStudentLoaded) {
        context.read<FinanceBloc>().add(FetchFees(studentState.student.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Make Payment'),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          double? balance;
          if (state is FinanceLoaded) {
            balance = state.fees
                .where((item) => item.status != FeeStatus.paid)
                .fold(0.0, (sum, item) => sum! + item.amount);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (balance != null)
                FadeInSlide(
                  child: AppCard(
                    child: Column(
                      children: [
                        Text(
                          'Outstanding Balance',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(balance),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: balance > 0
                                    ? semanticColors.warning
                                    : semanticColors.success,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: AlertBanner(
                  title: 'In-App Payments Coming Soon',
                  message:
                      'Paying school fees directly from this app (MTN MoMo and '
                      'Airtel Money) is under development. Until then, please '
                      'use one of the options below.',
                  color: semanticColors.info,
                  icon: Icons.info_outline,
                ),
              ),
              const FadeInSlide(
                delay: Duration(milliseconds: 200),
                child: SectionHeader(title: 'How to Pay Today'),
              ),
              FadeInSlide(
                delay: const Duration(milliseconds: 300),
                child: _buildOption(
                  context,
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Deposit',
                  message:
                      'Deposit to the school\'s bank account and keep your '
                      'deposit slip. The bursar will record it against your '
                      'child\'s account.',
                ),
              ),
              FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: _buildOption(
                  context,
                  icon: Icons.storefront_outlined,
                  title: 'School Bursar\'s Office',
                  message:
                      'Pay in person at the bursar\'s office and collect an '
                      'official receipt.',
                ),
              ),
              const SizedBox(height: 16),
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: SecondaryButton(
                  label: 'View Payment History',
                  icon: Icons.history,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
