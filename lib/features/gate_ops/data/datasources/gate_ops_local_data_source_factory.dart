import 'gate_ops_local_data_source.dart';
import 'gate_ops_local_data_source_stub.dart'
    if (dart.library.js_interop) 'gate_ops_local_data_source_web.dart'
    if (dart.library.io) 'gate_ops_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] only on web.
GateOpsLocalDataSource createGateOpsLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
