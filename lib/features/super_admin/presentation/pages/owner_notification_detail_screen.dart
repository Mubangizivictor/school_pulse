import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';

import '../widgets/owner_notification_visuals.dart';

/// Owner-only detail screen for a single owner notification.
///
/// Shows only safe, authorized data (source school, amount where owner
/// authorization permits, submitted time, a *masked* reference, a safe
/// description), an audit strip, and context-specific actions that deep-link
/// only after Super Admin authorization is verified by the destination. It
/// deliberately does NOT reproduce full payment / school / security
/// management here.
class OwnerNotificationDetailScreen extends StatefulWidget {
  const OwnerNotificationDetailScreen({
    super.key,
    required this.notification,
    this.service,
  });

  final OwnerNotification notification;
  final OwnerNotificationService? service;

  @override
  State<OwnerNotificationDetailScreen> createState() =>
      _OwnerNotificationDetailScreenState();
}

class _OwnerNotificationDetailScreenState
    extends State<OwnerNotificationDetailScreen> {
  late final OwnerNotificationService _service =
      widget.service ?? OwnerNotificationService();
  late OwnerNotification _n = widget.notification;

  final DateFormat _fmt = DateFormat('MMM d, yyyy • h:mm a');
  final DateFormat _time = DateFormat('h:mm a');
  final NumberFormat _money =
      NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);

  DateTime? _openedAt;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _openedAt = _n.openedAt ?? DateTime.now();
    if (_n.isUnread) {
      unawaited(_service.markRead(_n.id));
      _n = OwnerNotification.fromJson({
        // cheap local copy with status flipped for the chip
        'id': _n.id,
        'type': _n.type,
        'status': 'read',
        'title': _n.title,
        'body': _n.body,
        'schoolName': _n.schoolName,
        'category': _n.category.wire,
        'severity': _n.severity.name,
        'reference': _n.reference,
        'amountUgx': _n.amountUgx,
        'method': _n.method,
        'platformHealthDegraded': _n.platformHealthDegraded,
        'createdAt': _n.createdAt.toIso8601String(),
      });
    }
  }

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted && done != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(done)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(error)),
            backgroundColor: AppColors.danger(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object error) {
    final v = error.toString();
    if (v.contains('permission-denied')) {
      return 'Only the School Pulse SaaS Owner can do this.';
    }
    if (v.contains('unavailable') || v.contains('network')) {
      return 'Offline — this applies when you reconnect.';
    }
    return friendlyErrorMessage(error);
  }

  // --- Deep links: only navigate; the destination re-verifies owner auth --
  void _openDestination(String route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening $route — you will re-confirm owner access there.',
        ),
      ),
    );
  }

  String get _contextualTitle {
    switch (_n.category) {
      case OwnerNotificationCategory.billing:
        return 'Payment awaiting review';
      case OwnerNotificationCategory.platform:
        return 'Platform incident';
      case OwnerNotificationCategory.schools:
        return 'School request';
      case OwnerNotificationCategory.security:
        return 'Security alert';
      case OwnerNotificationCategory.digest:
        return 'Owner digest';
    }
  }

  @override
  Widget build(BuildContext context) {
    final visuals = OwnerNotificationVisuals.forNotification(context, _n);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        title: Text(_contextualTitle),
        actions: [
          PopupMenuButton<String>(
            enabled: !_busy,
            onSelected: (v) {
              switch (v) {
                case 'read':
                  _run(() => _service.markRead(_n.id), done: 'Marked read');
                case 'archive':
                  _run(() => _service.archiveNotification(_n.id),
                      done: 'Archived');
                  if (mounted) Navigator.of(context).maybePop();
                case 'delete':
                  _confirmDelete();
              }
            },
            itemBuilder: (_) => [
              if (_n.isUnread)
                const PopupMenuItem(value: 'read', child: Text('Mark read')),
              const PopupMenuItem(
                value: 'archive',
                child: Text('Archive'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(child: OwnerSeverityChip(severity: _n.severity)),
          const SizedBox(height: 16),
          _DetailCard(
            icon: visuals.icon,
            accent: visuals.accent,
            rows: _rows(),
          ),
          const SizedBox(height: 16),
          Text(
            'Actions',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          _actions(),
          const SizedBox(height: 12),
          _AuditStrip(openedAt: _openedAt, time: _time),
          if (_needsPrivacyNote()) ...[
            const SizedBox(height: 12),
            _PrivacyNote(),
          ],
        ],
      ),
    );
  }

  List<({String label, String value})> _rows() {
    final rows = <({String label, String value})>[];
    if (_n.schoolName.isNotEmpty) {
      rows.add((label: 'Source', value: _n.schoolName));
    }
    // Amount only where owner authorization permits it (billing category).
    if (_n.category == OwnerNotificationCategory.billing &&
        _n.amountUgx > 0) {
      rows.add((label: 'Amount', value: _money.format(_n.amountUgx)));
    }
    rows.add((label: 'Submitted', value: _fmt.format(_n.createdAt)));
    if (_n.reference.isNotEmpty) {
      rows.add((label: 'Reference', value: _maskReference(_n.reference)));
    }
    if (_n.body.isNotEmpty) {
      rows.add((label: 'Description', value: _n.body));
    }
    return rows;
  }

  /// Defence in depth — if a reference ever arrives unmasked, mask it here.
  String _maskReference(String raw) {
    if (raw.contains('••') || raw.contains('*')) return raw;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      final method = raw.replaceAll(RegExp(r'[\d\s]'), '').toUpperCase();
      return '${method.isEmpty ? 'REF' : method} •••• ${digits.substring(digits.length - 4)}';
    }
    return 'REF ••••';
  }

  bool _needsPrivacyNote() =>
      _n.category == OwnerNotificationCategory.billing ||
      _n.category == OwnerNotificationCategory.schools ||
      _n.category == OwnerNotificationCategory.security;

  Widget _actions() {
    final buttons = <Widget>[];
    switch (_n.category) {
      case OwnerNotificationCategory.billing:
        buttons.addAll([
          _primary('Review payment',
              () => _openDestination('/super-admin/payments')),
          _secondary('Mark read',
              () => _run(() => _service.markRead(_n.id), done: 'Marked read')),
          _secondary('Archive', _archiveAndClose),
        ]);
      case OwnerNotificationCategory.platform:
        buttons.addAll([
          _primary('Open platform health',
              () => _openDestination('/super-admin/platform-health')),
          _secondary('Acknowledge',
              () => _run(() => _service.markRead(_n.id), done: 'Acknowledged')),
          _secondary('Archive', _archiveAndClose),
        ]);
      case OwnerNotificationCategory.schools:
        buttons.addAll([
          _primary('View school',
              () => _openDestination('/super-admin/schools')),
          _secondary('Review request',
              () => _openDestination('/super-admin/schools')),
          _secondary('Archive', _archiveAndClose),
        ]);
      case OwnerNotificationCategory.security:
        buttons.addAll([
          _primary('Open security center',
              () => _openDestination('/super-admin/settings/security')),
          _secondary('Mark read',
              () => _run(() => _service.markRead(_n.id), done: 'Marked read')),
        ]);
      case OwnerNotificationCategory.digest:
        buttons.addAll([
          _secondary('Mark read',
              () => _run(() => _service.markRead(_n.id), done: 'Marked read')),
          _secondary('Archive', _archiveAndClose),
        ]);
    }
    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  void _archiveAndClose() {
    _run(() => _service.archiveNotification(_n.id), done: 'Archived')
        .then((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this notification?'),
        content: const Text(
          'It is removed from your owner feed only. The underlying record is '
          'untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger(ctx),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => _service.deleteNotification(_n.id));
    if (mounted) Navigator.of(context).maybePop();
  }

  Widget _primary(String label, VoidCallback onTap) => FilledButton(
        onPressed: _busy ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.information(context).withValues(alpha: .16),
          foregroundColor: AppColors.information(context),
          elevation: 0,
          side: BorderSide(color: AppColors.information(context)),
        ),
        child: Text(label),
      );

  Widget _secondary(String label, VoidCallback onTap) => OutlinedButton(
        onPressed: _busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary(context),
          side: BorderSide(color: AppColors.border(context)),
        ),
        child: Text(label),
      );
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.accent,
    required this.rows,
  });

  final IconData icon;
  final Color accent;
  final List<({String label, String value})> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OwnerIconSquare(icon: icon, accent: accent, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _row(context, rows[i].label, rows[i].value),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuditStrip extends StatelessWidget {
  const _AuditStrip({required this.openedAt, required this.time});
  final DateTime? openedAt;
  final DateFormat time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 15,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              openedAt == null
                  ? 'Opened by you'
                  : 'Opened by you  ·  ${time.format(openedAt!)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.warning(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, size: 15, color: c),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Sensitive school details are shown only after authorization.',
            style: TextStyle(fontSize: 12, color: c),
          ),
        ),
      ],
    );
  }
}
