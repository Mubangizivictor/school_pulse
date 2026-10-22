import 'class_resource_local_data_source.dart';
import 'class_resource_local_data_source_stub.dart'
    if (dart.library.js_interop) 'class_resource_local_data_source_web.dart'
    if (dart.library.io) 'class_resource_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
ClassResourceLocalDataSource createClassResourceLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar, remote: null);
