import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/budget.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/presentation/screens/expenditure_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Budget Details — matches the reference "Budget Progress" screenshot:
/// a period + budget-type header, per-category progress bars with a percent
/// and allocated amount (red when over 100%), and a "Create requisition"
/// action linking to the expenditure flow. Reads the existing
/// `schools/{id}/budgets` collection via [FinanceBloc].
class BudgetDetailsScreen extends StatefulWidget {
  const BudgetDetailsScreen({super.key});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  final String _year = DateTime.now().year.toString();
  final String _term =
      'Term ${DateTime.now().month <= 4
          ? 1
          : DateTime.now().month <= 8
          ? 2
          : 3}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadBudgets(
          schoolId: auth.user.schoolId,
          academicYear: _year,
          term: _term,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceScaffold(
      title: 'Budget Details',
      constrainWidth: true,
      bottomBar: PrimaryActionBar(
        label: 'Create requisition',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ExpenditureScreen())),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is FinanceLoading || state is FinanceInitial) {
            return FinanceStates.loading();
          }
          final budgets = state is BudgetsLoaded
              ? state.budgets
              : const <Budget>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Pill(label: '$_term, $_year', onTap: () {}),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Pill(label: 'School Budget', onTap: () {}),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Budget Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              if (budgets.isEmpty)
                FinanceCard(
                  child: Text(
                    'No budget lines for $_term, $_year.',
                    style: TextStyle(color: AppColors.textMuted(context)),
                  ),
                )
              else
                for (final b in budgets) _BudgetRow(budget: b),
            ],
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final Budget budget;
  const _BudgetRow({required this.budget});

  @override
  Widget build(BuildContext context) {
    final pct = budget.utilizationPercentage.round();
    final over = pct > 100;
    final barValue = (budget.utilizationPercentage / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: over
                      ? AppColors.danger(context)
                      : AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Text(
                CurrencyFormatter.ugx(budget.spentAmount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: over
                      ? AppColors.danger(context)
                      : AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: barValue,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainer(context),
              valueColor: AlwaysStoppedAnimation(
                over ? AppColors.danger(context) : AppColors.primary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
