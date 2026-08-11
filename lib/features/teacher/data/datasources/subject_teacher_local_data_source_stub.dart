import 'subject_teacher_local_data_source.dart';
import 'subject_teacher_local_data_source_web.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// reuses the web (empty-cache) implementation as the safest default.
SubjectTeacherLocalDataSource create({dynamic isar, dynamic remote}) =>
    const SubjectTeacherLocalDataSourceWeb();
