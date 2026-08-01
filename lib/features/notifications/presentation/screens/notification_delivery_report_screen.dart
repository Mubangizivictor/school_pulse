import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Delivery outcomes for notifications this user sent.
///
/// Deliberately scoped to the caller's own sends: the spec rules out exposing
/// personal behaviour analytics to staff who have no reason to see them, and
/// the security rules only permit reading requests where senderId is the
/// caller. This screen therefore answers "did what I sent arrive?", not "what
/// is everyone reading?".
class NotificationDeliveryReportScreen extends StatelessWidget {
  const NotificationDeliveryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    if (user == null) {
      return const _ReportScaffold(
        child: Center(
          child: Text(
            'Sign in to view delivery reports',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final granted = RolePermissionDefaults.permissionsFor(user.roles);
    if (!granted.contains(Permission.notificationViewDeliveryReports)) {
      return const _ReportScaffold(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'You do not have permission to view delivery reports.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return _ReportScaffold(
      child: StreamBuilder<List<NotificationDeliveryReport>>(
        stream: di.sl<NotificationSendService>().watchMyRequests(
              schoolId: user.schoolId,
              senderId: user.id,
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Delivery reports could not be loaded right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          final reports = snapshot.data ?? const [];
          if (reports.isEmpty) {
            return const Center(
              child: Text(
                'You have not sent any notifications yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _SummaryCard(reports: reports);
              return _ReportTile(report: reports[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _ReportScaffold extends StatelessWidget {
  final Widget child;

  const _ReportScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Delivery Reports',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: child,
    );
  }
}

/// Totals across everything this sender has sent.
class _SummaryCard extends StatelessWidget {
  final List<NotificationDeliveryReport> reports;

  const _SummaryCard({required this.reports});

  @override
  Widget build(BuildContext context) {
    final sent = reports.where((r) => r.isSent).toList();
    final totalRecipients =
        sent.fold<int>(0, (sum, r) => sum + r.recipientCount);
    final totalSuccess = sent.fold<int>(0, (sum, r) => sum + r.successCount);
    final totalFailure = sent.fold<int>(0, (sum, r) => sum + r.failureCount);
    final scheduled = reports.where((r) => r.isScheduled).length;

    final totalDevices = totalSuccess + totalFailure;
    // Shown as "—" rather than 0% when nothing has been dispatched, so an
    // unsent queue does not read as a total delivery failure.
    final rate = totalDevices == 0
        ? '—'
        : '${((totalSuccess / totalDevices) * 100).round()}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your sends',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(label: 'Sent', value: '${sent.length}'),
              _Metric(label: 'Recipients', value: '$totalRecipients'),
              _Metric(label: 'Delivered', value: rate),
              if (scheduled > 0)
                _Metric(label: 'Scheduled', value: '$scheduled'),
            ],
          ),
          if (totalFailure > 0) ...[
            const SizedBox(height: 12),
            Text(
              '$totalFailure device(s) could not be reached. This is usually '
              'an app that was uninstalled or notifications turned off.',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final NotificationDeliveryReport report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _status(report);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _timestampLabel(report),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (report.isSent) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _Chip(
                  icon: Icons.group,
                  label: '${report.recipientCount} recipients',
                ),
                const SizedBox(width: 8),
                _Chip(
                  icon: Icons.phone_iphone,
                  label: '${report.successCount}/${report.deviceCount} devices',
                ),
              ],
            ),
          ],
          if (report.isFailed && report.error != null) ...[
            const SizedBox(height: 8),
            Text(
              report.error!,
              style: const TextStyle(color: Color(0xFFE11D48), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  static (Color, String) _status(NotificationDeliveryReport report) {
    if (report.isSent) return (const Color(0xFF10B981), 'Sent');
    if (report.isScheduled) return (const Color(0xFF3B82F6), 'Scheduled');
    if (report.isFailed) return (const Color(0xFFE11D48), 'Failed');
    if (report.isCancelled) return (const Color(0xFF94A3B8), 'Cancelled');
    return (const Color(0xFFF59E0B), 'Pending');
  }

  static String _timestampLabel(NotificationDeliveryReport report) {
    final format = DateFormat('dd MMM yyyy • h:mm a');
    if (report.isScheduled && report.scheduledAt != null) {
      return 'Scheduled for ${format.format(report.scheduledAt!)}';
    }
    final at = report.sentAt ?? report.createdAt;
    if (at == null) return 'Queued';
    return format.format(at);
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white54),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
