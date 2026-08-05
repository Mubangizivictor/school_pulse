import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A stable per-install device identifier, persisted once and reused for
/// every attendance record marked from this device - no app-wide device
/// concept exists yet, so this is deliberately minimal rather than pulling
/// in a new platform-info package.
class DeviceIdProvider {
  static const _prefsKey = 'attendance_device_id';
  String? _cached;

  Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefsKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_prefsKey, id);
    }
    _cached = id;
    return id;
  }
}
