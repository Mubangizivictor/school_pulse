import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/payroll_calculator.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/hr/domain/entities/payroll_record.dart';
import 'package:school_pulse/features/hr/presentation/bloc/hr_bloc.dart';
import 'package:school_pulse/features/hr/presentation/bloc/hr_event.dart';
import 'package:school_pulse/features/hr/presentation/bloc/hr_state.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class PayrollManagementScreen extends StatefulWidget {
  const PayrollManagementScreen({super.key});

  @override
  State<PayrollManagementScreen> createState() =>
      _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends State<PayrollManagementScreen> {
  final _currencyFormat = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final _staffAssignmentRepository = di.sl<StaffAssignmentRepository>();

  String get _schoolId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<HrBloc>().add(LoadPayrollRecords(_schoolId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showGeneratePayrollDialog,
          ),
        ],
      ),
      body: BlocBuilder<HrBloc, HrState>(
        builder: (context, state) {
          if (state is HrLoading) {
            return const Center(child: SchoolPulseLoader());
          } else if (state is PayrollRecordsLoaded) {
            if (state.records.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                return _PayrollRecordTile(
                  record: record,
                  currencyFormat: _currencyFormat,
                );
              },
            );
          } else if (state is HrError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          const Text('No payroll records generated yet.'),
        ],
      ),
    );
  }

  void _showGeneratePayrollDialog() {
    final staffNameController = TextEditingController();
    final baseSalaryController = TextEditingController();
    final allowancesController = TextEditingController();
    final deductionsController = TextEditingController();
    PayrollFundingSource fundingSource = PayrollFundingSource.government;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate Payroll'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: staffNameController,
                  decoration: const InputDecoration(labelText: 'Staff Name'),
                ),
                TextField(
                  controller: baseSalaryController,
                  decoration: const InputDecoration(labelText: 'Base Salary'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: allowancesController,
                  decoration: const InputDecoration(labelText: 'Allowances'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: deductionsController,
                  decoration: const InputDecoration(
                    labelText: 'Other Deductions',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PayrollFundingSource>(
                  initialValue: fundingSource,
                  decoration: const InputDecoration(
                    labelText: 'Funding Source',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PayrollFundingSource.government,
                      child: Text('Government Sponsored'),
                    ),
                    DropdownMenuItem(
                      value: PayrollFundingSource.pta,
                      child: Text('PTA Sponsored'),
                    ),
                    DropdownMenuItem(
                      value: PayrollFundingSource.other,
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => fundingSource = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final base = double.tryParse(baseSalaryController.text) ?? 0;
                final allowances =
                    double.tryParse(allowancesController.text) ?? 0;
                final otherDeductions =
                    double.tryParse(deductionsController.text) ?? 0;
                final staffId =
                    'STF-${DateTime.now().millisecondsSinceEpoch}';

                final bonuses = await _roleAssignmentBonuses(staffId);

                final grossTaxable = base + allowances;
                final paye = PayrollCalculator.calculatePAYE(grossTaxable);
                final nssfEmployee = PayrollCalculator.calculateNSSFEmployee(
                  base,
                );
                final nssfEmployer = PayrollCalculator.calculateNSSFEmployer(
                  base,
                );
                final netPay =
                    grossTaxable +
                    bonuses -
                    paye -
                    nssfEmployee -
                    otherDeductions;

                final record = PayrollRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  schoolId: _schoolId,
                  staffId: staffId,
                  staffName: staffNameController.text,
                  month: DateFormat('MMMM yyyy').format(DateTime.now()),
                  baseSalary: base,
                  allowances: allowances,
                  bonuses: bonuses,
                  deductions: otherDeductions,
                  nssfEmployee: nssfEmployee,
                  nssfEmployer: nssfEmployer,
                  paye: paye,
                  netPay: netPay,
                  createdAt: DateTime.now(),
                  fundingSource: fundingSource,
                );

                if (!context.mounted) return;
                context.read<HrBloc>().add(GeneratePayroll(record));
                Navigator.pop(context);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  /// Sums [StaffRoleAssignment.monthlyBonusAmount] across every currently
  /// active assignment held by this staff member, so patron/house/department
  /// extra pay is auto-included instead of retyped each payroll run.
  Future<double> _roleAssignmentBonuses(String staffId) async {
    final result = await _staffAssignmentRepository.getValidAssignments(
      schoolId: _schoolId,
      userId: staffId,
    );
    return result.fold((_) => 0, (assignments) {
      var total = 0.0;
      for (final assignment in assignments) {
        total += assignment.monthlyBonusAmount ?? 0;
      }
      return total;
    });
  }
}

class _PayrollRecordTile extends StatelessWidget {
  final PayrollRecord record;
  final NumberFormat currencyFormat;

  const _PayrollRecordTile({
    required this.record,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          record.staffName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${record.month} • ${_fundingSourceLabel(record.fundingSource)} '
          '• Net: ${currencyFormat.format(record.netPay)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow('Base Salary', record.baseSalary),
                _buildDetailRow('Allowances', record.allowances),
                _buildDetailRow('Bonuses', record.bonuses),
                _buildDetailRow(
                  'Deductions',
                  -record.deductions,
                  isNegative: true,
                ),
                const Divider(),
                _buildDetailRow(
                  'NSSF (5%)',
                  -record.nssfEmployee,
                  isNegative: true,
                ),
                _buildDetailRow('PAYE', -record.paye, isNegative: true),
                const Divider(),
                _buildDetailRow('Net Pay', record.netPay, isBold: true),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'NSSF Employer (10%)',
                  record.nssfEmployer,
                  isInfo: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fundingSourceLabel(PayrollFundingSource source) {
    switch (source) {
      case PayrollFundingSource.government:
        return 'Government';
      case PayrollFundingSource.pta:
        return 'PTA';
      case PayrollFundingSource.other:
        return 'Other';
    }
  }

  Widget _buildDetailRow(
    String label,
    double value, {
    bool isBold = false,
    bool isNegative = false,
    bool isInfo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isInfo ? Colors.grey : null,
            ),
          ),
          Text(
            currencyFormat.format(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative ? Colors.red : (isInfo ? Colors.grey : null),
            ),
          ),
        ],
      ),
    );
  }
}
