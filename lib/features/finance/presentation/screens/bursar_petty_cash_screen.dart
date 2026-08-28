import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Petty Cash — read-only view matching the reference: current float, total
/// in/out, and a cash-in/out ledger with a running balance. Replenishment
/// requests land in a later phase.
class BursarPettyCashScreen extends StatelessWidget {
  const BursarPettyCashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final repo = sl<BursarOpsReadRepository>();

    return StreamBuilder<PettyCashFloat?>(
      stream: repo.watchPettyCashFloat(schoolId),
      builder: (context, floatSnap) {
        final float = floatSnap.data;
        return FinanceScaffold(
          title: float == null
              ? 'Petty Cash'
              : 'Petty Cash — ${float.location}',
          bottomBar: PrimaryActionBar(
            label: 'Request replenishment',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Replenishment requests are coming soon.'),
              ),
            ),
          ),
          body: !floatSnap.hasData
              ? FinanceStates.loading()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    FinanceCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Current float',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.ugx(
                              (float?.currentFloatUgx ?? 0).toDouble(),
                            ),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'Total in',
                            value: CurrencyFormatter.ugx(
                              (float?.totalInUgx ?? 0).toDouble(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            label: 'Total out',
                            value: CurrencyFormatter.ugx(
                              (float?.totalOutUgx ?? 0).toDouble(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ledger',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<LedgerEntry>>(
                      stream: repo.watchPettyCashLedger(schoolId),
                      builder: (context, ledSnap) {
                        final entries = ledSnap.data ?? const <LedgerEntry>[];
                        if (entries.isEmpty) {
                          return FinanceCard(
                            child: Text(
                              'No petty-cash movements yet.',
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                              ),
                            ),
                          );
                        }
                        return FinanceCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < entries.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    color: AppColors.border(context),
                                  ),
                                _PettyRow(entry: entries[i]),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PettyRow extends StatelessWidget {
  final LedgerEntry entry;
  const _PettyRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isIn = entry.amountUgx >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (entry.date != null)
                  Text(
                    DateFormatter.format(entry.date!),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted(context),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              isIn ? CurrencyFormatter.ugx(entry.amountUgx.toDouble()) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: AppColors.success(context)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              !isIn
                  ? CurrencyFormatter.ugx(entry.amountUgx.abs().toDouble())
                  : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              entry.balanceUgx == null
                  ? ''
                  : CurrencyFormatter.ugx(entry.balanceUgx!.toDouble()),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
