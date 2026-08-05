import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_state.dart';
import '../bloc/super_admin_event.dart';
import '../../domain/entities/payment.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/app_components.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard()),
          ),
          if (!isSuperAdminWide(context)) const SuperAdminLogoutButton(),
        ],
      ),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.invoices.length,
            itemBuilder: (context, index) {
              final invoice = state.invoices[index];
              return _InvoiceCard(invoice: invoice);
            },
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(invoice.schoolName),
        subtitle: Text(
          'Due: ${dateFormat.format(invoice.dueDate)} • ${invoice.billingPeriod}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(invoice.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            StatusBadge(
              label: invoice.status.name,
              color: _paymentStatusColor(invoice.status),
            ),
          ],
        ),
        onTap: () {
          // Show invoice details / history
        },
      ),
    );
  }
}

Color _paymentStatusColor(PaymentStatus status) => switch (status) {
  PaymentStatus.completed => Colors.green,
  PaymentStatus.pending => Colors.orange,
  PaymentStatus.failed => Colors.red,
  PaymentStatus.refunded => Colors.blue,
};
