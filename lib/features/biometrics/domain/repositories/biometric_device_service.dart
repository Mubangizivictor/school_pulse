import 'package:school_pulse/features/biometrics/domain/entities/biometric_device.dart';

abstract class BiometricDeviceService {
  /// Unique identifier for the driver/provider
  String get providerId;

  /// Human-readable name of the provider
  String get providerName;

  /// Stream of discovered devices
  Stream<List<BiometricDevice>> get discoveredDevices;

  /// Initialize the hardware/SDK
  Future<void> initialize();

  /// Start scanning for devices
  Future<void> startScan();

  /// Stop scanning for devices
  Future<void> stopScan();

  /// Connect to a specific device
  Future<void> connect(BiometricDevice device);

  /// Disconnect from the current device
  Future<void> disconnect();

  /// Capture a biometric template
  /// Returns the encrypted template or null if failed
  Future<String?> captureTemplate();

  /// Verify a person's biometric template against the hardware
  /// This is used if the hardware supports on-device matching
  Future<bool> verify(String storedTemplate);

  /// Check if the device is currently connected
  bool get isConnected;
}
