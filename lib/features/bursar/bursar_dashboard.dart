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
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';

class _BursarFinanceSnapshot {
  final List<Student> students;
  final List<FeeItem> fees;
  final List<PaymentRecord> payments;

  const _BursarFinanceSnapshot({required this.students, required this.fees, required this.payments});
}

class BursarDashboardScreen extends StatelessWidget {
  const BursarDashboardScreen({super.key});

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
        future: _loadSnapshot(),
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
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Receipt',
                    icon: Icons.receipt_long,
                    color: semanticColors.success,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Debtors',
                    icon: Icons.person_off_outlined,
                    color: semanticColors.error,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Reports',
                    icon: Icons.assessment_outlined,
                    color: semanticColors.warning,
                    onTap: () {},
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
