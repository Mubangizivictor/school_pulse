import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../data/integration_center_service.dart';

/// Cheap aggregate health counts across every connected integration and
/// registered device - reads a cached summary from the server, never fans
/// out to per-provider network calls.
class IntegrationHealthScreen extends StatefulWidget {
  const IntegrationHealthScreen({super.key});
  @override
  State<IntegrationHealthScreen> createState() =>
      _IntegrationHealthScreenState();
}

class _IntegrationHealthScreenState extends State<IntegrationHealthScreen> {
  final _service = IntegrationCenterService();
  Map<String, dynamic>? _summary;
  bool _loading = true;
  String? _error;

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
      _summary = await _service.healthSummary();
    } catch (error) {
      _error = 'Could not load integration health: $error';
    }
    if (mounted) setState(() => _loading = false);
  }

  int _count(String key) => (_summary?[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integration Health'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
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
                    title: 'Unable to load health',
                    message: _error!,
                    ctaLabel: 'Retry',
                    onCtaPressed: _reload,
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Institution-wide status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Counts reflect the last recorded status for each integration and device - not a live provider check.',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 720
                          ? 3
                          : constraints.maxWidth > 420
                          ? 2
                          : 1;
                      final tiles = [
                        DashboardStatCard(
                          title: 'Connected',
                          value: _count('connected').toDouble(),
                          icon: Icons.link,
                          color: Colors.blue,
                        ),
                        DashboardStatCard(
                          title: 'Healthy',
                          value: _count('healthy').toDouble(),
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        DashboardStatCard(
                          title: 'Warning',
                          value: _count('warning').toDouble(),
                          icon: Icons.warning_amber_outlined,
                          color: Colors.orange,
                        ),
                        DashboardStatCard(
                          title: 'Failed',
                          value: _count('failed').toDouble(),
                          icon: Icons.error_outline,
                          color: Colors.red,
                        ),
                        DashboardStatCard(
                          title: 'Needs Reauth',
                          value: _count('reauthRequired').toDouble(),
                          icon: Icons.lock_reset_outlined,
                          color: Colors.deepOrange,
                        ),
                        DashboardStatCard(
                          title: 'Devices Offline',
                          value: _count('deviceOffline').toDouble(),
                          icon: Icons.wifi_off_outlined,
                          color: Colors.grey,
                        ),
                      ];
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: tiles,
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
