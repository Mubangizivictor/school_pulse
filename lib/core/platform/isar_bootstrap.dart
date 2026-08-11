import 'isar_bootstrap_stub.dart'
    if (dart.library.js_interop) 'isar_bootstrap_web.dart'
    if (dart.library.io) 'isar_bootstrap_mobile.dart'
    as impl;

/// Opens the shared Isar instance used by every mobile/desktop
/// XLocalDataSourceImpl, returned as `dynamic` so this file (and anything
/// that imports it, including injection_container.dart) never has to
/// import `package:isar` or any Isar model directly - those imports, and
/// the 64-bit schema ID literals Isar's generator embeds in them, live only
/// inside isar_bootstrap_mobile.dart, which the web compiler never sees
/// thanks to this conditional import. Only ever call this behind
/// `if (!kIsWeb)` - the web/stub variants return null rather than opening
/// anything.
Future<dynamic> openIsarForMobile() => impl.open();
