import 'subject_resource_local_data_source.dart';
import 'subject_resource_local_data_source_stub.dart'
    if (dart.library.js_interop) 'subject_resource_local_data_source_web.dart'
    if (dart.library.io) 'subject_resource_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
SubjectResourceLocalDataSource createSubjectResourceLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar, remote: null);
