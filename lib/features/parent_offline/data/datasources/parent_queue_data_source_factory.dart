import 'parent_queue_data_source.dart';
import 'parent_queue_data_source_web.dart'
    if (dart.library.io) 'parent_queue_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop - see ParentQueueDataSourceWeb doc.
ParentQueueDataSource createParentQueueDataSource({required dynamic isar}) =>
    impl.create(isar: isar);
