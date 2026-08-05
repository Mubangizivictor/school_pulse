import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../domain/services/structure_setup_progress_calculator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

/// Standalone completeness dashboard - one section per configurable area,
/// reading the same [StructureSetupProgressCalculator] the hub and setup
/// wizard use, so all three surfaces agree on what "configured" means.
class SetupProgressScreen extends StatelessWidget {
  const SetupProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Setup Progress',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final progress = StructureSetupProgressCalculator().calculate(state);
          return ListView(
            padding: EdgeInsets.all(AppSpacing.l),
            children: [
              _ProgressSummaryCard(progress: progress),
              const SizedBox(height: 20),
              ...progress.sections.map((s) => _SectionRow(section: s)),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final StructureSetupProgress progress;
  const _ProgressSummaryCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: progress.ratio,
                  strokeWidth: 5,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Text(
                '${progress.percentage}%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Structure Setup Progress',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.configuredCount} of ${progress.sections.length} sections configured - ${progress.pendingCount} pending.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final StructureProgressSection section;
  const _SectionRow({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            section.isConfigured
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: section.isConfigured
                ? Colors.green
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (section.isCore && !section.isConfigured)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(section.route),
            child: Text(section.isConfigured ? 'View' : 'Configure'),
          ),
        ],
      ),
    );
  }
}
