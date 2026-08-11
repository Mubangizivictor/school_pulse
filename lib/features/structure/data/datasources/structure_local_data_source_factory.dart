import 'structure_local_data_source.dart';
import 'structure_local_data_source_stub.dart'
    if (dart.library.js_interop) 'structure_local_data_source_web.dart'
    if (dart.library.io) 'structure_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] is unused today (kept
/// for signature consistency with the other factories in case a future
/// web implementation needs live Firestore reads instead of empty cache).
StructureLocalDataSource createStructureLocalDataSource({
  required dynamic isar,
  dynamic remote,
}) => impl.create(isar: isar, remote: remote);
