import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_dashboard_stats.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

enum _AlertFilter { all, critical, attention }

/// Academic Alerts — the full list of [AcademicAlert]s surfaced on the
/// dashboard, with an All/Critical/Attention filter.
class AcademicAlertsScreen extends StatefulWidget {
  const AcademicAlertsScreen({super.key});

  @override
  State<AcademicAlertsScreen> createState() => _AcademicAlertsScreenState();
}

class _AcademicAlertsScreenState extends State<AcademicAlertsScreen> {
  _AlertFilter _filter = _AlertFilter.all;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(AcademicDashboardRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainer(context),
          title: Text('Academic Alerts', style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is AcademicDashboardLoaded) {
              return _buildContent(context, state.stats.activeAlerts);
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load alerts',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<AcademicAlert> allAlerts) {
    final criticalCount = allAlerts
        .where((a) => a.severity == AlertSeverity.critical)
        .length;
    final attentionCount = allAlerts
        .where((a) => a.severity != AlertSeverity.critical)
        .length;
    final alerts = switch (_filter) {
      _AlertFilter.all => allAlerts,
      _AlertFilter.critical =>
        allAlerts.where((a) => a.severity == AlertSeverity.critical).toList(),
      _AlertFilter.attention =>
        allAlerts.where((a) => a.severity != AlertSeverity.critical).toList(),
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.l,
            AppSpacing.xl,
            AppSpacing.m,
          ),
          child: SegmentedButton<_AlertFilter>(
            segments: [
              const ButtonSegment(value: _AlertFilter.all, label: Text('All')),
              ButtonSegment(
                value: _AlertFilter.critical,
                label: Text('Critical ($criticalCount)'),
              ),
              ButtonSegment(
                value: _AlertFilter.attention,
                label: Text('Attention ($attentionCount)'),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) =>
                setState(() => _filter = selection.first),
          ),
        ),
        Expanded(
          child: alerts.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'No alerts',
                  message: 'Nothing matches this filter right now.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  itemCount: alerts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.l),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return _AlertCard(
                      alert: alert,
                      color: _severityColor(context, alert.severity),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _severityColor(BuildContext context, AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.danger(context);
      case AlertSeverity.high:
        return AppColors.warning(context);
      case AlertSeverity.medium:
        return AppColors.information(context);
      case AlertSeverity.low:
        return AppColors.textMuted(context);
    }
  }
}

class _AlertCard extends StatelessWidget {
  final AcademicAlert alert;
  final Color color;

  const _AlertCard({required this.alert, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.large,
      onTap: () => showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(alert.title),
          content: Text(alert.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.large,
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber, color: color, size: 22),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    alert.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Tap to view',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
