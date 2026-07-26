import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/finance/domain/entities/payroll_record.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final List<PayrollRecord> _records = [
    PayrollRecord.calculate(
      id: '1',
      staffId: 'ST001',
      staffName: 'John Doe',
      basicSalary: 2500000,
      allowances: 300000,
      otherDeductions: 50000,
      date: DateTime.now(),
    ),
    PayrollRecord.calculate(
      id: '2',
      staffId: 'ST002',
      staffName: 'Jane Smith',
      basicSalary: 1800000,
      allowances: 200000,
      otherDeductions: 0,
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Management'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Generate Payroll'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 24),
            const Text(
              'Staff Payroll - March 2024',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPayrollTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    double totalNet = _records.fold(0, (sum, item) => sum + item.netSalary);
    double totalPAYE = _records.fold(0, (sum, item) => sum + item.paye);
    double totalNSSF = _records.fold(0, (sum, item) => sum + item.nssf);

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _SummaryCard(
            title: 'Total Net Pay',
            value: CurrencyFormatter.ugx(totalNet),
            icon: Icons.payments,
            color: Colors.blue,
            width: isWide ? 250 : constraints.maxWidth,
          ),
          _SummaryCard(
            title: 'Total PAYE',
            value: CurrencyFormatter.ugx(totalPAYE),
            icon: Icons.account_balance,
            color: Colors.orange,
            width: isWide ? 250 : constraints.maxWidth,
          ),
          _SummaryCard(
            title: 'Total NSSF (5%)',
            value: CurrencyFormatter.ugx(totalNSSF),
            icon: Icons.savings,
            color: Colors.green,
            width: isWide ? 250 : constraints.maxWidth,
          ),
        ],
      );
    });
  }

  Widget _buildPayrollTable() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Staff Name')),
            DataColumn(label: Text('Basic Salary')),
            DataColumn(label: Text('Allowances')),
            DataColumn(label: Text('PAYE')),
            DataColumn(label: Text('NSSF')),
            DataColumn(label: Text('Deductions')),
            DataColumn(label: Text('Net Salary')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _records.map((record) {
            return DataRow(cells: [
              DataCell(Text(record.staffName)),
              DataCell(Text(CurrencyFormatter.ugx(record.basicSalary))),
              DataCell(Text(CurrencyFormatter.ugx(record.allowances))),
              DataCell(Text(CurrencyFormatter.ugx(record.paye))),
              DataCell(Text(CurrencyFormatter.ugx(record.nssf))),
              DataCell(Text(CurrencyFormatter.ugx(record.otherDeductions))),
              DataCell(Text(
                CurrencyFormatter.ugx(record.netSalary),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(IconButton(
                icon: const Icon(Icons.receipt_long),
                onPressed: () {},
                tooltip: 'Payslip',
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
