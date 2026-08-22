import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../data/integration_center_service.dart';
import '../domain/integration_registry.dart';

class IntegrationsCenterScreen extends StatefulWidget {
  const IntegrationsCenterScreen({super.key});
  @override
  State<IntegrationsCenterScreen> createState() =>
      _IntegrationsCenterScreenState();
}

class _IntegrationsCenterScreenState extends State<IntegrationsCenterScreen> {
  final _service = IntegrationCenterService();
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String _filter = 'All';
  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      _items = await _service.load();
    } catch (_) {
      _items = const [];
    }
    if (mounted) setState(() => _loading = false);
  }

  String _label(String status) =>
      status.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}').trim();
  Color _color(String status) => switch (status) {
    'healthy' => Colors.green,
    'failed' || 'degraded' || 'credentialExpired' => Colors.red,
    'warning' || 'setupRequired' || 'reauthorizationRequired' => Colors.orange,
    'disabled' => Colors.grey,
    _ => Colors.blueGrey,
  };
  @override
  Widget build(BuildContext context) {
    final term = _search.text.toLowerCase();
    final shown = _items.where((item) {
      final matches =
          term.isEmpty ||
          '${item['displayName']} ${item['category']} ${item['integrationKey']}'
              .toLowerCase()
              .contains(term);
      return matches &&
          (_filter == 'All' ||
              item['category'] == _filter ||
              (_filter == 'Connected' && item['enabled'] == true) ||
              (_filter == 'Needs attention' &&
                  const [
                    'failed',
                    'warning',
                    'setupRequired',
                    'reauthorizationRequired',
                  ].contains(item['status'])));
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrations Center'),
        actions: [
          IconButton(
            onPressed: () => context.push('/staff/admin/integrations/health'),
            icon: const Icon(Icons.monitor_heart_outlined),
            tooltip: 'Integration health dashboard',
          ),
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'External services',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'School Pulse remains the source of truth. Credentials and webhook secrets are stored only on the server.',
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'All',
                              'Connected',
                              'Needs attention',
                              'Payments',
                              'Communication',
                              'Productivity',
                              'Devices',
                              'Printing',
                              'Domains',
                            ]
                            .map(
                              (label) => ChoiceChip(
                                label: Text(label),
                                selected: _filter == label,
                                onSelected: (_) =>
                                    setState(() => _filter = label),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search provider, integration, or category',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (shown.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No integrations match these filters.'),
                      ),
                    ),
                  ...shown.map(
                    (item) => _IntegrationCard(
                      item: item,
                      definition: IntegrationRegistry.byKey(
                        item['integrationKey'] as String,
                      ),
                      label: _label,
                      color: _color,
                      onChanged: _reload,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.item,
    required this.definition,
    required this.label,
    required this.color,
    required this.onChanged,
  });
  final Map<String, dynamic> item;
  final IntegrationDefinition? definition;
  final String Function(String) label;
  final Color Function(String) color;
  final Future<void> Function() onChanged;
  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String? ?? 'notConnected';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(definition?.icon ?? Icons.extension_outlined),
          ),
          title: Text(item['displayName'] as String),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${item['category']} • Requires ${item['minimumEntitlement']} • ${item['requiredModule']}',
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(label(status)),
                    backgroundColor: color(status).withValues(alpha: .12),
                  ),
                  if ((item['connectedAccountDisplay'] as String? ?? '')
                      .isNotEmpty)
                    Chip(
                      label: Text(item['connectedAccountDisplay'] as String),
                    ),
                ],
              ),
              if ((item['lastErrorSummary'] as String? ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    item['lastErrorSummary'] as String,
                    style: TextStyle(color: color(status)),
                  ),
                ),
            ],
          ),
          isThreeLine: true,
          trailing: FilledButton.tonal(
            onPressed: () => context
                .push('/staff/admin/integrations/${item['integrationKey']}')
                .then((_) => onChanged()),
            child: const Text('Manage'),
          ),
        ),
      ),
    );
  }
}
