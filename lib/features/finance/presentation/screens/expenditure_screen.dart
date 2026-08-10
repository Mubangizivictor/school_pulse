import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../../domain/entities/expenditure.dart';

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  @override
  void initState() {
    super.initState();
    _loadExpenditures();
  }

  void _loadExpenditures() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadExpenditureRequests(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenditure Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRequestForm(context),
          ),
        ],
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state is FinanceLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is ExpendituresLoaded) {
            if (state.requests.isEmpty) {
              return const EmptyState(
                icon: Icons.outbond_outlined,
                title: 'No expenditure requests',
                message: 'Requests for funds will appear here',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadExpenditures(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return _buildExpenditureItem(context, request);
                },
              ),
            );
          }

          if (state is FinanceError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildExpenditureItem(
    BuildContext context,
    ExpenditureRequest request,
  ) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    Color statusColor;
    switch (request.status) {
      case ExpenditureStatus.approved:
        statusColor = semanticColors.success;
        break;
      case ExpenditureStatus.rejected:
        statusColor = semanticColors.error;
        break;
      case ExpenditureStatus.pending:
        statusColor = Colors.orange;
        break;
      case ExpenditureStatus.released:
        statusColor = semanticColors.info;
        break;
      case ExpenditureStatus.reviewed:
        statusColor = Colors.blue;
        break;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showRequestDetails(context, request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(label: request.status.name, color: statusColor),
              Text(
                CurrencyFormatter.ugx(request.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Requested by: ${request.requesterName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(request.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              if (request.status == ExpenditureStatus.pending)
                TextButton(
                  onPressed: () => _showApprovalDialog(context, request),
                  child: const Text('Action'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRequestForm(BuildContext context) {
    // Show form to submit new expenditure request
  }

  void _showRequestDetails(BuildContext context, ExpenditureRequest request) {
    // Show detailed view of the request and approval history
  }

  void _showApprovalDialog(BuildContext context, ExpenditureRequest request) {
    // Show dialog to approve or reject request
  }
}
