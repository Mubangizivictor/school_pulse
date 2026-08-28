import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Suppliers — read-only list of supplier profiles with payable balances,
/// tapping through to that supplier's invoices and payment history.
class BursarSuppliersScreen extends StatelessWidget {
  const BursarSuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final repo = sl<BursarOpsReadRepository>();

    return FinanceScaffold(
      title: 'Suppliers',
      body: StreamBuilder<List<Supplier>>(
        stream: repo.watchSuppliers(schoolId),
        builder: (context, snap) {
          if (!snap.hasData) return FinanceStates.loading();
          final suppliers = snap.data!;
          if (suppliers.isEmpty) {
            return FinanceStates.empty(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'No suppliers yet',
              message:
                  'Suppliers you pay will appear here with their payable '
                  'balances.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              for (final s in suppliers)
                FinanceListRow(
                  leadingIcon: Icons.storefront_outlined,
                  title: s.name,
                  subtitle: s.category,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _SupplierDetailScreen(
                        schoolId: schoolId,
                        supplier: s,
                      ),
                    ),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.ugx(s.payableBalanceUgx.toDouble()),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: s.payableBalanceUgx > 0
                              ? AppColors.danger(context)
                              : AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'payable',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SupplierDetailScreen extends StatelessWidget {
  final String schoolId;
  final Supplier supplier;

  const _SupplierDetailScreen({required this.schoolId, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final repo = sl<BursarOpsReadRepository>();
    return FinanceScaffold(
      title: supplier.name,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          SectionCard(
            child: Column(
              children: [
                KeyValueRow('Category', supplier.category),
                if (supplier.phone != null)
                  KeyValueRow('Phone', supplier.phone!),
                KeyValueRow(
                  'Payable balance',
                  CurrencyFormatter.ugx(supplier.payableBalanceUgx.toDouble()),
                  bold: true,
                  valueColor: supplier.payableBalanceUgx > 0
                      ? AppColors.danger(context)
                      : AppColors.success(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Invoices',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<SupplierInvoice>>(
            stream: repo.watchSupplierInvoices(
              schoolId,
              supplierId: supplier.id,
            ),
            builder: (context, snap) {
              final invoices = snap.data ?? const <SupplierInvoice>[];
              if (invoices.isEmpty) {
                return FinanceCard(
                  child: Text(
                    'No invoices recorded.',
                    style: TextStyle(color: AppColors.textMuted(context)),
                  ),
                );
              }
              return Column(
                children: [
                  for (final inv in invoices)
                    FinanceListRow(
                      leadingIcon: Icons.receipt_outlined,
                      title: inv.reference,
                      subtitle: inv.issuedAt != null
                          ? DateFormatter.format(inv.issuedAt!)
                          : null,
                      showChevron: false,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FinanceStatusChip.forStatus(inv.status),
                          const SizedBox(width: AppSpacing.m),
                          Text(
                            CurrencyFormatter.ugx(inv.amountUgx.toDouble()),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
