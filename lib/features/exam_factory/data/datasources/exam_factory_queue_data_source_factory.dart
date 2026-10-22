import 'exam_factory_queue_data_source.dart';
import 'exam_factory_queue_data_source_web.dart'
    if (dart.library.io) 'exam_factory_queue_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop - see ExamFactoryQueueDataSourceWeb doc.
ExamFactoryQueueDataSource createExamFactoryQueueDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
