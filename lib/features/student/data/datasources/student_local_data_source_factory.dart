import 'student_local_data_source.dart';
import 'student_local_data_source_stub.dart'
    if (dart.library.js_interop) 'student_local_data_source_web.dart'
    if (dart.library.io) 'student_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] only on web - whichever
/// platform's create() is selected picks the one argument it needs and
/// ignores the other. Neither is typed here (dynamic) so this file never
/// has to import `package:isar` or any Isar model, keeping it safe for
/// injection_container.dart to import unconditionally.
StudentLocalDataSource createStudentLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
