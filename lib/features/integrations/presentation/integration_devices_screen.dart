import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../data/integration_center_service.dart';

/// Biometric/scan device registry - register, assign, mark online/offline
/// and revoke. Device credentials never appear here; only hardware metadata.
class IntegrationDevicesScreen extends StatefulWidget {
  const IntegrationDevicesScreen({super.key});
  @override
  State<IntegrationDevicesScreen> createState() =>
      _IntegrationDevicesScreenState();
}

class _IntegrationDevicesScreenState extends State<IntegrationDevicesScreen> {
  final _service = IntegrationCenterService();
  List<Map<String, dynamic>> _devices = const [];
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
      _devices = await _service.listDevices();
    } catch (error) {
      _error = 'Could not load devices: $error';
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

  Future<void> _openRegisterDialog() async {
    final deviceType = TextEditingController(text: 'biometric_scanner');
    final vendor = TextEditingController();
    final model = TextEditingController();
    final serial = TextEditingController();
    final campus = TextEditingController();
    final location = TextEditingController();
    final gate = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceType,
                decoration: const InputDecoration(labelText: 'Device type'),
              ),
              TextField(
                controller: vendor,
                decoration: const InputDecoration(labelText: 'Vendor'),
              ),
              TextField(
                controller: model,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: serial,
                decoration: const InputDecoration(labelText: 'Serial number'),
              ),
              TextField(
                controller: campus,
                decoration: const InputDecoration(labelText: 'Campus'),
              ),
              TextField(
                controller: location,
                decoration: const InputDecoration(
                  labelText: 'Physical location',
                ),
              ),
              TextField(
                controller: gate,
                decoration: const InputDecoration(
                  labelText: 'Assigned gate/facility (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    if (serial.text.trim().isEmpty || deviceType.text.trim().isEmpty) {
      _message('Device type and serial number are required.');
      return;
    }
    setState(() => _busy = true);
    try {
      await _service.registerDevice({
        'deviceType': deviceType.text.trim(),
        'vendor': vendor.text.trim(),
        'model': model.text.trim(),
        'serialNumber': serial.text.trim(),
        'campus': campus.text.trim(),
        'physicalLocation': location.text.trim(),
        'assignedModule': 'Attendance',
        'assignedGateFacility': gate.text.trim(),
        'connectionMethod': 'network',
      });
      _message('Device registered.');
      await _reload();
    } catch (error) {
      _message('Could not register device: $error');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _setStatus(String deviceId, String status) async {
    setState(() => _busy = true);
    try {
      await _service.updateDeviceStatus(deviceId, status);
      await _reload();
    } catch (error) {
      _message('Could not update device status: $error');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _revoke(String deviceId) async {
    setState(() => _busy = true);
    try {
      await _service.revokeDevice(deviceId);
      _message('Device revoked.');
      await _reload();
    } catch (error) {
      _message('Could not revoke device: $error');
    }
    if (mounted) setState(() => _busy = false);
  }

  Color _statusColor(String status) => switch (status) {
    'online' => Colors.green,
    'offline' => Colors.grey,
    'revoked' => Colors.red,
    _ => Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Devices'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _openRegisterDialog,
        icon: const Icon(Icons.add),
        label: const Text('Register device'),
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
                    title: 'Unable to load devices',
                    message: _error!,
                    ctaLabel: 'Retry',
                    onCtaPressed: _reload,
                  ),
                ],
              )
            : _devices.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.fingerprint_outlined,
                    title: 'No devices registered',
                    message:
                        'Register a biometric scanner or gate device to see it here.',
                    ctaLabel: 'Register device',
                    onCtaPressed: _openRegisterDialog,
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: _devices
                    .map(
                      (device) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(
                                device['status'] as String? ?? '',
                              ).withValues(alpha: .15),
                              child: Icon(
                                Icons.fingerprint_outlined,
                                color: _statusColor(
                                  device['status'] as String? ?? '',
                                ),
                              ),
                            ),
                            title: Text(
                              '${device['vendor'] ?? ''} ${device['model'] ?? ''}'
                                      .trim()
                                      .isEmpty
                                  ? (device['deviceType'] as String? ??
                                        'Device')
                                  : '${device['vendor']} ${device['model']}',
                            ),
                            isThreeLine: true,
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Serial ${device['serialNumber'] ?? ''} • ${device['physicalLocation'] ?? 'No location set'}',
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    (device['status'] as String? ?? 'unknown')
                                        .toUpperCase(),
                                  ),
                                  backgroundColor: _statusColor(
                                    device['status'] as String? ?? '',
                                  ).withValues(alpha: .12),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              enabled: !_busy,
                              onSelected: (value) {
                                if (value == 'revoke') {
                                  _revoke(device['deviceId'] as String);
                                } else {
                                  _setStatus(
                                    device['deviceId'] as String,
                                    value,
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'online',
                                  child: Text('Mark online'),
                                ),
                                PopupMenuItem(
                                  value: 'offline',
                                  child: Text('Mark offline'),
                                ),
                                PopupMenuItem(
                                  value: 'revoke',
                                  child: Text('Revoke'),
                                ),
                              ],
                            ),
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
