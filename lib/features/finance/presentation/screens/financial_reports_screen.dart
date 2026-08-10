import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  String _period = 'This term';

  Future<List<PaymentRecord>> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return [];
    final result = await di.sl<FinanceRepository>().getSchoolPayments(
      auth.user.schoolId,
    );
    final all = result.getOrElse(() => []);
    final now = DateTime.now();
    return all.where((payment) {
      if (_period == 'Today') {
        return payment.date.year == now.year &&
            payment.date.month == now.month &&
            payment.date.day == now.day;
      }
      if (_period == 'This month') {
        return payment.date.year == now.year && payment.date.month == now.month;
      }
      if (_period == 'This year') {
        return payment.date.year == now.year;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Financial reports')),
    body: FutureBuilder<List<PaymentRecord>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SchoolPulseLoader());
        }
        final payments = snapshot.data ?? [];
        final total = payments.fold<double>(
          0,
          (sum, payment) => sum + payment.amount,
        );
        final byMethod = <String, double>{};
        for (final payment in payments) {
          byMethod[payment.method] =
              (byMethod[payment.method] ?? 0) + payment.amount;
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _period,
              decoration: const InputDecoration(
                labelText: 'Reporting period',
                prefixIcon: Icon(Icons.date_range),
              ),
              items: ['Today', 'This month', 'This term', 'This year']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _period = value ?? _period),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collections',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.ugx(total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${payments.length} transactions'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Collections by payment method'),
            if (byMethod.isEmpty)
              const AppCard(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No collections in this period.')),
              )
            else
              ...byMethod.entries.map(
                (entry) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.key)),
                      Text(
                        CurrencyFormatter.ugx(entry.value),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Choose PDF, Excel, or CSV from the school export service when configured.',
                  ),
                ),
              ),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export report'),
            ),
          ],
        );
      },
    ),
  );
}
