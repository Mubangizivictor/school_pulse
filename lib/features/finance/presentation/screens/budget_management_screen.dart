import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
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
  String _selectedYear = '';
  String _selectedTerm = 'Term 1';

  @override
  void initState() {
    super.initState();
    _initPeriodAndLoad();
  }

  Future<void> _initPeriodAndLoad() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final period = await sl<AcademicCalendarService>().getCurrentPeriod(
          authState.user.schoolId,
        );
        if (!mounted) return;
        setState(() {
          _selectedYear = period.academicYearName.isNotEmpty
              ? period.academicYearName
              : DateTime.now().year.toString();
          if (period.termName.isNotEmpty) {
            _selectedTerm = period.termName;
          }
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _selectedYear = DateTime.now().year.toString());
      }
    }
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
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is FinanceActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _loadBudgets();
        }
      },
      child: Scaffold(
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
                    return const Center(child: SchoolPulseLoader());
                  }

                  if (state is BudgetsLoaded) {
                    if (state.budgets.isEmpty) {
                      return const EmptyState(
                        icon: Icons.pie_chart_outline,
                        title: 'No budgets defined',
                        message:
                            'Set up budgets for this term to track spending',
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
        ? Colors.black
        : semanticColors.success;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _showBudgetForm(context, existing: budget),
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
            backgroundColor: color,
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

  void _showBudgetForm(BuildContext context, {Budget? existing}) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController(
      text: existing != null
          ? existing.allocatedAmount.toStringAsFixed(0)
          : '',
    );
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    String year = existing?.academicYear ?? _selectedYear;
    String term = existing?.term ?? _selectedTerm;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Budget' : 'Edit Budget'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Budget Name / Category',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Allocated Amount (UGX)',
                    ),
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: [
                            '2023',
                            '2024',
                            '2025',
                          ].contains(year)
                              ? year
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                          ),
                          items: {
                            year,
                            '2023',
                            '2024',
                            '2025',
                          }.map(
                            (y) =>
                                DropdownMenuItem(value: y, child: Text(y)),
                          ).toList(),
                          onChanged: (v) => setState(() => year = v ?? year),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: term,
                          decoration: const InputDecoration(
                            labelText: 'Term',
                          ),
                          items: ['Term 1', 'Term 2', 'Term 3']
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => term = v ?? term),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final amount = double.tryParse(amountController.text) ?? 0;
                context.read<FinanceBloc>().add(
                  SaveSchoolBudget(
                    Budget(
                      id: existing?.id ?? '',
                      schoolId: authState.user.schoolId,
                      name: nameController.text.trim(),
                      academicYear: year,
                      term: term,
                      allocatedAmount: amount,
                      spentAmount: existing?.spentAmount ?? 0,
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
