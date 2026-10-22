import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/offline_operation.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_sync_service.dart';
import 'package:school_pulse/injection_container.dart' as di;

class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen({super.key});

  @override
  State<OfflineDataScreen> createState() => _OfflineDataScreenState();
}

class _OfflineDataScreenState extends State<OfflineDataScreen> {
  final _syncService = di.sl<SubjectSyncService>();
  final _networkInfo = di.sl<NetworkInfo>();

  List<OfflineOperation> _pending = const [];
  bool _loading = true;
  bool _syncing = false;
  bool _isOnline = true;
  SyncResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _schoolId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.schoolId : null;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final online = await _networkInfo.isConnected;
    final pending = await _syncService.pending(schoolId: _schoolId);
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _pending = pending;
      _loading = false;
    });
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    final result = await _syncService.drain(schoolId: _schoolId);
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _lastResult = result;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final failed = _pending
        .where((o) => o.status == OfflineSyncStatus.failed)
        .length;
    final waiting = _pending.length - failed;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Offline Data')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        Icon(
                          _isOnline
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          color: _isOnline
                              ? AppColors.successGreen
                              : AppColors.black,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isOnline ? 'Connected' : 'Offline',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _statRow(context, 'Waiting to sync', '$waiting'),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _statRow(context, 'Failed', '$failed'),
                      ],
                    ),
                  ),
                  if (_lastResult != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Last sync: ${_lastResult!.synced} synced, '
                      '${_lastResult!.failed} failed, '
                      '${_lastResult!.conflicted} conflicted.',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Sync Now',
                    icon: Icons.sync,
                    isLoading: _syncing,
                    onPressed: _isOnline && _pending.isNotEmpty
                        ? _syncNow
                        : null,
                  ),
                  if (_pending.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Pending items',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_pending.map(
                      (op) => AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              op.status == OfflineSyncStatus.failed
                                  ? Icons.error_outline
                                  : Icons.schedule,
                              size: 18,
                              color: op.status == OfflineSyncStatus.failed
                                  ? AppColors.black
                                  : AppColors.textMuted(context),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    op.entityType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (op.lastError != null)
                                    Text(
                                      op.lastError!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'All synced',
                        message: 'Nothing waiting to sync on this device.',
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
