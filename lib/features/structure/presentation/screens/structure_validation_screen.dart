import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../../domain/services/structure_validation_service.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

/// Cross-entity consistency checks across Structure's own configuration -
/// orphaned streams, classes without a level, overlapping grade bands,
/// terms outside their academic year's range. Distinct from per-record
/// dependency checks shown before archive/delete.
class StructureValidationScreen extends StatelessWidget {
  const StructureValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Structure Validation'),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final issues = StructureValidationService().validate(state);
          if (issues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 72,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Issues Found',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your Structure configuration is internally consistent.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.l),
            itemCount: issues.length,
            itemBuilder: (context, index) =>
                _ValidationIssueCard(issue: issues[index]),
          );
        },
      ),
    );
  }
}

class _ValidationIssueCard extends StatelessWidget {
  final StructureValidationIssue issue;
  const _ValidationIssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final isError = issue.severity == ValidationSeverity.error;
    final color = isError ? Colors.redAccent : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.warning_amber_outlined,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.category,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issue.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (issue.fixRoute != null)
            TextButton(
              onPressed: () => context.push(issue.fixRoute!),
              child: const Text('Fix'),
            ),
        ],
      ),
    );
  }
}
