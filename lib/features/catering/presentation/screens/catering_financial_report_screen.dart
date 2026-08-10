import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/catering_bloc.dart';
import '../bloc/catering_event.dart';
import '../bloc/catering_state.dart';

class CateringFinancialReportScreen extends StatefulWidget {
  const CateringFinancialReportScreen({super.key});

  @override
  State<CateringFinancialReportScreen> createState() =>
      _CateringFinancialReportScreenState();
}

class _CateringFinancialReportScreenState
    extends State<CateringFinancialReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<CateringBloc>().add(LoadFinancialReport(_startDate, _endDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Financial Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: _startDate,
                  end: _endDate,
                ),
              );
              if (range != null) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                });
                _loadReport();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CateringBloc, CateringState>(
        builder: (context, state) {
          if (state is CateringLoading) {
            return const Center(child: SchoolPulseLoader());
          } else if (state is FinancialReportLoaded) {
            final data = state.report;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(data),
                  const SizedBox(height: 24),
                  const Text(
                    'Cost Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    'Total Revenue (Meal Fees)',
                    data['totalRevenue'],
                    Colors.green,
                  ),
                  _buildDetailItem(
                    'Direct Food Costs',
                    data['foodCost'],
                    Colors.orange,
                  ),
                  _buildDetailItem(
                    'Wastage Impact',
                    data['wastageCost'],
                    Colors.red,
                  ),
                  _buildDetailItem(
                    'Labor & Overheads',
                    data['laborCost'],
                    Colors.blueGrey,
                  ),
                  const Divider(height: 32),
                  _buildDetailItem(
                    'Net Operating Profit',
                    data['netProfit'],
                    Colors.blue,
                    isBold: true,
                  ),
                  const SizedBox(height: 32),
                  _buildEfficiencyMetrics(data),
                ],
              ),
            );
          } else if (state is CateringError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Failed to load report.'));
        },
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> data) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade800,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Gross Profit Margin',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${((data['grossProfit'] / data['totalRevenue']) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Total Rev',
                  currencyFormat.format(data['totalRevenue']),
                ),
                _buildSummaryItem(
                  'Total Cost',
                  currencyFormat.format(
                    data['foodCost'] + data['wastageCost'] + data['laborCost'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    dynamic value,
    Color color, {
    bool isBold = false,
  }) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            currencyFormat.format(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyMetrics(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Indicators',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Food Cost %',
            '${((data['foodCost'] / data['totalRevenue']) * 100).toStringAsFixed(1)}%',
          ),
          _buildMetricRow(
            'Wastage %',
            '${((data['wastageCost'] / data['foodCost']) * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
