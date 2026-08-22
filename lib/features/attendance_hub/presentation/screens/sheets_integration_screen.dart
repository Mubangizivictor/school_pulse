import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/sheets_integration.dart';
import '../../domain/repositories/sheets_integration_repository.dart';

class SheetsIntegrationScreen extends StatefulWidget {
  const SheetsIntegrationScreen({super.key});

  @override
  State<SheetsIntegrationScreen> createState() =>
      _SheetsIntegrationScreenState();
}

class _SheetsIntegrationScreenState extends State<SheetsIntegrationScreen> {
  final _repo = di.sl<SheetsIntegrationRepository>();
  SheetsIntegration _integration = const SheetsIntegration();
  List<SheetsSyncLogEntry> _log = [];
  bool _loading = true;
  bool _syncing = false;
  bool _resyncing = false;
  bool _connecting = false;
  Timer? _connectPollTimer;

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _connectPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final integrationResult = await _repo.getIntegration(_schoolId);
    final logResult = await _repo.getSyncLog(_schoolId);
    if (!mounted) return;
    setState(() {
      _integration = integrationResult.fold(
        (f) => const SheetsIntegration(),
        (i) => i,
      );
      _log = logResult.fold((f) => [], (l) => l);
      _loading = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final result = await _repo.startConnect(_schoolId);
    await result.fold(
      (failure) async {
        setState(() => _connecting = false);
        _showMessage(failure.message);
      },
      (authUrl) async {
        final launched = await launchUrl(
          Uri.parse(authUrl),
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          setState(() => _connecting = false);
          _showMessage('Could not open the browser to connect Google Sheets.');
          return;
        }
        _pollForConnection();
      },
    );
  }

  /// The OAuth handshake finishes in a browser tab, out-of-band from this
  /// screen, so completion is detected by polling getIntegration until it
  /// reports linked, rather than a deep-link back into the app.
  void _pollForConnection() {
    var elapsedSeconds = 0;
    const pollInterval = Duration(seconds: 2);
    const timeout = Duration(seconds: 60);
    _connectPollTimer?.cancel();
    _connectPollTimer = Timer.periodic(pollInterval, (timer) async {
      elapsedSeconds += pollInterval.inSeconds;
      final result = await _repo.getIntegration(_schoolId);
      final integration = result.fold((f) => null, (i) => i);
      if (integration != null && integration.linked) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _integration = integration;
          _connecting = false;
        });
        _load();
        return;
      }
      if (elapsedSeconds >= timeout.inSeconds) {
        timer.cancel();
        if (!mounted) return;
        setState(() => _connecting = false);
        _showMessage(
          'Still waiting for Google sign-in. Finish connecting in the browser, then reopen this screen.',
        );
      }
    });
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disconnect Google Sheets'),
        content: const Text(
          'School Pulse will stop exporting attendance to this spreadsheet. '
          'Existing attendance records and the spreadsheet itself are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger(dialogContext),
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await _repo.disconnect(_schoolId);
    await _load();
    if (!mounted) return;
    result.fold(
      (failure) => _showMessage(failure.message),
      (_) => _showMessage('Google Sheets disconnected'),
    );
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    final result = await _repo.triggerSync(_schoolId, 0);
    await _load();
    if (!mounted) return;
    setState(() => _syncing = false);
    result.fold(
      (failure) => _showMessage(failure.message),
      (_) => _showMessage('Synced to Google Sheets'),
    );
  }

  Future<void> _resync() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resync Attendance'),
        content: const Text(
          'Rebuilds the last 90 days of attendance in Google Sheets from '
          'School Pulse. Records already in the sheet are left as-is - this '
          'only fills in anything missing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Resync'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _resyncing = true);
    final result = await _repo.resync(_schoolId);
    await _load();
    if (!mounted) return;
    setState(() => _resyncing = false);
    result.fold(
      (failure) => _showMessage(failure.message),
      (r) => _showMessage(
        'Exported ${r.recordsExported} records (${r.recordsSkippedAlreadyExported} already synced)',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsReauth =
        _integration.connectionStatus == SheetsConnectionStatus.needsAttention;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Google Sheets Integration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: SchoolPulseLoader())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                if (needsReauth) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.warning(context).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning(
                          context,
                        ).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning(context),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        const Expanded(
                          child: Text(
                            'Google Sheets connection needs to be renewed.',
                          ),
                        ),
                        TextButton(
                          onPressed: _connecting ? null : _connect,
                          child: const Text('Reconnect'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _integration.linked
                                  ? Icons.check_circle
                                  : Icons.link_off,
                              color: _integration.linked
                                  ? AppColors.success(context)
                                  : AppColors.textMuted(context),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Text(
                              _integration.linked
                                  ? 'Connected'
                                  : 'Not Connected',
                            ),
                          ],
                        ),
                        if (_integration.linked) ...[
                          const SizedBox(height: AppSpacing.m),
                          if (_integration
                              .connectedAccountEmail
                              .isNotEmpty) ...[
                            Text(
                              'Connected Account',
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                                fontSize: 12,
                              ),
                            ),
                            Text(_integration.connectedAccountEmail),
                            const SizedBox(height: AppSpacing.s),
                          ],
                          Text(
                            'Spreadsheet',
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                          Text(_integration.spreadsheetName),
                          if (_integration.lastSyncAt != null) ...[
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              'Last Synced',
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                                fontSize: 12,
                              ),
                            ),
                            Text(_integration.lastSyncAt.toString()),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_integration.linked) ...[
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Auto Sync'),
                          subtitle: const Text(
                            'Automatically sync after marking attendance',
                          ),
                          value: _integration.autoSync,
                          onChanged: (v) async {
                            await _repo.updateAutoSync(_schoolId, v);
                            await _load();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _syncing ? null : _syncNow,
                      child: _syncing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sync Now'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resyncing ? null : _resync,
                      child: _resyncing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Resync Attendance'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _disconnect,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger(context),
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Sync History',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ..._log.map(
                    (entry) => Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: ListTile(
                        leading: Icon(
                          entry.success ? Icons.check_circle : Icons.error,
                          color: entry.success
                              ? AppColors.success(context)
                              : AppColors.danger(context),
                        ),
                        title: Text(
                          entry.success
                              ? 'Success · ${entry.recordCount} records'
                              : 'Failed',
                        ),
                        subtitle: Text(entry.startedAt.toString()),
                      ),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _connecting ? null : _connect,
                      child: _connecting
                          ? const Text('Waiting for Google sign-in…')
                          : const Text('Connect Google Sheets'),
                    ),
                  ),
              ],
            ),
    );
  }
}
