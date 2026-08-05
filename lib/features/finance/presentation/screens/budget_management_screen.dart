import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../../domain/entities/budget.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  String _selectedYear = '2024';
  String _selectedTerm = 'Term 1';

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadBudgets(
          schoolId: authState.user.schoolId,
          academicYear: _selectedYear,
          term: _selectedTerm,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBudgetForm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<FinanceBloc, FinanceState>(
              builder: (context, state) {
                if (state is FinanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BudgetsLoaded) {
                  if (state.budgets.isEmpty) {
                    return const EmptyState(
                      icon: Icons.pie_chart_outline,
                      title: 'No budgets defined',
                      message: 'Set up budgets for this term to track spending',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = state.budgets[index];
                      return _buildBudgetItem(context, budget);
                    },
                  );
                }

                if (state is FinanceError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              items: [
                '2023',
                '2024',
                '2025',
              ].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedYear = val);
                  _loadBudgets();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTerm,
              decoration: const InputDecoration(
                labelText: 'Term',
                border: OutlineInputBorder(),
              ),
              items: [
                'Term 1',
                'Term 2',
                'Term 3',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedTerm = val);
                  _loadBudgets();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BuildContext context, Budget budget) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final utilization = budget.utilizationPercentage;
    final color = utilization > 90
        ? semanticColors.error
        : utilization > 70
        ? Colors.orange
        : semanticColors.success;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              StatusBadge(
                label: '${utilization.toStringAsFixed(1)}%',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: utilization / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Allocated',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    CurrencyFormatter.ugx(budget.allocatedAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    CurrencyFormatter.ugx(budget.remainingAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: budget.remainingAmount < 0
                          ? semanticColors.error
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBudgetForm(BuildContext context) {
    // Show form to add/edit budget
  }
}
