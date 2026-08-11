import 'subject_teacher_local_data_source.dart';
import 'subject_teacher_local_data_source_stub.dart'
    if (dart.library.js_interop) 'subject_teacher_local_data_source_web.dart'
    if (dart.library.io) 'subject_teacher_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
SubjectTeacherLocalDataSource createSubjectTeacherLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
