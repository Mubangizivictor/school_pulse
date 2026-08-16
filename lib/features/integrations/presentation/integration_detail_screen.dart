import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../data/integration_center_service.dart';
import '../domain/integration_registry.dart';

class IntegrationDetailScreen extends StatefulWidget {
  const IntegrationDetailScreen({super.key, required this.integrationKey});
  final String integrationKey;
  @override
  State<IntegrationDetailScreen> createState() =>
      _IntegrationDetailScreenState();
}

class _IntegrationDetailScreenState extends State<IntegrationDetailScreen> {
  final _service = IntegrationCenterService();
  final _account = TextEditingController();
  final _reference = TextEditingController();
  bool _enabled = false;
  bool _busy = false;
  List<Map<String, dynamic>> _syncJobs = const [];
  bool _syncLoading = false;
  IntegrationDefinition? get _definition =>
      IntegrationRegistry.byKey(widget.integrationKey);
  bool get _showsSyncStatus =>
      widget.integrationKey == 'google_sheets' ||
      widget.integrationKey == 'google_calendar';

  @override
  void initState() {
    super.initState();
    if (_showsSyncStatus) _loadSyncJobs();
  }

  Future<void> _loadSyncJobs() async {
    setState(() => _syncLoading = true);
    try {
      _syncJobs = await _service.syncJobs(widget.integrationKey);
    } catch (_) {
      _syncJobs = const [];
    }
    if (mounted) setState(() => _syncLoading = false);
  }

  @override
  void dispose() {
    _account.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await _service.save(
        widget.integrationKey,
        configuration: {'reference': _reference.text},
        account: _account.text,
        enabled: _enabled,
      );
      _message(
        'Safe configuration saved. Complete secure authorization with the provider flow.',
      );
    } catch (error) {
      _message('Could not save configuration: $error');
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _test() async {
    setState(() => _busy = true);
    try {
      final result = await _service.test(widget.integrationKey);
      _message(result['message'] as String);
    } catch (error) {
      _message('Test unavailable: $error');
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    try {
      await _service.disconnect(widget.integrationKey);
      _message('Integration disabled. School Pulse data has been preserved.');
    } catch (error) {
      _message('Could not disconnect: $error');
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final definition = _definition;
    if (definition == null) {
      return const Scaffold(
        body: Center(child: Text('Integration not found.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(definition.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            definition.description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const AppCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Source of truth: School Pulse\nExternal services receive controlled exports or verified callbacks; they never replace School Pulse operational data.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safe configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _account,
                    decoration: const InputDecoration(
                      labelText: 'Account display / merchant reference',
                      helperText:
                          'Never enter API keys, passwords, OAuth tokens, or webhook secrets here.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reference,
                    decoration: const InputDecoration(
                      labelText:
                          'Workbook, calendar, device, or domain reference',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable integration'),
                    value: _enabled,
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _enabled = value),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: const Text('Save safe configuration'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.integrationKey == 'google_sheets') ...[
            OutlinedButton.icon(
              onPressed: () => context.push('/staff/attendance/sheets'),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Open attendance export settings'),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.integrationKey == 'biometric_device') ...[
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/staff/admin/integrations/devices'),
              icon: const Icon(Icons.fingerprint_outlined),
              label: const Text('Manage devices'),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.integrationKey == 'outbound_webhook') ...[
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/staff/admin/integrations/webhooks'),
              icon: const Icon(Icons.webhook_outlined),
              label: const Text('Manage webhooks'),
            ),
            const SizedBox(height: 8),
          ],
          if (_showsSyncStatus) ...[
            _SyncStatusCard(
              loading: _syncLoading,
              jobs: _syncJobs,
              onRefresh: _loadSyncJobs,
            ),
            const SizedBox(height: 16),
          ],
          if (definition.supportsTestConnection)
            OutlinedButton.icon(
              onPressed: _busy ? null : _test,
              icon: const Icon(Icons.health_and_safety_outlined),
              label: const Text('Test connection safely'),
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _busy ? null : _disconnect,
            icon: const Icon(Icons.link_off),
            label: const Text('Disconnect / disable'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sensitive changes, credential setup, secret rotation, provider callbacks, and webhook signing require a server-side authorization flow. Client-submitted payment success is never accepted.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.loading,
    required this.jobs,
    required this.onRefresh,
  });
  final bool loading;
  final List<Map<String, dynamic>> jobs;
  final Future<void> Function() onRefresh;

  String _formatTimestamp(dynamic value) {
    if (value == null) return 'Never';
    if (value is Map && value['_seconds'] != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as num).toInt() * 1000,
      );
      return date.toLocal().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final latest = jobs.isNotEmpty ? jobs.first : null;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sync status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh sync status',
                ),
              ],
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (latest == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No sync jobs recorded yet.'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last sync: ${_formatTimestamp(latest['startedAt'])}'),
                  const SizedBox(height: 4),
                  Text('Status: ${latest['status'] ?? 'unknown'}'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      Text('Processed: ${latest['recordsProcessed'] ?? 0}'),
                      Text('Succeeded: ${latest['recordsSucceeded'] ?? 0}'),
                      Text('Failed: ${latest['recordsFailed'] ?? 0}'),
                    ],
                  ),
                  if ((latest['lastError'] as String?)?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        latest['lastError'] as String,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
