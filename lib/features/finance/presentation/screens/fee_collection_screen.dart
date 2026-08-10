import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/student_financial_account.dart';

class FeeCollectionScreen extends StatefulWidget {
  const FeeCollectionScreen({super.key});

  @override
  State<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends State<FeeCollectionScreen> {
  final _searchController = TextEditingController();
  Student? _selectedStudent;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is FinanceActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          // Re-load profile to show updated balance
          if (_selectedStudent != null) {
            context.read<FinanceBloc>().add(
              LoadStudentFinancialProfile(
                studentId: _selectedStudent!.id,
                schoolId: _selectedStudent!.schoolId,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Collect Fees')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppSearchField(
                controller: _searchController,
                hintText: 'Search student by name or ID...',
                onChanged: (query) {
                  if (query.length > 2) {
                    context.read<StudentsBloc>().add(SearchStudents(query));
                  }
                },
              ),
            ),
            Expanded(
              child: _selectedStudent == null
                  ? _buildStudentSearchList()
                  : _buildFinancialProfile(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSearchList() {
    return BlocBuilder<StudentsBloc, StudentsState>(
      builder: (context, state) {
        if (state is StudentsLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is StudentsLoaded) {
          if (state.students.isEmpty) {
            return const EmptyState(
              icon: Icons.person_search,
              title: 'No students found',
              message: 'Try a different search term',
            );
          }
          return ListView.builder(
            itemCount: state.students.length,
            itemBuilder: (context, index) {
              final student = state.students[index];
              return ListTile(
                leading: AvatarInitials(name: student.name),
                title: Text(student.name),
                subtitle: Text(student.studentCode),
                onTap: () {
                  setState(() {
                    _selectedStudent = student;
                  });
                  context.read<FinanceBloc>().add(
                    LoadStudentFinancialProfile(
                      studentId: student.id,
                      schoolId: student.schoolId,
                    ),
                  );
                },
              );
            },
          );
        }
        return const Center(child: Text('Enter student name to start'));
      },
    );
  }

  Widget _buildFinancialProfile() {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(child: SchoolPulseLoader());
        }

        if (state is StudentFinancialProfileLoaded) {
          final semanticColors = Theme.of(context).extension<SemanticColors>()!;
          final account = state.account;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Row(
                  children: [
                    AvatarInitials(name: _selectedStudent!.name, size: 50),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedStudent!.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            _selectedStudent!.studentCode,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selectedStudent = null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      title: 'Balance Due',
                      value: CurrencyFormatter.ugx(account.balance),
                      color: account.balance > 0
                          ? semanticColors.error
                          : semanticColors.success,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KPICard(
                      title: 'Total Paid',
                      value: CurrencyFormatter.ugx(account.totalPaid),
                      color: semanticColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Record New Payment',
                icon: Icons.add_card,
                onPressed: () => _showPaymentForm(context, account),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Payment History'),
              if (state.paymentHistory.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No previous payments found'),
                  ),
                )
              else
                ...state.paymentHistory.map(
                  (p) =>
                      TransactionTile(transaction: p, colors: semanticColors),
                ),
            ],
          );
        }

        if (state is FinanceError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showPaymentForm(BuildContext context, StudentFinancialAccount account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _PaymentForm(student: _selectedStudent!, account: account),
    );
  }
}

class _PaymentForm extends StatefulWidget {
  final Student student;
  final StudentFinancialAccount account;

  const _PaymentForm({required this.student, required this.account});

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Record Payment',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (UGX)',
              border: OutlineInputBorder(),
              prefixText: 'UGX ',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: [
              'Cash',
              'Bank Deposit',
              'Bank Transfer',
              'Mobile Money',
              'Cheque',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => _paymentMethod = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _refController,
            decoration: const InputDecoration(
              labelText: 'Reference # (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Process Payment',
            onPressed: () {
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (amount <= 0) return;

              final payment = PaymentRecord(
                id: '', // Generated by Firestore
                schoolId: widget.student.schoolId,
                studentId: widget.student.id,
                academicYear: widget.account.academicYear,
                term: widget.account.term,
                amount: amount,
                date: DateTime.now(),
                method: _paymentMethod,
                reference: _refController.text,
                receiptNumber: 'REC-${DateTime.now().millisecondsSinceEpoch}',
                feeBreakdown: {
                  'Tuition': amount, // Simplified allocation for now
                },
                recordedBy: 'Current User', // TODO: Get from AuthBloc
                notes: _notesController.text,
              );

              context.read<FinanceBloc>().add(RecordNewPayment(payment));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final dynamic transaction;
  final SemanticColors colors;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.success.withValues(alpha: 0.1),
            child: Icon(Icons.arrow_downward, color: colors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.receiptNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  transaction.method,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.ugx(transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.success,
                ),
              ),
              Text(
                DateFormatter.format(transaction.date),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              IconButton(
                icon: const Icon(Icons.print, size: 20),
                onPressed: () {
                  final studentName =
                      context.read<FinanceBloc>().state
                          is StudentFinancialProfileLoaded
                      ? (context.read<FinanceBloc>().state
                                as StudentFinancialProfileLoaded)
                            .account
                            .studentId
                      : 'Student';
                  // In a real app, we'd get the name correctly.
                  context.read<FinanceBloc>().add(
                    PrintReceipt(
                      payment: transaction,
                      studentName: studentName,
                      className: 'Class',
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
