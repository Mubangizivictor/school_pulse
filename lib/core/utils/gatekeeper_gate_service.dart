import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which gate a Gatekeeper Simple Mode device is stationed at, so
/// the guard is never asked to re-select it on every launch - per spec, a
/// gate must not repeatedly select the same operational context. Cached
/// per-install via SharedPreferences, same approach as [DeviceIdService].
class GatekeeperGateService {
  static const _prefsKey = 'school_pulse_gatekeeper_gate_id';

  Future<String?> getSelectedGateId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  Future<void> setSelectedGateId(String gateId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, gateId);
  }

  Future<void> clearSelectedGate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
