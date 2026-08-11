import 'structure_local_data_source.dart';
import 'structure_local_data_source_web.dart';

/// Selected only if the build target is neither web nor mobile/desktop -
/// should never happen for this app's supported platforms. Reuses the web
/// (empty-cache) implementation as the safest default rather than throwing,
/// since every method here is already a documented no-op/empty-result.
StructureLocalDataSource create({dynamic isar, dynamic remote}) =>
    const StructureLocalDataSourceWeb();
