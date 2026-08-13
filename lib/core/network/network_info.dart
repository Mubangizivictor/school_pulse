import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
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
