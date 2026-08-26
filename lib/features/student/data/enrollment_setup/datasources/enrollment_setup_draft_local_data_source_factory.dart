import 'enrollment_setup_draft_local_data_source.dart';
import 'enrollment_setup_draft_local_data_source_web.dart'
    if (dart.library.io) 'enrollment_setup_draft_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop.
EnrollmentSetupDraftLocalDataSource createEnrollmentSetupDraftLocalDataSource({
  required dynamic isar,
}) => impl.create(isar: isar);
