import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../../domain/entities/payment_record.dart';

class ReceiptVerificationResultScreen extends StatelessWidget {
  final PaymentRecord payment;

  const ReceiptVerificationResultScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final currencyFormatter = NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Verification'),
        backgroundColor: semanticColors.success,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.black, size: 80),
            const SizedBox(height: 16),
            const Text(
              'AUTHENTIC RECEIPT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verified via School Pulse Financial System',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildRow('Receipt Number', payment.receiptNumber),
                  _buildDivider(),
                  _buildRow('Date Paid', dateFormatter.format(payment.date)),
                  _buildDivider(),
                  _buildRow('Academic Year', payment.academicYear),
                  _buildRow('Term', payment.term),
                  _buildDivider(),
                  _buildRow('Payment Method', payment.method),
                  _buildRow('Reference', payment.reference),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: semanticColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL AMOUNT PAID',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(payment.amount),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: semanticColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 24);
}
