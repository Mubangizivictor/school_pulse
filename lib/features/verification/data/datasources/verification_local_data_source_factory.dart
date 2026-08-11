import 'verification_local_data_source.dart';
import 'verification_local_data_source_stub.dart'
    if (dart.library.js_interop) 'verification_local_data_source_web.dart'
    if (dart.library.io) 'verification_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] (a FirebaseFirestore
/// instance) only on web.
VerificationLocalDataSource createVerificationLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
