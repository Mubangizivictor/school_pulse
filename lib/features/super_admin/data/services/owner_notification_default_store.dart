import 'owner_notification_store.dart';

/// Platform-appropriate [OwnerNotificationCacheStore] factory.
///
/// Web never imports `owner_notification_isar_store.dart` (and therefore
/// never compiles the Isar-backed models/schemas it pulls in) — dart2js
/// cannot represent Isar's 64-bit FNV collection/property hashes as JS
/// numbers, so any accidental compile-time reference to that file breaks
/// `flutter build web` even when the code is never reached at runtime
/// (a `kIsWeb` runtime check does not stop dart2js from parsing it). This
/// mirrors the existing `portal_host.dart` conditional-export split.
export 'owner_notification_default_store_stub.dart'
    if (dart.library.html) 'owner_notification_default_store_web.dart';
