import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` for the two things this app needs:
/// checking whether the current device can actually do biometric auth, and
/// running a single authentication challenge. Kept separate from the
/// unrelated `features/biometrics/` feature (which is Isar-backed and
/// scoped to school gate/attendance enrollment, a different data model and
/// purpose) - this one is purely a device-capability + challenge helper for
/// the owner account's app-level unlock preference.
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// True if this device has enrolled biometrics (or device credentials)
  /// and the plugin can invoke them at all.
  Future<bool> isDeviceCapable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Runs one real authentication challenge. Returns true only on a
  /// genuine success - any exception (cancelled, lockout, plugin error) is
  /// treated as a failed attempt, never silently swallowed as success.
  Future<bool> authenticate(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
