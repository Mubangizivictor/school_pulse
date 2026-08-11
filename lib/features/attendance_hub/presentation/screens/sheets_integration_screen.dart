import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;
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
  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final integrationResult = await _repo.getIntegration(_schoolId);
    final logResult = await _repo.getSyncLog(_schoolId);
    setState(() {
      _integration = integrationResult.fold(
        (f) => const SheetsIntegration(),
        (i) => i,
      );
      _log = logResult.fold((f) => [], (l) => l);
      _loading = false;
    });
  }

  Future<void> _connect() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Connect Spreadsheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Spreadsheet name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Spreadsheet ID',
                hintText: 'From the sheet URL: .../d/<this part>/edit',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.warning(dialogContext).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning(
                    dialogContext,
                  ).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.warning(dialogContext),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Before connecting: share this spreadsheet with the '
                      'school\'s Sheets export service account (Editor '
                      'access - ask your administrator for its email). '
                      'Every sync will silently fail until it\'s shared.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(dialogContext),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, (
              nameController.text.trim(),
              idController.text.trim(),
            )),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    if (result == null || result.$1.isEmpty || result.$2.isEmpty) return;

    final updated = _integration.copyWith(
      linked: true,
      spreadsheetName: result.$1,
      spreadsheetId: result.$2,
      worksheetName: 'Attendance Records',
    );
    await _repo.saveIntegration(_schoolId, updated);
    await _load();
  }

  Future<void> _disconnect() async {
    await _repo.disconnect(_schoolId);
    await _load();
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    final result = await _repo.triggerSync(_schoolId, 0);
    await _load();
    setState(() => _syncing = false);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Synced to Google Sheets'))),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            Text(_integration.linked ? 'Linked' : 'Not Linked'),
                          ],
                        ),
                        if (_integration.linked) ...[
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'Spreadsheet',
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                          Text(_integration.spreadsheetName),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Worksheet',
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                          Text(_integration.worksheetName),
                          if (_integration.lastSyncAt != null) ...[
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              'Last Sync',
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
                            await _repo.saveIntegration(
                              _schoolId,
                              _integration.copyWith(autoSync: v),
                            );
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
                      onPressed: _connect,
                      child: const Text('Connect Google Sheets'),
                    ),
                  ),
              ],
            ),
    );
  }
}
