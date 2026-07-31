import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/biometric_device.dart';
import '../../domain/repositories/biometric_device_service.dart';
import '../bloc/biometrics_bloc.dart';
import '../bloc/biometrics_event.dart';
import '../bloc/biometrics_state.dart';

/// The bloc-level plumbing for fingerprint enrollment (EnrollFingerprint
/// usecase, EnrollStudentFingerprint event) already existed but had no UI
/// - nothing anywhere discovered/connected a device or dispatched the
/// event. This is that missing screen. BiometricDeviceService is a
/// standalone singleton (MockBiometricDeviceService today, pending real
/// hardware/SDK integration) - discovery/connect happen directly against
/// it, capture happens inside EnrollFingerprint once connected.
class BiometricEnrollmentScreen extends StatefulWidget {
  final String personId;
  final String personName;
  final String schoolId;

  const BiometricEnrollmentScreen({
    super.key,
    required this.personId,
    required this.personName,
    required this.schoolId,
  });

  @override
  State<BiometricEnrollmentScreen> createState() => _BiometricEnrollmentScreenState();
}

class _BiometricEnrollmentScreenState extends State<BiometricEnrollmentScreen> {
  final _deviceService = sl<BiometricDeviceService>();
  StreamSubscription<List<BiometricDevice>>? _devicesSub;

  List<BiometricDevice> _devices = [];
  BiometricDevice? _selectedDevice;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _devicesSub = _deviceService.discoveredDevices.listen((devices) {
      setState(() => _devices = devices);
    });
    _deviceService.initialize().then((_) => _deviceService.startScan());
  }

  @override
  void dispose() {
    _devicesSub?.cancel();
    _deviceService.stopScan();
    super.dispose();
  }

  Future<void> _connect(BiometricDevice device) async {
    setState(() => _connecting = true);
    try {
      await _deviceService.connect(device);
      setState(() => _selectedDevice = device);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _enroll() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _selectedDevice == null) return;
    context.read<BiometricsBloc>().add(EnrollStudentFingerprint(
          schoolId: widget.schoolId,
          studentId: widget.personId,
          deviceId: _selectedDevice!.id,
          operatorId: authState.user.id,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BiometricsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: Text('Enroll Fingerprint - ${widget.personName}')),
        body: BlocConsumer<BiometricsBloc, BiometricsState>(
          listener: (context, state) {
            if (state is BiometricOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is BiometricOperationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final enrolling = state is BiometricEnrollmentInProgress;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Provider: ${_deviceService.providerName}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('Available Devices', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_devices.isEmpty) const Text('Scanning for devices…'),
                for (final device in _devices)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        _selectedDevice?.id == device.id ? Icons.fingerprint : Icons.fingerprint_outlined,
                        color: _selectedDevice?.id == device.id ? Colors.green : null,
                      ),
                      title: Text(device.name),
                      subtitle: Text(device.location),
                      trailing: _selectedDevice?.id == device.id
                          ? const Chip(label: Text('Connected'))
                          : TextButton(
                              onPressed: _connecting ? null : () => _connect(device),
                              child: const Text('Connect'),
                            ),
                    ),
                  ),
                const SizedBox(height: 24),
                if (enrolling) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                  Center(child: Text(state.step)),
                ] else
                  FilledButton.icon(
                    onPressed: _selectedDevice == null ? null : _enroll,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Scan & Enroll Fingerprint'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
