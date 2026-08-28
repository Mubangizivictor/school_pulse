import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:school_pulse/features/finance/domain/services/receipt_pdf_generator.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Real reconciled payment records only. A pending (unreconciled) claim is
/// labelled "Pending confirmation", never "Paid" - School Pulse never
/// generates a receipt for a manually entered parent claim, only for a
/// bursar-confirmed or provider-reconciled payment.
class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        title: Text(
          'Receipts',
          style: TextStyle(
            color: AppColors.textPrimary(context),
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

class _Body extends StatefulWidget {
  final Student student;

  const _Body({required this.student});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final Map<String, List<StudentPayment>> _byBill = {};
  final List<StreamSubscription<List<StudentPayment>>> _subs = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    di
        .sl<StudentBillingRepository>()
        .watchBills(widget.student.schoolId, widget.student.id)
        .listen((bills) {
          if (!mounted) return;
          for (final sub in _subs) {
            sub.cancel();
          }
          _subs.clear();
          _byBill.clear();
          if (bills.isEmpty) {
            setState(() => _loaded = true);
            return;
          }
          var pending = bills.length;
          for (final bill in bills) {
            final sub = di
                .sl<StudentBillingRepository>()
                .watchPayments(
                  widget.student.schoolId,
                  widget.student.id,
                  bill.id,
                )
                .listen((payments) {
                  if (!mounted) return;
                  setState(() {
                    _byBill[bill.id] = payments;
                    if (!_loaded) {
                      pending--;
                      if (pending <= 0) _loaded = true;
                    }
                  });
                });
            _subs.add(sub);
          }
        });
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: SchoolPulseLoader());
    }

    final confirmedPayments =
        _byBill.values.expand((p) => p).where((p) => !p.isReversal).toList()
          ..sort((a, b) {
            final aDate = a.recordedAt ?? DateTime(0);
            final bDate = b.recordedAt ?? DateTime(0);
            return bDate.compareTo(aDate);
          });

    return _PendingAndConfirmedList(
      student: widget.student,
      confirmedPayments: confirmedPayments,
    );
  }
}

class _PendingAndConfirmedList extends StatelessWidget {
  final Student student;
  final List<StudentPayment> confirmedPayments;

  const _PendingAndConfirmedList({
    required this.student,
    required this.confirmedPayments,
  });

  @override
  Widget build(BuildContext context) {
    if (confirmedPayments.isEmpty) {
      return const EmptyState(
        icon: Icons.description_outlined,
        title: 'No receipts yet',
        message: 'Receipts for confirmed payments will appear here.',
      );
    }

    final schoolName = context.watch<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated)
                  .user
                  .schoolName ??
              'School'
        : 'School';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _NoticeCard(
          icon: Icons.info_outline,
          text: 'Receipts are issued after the school confirms your payment.',
        ),
        const SizedBox(height: 16),
        for (final payment in confirmedPayments) ...[
          _ReceiptCard(
            payment: payment,
            studentName: student.name,
            schoolName: schoolName,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NoticeCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textPrimary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final StudentPayment payment;
  final String studentName;
  final String schoolName;

  const _ReceiptCard({
    required this.payment,
    required this.studentName,
    required this.schoolName,
  });

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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Receipt ${payment.receiptNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          const SizedBox(height: 14),
          _detailRow(context, 'Learner', studentName),
          _detailRow(
            context,
            'Amount',
            CurrencyFormatter.ugx(payment.amountUgx.toDouble()),
          ),
          _detailRow(context, 'Channel', _methodLabel(payment.method)),
          _detailRow(
            context,
            'Date',
            payment.recordedAt != null
                ? DateFormat('d MMM yyyy, h:mm a').format(payment.recordedAt!)
                : '—',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Download PDF',
                  icon: Icons.download_outlined,
                  onPressed: () => _downloadReceipt(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Share',
                  icon: Icons.ios_share_outlined,
                  onPressed: () => _downloadReceipt(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey500)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      await ReceiptPdfGenerator.download(
        payment: payment,
        studentName: studentName,
        schoolName: schoolName,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not generate receipt.')),
      );
    }
  }
}
