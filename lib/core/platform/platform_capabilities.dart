import 'dart:io' as io show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Centralized platform-capability surface. Enough for future work to depend
/// on instead of scattering kIsWeb / dart:io Platform checks through feature
/// code. Service-level web adapters (biometric, printer, NFC, etc.) are
/// deliberately not part of this file yet.
class PlatformCapabilities {
  const PlatformCapabilities._();

  static bool get isWeb => kIsWeb;

  // The `!kIsWeb &&` short-circuit is load-bearing: dart:io Platform.is*
  // throws UnsupportedError on web, so kIsWeb must be checked first.
  static bool get isAndroid => !kIsWeb && io.Platform.isAndroid;

  static bool get isIOS => !kIsWeb && io.Platform.isIOS;

  static bool get isDesktop =>
      !kIsWeb &&
      (io.Platform.isMacOS || io.Platform.isWindows || io.Platform.isLinux);
}
