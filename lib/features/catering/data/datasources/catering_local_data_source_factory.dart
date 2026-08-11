import 'catering_local_data_source.dart';
import 'catering_local_data_source_stub.dart'
    if (dart.library.js_interop) 'catering_local_data_source_web.dart'
    if (dart.library.io) 'catering_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] only on web.
CateringLocalDataSource createCateringLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
