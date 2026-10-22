import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/custom_domain_service.dart';

import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';

/// SaaS Owner-only Custom Domains console.
///
/// Surfaces every `portal_domain_requests` document with its verification
/// state. Schools submit a request through `requestCustomPortalDomain`
/// (School Admin only); the owner rechecks DNS, activates once verified, or
/// rejects/removes - each via an owner-only callable that also writes a
/// `super_admin_audit_logs` entry. Nothing here is available to a school
/// role.
class CustomDomainsScreen extends StatefulWidget {
  const CustomDomainsScreen({super.key, this.service});

  /// Injectable for tests; production uses the default [CustomDomainService].
  final CustomDomainService? service;

  @override
  State<CustomDomainsScreen> createState() => _CustomDomainsScreenState();
}

class _CustomDomainsScreenState extends State<CustomDomainsScreen> {
  late final CustomDomainService _service =
      widget.service ?? CustomDomainService();
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
      return 'Only the seeded School Pulse SaaS Owner can manage custom domains.';
    }
    if (value.contains('failed-precondition')) {
      return 'DNS is not pointing at the required target yet. Ask the school '
          'to update their CNAME, then recheck.';
    }
    if (value.contains('not-found')) {
      return 'That domain request no longer exists.';
    }
    return friendlyErrorMessage(error);
  }

  Future<void> _reject(CustomDomainRequest request) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          request.isActive ? 'Remove this domain?' : 'Reject this request?',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              request.isActive
                  ? '"${request.hostname}" will be deactivated, its public '
                        'projection removed, and it will be dropped from the '
                        "school's custom domains."
                  : '"${request.hostname}" will be marked rejected and will no '
                        'longer appear as actionable.',
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
            child: Text(request.isActive ? 'Remove' : 'Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(
        () => _service.reject(request.hostname, controller.text),
        request.isActive ? 'Domain removed' : 'Request rejected',
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
        title: const Text('Custom Domains'),
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
          return StreamBuilder<List<CustomDomainRequest>>(
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
              final requests = [...(snapshot.data ?? const <CustomDomainRequest>[])]
                ..sort((a, b) => a.hostname.compareTo(b.hostname));
              if (requests.isEmpty) {
                return const EmptyState(
                  icon: Icons.dns_outlined,
                  title: 'No custom domain requests',
                  message:
                      'When a school requests a custom portal hostname it '
                      'will appear here for verification and activation.',
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
                      child: _DomainCard(
                        request: request,
                        schoolName: _schoolName(adminState, request.schoolId),
                        lastChecked: request.checkedAt == null
                            ? null
                            : _dateTime.format(request.checkedAt!),
                        busy: _busy,
                        onRecheck: () => _run(
                          () => _service.recheck(request.hostname),
                          'Recheck complete',
                        ),
                        onActivate: request.canActivate
                            ? () => _run(
                                () => _service.activate(request.hostname),
                                'Domain activated',
                              )
                            : null,
                        onReject: () => _reject(request),
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

class _DomainCard extends StatelessWidget {
  const _DomainCard({
    required this.request,
    required this.schoolName,
    required this.lastChecked,
    required this.busy,
    required this.onRecheck,
    required this.onActivate,
    required this.onReject,
  });

  final CustomDomainRequest request;
  final String schoolName;
  final String? lastChecked;
  final bool busy;
  final VoidCallback onRecheck;
  final VoidCallback? onActivate;
  final VoidCallback onReject;

  (String, Color) _chip(BuildContext context) {
    switch (request.status) {
      case 'active':
        return ('Active', AppColors.success(context));
      case 'verified':
        return ('Verified', AppColors.information(context));
      case 'verification_failed':
        return ('Failed', AppColors.danger(context));
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
                  request.hostname,
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
          _kv(context, 'Verification', 'CNAME → ${request.cnameTarget}'),
          if (lastChecked != null) _kv(context, 'Last checked', lastChecked!),
          if (request.isFailed && request.lastError != null)
            _kv(context, 'Failure', request.lastError!),
          if (request.isRejected && request.rejectionReason != null)
            _kv(context, 'Reason', request.rejectionReason!),
          const SizedBox(height: AppSpacing.m),
          if (!request.isRejected)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onRecheck,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Recheck'),
                ),
                if (onActivate != null)
                  FilledButton.icon(
                    onPressed: busy ? null : onActivate,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Activate'),
                  ),
                TextButton.icon(
                  onPressed: busy ? null : onReject,
                  icon: Icon(
                    request.isActive
                        ? Icons.link_off_rounded
                        : Icons.block_rounded,
                    size: 18,
                    color: AppColors.danger(context),
                  ),
                  label: Text(
                    request.isActive ? 'Remove' : 'Reject',
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
          Expanded(
            child: Text(v, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}
