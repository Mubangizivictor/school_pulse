import 'student_identity_local_cache.dart';
import 'student_identity_local_cache_web.dart'
    if (dart.library.io) 'student_identity_local_cache_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
StudentIdentityLocalCache createStudentIdentityLocalCache({
  required dynamic isar,
}) => impl.create(isar: isar);
