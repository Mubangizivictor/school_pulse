import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/portal_subdomain_change_service.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';

/// SaaS Owner-only review console for platform subdomain change requests.
///
/// Distinct from CustomDomainsScreen: that screen reviews a school bringing
/// an external vanity domain; this one reviews a school asking to change its
/// own `<slug>.schoolpulseapp.com` subdomain. Surfaces every
/// `portal_subdomain_change_requests` document; approve/reject each go
/// through an owner-only callable that also writes a
/// `super_admin_audit_logs` entry.
class SubdomainChangeRequestsScreen extends StatefulWidget {
  const SubdomainChangeRequestsScreen({super.key, this.service});

  /// Injectable for tests; production uses the default
  /// [PortalSubdomainChangeService].
  final PortalSubdomainChangeService? service;

  @override
  State<SubdomainChangeRequestsScreen> createState() =>
      _SubdomainChangeRequestsScreenState();
}

class _SubdomainChangeRequestsScreenState
    extends State<SubdomainChangeRequestsScreen> {
  late final PortalSubdomainChangeService _service =
      widget.service ?? PortalSubdomainChangeService();
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');
  bool _busy = false;

  String _schoolName(SuperAdminState state, String schoolId) {
    for (final s in state.schools) {
      if (s.id == schoolId) return s.name;
    }
    return schoolId.isEmpty ? 'Unknown school' : schoolId;
  }

  Future<void> _run(Future<void> Function() action, String okMessage) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(okMessage)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(error)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object error) {
    final value = error.toString();
    if (value.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can review subdomain '
          'change requests.';
    }
    if (value.contains('already-exists')) {
      return 'That subdomain was claimed by another school in the meantime.';
    }
    if (value.contains('not-found')) {
      return 'That request no longer exists.';
    }
    if (value.contains('failed-precondition')) {
      return 'This request has already been reviewed.';
    }
    return friendlyErrorMessage(error);
  }

  Future<void> _reject(PortalSubdomainChangeRequest request) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject this request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The school will keep its current subdomain '
              '(${request.currentSlug ?? '—'}) and this request will be '
              'marked rejected.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(
        () => _service.reject(request.schoolId, controller.text),
        'Request rejected',
      );
    }
  }

  Future<void> _approve(PortalSubdomainChangeRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve this subdomain change?'),
        content: Text(
          'The school will move from '
          '${request.currentSlug ?? '—'}.schoolpulseapp.com to '
          '${request.requestedSlug}.schoolpulseapp.com immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(
        () => _service.approve(request.schoolId),
        'Subdomain change approved',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (context.read<SuperAdminBloc>().state.schools.isEmpty) {
      context.read<SuperAdminBloc>().add(LoadSuperAdminDashboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subdomain Change Requests'),
        leading: const BackButton(),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, adminState) {
          return StreamBuilder<List<PortalSubdomainChangeRequest>>(
            stream: _service.watchRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: SchoolPulseLoader());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      _friendlyError(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final requests = [
                ...(snapshot.data ?? const <PortalSubdomainChangeRequest>[]),
              ]..sort((a, b) => a.requestedSlug.compareTo(b.requestedSlug));
              if (requests.isEmpty) {
                return const EmptyState(
                  icon: Icons.alternate_email_rounded,
                  title: 'No subdomain change requests',
                  message:
                      'When a school asks to change its '
                      '.schoolpulseapp.com subdomain it will appear here '
                      'for review.',
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.l,
                  AppSpacing.xl,
                  AppSpacing.x3l,
                ),
                children: [
                  for (final request in requests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RequestCard(
                        request: request,
                        schoolName: _schoolName(adminState, request.schoolId),
                        requestedAt: request.requestedAt == null
                            ? null
                            : _dateTime.format(request.requestedAt!),
                        busy: _busy,
                        onApprove: request.isPending
                            ? () => _approve(request)
                            : null,
                        onReject: request.isPending
                            ? () => _reject(request)
                            : null,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.schoolName,
    required this.requestedAt,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final PortalSubdomainChangeRequest request;
  final String schoolName;
  final String? requestedAt;
  final bool busy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  (String, Color) _chip(BuildContext context) {
    switch (request.status) {
      case 'approved':
        return ('Approved', AppColors.success(context));
      case 'rejected':
        return ('Rejected', AppColors.textSecondary(context));
      default:
        return ('Pending', AppColors.warning(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (chipLabel, chipColor) = _chip(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.requestedSlug}.schoolpulseapp.com',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              StatusBadge(label: chipLabel, color: chipColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            schoolName,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _kv(
            context,
            'Current',
            request.currentSlug == null
                ? '—'
                : '${request.currentSlug}.schoolpulseapp.com',
          ),
          if (requestedAt != null) _kv(context, 'Requested', requestedAt!),
          if (request.isRejected && request.rejectionReason != null)
            _kv(context, 'Reason', request.rejectionReason!),
          const SizedBox(height: AppSpacing.m),
          if (request.isPending)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Approve'),
                ),
                TextButton.icon(
                  onPressed: busy ? null : onReject,
                  icon: Icon(
                    Icons.block_rounded,
                    size: 18,
                    color: AppColors.danger(context),
                  ),
                  label: Text(
                    'Reject',
                    style: TextStyle(color: AppColors.danger(context)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Text(v, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
