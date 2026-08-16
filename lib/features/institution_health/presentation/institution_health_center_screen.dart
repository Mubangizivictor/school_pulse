import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/institution_health/data/institution_health_repository.dart';
import 'package:school_pulse/features/institution_health/domain/institution_health_models.dart';

class InstitutionHealthCenterScreen extends StatefulWidget {
  const InstitutionHealthCenterScreen({super.key});
  @override
  State<InstitutionHealthCenterScreen> createState() =>
      _InstitutionHealthCenterScreenState();
}

class _InstitutionHealthCenterScreenState
    extends State<InstitutionHealthCenterScreen> {
  final _repository = InstitutionHealthRepository();
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final institutionId = auth is AuthAuthenticated ? auth.user.schoolId : null;
    if (institutionId == null || institutionId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Institution Health',
        actions: [
          IconButton(
            tooltip: 'Recheck health',
            onPressed: () => _recheck(institutionId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<InstitutionHealthScore?>(
        stream: _repository.watchScore(institutionId),
        builder: (context, scoreSnapshot) =>
            StreamBuilder<List<HealthCheckResult>>(
              stream: _repository.watchChecks(institutionId),
              builder: (context, checksSnapshot) {
                if (scoreSnapshot.hasError || checksSnapshot.hasError) {
                  return const Center(
                    child: EmptyState(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Health data unavailable',
                      message: 'Check your access and try again.',
                    ),
                  );
                }
                if (!scoreSnapshot.hasData || !checksSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _body(
                  context,
                  institutionId,
                  scoreSnapshot.data,
                  checksSnapshot.data!,
                );
              },
            ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    String institutionId,
    InstitutionHealthScore? score,
    List<HealthCheckResult> checks,
  ) {
    final filtered = checks.where((check) {
      final matchingFilter =
          _filter == 'All' ||
          check.category == _filter ||
          (_filter == 'Actionable' && check.actionable);
      final text =
          '${check.title} ${check.description} ${check.affectedModule} ${check.correlationId}'
              .toLowerCase();
      return matchingFilter && text.contains(_query.toLowerCase());
    }).toList();
    final critical = checks
        .where(
          (item) => item.actionable && item.severity == HealthSeverity.critical,
        )
        .length;
    final warnings = checks
        .where((item) => item.status == HealthCheckStatus.warning)
        .length;
    final recommendations = checks.where((item) => item.actionable).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return RefreshIndicator(
      onRefresh: () => _recheck(institutionId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _ScoreCard(score: score, critical: critical, warnings: warnings),
          if (score == null || score.isStale)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: AlertBanner(
                icon: Icons.schedule_outlined,
                title: 'Health data may be outdated',
                color: Colors.orange,
                message:
                    'The last confirmed health result is shown. Recheck to request a targeted server refresh.',
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Recommended actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (recommendations.isEmpty)
            const EmptyState(
              icon: Icons.task_alt,
              title: 'No active issues',
              message: 'No server-reported health checks need action.',
            ),
          ...recommendations
              .take(3)
              .map(
                (check) => _CheckCard(
                  check: check,
                  compact: true,
                  onOpen: () => _openCheck(context, institutionId, check),
                ),
              ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search checks, modules or reference codes',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                        'All',
                        'Actionable',
                        'Setup',
                        'Academics',
                        'People',
                        'Security',
                        'Data',
                        'Integrations',
                        'Sync',
                        'Subscription',
                      ]
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _filter == filter,
                            onSelected: (_) => setState(() => _filter = filter),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Health checks (${filtered.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'No matching checks',
              message: 'Try another filter or refresh the health summary.',
            ),
          ...filtered.map(
            (check) => _CheckCard(
              check: check,
              onOpen: () => _openCheck(context, institutionId, check),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recheck(String institutionId) async {
    try {
      await _repository.recheck(institutionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health recheck requested.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not request a health recheck.')),
        );
      }
    }
  }

  void _openCheck(
    BuildContext context,
    String institutionId,
    HealthCheckResult check,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: _IssueDetail(
        check: check,
        onAcknowledge: () async {
          await _repository.acknowledge(institutionId, check.id);
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
        onRecheck: () =>
            _repository.recheck(institutionId, checkKey: check.checkKey),
        onRoute: check.remediationRoute.isEmpty
            ? null
            : () {
                Navigator.pop(sheetContext);
                context.go(check.remediationRoute);
              },
      ),
    ),
  );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.critical,
    required this.warnings,
  });
  final InstitutionHealthScore? score;
  final int critical, warnings;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = score?.status ?? InstitutionHealthStatus.unknown;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Institution health',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              _statusLabel(status),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _statusColor(scheme, status),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              score?.overallScore == null
                  ? 'No calculated score is available yet.'
                  : '${score!.overallScore}/100 · Server-calculated',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                Text('$critical critical'),
                Text('$warnings warnings'),
                Text(
                  score?.calculatedAt == null
                      ? 'Not checked'
                      : 'Checked ${DateFormat.yMMMd().add_jm().format(score!.calculatedAt!)}',
                ),
              ],
            ),
            if (score != null && score!.overallScore != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    {
                          'Setup': score!.readinessScore,
                          'Academics': score!.academicSetupScore,
                          'Security': score!.securityScore,
                          'Data': score!.dataQualityScore,
                          'Integrations': score!.integrationScore,
                          'Sync': score!.syncScore,
                          'Subscription': score!.subscriptionScore,
                        }.entries
                        .map(
                          (e) =>
                              Chip(label: Text('${e.key} ${e.value ?? '—'}')),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.check,
    required this.onOpen,
    this.compact = false,
  });
  final HealthCheckResult check;
  final VoidCallback onOpen;
  final bool compact;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onOpen,
      leading: CircleAvatar(
        backgroundColor: _severityColor(
          Theme.of(context).colorScheme,
          check.severity,
        ).withValues(alpha: .14),
        child: Icon(
          _statusIcon(check.status),
          color: _severityColor(Theme.of(context).colorScheme, check.severity),
        ),
      ),
      title: Text(check.title),
      subtitle: Text(
        compact
            ? '${check.category} · ${check.affectedCount} affected'
            : '${check.description}${check.affectedCount > 0 ? ' · ${check.affectedCount} affected' : ''}',
        maxLines: compact ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class _IssueDetail extends StatelessWidget {
  const _IssueDetail({
    required this.check,
    required this.onAcknowledge,
    required this.onRecheck,
    this.onRoute,
  });
  final HealthCheckResult check;
  final Future<void> Function() onAcknowledge, onRecheck;
  final VoidCallback? onRoute;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(check.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(check.description),
        const SizedBox(height: 16),
        Text('Severity: ${check.severity.name} · ${check.status.name}'),
        Text(
          'Affected: ${check.affectedCount} · Module: ${check.affectedModule.isEmpty ? 'Institution' : check.affectedModule}',
        ),
        Text(
          'Last checked: ${check.lastCheckedAt == null ? 'Unknown' : DateFormat.yMMMd().add_jm().format(check.lastCheckedAt!)}',
        ),
        if (check.correlationId.isNotEmpty)
          Text('Reference: ${check.correlationId}'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () async => onRecheck(),
              icon: const Icon(Icons.refresh),
              label: const Text('Recheck'),
            ),
            if (check.resolutionState == HealthResolutionState.open)
              OutlinedButton.icon(
                onPressed: () async => onAcknowledge(),
                icon: const Icon(Icons.visibility),
                label: const Text('Acknowledge'),
              ),
            if (onRoute != null)
              FilledButton.icon(
                onPressed: onRoute,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Open fix'),
              ),
          ],
        ),
      ],
    ),
  );
}

String _statusLabel(InstitutionHealthStatus value) => switch (value) {
  InstitutionHealthStatus.excellent => 'Excellent',
  InstitutionHealthStatus.good => 'Good',
  InstitutionHealthStatus.needsAttention => 'Needs attention',
  InstitutionHealthStatus.atRisk => 'At risk',
  InstitutionHealthStatus.critical => 'Critical',
  InstitutionHealthStatus.unknown => 'Unknown',
};
Color _statusColor(ColorScheme scheme, InstitutionHealthStatus value) =>
    switch (value) {
      InstitutionHealthStatus.excellent ||
      InstitutionHealthStatus.good => scheme.primary,
      InstitutionHealthStatus.needsAttention => Colors.orange,
      InstitutionHealthStatus.atRisk ||
      InstitutionHealthStatus.critical => scheme.error,
      InstitutionHealthStatus.unknown => scheme.outline,
    };
Color _severityColor(ColorScheme scheme, HealthSeverity value) =>
    switch (value) {
      HealthSeverity.critical || HealthSeverity.high => scheme.error,
      HealthSeverity.medium => Colors.orange,
      HealthSeverity.low => scheme.primary,
      HealthSeverity.informational => scheme.outline,
    };
IconData _statusIcon(HealthCheckStatus value) => switch (value) {
  HealthCheckStatus.passed => Icons.check_circle_outline,
  HealthCheckStatus.warning ||
  HealthCheckStatus.stale => Icons.warning_amber_outlined,
  HealthCheckStatus.failed => Icons.error_outline,
  _ => Icons.help_outline,
};
