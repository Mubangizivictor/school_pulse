import 'library_local_data_source.dart';
import 'library_local_data_source_stub.dart'
    if (dart.library.js_interop) 'library_local_data_source_web.dart'
    if (dart.library.io) 'library_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] only on web.
LibraryLocalDataSource createLibraryLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
