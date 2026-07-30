import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/medical_supply_request.dart';
import 'package:school_pulse/features/health/domain/usecases/health_usecases.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MedicalSupplyRequestsScreen extends StatefulWidget {
  const MedicalSupplyRequestsScreen({super.key});

  @override
  State<MedicalSupplyRequestsScreen> createState() =>
      _MedicalSupplyRequestsScreenState();
}

class _MedicalSupplyRequestsScreenState
    extends State<MedicalSupplyRequestsScreen> {
  late Future<List<MedicalSupplyRequest>> _requests;
  String? _error;
  final Set<String> _updatingRequestIds = {};

  String get _schoolId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    _requests = _load();
  }

  Future<List<MedicalSupplyRequest>> _load() async {
    final result = await di.sl<GetMedicalSupplyRequests>()(_schoolId);
    return result.fold(
      (failure) {
        _error = failure.message;
        return <MedicalSupplyRequest>[];
      },
      (requests) {
        _error = null;
        return requests;
      },
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _requests = _load();
    });
    await _requests;
  }

  Future<void> _changeStatus(
    MedicalSupplyRequest request,
    SupplyRequestStatus status, {
    String? rejectionReason,
  }) async {
    if (_updatingRequestIds.contains(request.id)) return;
    setState(() => _updatingRequestIds.add(request.id));
    final result = await di.sl<UpdateSupplyRequestStatus>()(
      request.id,
      _schoolId,
      status,
      rejectionReason: rejectionReason,
    );
    if (!mounted) return;
    final failure = result.fold((value) => value, (_) => null);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      );
      setState(() => _updatingRequestIds.remove(request.id));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Request marked ${status.name}.')));
    await _refresh();
    if (mounted) {
      setState(() => _updatingRequestIds.remove(request.id));
    }
  }

  Future<void> _rejectRequest(MedicalSupplyRequest request) async {
    final controller = TextEditingController();
    String? validationError;
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reject medical request?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Explain why Store cannot fulfil this request',
                ),
              ),
              if (validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  validationError!,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  setDialogState(
                    () => validationError = 'Enter a rejection reason.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Reject request'),
            ),
          ],
        ),
      ),
    );
    if (reason != null && mounted) {
      await _changeStatus(
        request,
        SupplyRequestStatus.rejected,
        rejectionReason: reason,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Medical Supply Requests')),
    body: FutureBuilder<List<MedicalSupplyRequest>>(
      future: _requests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
          return EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load requests',
            message: _error!,
            ctaLabel: 'Retry',
            onCtaPressed: _refresh,
          );
        }
        final requests = snapshot.data ?? const [];
        if (requests.isEmpty) {
          return const EmptyState(
            icon: Icons.medical_services_outlined,
            title: 'No medical requests',
            message: 'Requests submitted by the school nurse appear here.',
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final isUpdating = _updatingRequestIds.contains(request.id);
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: request.status.name.toUpperCase(),
                          color: _statusColor(request.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${request.quantity} ${request.unit}'),
                    Text(
                      'Requested ${DateFormatter.format(request.requestDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (request.rejectionReason?.trim().isNotEmpty == true)
                      Text(
                        'Reason: ${request.rejectionReason}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (isUpdating) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    if (_nextActions(request.status).isNotEmpty) ...[
                      const Divider(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _nextActions(request.status)
                            .map(
                              (status) => status == SupplyRequestStatus.rejected
                                  ? OutlinedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => _rejectRequest(request),
                                      child: const Text('Reject'),
                                    )
                                  : FilledButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () =>
                                                _changeStatus(request, status),
                                      child: Text(_actionLabel(status)),
                                    ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    ),
  );

  List<SupplyRequestStatus> _nextActions(SupplyRequestStatus status) {
    return switch (status) {
      SupplyRequestStatus.pending => [
        SupplyRequestStatus.rejected,
        SupplyRequestStatus.approved,
      ],
      SupplyRequestStatus.approved => [SupplyRequestStatus.purchased],
      SupplyRequestStatus.purchased => [SupplyRequestStatus.delivered],
      SupplyRequestStatus.delivered || SupplyRequestStatus.rejected => const [],
    };
  }

  String _actionLabel(SupplyRequestStatus status) => switch (status) {
    SupplyRequestStatus.approved => 'Approve',
    SupplyRequestStatus.purchased => 'Mark purchased',
    SupplyRequestStatus.delivered => 'Mark delivered',
    _ => status.name,
  };

  Color _statusColor(SupplyRequestStatus status) => switch (status) {
    SupplyRequestStatus.pending => Colors.orange,
    SupplyRequestStatus.approved => Colors.green,
    SupplyRequestStatus.purchased => Colors.blue,
    SupplyRequestStatus.delivered => Colors.teal,
    SupplyRequestStatus.rejected => Colors.red,
  };
}
