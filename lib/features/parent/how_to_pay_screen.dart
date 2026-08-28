import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_channel_config.dart';
import 'package:school_pulse/features/finance/domain/repositories/student_billing_repository.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// School Pulse never accepts payment in-app - this screen only shows the
/// school's own configured external channels and the learner's payment
/// code to quote. No Pay-now button anywhere, per the Parent Payments
/// redesign spec.
class HowToPayScreen extends StatelessWidget {
  const HowToPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentState = context.watch<SelectedStudentBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        title: Text(
          'How to pay',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: studentState is! SelectedStudentLoaded
          ? const Center(child: SchoolPulseLoader())
          : _Body(
              schoolId: studentState.student.schoolId,
              studentId: studentState.student.id,
              studentName: studentState.student.name,
            ),
    );
  }
}

class _Body extends StatelessWidget {
  final String schoolId;
  final String studentId;
  final String studentName;

  const _Body({
    required this.schoolId,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: di.sl<StudentBillingRepository>().watchStudentPaymentCode(
        schoolId,
        studentId,
      ),
      builder: (context, codeSnapshot) {
        return StreamBuilder<PaymentChannelConfig>(
          stream: di.sl<StudentBillingRepository>().watchPaymentChannelConfig(
            schoolId,
          ),
          builder: (context, configSnapshot) {
            if (!codeSnapshot.hasData && !codeSnapshot.hasError) {
              return const Center(child: SchoolPulseLoader());
            }
            if (!configSnapshot.hasData && !configSnapshot.hasError) {
              return const Center(child: SchoolPulseLoader());
            }

            final code = codeSnapshot.data;
            final config = configSnapshot.data ?? PaymentChannelConfig.empty;

            final enabledBanks = config.bankAccounts
                .where((b) => b.enabled)
                .toList();
            final enabledOthers = config.otherChannels
                .where((c) => c.enabled)
                .toList();

            final hasAnyChannel =
                config.mtnMomo.enabled ||
                config.airtelMoney.enabled ||
                enabledBanks.isNotEmpty ||
                enabledOthers.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _HeaderCard(studentName: studentName, code: code),
                const SizedBox(height: 20),
                if (!hasAnyChannel)
                  const EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'No payment channels yet',
                    message:
                        'Your school hasn\'t configured any payment channels '
                        'yet. Please contact the school office.',
                  )
                else ...[
                  if (config.mtnMomo.enabled)
                    _ChannelCard(
                      icon: Icons.phone_android_outlined,
                      title: 'MTN MoMo',
                      subtitle: _momoInstructions(config.mtnMomo),
                    ),
                  if (config.airtelMoney.enabled)
                    _ChannelCard(
                      icon: Icons.phone_android_outlined,
                      title: 'Airtel Money',
                      subtitle: _momoInstructions(config.airtelMoney),
                    ),
                  for (final bank in enabledBanks)
                    _ChannelCard(
                      icon: Icons.account_balance_outlined,
                      title: bank.bankName.isEmpty
                          ? 'Bank or bank agent'
                          : bank.bankName,
                      subtitle: _bankInstructions(bank),
                    ),
                  for (final other in enabledOthers)
                    _ChannelCard(
                      icon: Icons.payments_outlined,
                      title: other.label.isEmpty
                          ? 'Other channel'
                          : other.label,
                      subtitle: other.instructions,
                    ),
                ],
                const SizedBox(height: 8),
                const _NoticeCard(
                  icon: Icons.shield_outlined,
                  text:
                      'Confirm the learner name before entering your '
                      'mobile-money PIN.',
                ),
                const SizedBox(height: 12),
                const _NoticeCard(
                  icon: Icons.info_outline,
                  text: 'Payment channels are set by your school.',
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _momoInstructions(MomoChannelConfig channel) {
    final steps = channel.steps.isNotEmpty
        ? channel.steps
        : [
            if (channel.ussdCode.isNotEmpty) 'Dial ${channel.ussdCode}',
            if (channel.merchantLabel.isNotEmpty)
              'Choose ${channel.merchantLabel}',
            'Enter your payment code',
          ];
    return steps.join(', then ');
  }

  String _bankInstructions(BankAccountConfig bank) {
    final parts = <String>[
      if (bank.accountName.isNotEmpty) 'Account: ${bank.accountName}',
      if (bank.showAccountNumber && bank.accountNumber.isNotEmpty)
        'A/C No: ${bank.accountNumber}',
      if (bank.branchOrAgentNotes.isNotEmpty) bank.branchOrAgentNotes,
      'Quote your payment code at the teller.',
    ];
    return parts.join('\n');
  }
}

class _HeaderCard extends StatelessWidget {
  final String studentName;
  final String? code;

  const _HeaderCard({required this.studentName, this.code});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceContainerHigh(context),
            child: Icon(
              Icons.person_outline,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              studentName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Payment code',
                style: TextStyle(fontSize: 11, color: AppColors.grey500),
              ),
              Text(
                code ?? '—',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ChannelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey500),
        ],
      ),
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
