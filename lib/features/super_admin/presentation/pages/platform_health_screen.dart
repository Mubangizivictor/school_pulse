import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/platform_health/data/platform_health_repository.dart';
import 'package:school_pulse/features/platform_health/domain/platform_health_models.dart';
import 'package:school_pulse/features/super_admin/domain/entities/audit_log.dart';

/// Real Super-Admin-only platform health screen: reads the cached
/// platform_health/current aggregate (checkPlatformHealth Cloud Function)
/// via PlatformHealthRepository, matching billing_home_screen.dart's
/// visual system exactly (same style helpers, PulseCard sections,
/// _CompactEmpty pattern, _IconAction header buttons).
class PlatformHealthScreen extends StatefulWidget {
  const PlatformHealthScreen({super.key});

  @override
  State<PlatformHealthScreen> createState() => _PlatformHealthScreenState();
}

class _PlatformHealthScreenState extends State<PlatformHealthScreen> {
  final PlatformHealthRepository _repo = PlatformHealthRepository();
  bool _refreshing = false;
  String? _refreshError;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _refreshError = null;
    });
    try {
      await _repo.refresh();
    } catch (_) {
      if (mounted) {
        setState(
          () => _refreshError = 'Could not refresh platform health right now.',
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _acknowledge(String componentId) async {
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _AcknowledgeDialog(
        componentLabel: platformHealthComponentLabel(componentId),
      ),
    );
    if (note == null) return;
    try {
      await _repo.acknowledgeIncident(componentId, note: note);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Incident acknowledged.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not acknowledge this incident right now.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    body: SafeArea(
      bottom: false,
      child: StreamBuilder<PlatformHealthSummary?>(
        stream: _repo.watchCurrent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorCard(
              message: 'Could not load platform health.',
              onRetry: () => setState(() {}),
            );
          }
          final summary = snapshot.data;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context, summary),
                      const SizedBox(height: 14),
                      _summaryCard(context, summary),
                      if (_refreshError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _refreshError!,
                          style: _rowBody(
                            context,
                          ).copyWith(color: AppColors.danger(context)),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _componentsSection(context, summary),
                      const SizedBox(height: 14),
                      _attentionSection(context, summary),
                      const SizedBox(height: 14),
                      _historySection(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _header(BuildContext context, PlatformHealthSummary? summary) => Row(
    children: [
      _IconAction(
        icon: Icons.arrow_back_rounded,
        tooltip: 'Back',
        onTap: () => Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : context.go('/super-admin'),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform health', style: _pageTitle(context)),
            Text(
              summary?.checkedAt != null
                  ? 'Checked ${_relative(summary!.checkedAt!)}'
                  : 'Not checked yet',
              style: _rowBody(context),
            ),
          ],
        ),
      ),
      _IconAction(
        icon: Icons.refresh_rounded,
        tooltip: 'Refresh status',
        onTap: _refreshing ? null : _refresh,
        loading: _refreshing,
      ),
    ],
  );

  Widget _summaryCard(BuildContext context, PlatformHealthSummary? summary) {
    if (summary == null) {
      return PulseCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.textMuted(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Checking platform status…',
                style: _rowTitle(context),
              ),
            ),
          ],
        ),
      );
    }
    final color = _statusColor(context, summary.status);
    return PulseCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChipLabel(status: summary.status),
                const SizedBox(height: 2),
                Text(summary.summary, style: _rowBody(context)),
              ],
            ),
          ),
          TextButton(
            onPressed: _refreshing ? null : _refresh,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _refreshing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Refresh status'),
          ),
        ],
      ),
    );
  }

  Widget _componentsSection(
    BuildContext context,
    PlatformHealthSummary? summary,
  ) => _SectionCard(
    title: 'Components',
    child: summary == null || summary.components.isEmpty
        ? const _CompactEmpty('No component data yet.')
        : Column(
            children: [
              for (final (i, component) in summary.components.indexed) ...[
                if (i > 0) Divider(height: 1, color: AppColors.border(context)),
                _ComponentRow(component: component),
              ],
            ],
          ),
  );

  Widget _attentionSection(
    BuildContext context,
    PlatformHealthSummary? summary,
  ) {
    final attention = summary?.attentionComponents ?? const [];
    return _SectionCard(
      title: 'Attention',
      child: attention.isEmpty
          ? const _CompactEmpty('Nothing needs your attention right now.')
          : Column(
              children: [
                for (final (i, component) in attention.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: AppColors.border(context)),
                  _AttentionRow(
                    component: component,
                    onAcknowledge: () => _acknowledge(component.id),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _historySection(BuildContext context) => _SectionCard(
    title: 'History',
    child: StreamBuilder<List<AuditLog>>(
      stream: _repo.watchIncidentHistory(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const [];
        if (snapshot.connectionState == ConnectionState.waiting &&
            logs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (logs.isEmpty) {
          return const _CompactEmpty('No acknowledged incidents yet.');
        }
        return Column(
          children: [
            for (final (i, log) in logs.indexed) ...[
              if (i > 0) Divider(height: 1, color: AppColors.border(context)),
              _HistoryRow(log: log),
            ],
          ],
        );
      },
    ),
  );

  Color _statusColor(BuildContext context, PlatformHealthStatus status) =>
      switch (status) {
        PlatformHealthStatus.operational => AppColors.success(context),
        PlatformHealthStatus.degraded => AppColors.warning(context),
        PlatformHealthStatus.outage => AppColors.danger(context),
        PlatformHealthStatus.unknown => AppColors.textMuted(context),
        PlatformHealthStatus.notConfigured => AppColors.textMuted(context),
      };
}

class _StatusChipLabel extends StatelessWidget {
  const _StatusChipLabel({required this.status});
  final PlatformHealthStatus status;
  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      PlatformHealthStatus.operational => 'Platform healthy',
      PlatformHealthStatus.degraded => 'Attention needed',
      PlatformHealthStatus.outage => 'Outage',
      PlatformHealthStatus.unknown => 'Unknown',
      PlatformHealthStatus.notConfigured => 'Not configured',
    };
    return Text(label, style: _rowTitle(context));
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.component});
  final PlatformHealthComponent component;
  @override
  Widget build(BuildContext context) {
    final color = _dotColor(context, component.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platformHealthComponentLabel(component.id),
                  style: _rowTitle(context),
                ),
                const SizedBox(height: 2),
                Text(
                  component.message.isEmpty ? '—' : component.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _rowBody(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            component.checkedAt != null ? _relative(component.checkedAt!) : '—',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.component, required this.onAcknowledge});
  final PlatformHealthComponent component;
  final VoidCallback onAcknowledge;
  @override
  Widget build(BuildContext context) {
    final action = platformHealthRecommendedAction(component.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platformHealthComponentLabel(component.id),
                  style: _rowTitle(context),
                ),
                const SizedBox(height: 2),
                Text(component.message, style: _rowBody(context)),
                if (action != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    action,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.information(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAcknowledge,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.log});
  final AuditLog log;
  @override
  Widget build(BuildContext context) {
    final resolved = log.action == 'PLATFORM_HEALTH_INCIDENT_RESOLVED';
    final componentId = log.metadata['component'] as String?;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            resolved ? Icons.check_circle_outline_rounded : Icons.flag_outlined,
            size: 18,
            color: resolved
                ? AppColors.success(context)
                : AppColors.warning(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolved
                      ? '${componentId != null ? platformHealthComponentLabel(componentId) : 'Incident'} resolved'
                      : '${componentId != null ? platformHealthComponentLabel(componentId) : 'Incident'} acknowledged',
                  style: _rowTitle(context),
                ),
                if ((log.metadata['note'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    log.metadata['note'] as String,
                    style: _rowBody(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _relative(log.timestamp),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcknowledgeDialog extends StatefulWidget {
  const _AcknowledgeDialog({required this.componentLabel});
  final String componentLabel;
  @override
  State<_AcknowledgeDialog> createState() => _AcknowledgeDialogState();
}

class _AcknowledgeDialogState extends State<_AcknowledgeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Acknowledge ${widget.componentLabel}?'),
    content: TextField(
      controller: _controller,
      decoration: const InputDecoration(hintText: 'Optional note'),
      maxLength: 500,
      maxLines: 3,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Acknowledge'),
      ),
    ],
  );
}

Color _dotColor(BuildContext context, PlatformHealthStatus status) =>
    switch (status) {
      PlatformHealthStatus.operational => AppColors.success(context),
      PlatformHealthStatus.degraded => AppColors.warning(context),
      PlatformHealthStatus.outage => AppColors.danger(context),
      PlatformHealthStatus.unknown => AppColors.textMuted(context),
      PlatformHealthStatus.notConfigured => AppColors.textMuted(context),
    };

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool loading;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(9),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        ),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => PulseCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitle(context)),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 20,
          color: AppColors.textMuted(context),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: _rowBody(context))),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, color: AppColors.danger(context)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: _rowBody(context)),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

String _relative(DateTime value) {
  final d = DateTime.now().difference(value);
  if (d.inMinutes < 1) return 'now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

TextStyle _pageTitle(BuildContext c) => AppTypography.headlineMedium.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 24,
  fontWeight: FontWeight.w800,
);
TextStyle _sectionTitle(BuildContext c) => AppTypography.titleLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 17,
  fontWeight: FontWeight.w800,
);
TextStyle _rowTitle(BuildContext c) => AppTypography.labelLarge.copyWith(
  color: AppColors.textPrimary(c),
  fontWeight: FontWeight.w700,
  fontSize: 14,
);
TextStyle _rowBody(BuildContext c) => AppTypography.bodySmall.copyWith(
  color: AppColors.textSecondary(c),
  fontSize: 12.5,
);
