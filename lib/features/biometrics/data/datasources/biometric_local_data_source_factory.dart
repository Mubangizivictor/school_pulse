import 'biometric_local_data_source.dart';
import 'biometric_local_data_source_stub.dart'
    if (dart.library.js_interop) 'biometric_local_data_source_web.dart'
    if (dart.library.io) 'biometric_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
BiometricLocalDataSource createBiometricLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
