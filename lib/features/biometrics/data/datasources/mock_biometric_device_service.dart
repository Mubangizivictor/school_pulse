import 'dart:async';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_device.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_device_service.dart';

class MockBiometricDeviceService implements BiometricDeviceService {
  final _deviceController = StreamController<List<BiometricDevice>>.broadcast();
  bool _isConnected = false;

  @override
  String get providerId => 'mock_provider';

  @override
  String get providerName => 'Mock Biometric Scanner';

  @override
  Stream<List<BiometricDevice>> get discoveredDevices =>
      _deviceController.stream;

  @override
  Future<void> initialize() async {
    // Simulate initialization
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> startScan() async {
    _deviceController.add([
      BiometricDevice(
        id: 'mock_1',
        name: 'USB Fingerprint Scanner',
        location: 'Admin Desk',
        type: BiometricDeviceType.usb,
      ),
    ]);
  }

  @override
  Future<void> stopScan() async {
    // No-op
  }

  @override
  Future<void> connect(BiometricDevice device) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
  }

  @override
  Future<String?> captureTemplate() async {
    if (!_isConnected) throw Exception('Device not connected');

    // Simulate multi-step capture
    await Future.delayed(const Duration(seconds: 1));
    // Step 1: Capture
    await Future.delayed(const Duration(seconds: 1));
    // Step 2: Capture
    await Future.delayed(const Duration(seconds: 1));
    // Step 3: Capture

    // Return a dummy encrypted template
    return 'encrypted_template_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> verify(String storedTemplate) async {
    if (!_isConnected) throw Exception('Device not connected');
    await Future.delayed(const Duration(seconds: 1));
    // For mock, we'll just return true
    return true;
  }

  @override
  bool get isConnected => _isConnected;
}
