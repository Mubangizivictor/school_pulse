import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A stable per-install device identifier for audit trails (gate movements,
/// visitor logs, etc). No device_info_plus dependency exists in this app, so
/// this generates a UUID once and caches it in SharedPreferences - good
/// enough to distinguish devices for audit purposes without adding a new
/// native plugin.
class DeviceIdService {
  static const _prefsKey = 'school_pulse_device_id';
  static String? _cached;

  Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefsKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_prefsKey, id);
    }
    _cached = id;
    return id;
  }
}
