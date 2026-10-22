import 'health_local_data_source.dart';
import 'health_local_data_source_stub.dart'
    if (dart.library.js_interop) 'health_local_data_source_web.dart'
    if (dart.library.io) 'health_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
HealthLocalDataSource createHealthLocalDataSource({required dynamic isar}) =>
    impl.create(isar: isar);
