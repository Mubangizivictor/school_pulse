import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/student_bill.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';
import 'package:school_pulse/features/parent/how_to_pay_screen.dart';
import 'package:school_pulse/features/parent/receipts_screen.dart';
import 'package:school_pulse/features/parent/widgets/child_selector_sheet.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Fees & payments - the redesigned Parent Payments landing screen. School
/// Pulse never accepts money in-app: this screen shows the current balance,
/// the learner's bursar-managed payment code (to quote at any external
/// channel), and links to How to pay / Receipts. No checkout UI here.
class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Fees & payments',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
        builder: (context, studentState) {
          if (studentState is! SelectedStudentLoaded) {
            return const Center(child: SchoolPulseLoader());
          }
          return _Body(student: studentState.student);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Student student;

  const _Body({required this.student});

  @override
  Widget build(BuildContext context) {
    final schoolName = context.watch<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated)
                  .user
                  .schoolName ??
              'your school'
        : 'your school';

    return StreamBuilder<List<StudentBill>>(
      stream: di.sl<StudentBillingRepository>().watchBills(
        student.schoolId,
        student.id,
      ),
      builder: (context, billsSnapshot) {
        if (!billsSnapshot.hasData) {
          return _loadingSkeleton();
        }
        final bills = billsSnapshot.data!;
        final openBills = bills.where((b) => b.status != 'paid').toList();
        final balanceUgx = bills.fold<int>(0, (sum, b) => sum + b.balanceUgx);
        final currentBill = openBills.isNotEmpty ? openBills.first : null;

        return StreamBuilder<String?>(
          stream: di.sl<StudentBillingRepository>().watchStudentPaymentCode(
            student.schoolId,
            student.id,
          ),
          builder: (context, codeSnapshot) {
            final code = codeSnapshot.data;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ChildSwitcherRow(student: student),
                const SizedBox(height: 16),
                _BalanceCard(balanceUgx: balanceUgx, currentBill: currentBill),
                const SizedBox(height: 20),
                _PaymentCodeCard(code: code, schoolName: schoolName),
                const SizedBox(height: 16),
                _NavRow(
                  icon: Icons.info_outline,
                  title: 'How to pay',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HowToPayScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Recent payment'),
                const SizedBox(height: 8),
                _RecentPaymentCard(
                  schoolId: student.schoolId,
                  studentId: student.id,
                  bills: bills,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _loadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Skeleton(height: 60, borderRadius: 16),
        SizedBox(height: 16),
        Skeleton(height: 140, borderRadius: 16),
        SizedBox(height: 20),
        Skeleton(height: 160, borderRadius: 16),
      ],
    );
  }
}

class _ChildSwitcherRow extends StatelessWidget {
  final Student student;

  const _ChildSwitcherRow({required this.student});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      onTap: () => ChildSelectorSheet.show(context),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceContainerHigh(context),
            backgroundImage: student.photoUrl != null
                ? NetworkImage(student.photoUrl!)
                : null,
            child: student.photoUrl == null
                ? Icon(
                    Icons.person_outline,
                    color: AppColors.textPrimary(context),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const Icon(Icons.expand_more, color: AppColors.grey500),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balanceUgx;
  final StudentBill? currentBill;

  const _BalanceCard({required this.balanceUgx, this.currentBill});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance',
            style: TextStyle(fontSize: 13, color: AppColors.grey500),
          ),
          const SizedBox(height: 6),
          Text(
            '${CurrencyFormatter.ugx(balanceUgx.toDouble())} due',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          if (currentBill != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: AppColors.textPrimary(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current bill',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currentBill!.termId.isNotEmpty
                              ? currentBill!.termId
                              : 'Current term',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.grey500),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentCodeCard extends StatelessWidget {
  final String? code;
  final String schoolName;

  const _PaymentCodeCard({this.code, required this.schoolName});

  String _grouped(String raw) {
    // "VHS-P1234567" -> "VHS-P123 4567", purely cosmetic grouping so the
    // code is easier to read/say aloud, same idea as the mockup.
    final dashIndex = raw.indexOf('-');
    if (dashIndex == -1 || raw.length - dashIndex <= 5) return raw;
    final prefix = raw.substring(0, dashIndex + 1);
    final rest = raw.substring(dashIndex + 1);
    final mid = rest.length - 4;
    return '$prefix${rest.substring(0, mid)} ${rest.substring(mid)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Your payment code',
            style: TextStyle(fontSize: 13, color: AppColors.grey500),
          ),
          const SizedBox(height: 10),
          Text(
            code != null ? _grouped(code!) : '—',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          SecondaryButton(
            label: 'Copy code',
            icon: Icons.copy_outlined,
            onPressed: code == null
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: code!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment code copied.')),
                    );
                  },
          ),
          const SizedBox(height: 12),
          Text(
            'Use this code for every payment to $schoolName.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavRow({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary(context)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey500),
        ],
      ),
    );
  }
}

class _RecentPaymentCard extends StatefulWidget {
  final String schoolId;
  final String studentId;
  final List<StudentBill> bills;

  const _RecentPaymentCard({
    required this.schoolId,
    required this.studentId,
    required this.bills,
  });

  @override
  State<_RecentPaymentCard> createState() => _RecentPaymentCardState();
}

class _RecentPaymentCardState extends State<_RecentPaymentCard> {
  final Map<String, List<StudentPayment>> _byBill = {};

  @override
  void initState() {
    super.initState();
    for (final bill in widget.bills) {
      di
          .sl<StudentBillingRepository>()
          .watchPayments(widget.schoolId, widget.studentId, bill.id)
          .listen((payments) {
            if (!mounted) return;
            setState(() => _byBill[bill.id] = payments);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final payments =
        _byBill.values.expand((p) => p).where((p) => !p.isReversal).toList()
          ..sort((a, b) {
            final aDate = a.recordedAt ?? DateTime(0);
            final bDate = b.recordedAt ?? DateTime(0);
            return bDate.compareTo(aDate);
          });

    if (payments.isEmpty) {
      return AppCard(
        showShadow: false,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReceiptsScreen())),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.grey500),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No payments yet',
                style: TextStyle(color: AppColors.grey500),
              ),
            ),
          ],
        ),
      );
    }

    final payment = payments.first;
    return AppCard(
      showShadow: false,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ReceiptsScreen())),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_outlined,
              size: 20,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt ${payment.receiptNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${CurrencyFormatter.ugx(payment.amountUgx.toDouble())} · '
                  '${_methodLabel(payment.method)}',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
                Text(
                  payment.recordedAt != null
                      ? DateFormat('d MMM yyyy').format(payment.recordedAt!)
                      : '—',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Confirmed',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'mobile_money':
        return 'Mobile Money';
      case 'bank_transfer':
        return 'Bank';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }
}
