import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Audit trail — a read-only viewer over `schools/{id}/finance_audit_events`.
/// Every money movement, approval, reversal and reconciliation action writes
/// an immutable event here (server-side); this screen just lists them
/// newest-first.
class BursarAuditTrailScreen extends StatelessWidget {
  const BursarAuditTrailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final repo = sl<BursarOpsReadRepository>();

    return FinanceScaffold(
      title: 'Audit trail',
      constrainWidth: true,
      body: StreamBuilder<List<AuditEvent>>(
        stream: repo.watchAuditEvents(schoolId),
        builder: (context, snap) {
          if (!snap.hasData) return FinanceStates.loading();
          final events = snap.data!;
          if (events.isEmpty) {
            return FinanceStates.empty(
              context,
              icon: Icons.fact_check_outlined,
              title: 'No audit events yet',
              message:
                  'Money movements, approvals and reversals are recorded '
                  'here as they happen.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: events.length,
            itemBuilder: (context, i) => _AuditRow(event: events[i]),
          );
        },
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  final AuditEvent event;
  const _AuditRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.action,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (event.amountUgx != null)
                Text(
                  CurrencyFormatter.ugx(event.amountUgx!.toDouble()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            event.summary,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.actor}'
            '${event.at != null ? ' • ${DateFormat('d MMM yyyy, h:mm a').format(event.at!)}' : ''}',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }
}
