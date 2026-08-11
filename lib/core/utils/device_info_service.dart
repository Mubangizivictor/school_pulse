import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Best-effort human-readable device platform + model, for display in the
/// owner Trusted Devices / Active Sessions registry. Falls back to a plain
/// platform label if the native plugin can't resolve details (e.g. some web
/// or desktop targets), since this is display-only and never blocks a
/// write to the session registry.
class DeviceInfoService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  Future<String> platformLabel() async {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  Future<String> deviceName() async {
    try {
      if (kIsWeb) {
        final info = await _plugin.webBrowserInfo;
        return info.browserName.name;
      }
      if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        return info.utsname.machine.isNotEmpty
            ? info.utsname.machine
            : (info.name.isNotEmpty ? info.name : 'iPhone/iPad');
      }
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        final make = info.manufacturer.isNotEmpty ? info.manufacturer : '';
        final model = info.model.isNotEmpty ? info.model : 'Android device';
        return make.isNotEmpty ? '$make $model' : model;
      }
      if (Platform.isMacOS) {
        final info = await _plugin.macOsInfo;
        return info.model.isNotEmpty ? info.model : 'Mac';
      }
    } catch (_) {
      // Fall through to the generic label below.
    }
    return await platformLabel();
  }
}
