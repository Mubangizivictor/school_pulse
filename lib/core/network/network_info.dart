import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    try {
      // Connectivity is only a hint. Never let a socket probe strand an
      // entire Firebase-backed screen in a loading state. If the probe does
      // not answer quickly, let Firestore/Functions make the real network
      // decision and surface their own error/offline cache behavior.
      return await connectionChecker.hasConnection.timeout(
        const Duration(seconds: 3),
        onTimeout: () => true,
      );
    } on TimeoutException {
      return true;
    } catch (_) {
      return true;
    }
  }
}

/// Web has no raw-socket API, so `internet_connection_checker` (which
/// constructs `dart:io` `InternetAddress`/`Socket` objects) throws
/// `UnsupportedError` there - and does so eagerly, the instant its
/// singleton is first touched, not just when a check actually runs. This
/// implementation is what `injection_container.dart` registers for
/// `NetworkInfo` on web instead, so that singleton is never constructed at
/// all. Firebase's own SDKs already handle their offline/online state on
/// web, so callers of `isConnected` (queueing/retry logic written for
/// mobile's more failure-prone connectivity) can safely assume "online" on
/// web and let Firestore's own persistence/retry take over.
class WebNetworkInfo implements NetworkInfo {
  const WebNetworkInfo();

  @override
  Future<bool> get isConnected => Future.value(true);
}
