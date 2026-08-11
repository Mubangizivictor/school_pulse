import 'biometric_local_data_source.dart';
import 'biometric_local_data_source_web.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// reuses the web (always-miss) implementation as the safest default.
BiometricLocalDataSource create({dynamic isar, dynamic remote}) =>
    const BiometricLocalDataSourceWeb();
