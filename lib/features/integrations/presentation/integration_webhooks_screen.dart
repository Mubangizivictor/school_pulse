import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../data/integration_center_service.dart';

/// Outbound webhook management. The signing secret is shown exactly once,
/// right after creation, and is never persisted or re-displayed client-side.
class IntegrationWebhooksScreen extends StatefulWidget {
  const IntegrationWebhooksScreen({super.key});
  @override
  State<IntegrationWebhooksScreen> createState() =>
      _IntegrationWebhooksScreenState();
}

class _IntegrationWebhooksScreenState
    extends State<IntegrationWebhooksScreen> {
  final _service = IntegrationCenterService();
  List<Map<String, dynamic>> _webhooks = const [];
  bool _loading = true;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _webhooks = await _service.listWebhooks();
    } catch (error) {
      _error = 'Could not load webhooks: $error';
    }
    if (mounted) setState(() => _loading = false);
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openCreateDialog() async {
    final url = TextEditingController();
    final events = TextEditingController(text: 'attendance.marked');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create webhook'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: url,
              decoration: const InputDecoration(
                labelText: 'Endpoint URL (https only)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: events,
              decoration: const InputDecoration(
                labelText: 'Events (comma separated)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!url.text.trim().startsWith('https://')) {
      _message('Webhook URL must start with https://');
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await _service.createWebhook(
        url: url.text.trim(),
        events: events.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
      await _reload();
      if (mounted) {
        await _showSecretOnce(result['secret'] as String? ?? '');
      }
    } catch (error) {
      _message('Could not create webhook: $error');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _showSecretOnce(String secret) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Signing secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This secret will not be shown again. Copy it now and store it in your receiving service\'s configuration.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                secret,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: secret));
              _message('Secret copied to clipboard.');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _disable(String webhookId) async {
    setState(() => _busy = true);
    try {
      await _service.disableWebhook(webhookId);
      _message('Webhook disabled.');
      await _reload();
    } catch (error) {
      _message('Could not disable webhook: $error');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbound Webhooks'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _openCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create webhook'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.error_outline,
                    title: 'Unable to load webhooks',
                    message: _error!,
                    ctaLabel: 'Retry',
                    onCtaPressed: _reload,
                  ),
                ],
              )
            : _webhooks.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.webhook_outlined,
                    title: 'No webhooks configured',
                    message:
                        'Create a webhook to receive signed, replay-protected event delivery.',
                    ctaLabel: 'Create webhook',
                    onCtaPressed: _openCreateDialog,
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: _webhooks
                    .map(
                      (webhook) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: ListTile(
                            leading: Icon(
                              Icons.webhook_outlined,
                              color: webhook['status'] == 'active'
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            title: Text(
                              webhook['url'] as String? ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ((webhook['events'] as List?) ?? const [])
                                      .join(', '),
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    (webhook['status'] as String? ?? '')
                                        .toUpperCase(),
                                  ),
                                  backgroundColor:
                                      (webhook['status'] == 'active'
                                              ? Colors.green
                                              : Colors.grey)
                                          .withValues(alpha: .12),
                                ),
                              ],
                            ),
                            trailing: webhook['status'] == 'active'
                                ? TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _disable(
                                            webhook['webhookId'] as String,
                                          ),
                                    child: const Text('Disable'),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
