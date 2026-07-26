import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_item.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_all_fees.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_all_payment_history.dart';
import 'package:school_pulse/features/finance/domain/usecases/process_payment.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class _BursarFinanceSnapshot {
  final List<Student> students;
  final List<FeeItem> fees;
  final List<PaymentRecord> payments;

  const _BursarFinanceSnapshot({required this.students, required this.fees, required this.payments});
}

class BursarDashboardScreen extends StatefulWidget {
  const BursarDashboardScreen({super.key});

  @override
  State<BursarDashboardScreen> createState() => _BursarDashboardScreenState();
}

class _BursarDashboardScreenState extends State<BursarDashboardScreen> {
  late Future<_BursarFinanceSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  void _reload() {
    setState(() => _snapshotFuture = _loadSnapshot());
  }

  Future<_BursarFinanceSnapshot> _loadSnapshot() async {
    final results = await Future.wait([
      di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const <Student>[])),
      di.sl<GetAllFees>()().then((r) => r.getOrElse(() => const <FeeItem>[])),
      di.sl<GetAllPaymentHistory>()().then((r) => r.getOrElse(() => const <PaymentRecord>[])),
    ]);
    return _BursarFinanceSnapshot(
      students: results[0] as List<Student>,
      fees: results[1] as List<FeeItem>,
      payments: results[2] as List<PaymentRecord>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bursar Portal'),
        actions: const [
          IconButton(icon: Icon(Icons.search), onPressed: null),
          NotificationBellButton(),
        ],
      ),
      body: FutureBuilder<_BursarFinanceSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final studentsById = {for (final s in data?.students ?? const <Student>[]) s.id: s};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFinancialSummary(context, semanticColors, data, isLoading),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Quick Actions'),
              QuickActionGrid(
                items: [
                  QuickActionItem(
                    label: 'Collect',
                    icon: Icons.add_card,
                    color: semanticColors.info,
                    onTap: () => _showCollectPaymentDialog(context, data),
                  ),
                  QuickActionItem(
                    label: 'Debtors',
                    icon: Icons.person_off_outlined,
                    color: semanticColors.error,
                    onTap: () => _showDebtorsSheet(context, data),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Skeleton(height: 80)
              else
                _buildCollectionProgress(context, semanticColors, data),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent Transactions', actionLabel: 'View All'),
              if (isLoading)
                ...List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Skeleton(height: 60),
                ))
              else if (data != null && data.payments.isEmpty)
                const AppCard(
                  padding: EdgeInsets.all(16),
                  child: Text('No transactions recorded yet.'),
                )
              else if (data != null)
                ...data.payments.take(3).map((record) {
                  final studentName = studentsById[record.studentId]?.name ?? 'Unknown Student';
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: semanticColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_downward, color: semanticColors.success, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(record.method, style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.ugx(record.amount),
                          style: TextStyle(fontWeight: FontWeight.bold, color: semanticColors.success),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showCollectPaymentDialog(BuildContext context, _BursarFinanceSnapshot? data) {
    final students = data?.students ?? const <Student>[];
    if (students.isEmpty) return;

    final amountController = TextEditingController();
    String? selectedStudentId = students.first.id;
    String method = 'Cash';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Collect Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStudentId,
                decoration: const InputDecoration(labelText: 'Student'),
                items: students
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => setDialogState(() => selectedStudentId = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (UGX)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Method'),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'Mobile Money', child: Text('Mobile Money')),
                  DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                ],
                onChanged: (value) => setDialogState(() => method = value ?? 'Cash'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0 || selectedStudentId == null) return;
                await di.sl<ProcessPayment>()(PaymentRecord(
                  id: '',
                  studentId: selectedStudentId!,
                  amount: amount,
                  date: DateTime.now(),
                  method: method,
                  reference: 'Collected by bursar',
                ));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _reload();
              },
              child: const Text('Collect'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDebtorsSheet(BuildContext context, _BursarFinanceSnapshot? data) {
    final students = data?.students ?? const <Student>[];
    final fees = data?.fees ?? const <FeeItem>[];
    final payments = data?.payments ?? const <PaymentRecord>[];

    final owedByStudent = <String, double>{};
    for (final fee in fees) {
      owedByStudent[fee.studentId] = (owedByStudent[fee.studentId] ?? 0) + fee.amount;
    }
    for (final payment in payments) {
      owedByStudent[payment.studentId] = (owedByStudent[payment.studentId] ?? 0) - payment.amount;
    }
    final debtors = owedByStudent.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (sheetContext, scrollController) {
          if (debtors.isEmpty) {
            return const Center(child: Text('No outstanding balances.'));
          }
          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: debtors.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final entry = debtors[index];
              final name = students.firstWhere(
                (s) => s.id == entry.key,
                orElse: () => Student(id: entry.key, name: 'Unknown Student', className: '', studentId: ''),
              ).name;
              return ListTile(
                title: Text(name),
                trailing: Text(
                  CurrencyFormatter.ugx(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCollectionProgress(BuildContext context, SemanticColors semanticColors, _BursarFinanceSnapshot? data) {
    final target = data?.fees.fold<double>(0, (sum, fee) => sum + fee.amount) ?? 0;
    final collected = data?.payments.fold<double>(0, (sum, p) => sum + p.amount) ?? 0;
    final progress = target > 0 ? (collected / target).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).round();

    return ProgressCard(
      title: 'Fee Collection Target',
      progress: progress,
      subtitle: '${CurrencyFormatter.ugx(collected)} of ${CurrencyFormatter.ugx(target)} collected ($percent%)',
      color: semanticColors.success,
    );
  }

  Widget _buildFinancialSummary(BuildContext context, SemanticColors colors, _BursarFinanceSnapshot? data, bool isLoading) {
    if (isLoading) {
      return const Skeleton(height: 180);
    }

    final target = data?.fees.fold<double>(0, (sum, fee) => sum + fee.amount) ?? 0;
    final collected = data?.payments.fold<double>(0, (sum, p) => sum + p.amount) ?? 0;
    final outstanding = (target - collected).clamp(0, double.infinity);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Total Collections (This Term)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.ugx(collected),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Target',
                  value: CurrencyFormatter.ugx(target),
                  color: colors.info,
                ),
              ),
              Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
              Expanded(
                child: _SummaryItem(
                  label: 'Outstanding',
                  value: CurrencyFormatter.ugx(outstanding.toDouble()),
                  color: colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18),
        ),
      ],
    );
  }
}
