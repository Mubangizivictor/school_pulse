import 'subject_resource_local_data_source.dart';
import 'subject_resource_local_data_source_web.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// reuses the web (empty-cache) implementation as the safest default.
SubjectResourceLocalDataSource create({dynamic isar, dynamic remote}) =>
    SubjectResourceLocalDataSourceWeb();
