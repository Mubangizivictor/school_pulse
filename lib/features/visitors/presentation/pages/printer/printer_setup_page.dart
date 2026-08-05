import 'package:flutter/material.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:school_pulse/injection_container.dart';

class PrinterSetupPage extends StatefulWidget {
  const PrinterSetupPage({super.key});

  @override
  State<PrinterSetupPage> createState() => _PrinterSetupPageState();
}

class _PrinterSetupPageState extends State<PrinterSetupPage> {
  final PrinterService _printerService = sl<PrinterService>();
  List<PrinterDevice> _devices = [];
  bool _isScanning = false;
  PrinterDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  Future<void> _scanForDevices() async {
    setState(() => _isScanning = true);
    try {
      final devices = await _printerService.discoverPrinters();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to scan: $e')));
      }
    }
  }

  Future<void> _connectToDevice(PrinterDevice device) async {
    final success = await _printerService.connect(device);
    if (success) {
      setState(() => _connectedDevice = device);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connected to ${device.name}')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_connectedDevice != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected Printer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_connectedDevice!.name} (${_connectedDevice!.address})',
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _printerService.disconnect();
                      setState(() => _connectedDevice = null);
                    },
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isScanning
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isConnected =
                          _connectedDevice?.address == device.address;
                      return ListTile(
                        leading: Icon(
                          device.type == PrinterType.bluetooth
                              ? Icons.bluetooth
                              : Icons.settings_ethernet,
                        ),
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        trailing: isConnected
                            ? const Icon(Icons.check, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () => _connectToDevice(device),
                                child: const Text('Connect'),
                              ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print Test Page'),
              onPressed: _connectedDevice == null
                  ? null
                  : () => _printerService.printText(
                      'School Pulse Printer Test\nDate: ${DateTime.now()}\nStatus: Operational\n\n\n\n',
                    ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
