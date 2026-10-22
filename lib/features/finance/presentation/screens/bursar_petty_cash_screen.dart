import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_offline_queue.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_operations_remote_data_source.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_forms.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

const _pettyCashOperatorRoles = {'bursar', 'schoolAdmin'};

/// Petty Cash — running float, in/out totals, full ledger, and the two real
/// callable-backed actions: **replenish float** (moves money from a
/// cash/bank account into the tin) and **record disbursement** (money out,
/// with payee/category/purpose/approver). Both go through
/// `finance_operations.js`.
class BursarPettyCashScreen extends StatefulWidget {
  const BursarPettyCashScreen({super.key});

  @override
  State<BursarPettyCashScreen> createState() => _BursarPettyCashScreenState();
}

class _BursarPettyCashScreenState extends State<BursarPettyCashScreen> {
  List<FinanceQueuedDisbursement> _pending = const [];

  @override
  void initState() {
    super.initState();
    _refreshQueue(trySync: true);
  }

  Future<void> _refreshQueue({bool trySync = false}) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final queue = sl<FinanceOfflineQueue>();
    if (trySync) {
      await queue.sync(auth.user.schoolId);
    }
    if (!mounted) return;
    setState(() => _pending = queue.pendingFor(auth.user.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final roles = auth is AuthAuthenticated
        ? auth.user.roles.map((r) => r.name).toSet()
        : <String>{};
    final canOperate = roles.any(_pettyCashOperatorRoles.contains);
    final repo = sl<BursarOpsReadRepository>();

    return StreamBuilder<PettyCashFloat?>(
      stream: repo.watchPettyCashFloat(schoolId),
      builder: (context, floatSnap) {
        final float = floatSnap.data;
        return FinanceScaffold(
          title: float == null
              ? 'Petty Cash'
              : 'Petty Cash — ${float.location}',
          actions: canOperate
              ? [
                  IconButton(
                    tooltip: 'Replenish float',
                    icon: const Icon(Icons.add_card_outlined),
                    onPressed: () =>
                        _openReplenish(context, schoolId, float?.location),
                  ),
                ]
              : null,
          bottomBar: canOperate
              ? PrimaryActionBar(
                  label: 'Record disbursement',
                  onPressed: float == null
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Replenish the float before recording a disbursement.',
                            ),
                          ),
                        )
                      : () async {
                          await _openDisbursement(context, schoolId, float);
                          await _refreshQueue();
                        },
                )
              : null,
          body: !floatSnap.hasData
              ? FinanceStates.loading()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    if (_pending.isNotEmpty)
                      _PendingSyncBanner(
                        count: _pending.length,
                        failed: _pending.any(
                          (p) => p.status == FinanceQueueStatus.failed,
                        ),
                        onSync: () => _refreshQueue(trySync: true),
                      ),
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

// ---------------------------------------------------------------------------
//  Actions
// ---------------------------------------------------------------------------

Future<void> _openReplenish(
  BuildContext context,
  String schoolId,
  String? location,
) async {
  final accounts = await sl<BursarOpsReadRepository>()
      .watchBankAccounts(schoolId)
      .first;
  final payable = accounts
      .where((a) => a.kind == 'bank' || a.kind == 'cash')
      .toList();
  if (!context.mounted) return;
  if (payable.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No cash or bank account to replenish from.'),
      ),
    );
    return;
  }
  String accountId = payable.first.id;
  final amount = TextEditingController();
  final reference = TextEditingController();
  final locationCtl = TextEditingController(text: location ?? 'Main Office');
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => _Sheet(
        title: 'Replenish petty cash',
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: accountId,
                decoration: const InputDecoration(
                  labelText: 'From account',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (final a in payable)
                    DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        '${a.name} · ${CurrencyFormatter.ugx(a.balanceUgx.toDouble())}',
                      ),
                    ),
                ],
                onChanged: (v) => setSheet(() => accountId = v ?? accountId),
              ),
              const SizedBox(height: 12),
              FinanceField(
                controller: amount,
                label: 'Amount',
                moneyUgx: true,
                required: true,
              ),
              FinanceField(
                controller: reference,
                label: 'Reference',
                required: true,
              ),
              FinanceField(controller: locationCtl, label: 'Location'),
              const SizedBox(height: 8),
              FinanceSubmitButton(
                label: 'Replenish',
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  await runFinanceAction(
                    sheetContext,
                    successMessage: 'Float replenished',
                    popOnDone: 1,
                    action: () => sl<FinanceOperationsRemoteDataSource>()
                        .replenishPettyCash(
                          schoolId: schoolId,
                          accountId: accountId,
                          amountUgx: int.parse(amount.text.trim()),
                          reference: reference.text.trim(),
                          location: locationCtl.text.trim().isEmpty
                              ? null
                              : locationCtl.text.trim(),
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _openDisbursement(
  BuildContext context,
  String schoolId,
  PettyCashFloat float,
) {
  final payee = TextEditingController();
  final category = TextEditingController();
  final purpose = TextEditingController();
  final amount = TextEditingController();
  final requestedBy = TextEditingController();
  final approvedBy = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _Sheet(
      title: 'Record disbursement',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available float: ${CurrencyFormatter.ugx(float.currentFloatUgx.toDouble())}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(sheetContext),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FinanceField(controller: payee, label: 'Paid to', required: true),
            FinanceField(
              controller: category,
              label: 'Category',
              required: true,
            ),
            FinanceField(controller: purpose, label: 'Purpose', required: true),
            FinanceField(
              controller: amount,
              label: 'Amount',
              moneyUgx: true,
              required: true,
            ),
            FinanceField(controller: requestedBy, label: 'Requested by'),
            FinanceField(
              controller: approvedBy,
              label: 'Approved by (required for large amounts)',
            ),
            const SizedBox(height: 8),
            FinanceSubmitButton(
              label: 'Record disbursement',
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final queue = sl<FinanceOfflineQueue>();
                final online = await queue.isOnline;
                final args = (
                  payee: payee.text.trim(),
                  category: category.text.trim(),
                  purpose: purpose.text.trim(),
                  amount: int.parse(amount.text.trim()),
                  requestedBy: requestedBy.text.trim().isEmpty
                      ? null
                      : requestedBy.text.trim(),
                  approvedBy: approvedBy.text.trim().isEmpty
                      ? null
                      : approvedBy.text.trim(),
                );
                if (!online) {
                  // Offline: queue it (idempotency-keyed). Never queued:
                  // approvals, reconciliation, payment finalisation.
                  await queue.enqueueDisbursement(
                    schoolId: schoolId,
                    payee: args.payee,
                    category: args.category,
                    purpose: args.purpose,
                    amountUgx: args.amount,
                    requestedBy: args.requestedBy,
                    approvedBy: args.approvedBy,
                  );
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Saved offline — it will sync when you reconnect.',
                        ),
                      ),
                    );
                  }
                  return;
                }
                if (!sheetContext.mounted) return;
                await runFinanceAction(
                  sheetContext,
                  successMessage: 'Disbursement recorded',
                  popOnDone: 1,
                  action: () => sl<FinanceOperationsRemoteDataSource>()
                      .recordPettyCashDisbursement(
                        schoolId: schoolId,
                        payee: args.payee,
                        category: args.category,
                        purpose: args.purpose,
                        amountUgx: args.amount,
                        requestedBy: args.requestedBy,
                        approvedBy: args.approvedBy,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _Sheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
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

/// Shows how many petty-cash disbursements are captured but not yet synced
/// to the server, with a manual "Sync now" (they also sync automatically
/// when the screen opens online). Failed items are called out in red.
class _PendingSyncBanner extends StatelessWidget {
  final int count;
  final bool failed;
  final VoidCallback onSync;

  const _PendingSyncBanner({
    required this.count,
    required this.failed,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final tint = failed
        ? AppColors.danger(context)
        : AppColors.textSecondary(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: tint.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            failed ? Icons.sync_problem_outlined : Icons.cloud_upload_outlined,
            size: 18,
            color: tint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              failed
                  ? '$count disbursement${count == 1 ? '' : 's'} failed to sync — tap to retry.'
                  : '$count disbursement${count == 1 ? '' : 's'} waiting to sync.',
              style: TextStyle(fontSize: 12, color: tint),
            ),
          ),
          TextButton(onPressed: onSync, child: const Text('Sync now')),
        ],
      ),
    );
  }
}
