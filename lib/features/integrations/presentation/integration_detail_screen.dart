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
  IntegrationDefinition? get _definition =>
      IntegrationRegistry.byKey(widget.integrationKey);

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
