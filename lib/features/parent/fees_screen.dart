import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<FinanceBloc>().add(FetchFees(studentState.student.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Payments',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildBalanceCard(context),
              const SizedBox(height: 32),
              const Text(
                'FEE BREAKDOWN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                showShadow: false,
                child: Column(
                  children: [
                    _buildFeeRow('Tuition Fees', 'UGX 1,200,000', 'Unpaid'),
                    const Divider(height: 32),
                    _buildFeeRow('Transport', 'UGX 300,000', 'Unpaid'),
                    const Divider(height: 32),
                    _buildFeeRow('Lunch Program', 'UGX 150,000', 'Paid', isPaid: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'RECENT TRANSACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 16),
              _buildTransactionItem('School Fees Payment', '12 Oct 2023', 'UGX 500,000'),
              const SizedBox(height: 12),
              _buildTransactionItem('Uniform Purchase', '05 Oct 2023', 'UGX 120,000'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      color: AppColors.black,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Outstanding',
            style: TextStyle(color: AppColors.grey300, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'UGX 1,500,000',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Pay Now',
            color: AppColors.white,
            onPressed: () => context.push('/parent/payments/pay'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, String status, {bool isPaid = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: isPaid ? AppColors.successLight : AppColors.dangerLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      showShadow: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
