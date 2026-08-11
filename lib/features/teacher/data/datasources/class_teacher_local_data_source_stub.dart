import 'class_teacher_local_data_source.dart';
import 'class_teacher_local_data_source_web.dart';
import 'class_teacher_remote_data_source.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// reuses the web (empty-cache) implementation as the safest default.
ClassTeacherLocalDataSource create({dynamic isar, dynamic remote}) =>
    ClassTeacherLocalDataSourceWeb(remote as ClassTeacherRemoteDataSource);
