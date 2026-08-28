import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Cash & Bank tab (bottom-nav slot 3).
///
/// The reference screenshot shows till/bank/mobile-money accounts, deposits,
/// a ledger, and reconciliation with unmatched-transaction counts. None of
/// that backend exists yet (`bank_accounts`, `cash_tills`, `bank_transactions`,
/// `reconciliations` are Phase 2). Until then this tab renders the shared
/// "coming soon" state so the nav matches the screenshots exactly without
/// showing fabricated balances.
class BursarCashBankScreen extends StatelessWidget {
  const BursarCashBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.l,
        title: Text(
          'Cash & Bank',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: FinanceStates.comingSoon(
          context,
          feature: 'Cash & Bank',
          detail:
              'Till, bank and mobile-money accounts, deposits, the cash ledger '
              'and reconciliation are being built. Payments you record today '
              'still post to the student ledger and generate receipts.',
        ),
      ),
    );
  }
}
