import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_dashboard_stats.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Academic Alerts — the full list of [AcademicAlert]s surfaced on the
/// dashboard, with a client-side severity filter.
class AcademicAlertsScreen extends StatefulWidget {
  const AcademicAlertsScreen({super.key});

  @override
  State<AcademicAlertsScreen> createState() => _AcademicAlertsScreenState();
}

class _AcademicAlertsScreenState extends State<AcademicAlertsScreen> {
  AlertSeverity? _filter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(AcademicDashboardRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surface(context),
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
    final alerts = _filter == null
        ? allAlerts
        : allAlerts.where((a) => a.severity == _filter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.l,
            AppSpacing.xl,
            AppSpacing.m,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(context, null, 'All'),
                const SizedBox(width: AppSpacing.m),
                _filterChip(context, AlertSeverity.critical, 'Critical'),
                const SizedBox(width: AppSpacing.m),
                _filterChip(context, AlertSeverity.high, 'High'),
                const SizedBox(width: AppSpacing.m),
                _filterChip(context, AlertSeverity.medium, 'Medium'),
                const SizedBox(width: AppSpacing.m),
                _filterChip(context, AlertSeverity.low, 'Low'),
              ],
            ),
          ),
        ),
        Expanded(
          child: alerts.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'No alerts',
                  message: 'Nothing matches this filter right now.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return AlertBanner(
                      title: alert.title,
                      message:
                          '${alert.message}  •  ${_formatTime(alert.timestamp)}',
                      color: _severityColor(context, alert.severity),
                      icon: Icons.warning_amber,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(
    BuildContext context,
    AlertSeverity? severity,
    String label,
  ) {
    final selected = _filter == severity;
    final color = severity == null
        ? AppColors.primary(context)
        : _severityColor(context, severity);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = severity),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected ? color : AppColors.textSecondary(context),
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? color : AppColors.border(context)),
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

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, "0")}';
  }
}
